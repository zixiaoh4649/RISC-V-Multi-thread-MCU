import types::*;
module id(
    input wire clk,
	input wire rst,
	//input from if_id
	input wire [31:0] ins[NUM_Threads-1:0],
	input wire [31:0] pc2id_ex[NUM_Threads-1:0],
	//between id and regs
	output reg [4:0] rs1_addr[NUM_Threads-1:0],
	output reg [4:0] rs2_addr[NUM_Threads-1:0],
	input wire [31:0] rs1_data[NUM_Threads-1:0],
	input wire [31:0] rs2_data[NUM_Threads-1:0],
	
	//to ex
	output reg [31:0] op1_ex[NUM_Threads-1:0],
	output reg [31:0] op2_ex[NUM_Threads-1:0],
	output reg [31:0] ins_2ex[NUM_Threads-1:0],
	output reg [4:0]  rd_addr2ex[NUM_Threads-1:0],
	output reg [6:0]  oh_2ex[NUM_Threads-1:0],
	output reg [4:0] rs1_addrtoex[NUM_Threads-1:0],
	output reg [4:0] rs2_addrtoex[NUM_Threads-1:0],
    output reg [31:0] pc2ex[NUM_Threads-1:0],

	//hold
	input wire hold[NUM_Threads-1:0]

			
);
	reg [31:0] op1[NUM_Threads-1:0];
	reg [31:0] op2[NUM_Threads-1:0];
	reg [4:0]  rd_addr[NUM_Threads-1:0];    
	reg 	   rd_wen[NUM_Threads-1:0];
    reg [6:0]  oh[NUM_Threads-1:0];

	logic [6:0]  opcode[NUM_Threads-1:0];
	logic [4:0]  rd[NUM_Threads-1:0];
	logic [2:0]  f3[NUM_Threads-1:0];
	logic [4:0]  rs1[NUM_Threads-1:0];
	logic [4:0]  rs2[NUM_Threads-1:0];
	logic [11:0] imm_i[NUM_Threads-1:0];
	logic [6:0]  f7[NUM_Threads-1:0];
	logic [31:0] mem_addr[NUM_Threads-1:0];
        integer i;
	//I type
        always @(*) begin
        for(i=0;i<NUM_Threads;i++)begin
	opcode[i]=ins[i][6:0];
	rd[i]    =ins[i][11:7];
	f3[i]    =ins[i][14:12];
	rs1[i]   =ins[i][19:15];
	mem_addr[i] = rs1[i]+{{20{ins[i][31]}}, ins[i][31:20]};


	//R type
	f7[i]    =ins[i][31:25];
	rs2[i]   =ins[i][24:20];
        end
        end


	always @(*) begin
	for(i=0;i<NUM_Threads;i++)begin	
		//default
		oh[i]      =7'b0;
		op1[i]		=32'b0;
		op2[i]		=32'b0;
		rs1_addr[i]=5'b0;
		rs2_addr[i]=5'b0;
		rd_addr[i] =5'b0;
		rd_wen[i]  =1'b0;	
					 
		case(opcode[i])

			//I type and part of R type ？？？？？
			7'b1100111:begin
				oh[i] 	    = 7'd4;
				op1[i]	    =rs1_data[i];
				op2[i]     ={{20{ins[i][31]}}, ins[i][31:20]};
				rs1_addr[i]=rs1[i];
				rs2_addr[i]=5'b0;
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;				
			end
			7'b0000011:begin
				case(f3[i])
					3'b000: oh[i] = 7'd11; //LB
					3'b001: oh[i] = 7'd12; //LH
					3'b010: oh[i] = 7'd13; //LW
					3'b100: oh[i] = 7'd14; //LBU
					3'b101: oh[i] = 7'd15; //LHUS
				endcase
			end
			7'b0010011:begin  
				op1[i]	    =rs1_data[i];
				op2[i]     ={{20{ins[i][31]}}, ins[i][31:20]};
				rs1_addr[i]=rs1[i];
				rs2_addr[i]=5'b0;
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;
				case(f3[i]) 
					3'b000: oh[i] = 7'd19;	//ADDI
					3'b010: oh[i] = 7'd20;	//SLTI
					3'b011: oh[i] = 7'd21;	//SLTIU						
					3'b001:begin 		//SLLI
						oh[i] =7'd25; 
						op2[i] = rs2[i]; //shamt
					end
					3'b101:begin
						op2[i] = rs2[i]; //shamt
						case(f7[i])
							7'b0000000: oh[i] = 7'd26; //SRLI					
							7'b0100000: oh[i] = 7'd27; //SRAI 
						endcase
					end
					3'b100: oh[i] = 7'd22; //XORI
					3'b110: oh[i] = 7'd23; //ORI
					3'b111: oh[i] = 7'd24; //ANDI
				endcase
			end



			//R type
			7'b0110011:begin 
				op1[i]	    =rs1_data[i];
				op2[i]     =rs2_data[i];
				rs1_addr[i]=rs1[i];
				rs2_addr[i]=rs2[i];
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;				
				case(f3[i])
					3'b000:begin
						case(f7[i])
							7'b0000000: oh[i] =7'd28; //ADD
							7'b0100000: oh[i] =7'd29; //SUB
						endcase
					end
					3'b001: oh[i] =7'd30; //SLL
					3'b010: oh[i] =7'd31;//SLT						
					3'b011: oh[i] =7'd32;//SLTU
					3'b100: begin
						case(f7[i])
						    7'b0000000: oh[i] =7'd33;//XOR
							7'b0000001: oh[i] =7'd38;//DIV
						endcase
					end
					3'b101:begin
						case(f7[i])					
							7'b0000000: oh[i] =7'd34;//SRL								
							7'b0100000: oh[i] =7'd35;//SRA
						endcase
					end
					3'b110: oh[i] =7'd36;//OR								
					3'b111: oh[i] =7'd37;//AND								
				endcase
			end
			//R type

			//B type
			7'b1100011: begin
				op1[i]       = rs1_data[i];
				op2[i]       = rs2_data[i];
				rs1_addr[i]  = rs1[i];
				rs2_addr[i]  = rs2[i];
				rd_addr[i]   = 5'b0;
				rd_wen[i]    = 1'b0;
				oh[i] = 7'd0; //default
				case (f3[i])
					3'b001: oh[i] = 7'd6;  // BNE
					3'b000: oh[i] = 7'd5;  // BEQ
					3'b100: oh[i] = 7'd7;  // BLT
					3'b101: oh[i] = 7'd8;  // BGE
					3'b110: oh[i] = 7'd9;  // BLTU
					3'b111: oh[i] = 7'd10; // BGEU
				endcase
			end
			
			//U type
			7'b0110111:begin //LUI
				oh[i]  	=7'd1;
				op1[i]		={ins[i][31:12], 12'b0};
				op2[i]		=32'b0;
				rs1_addr[i]=5'b0;
				rs2_addr[i]=5'b0;
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;	
			end
			7'b0010111:begin //AUIPC
				oh[i]  	=7'd2;
				op1[i]		={ins[i][31:12], 12'b0};
				op2[i]		=32'b0;
				rs1_addr[i]=5'b0;
				rs2_addr[i]=5'b0;
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;	

			end

			//J type
			7'b1101111:begin //JAL
				oh[i]		=7'd3;
				op1[i]		=32'b0;
				op2[i]		=32'b0;
				rs1_addr[i]=5'b0;
				rs2_addr[i]=5'b0;
				rd_addr[i] =rd[i];
				rd_wen[i]  =1'b1;
			end
                        default: begin
                        end
					
		endcase//type
	   end// for
	end//always
// output to next stage
always @(posedge clk)begin
	for( i = 0; i < NUM_Threads; i++)begin
		if(rst==1'b0||hold[i])begin 
			pc2ex[i] <= 32'b0;
			op1_ex[i] <= 32'b0;
			op2_ex[i] <= 32'b0;
			ins_2ex[i] <= 32'h0;
			oh_2ex[i] <= 7'b0;
			rd_addr2ex[i] <=5'b0;
			rs1_addrtoex[i] <= 5'b0;
			rs2_addrtoex[i] <= 5'b0;
			end else begin
			pc2ex[i] <= pc2id_ex[i];
			op1_ex[i] <= op1[i];
			op2_ex[i] <= op2[i];
			ins_2ex[i] <= ins[i];
			oh_2ex[i] <= oh[i];
			rd_addr2ex[i] <= rd_addr[i];
			rs1_addrtoex[i] <= rs1_addr[i];
			rs2_addrtoex[i] <= rs2_addr[i];
		end
	end
end
endmodule

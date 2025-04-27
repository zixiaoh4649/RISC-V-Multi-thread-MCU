module ALU(
	input wire [31:0] ins,
	input wire [31:0] ins_addr2ex,
	input wire [31:0] op1,    //op1_ex
	input wire [31:0] op2,    //op2_ex
	input wire [4:0]  rd_addr2ex, 
	input wire [6:0]  oh,
	output reg [4:0]  rd_addr,
	output reg [31:0] rd_data,
	output reg        rd_wen2reg,

	//to ctrl
	output reg [31:0] jump_addr2ctrl,
	output reg 		  jump_en2ctrl,
	output reg        hold2ctrl
);

	//B type
	wire   [31:0] imm_jump;
	assign imm_jump = {{19{ins[31]}},ins[31], ins[7], ins[30:25], ins[11:8], 1'b0};
	wire   op1_equal_op2;
	assign op1_equal_op2 = (op1 == op2)? 1'b1:1'b0;



	//J type
	//wire   [31:0] imm_jal;
	//assign imm_jal = {12{ins[31]}, ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};

	//ALU
	wire [31:0] op1_add_op2;
	wire [31:0] op1_and_op2;
	wire [31:0] op1_or_op2;
	wire [31:0] op1_xor_op2;
	wire [31:0] op1_leftshift_op2;
	wire [31:0] op1_rightshift_op2;
	assign op1_add_op2 			= op1 + op2;
	assign op1_and_op2 			= op1 & op2;
	assign op1_or_op2 			= op1 | op2;
	assign op1_xor_op2 			= op1 ^ op2;
	assign op1_leftshift_op2 	= op1 << op2;
	assign op1_rightshift_op2 	= op1 >> op2;
	wire op1_unsignedless_op2;
	wire op1_signedless_op2;
	assign op1_unsignedless_op2 = (op1)<(op2);
	assign op1_signedless_op2   = $signed(op1)<$signed(op2);

	


	
	always @(*) begin

		//default
		rd_data    = 32'b0;
		rd_addr    = 5'b0;
		rd_wen2reg = 1'b0;
		jump_addr2ctrl = 32'b0;
		jump_en2ctrl   = 1'b0;
		hold2ctrl	   = 1'b0;
		
		case(oh)

			//U type
			7'd1:begin //LUI
				rd_data 	= op1;
				rd_addr		= rd_addr2ex;
				rd_wen2reg 	= 1'b1;
			end
			7'd2:begin //AUIPC
				rd_data = ins_addr2ex + op1;
				rd_addr		= rd_addr2ex;
				rd_wen2reg 	= 1'b1;
			end

			//J type
			7'd3:begin //Jal
				jump_addr2ctrl = ins_addr2ex + {{12{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};
				jump_en2ctrl   = 1'b1;
				rd_data		   = ins_addr2ex + 32'd4;
				rd_addr        = rd_addr2ex;
				rd_wen2reg	   = 1'b1;
			end


			7'd4:begin //JALR
				jump_addr2ctrl  = op1_add_op2; //PC
				jump_en2ctrl    = 1'b1;
				rd_data			= ins_addr2ex + 32'd4;
				rd_addr    	 	= rd_addr2ex;
				rd_wen2reg		= 1'b1;
			end


			//B type
			7'd5:begin //BEQ
				if(op1_equal_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end
			end			
			7'd6:begin //BNE
				if(~op1_equal_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end
			end
			7'd7:begin //BLT
				if(op1_signedless_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end
			end			
			7'd8:begin //BGE
				if(~op1_signedless_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end
			end
			7'd9:begin //BLTU
				if(op1_unsignedless_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end			
			end
			7'd10:begin //BGEU
				if(~op1_unsignedless_op2)begin
					jump_addr2ctrl = ins_addr2ex + imm_jump;
					jump_en2ctrl = 1'b1;
				end				
			end

			//I type
			7'd11:begin //LB    
			end 
			7'd12:begin //LH 
			end
			7'd13:begin //LW
			end
			7'd14:begin //LBU
			end
			7'd15:begin //LHU
			end

			//B type
			7'd16:begin //SB
			end
			7'd17:begin //SH
			end
			7'd18:begin //SW
			end

			//I type
			7'd19:begin //ADDI
				rd_data    = op1_add_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd20:begin //SLTI
				if(op1_signedless_op2)begin
					rd_data    = 32'b1;
					rd_addr    = rd_addr2ex;
					rd_wen2reg = 1'b1;
				end else begin
					rd_data    = 32'b0;
					rd_addr    = rd_addr2ex;
					rd_wen2reg = 1'b1;
				end
			end
			7'd21:begin //SLTIU
				if(op1_unsignedless_op2)begin
					rd_data    = 32'b1;
					rd_addr    = rd_addr2ex;
					rd_wen2reg = 1'b1;
				end else begin
					rd_data    = 32'b0;
					rd_addr    = rd_addr2ex;
					rd_wen2reg = 1'b1;
				end
			end
			7'd22:begin //XORI
				rd_data    = op1_xor_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd23:begin //ORI
				rd_data    = op1_or_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd24:begin //ANDI
				rd_data    = op1_and_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end

			//R type shamt
			7'd25:begin //SLLI
				rd_data    = op1_leftshift_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd26:begin //SRLI
				rd_data    = op1_rightshift_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;				
			end
			7'd27:begin //SRAI
			if (op1[31] == 1'b1) begin
				rd_data = (op1 >> op2) | ~(32'hFFFFFFFF >> op2);
			end else begin
				rd_data = op1 >> op2;
			end			
				rd_addr	   =rd_addr2ex;
				rd_wen2reg = 1'b1;				
			end
			//R type shamt
			//R type
			7'd28:begin //ADD
				rd_data    = op1_add_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd29:begin //SUB
				rd_data    = op1 - op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd30:begin //SLL
				rd_data    = op1 << op2[4:0];
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd31:begin //SLT
				if(op1_signedless_op2)begin
					rd_data = 1'b1;
				end else begin
					rd_data = 1'b0;
				end
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd32:begin //SLTU
				if(op1_unsignedless_op2)begin
					rd_data = 1'b1;
				end else begin
					rd_data = 1'b0;
				end
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd33:begin //XOR
				rd_data    = op1_xor_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd34:begin //SRL
				rd_data    = op1 >> op2[4:0];
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd35:begin //SRA
			    rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			if (op1[31] == 1'b1) begin
				rd_data = $signed(op1) >>> op2[4:0];
			end else begin
				rd_data = op1 >> op2;
			end			
			end
			7'd36:begin //OR
				rd_data    = op1_or_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			7'd37:begin //AND
				rd_data    = op1_and_op2;
				rd_addr    = rd_addr2ex;
				rd_wen2reg = 1'b1;
			end
			//R type


			
		endcase
		
	
	end



endmodule

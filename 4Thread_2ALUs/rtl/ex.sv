import types::*;
module ex(
        input wire clk,
        input wire rst,
	input wire [31:0] ins[NUM_Threads-1:0],
	input wire [31:0] op1[NUM_Threads-1:0],    //op1_ex
	input wire [31:0] op2[NUM_Threads-1:0],    //op2_ex
	input wire [4:0]  rd_addr2ex[NUM_Threads-1:0], 
	input wire [6:0]  oh[NUM_Threads-1:0],
    input wire [31:0] pc2ex[NUM_Threads-1:0],
	input wire [4:0] rs1_addr[NUM_Threads-1:0],
	input wire [4:0] rs2_addr[NUM_Threads-1:0],
	output reg [4:0]  rd_addr[NUM_Threads-1:0],
	output reg [31:0] rd_data[NUM_Threads-1:0],
	output reg        rd_wen2reg[NUM_Threads-1:0],

	//to ctrl
	output reg [31:0] jump_addr2ctrl[NUM_Threads-1:0],
	output reg        jump_en2ctrl[NUM_Threads-1:0],
	output reg        hold2ctrl[NUM_Threads-1:0],
        //dispatch ports
    output reg [6:0]  oh_dispatch[NUM_Threads-1:0],
    input  wire[2:0]  dispatch_threads[NUM_ALUs-1:0]
);
        integer i;
        integer j;
        integer z;
        // dispatch queue
    logic [31:0] ins_queue[NUM_Threads-1:0][2:0];
	logic [31:0] op1_queue[NUM_Threads-1:0][2:0];    //op1_ex
	logic [31:0] op2_queue[NUM_Threads-1:0][2:0];    //op2_ex
	logic [4:0]  rd_addr2ex_queue[NUM_Threads-1:0][2:0]; 
	logic [6:0]  oh_queue[NUM_Threads-1:0][2:0];
    logic [31:0] pc_queue[NUM_Threads-1:0][2:0];
    logic [4:0]  rs1_addr_queue[NUM_Threads-1:0][2:0];
    logic [4:0]  rs2_addr_queue[NUM_Threads-1:0][2:0];
        // generate oh_dispatch
		always @(*)begin
			for(i=0; i< NUM_Threads; i++)begin
				if(pc_queue[i][0]=='0 && oh_queue[i][0]=='0)begin
                    oh_dispatch[i] = oh[i];
				end
				else begin
					oh_dispatch[i] = oh_queue[i][0];
				end
            end
		end

       
        // dispatch queue
        always @(posedge clk)begin
              if(rst==0)begin
                  for(i=0;i<NUM_Threads;i++)begin
                         for(j=0;j<3;j++)begin
                              ins_queue[i][j] <='0;
                              op1_queue[i][j] <='0;
                              op2_queue[i][j] <='0;
                              rd_addr2ex_queue[i][j] <='0;
                              oh_queue[i][j] <='0;
                              pc_queue[i][j] <='0;
                              rs1_addr_queue[i][j] <= '0;
                              rs2_addr_queue[i][j] <= '0;
                         end
                   end
              end
              else begin 
                  for(i=0;i<NUM_Threads;i++)begin 
                         if(jump_en2ctrl[i] || hold2ctrl[i])begin // if thread jump ==> flush the queue
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;

                                    op1_queue[i][0]         <= '0;
                                    op2_queue[i][0]         <= '0;
                                    ins_queue[i][0]         <= '0;
                                    rd_addr2ex_queue[i][0]  <= '0;
                                    oh_queue[i][0]          <= '0;
                                    pc_queue[i][0]          <= '0;
                                    rs1_addr_queue[i][0]    <= '0;
                                    rs2_addr_queue[i][0]    <= '0;
                         end
                         else if (dispatch_threads[0]==i ||dispatch_threads[1]==i   ) begin //dispatched threads
                                if(pc_queue[i][0] == pc2ex[i])begin  //fetch same inst
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;

                                    op1_queue[i][0]         <= '0;
                                    op2_queue[i][0]         <= '0;
                                    ins_queue[i][0]         <= '0;
                                    rd_addr2ex_queue[i][0]  <= '0;
                                    oh_queue[i][0]          <= '0;
                                    pc_queue[i][0]          <= '0;
                                    rs1_addr_queue[i][0]    <= '0;
                                    rs2_addr_queue[i][0]    <= '0;
                                end
                                else if (pc_queue[i][0]=='0 && oh_queue[i][0]=='0)begin  // queue are all empty 
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;

                                    op1_queue[i][0]         <= '0;
                                    op2_queue[i][0]         <= '0;
                                    ins_queue[i][0]         <= '0;
                                    rd_addr2ex_queue[i][0]  <= '0;
                                    oh_queue[i][0]          <= '0;
                                    pc_queue[i][0]          <= '0;
                                    rs1_addr_queue[i][0]    <= '0;
                                    rs2_addr_queue[i][0]    <= '0;
                                end
                                else if(pc_queue[i][1] == pc2ex[i])begin
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;
                                   
                                    if(rd_wen2reg[i] && rd_addr[i] == rs1_addr_queue[i][1] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][0]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][0]         <= op1[i];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr_queue[i][1] && rd_addr[i]!='0)begin
                                        op2_queue[i][0]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][0]         <= op2[i];
                                    end
                                    ins_queue[i][0]         <= ins[i];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex[i];
                                    oh_queue[i][0]          <= oh[i];
                                    pc_queue[i][0]          <= pc2ex[i];
                                    rs1_addr_queue[i][0]    <= rs1_addr[i];
                                    rs2_addr_queue[i][0]    <= rs2_addr[i];
                                end
                                else if (pc_queue[i][1]=='0 && oh_queue[i][1]=='0)begin // no fetch same instruction==> fetched inst put in empty queue, oh_queue for detect first inst in queue(pc=0)
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;


                                    if(rd_wen2reg[i] && rd_addr[i] ==rs1_addr[i] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][0]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][0]         <= op1[i];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr[i] && rd_addr[i]!='0)begin
                                        op2_queue[i][0]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][0]         <= op2[i];
                                    end
                                    ins_queue[i][0]         <= ins[i];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex[i];
                                    oh_queue[i][0]          <= oh[i];
                                    pc_queue[i][0]          <= pc2ex[i];
                                    rs1_addr_queue[i][0]    <= rs1_addr[i];
                                    rs2_addr_queue[i][0]    <= rs2_addr[i];
                                end
                                else if(pc_queue[i][2] == pc2ex[i])begin
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    if(rd_wen2reg[i] && rd_addr[i] ==rs1_addr[i] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][1]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][1]         <= op1[i];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr[i] && rd_addr[i]!='0)begin
                                        op2_queue[i][1]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][1]         <= op2[i];
                                    end
                                    ins_queue[i][1]         <= ins[i];
                                    rd_addr2ex_queue[i][1]  <= rd_addr2ex[i];
                                    oh_queue[i][1]          <= oh[i];
                                    pc_queue[i][1]          <= pc2ex[i];
                                    rs1_addr_queue[i][1]    <= rs1_addr[i];
                                    rs2_addr_queue[i][1]    <= rs2_addr[i];


                                    if(rd_wen2reg[i] && rd_addr[i] == rs1_addr_queue[i][1] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][0]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][0]         <= op1_queue[i][1];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr_queue[i][1] && rd_addr[i]!='0)begin
                                        op2_queue[i][0]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][0]         <=op2_queue[i][1];
                                    end
                                    ins_queue[i][0]         <= ins_queue[i][1];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex_queue[i][1];
                                    oh_queue[i][0]          <= oh_queue[i][1];
                                    pc_queue[i][0]          <= pc_queue[i][1];
                                    rs1_addr_queue[i][0]    <= rs1_addr_queue[i][1];
                                    rs2_addr_queue[i][0]    <= rs2_addr_queue[i][1];
                                end
                                else if (pc_queue[i][2]=='0 && oh_queue[i][2]=='0)begin
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    if(rd_wen2reg[i] && rd_addr[i] ==rs1_addr[i] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][1]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][1]         <= op1[i];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr[i] && rd_addr[i]!='0)begin
                                        op2_queue[i][1]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][1]         <= op2[i];
                                    end
                                    ins_queue[i][1]         <= ins[i];
                                    rd_addr2ex_queue[i][1]  <= rd_addr2ex[i];
                                    oh_queue[i][1]          <= oh[i];
                                    pc_queue[i][1]          <= pc2ex[i];
                                    rs1_addr_queue[i][1]    <= rs1_addr[i];
                                    rs2_addr_queue[i][1]    <= rs2_addr[i];


                                    if(rd_wen2reg[i] && rd_addr[i] == rs1_addr_queue[i][1] && rd_addr[i]!='0)begin //WB forwarding to queue
                                        op1_queue[i][0]         <= rd_data[i];
                                    end
                                    else begin
                                        op1_queue[i][0]         <= op1_queue[i][1];
                                    end
                                    if(rd_wen2reg[i] && rd_addr[i] == rs2_addr_queue[i][1] && rd_addr[i]!='0)begin
                                        op2_queue[i][0]         <= rd_data[i];   
                                    end
                                    else begin
                                        op2_queue[i][0]         <=op2_queue[i][1];
                                    end
                                    ins_queue[i][0]         <= ins_queue[i][1];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex_queue[i][1];
                                    oh_queue[i][0]          <= oh_queue[i][1];
                                    pc_queue[i][0]          <= pc_queue[i][1];
                                    rs1_addr_queue[i][0]    <= rs1_addr_queue[i][1];
                                    rs2_addr_queue[i][0]    <= rs2_addr_queue[i][1];

                                end
                                else begin   //default
                                end
                              

                        
                          end
                          else begin  // thread not dispatched
                                if(pc_queue[i][0] == pc2ex[i])begin //no-op
                                end
                                else if (pc_queue[i][0]=='0 && oh_queue[i][0]=='0)begin
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    op1_queue[i][1]         <= '0;
                                    op2_queue[i][1]         <= '0;
                                    ins_queue[i][1]         <= '0;
                                    rd_addr2ex_queue[i][1]  <= '0;
                                    oh_queue[i][1]          <= '0;
                                    pc_queue[i][1]          <= '0;
                                    rs1_addr_queue[i][1]    <= '0;
                                    rs2_addr_queue[i][1]    <= '0;

                                    ins_queue[i][0]         <= ins[i];
                                    op1_queue[i][0]         <= op1[i];
                                    op2_queue[i][0]         <= op2[i];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex[i];
                                    oh_queue[i][0]          <= oh[i];
                                    pc_queue[i][0]          <= pc2ex[i];
                                    rs1_addr_queue[i][0]    <= rs1_addr[i];
                                    rs2_addr_queue[i][0]    <= rs2_addr[i];
                                end
                                else if(pc_queue[i][1] == pc2ex[i])begin   //no-op
                                end
                                else if (pc_queue[i][1]=='0 && oh_queue[i][1]=='0)begin
                                    op1_queue[i][2]         <= '0;
                                    op2_queue[i][2]         <= '0;
                                    ins_queue[i][2]         <= '0;
                                    rd_addr2ex_queue[i][2]  <= '0;
                                    oh_queue[i][2]          <= '0;
                                    pc_queue[i][2]          <= '0;
                                    rs1_addr_queue[i][2]    <= '0;
                                    rs2_addr_queue[i][2]    <= '0;

                                    ins_queue[i][1]         <= ins[i];
                                    op1_queue[i][1]         <= op1[i];
                                    op2_queue[i][1]         <= op2[i];
                                    rd_addr2ex_queue[i][1]  <= rd_addr2ex[i];
                                    oh_queue[i][1]          <= oh[i];
                                    pc_queue[i][1]          <= pc2ex[i];
                                    rs1_addr_queue[i][1]    <= rs1_addr[i];
                                    rs2_addr_queue[i][1]    <= rs2_addr[i];

                                    ins_queue[i][0]         <= ins_queue[i][0];
                                    op1_queue[i][0]         <= op1_queue[i][0];
                                    op2_queue[i][0]         <= op2_queue[i][0];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex_queue[i][0];
                                    oh_queue[i][0]          <= oh_queue[i][0];
                                    pc_queue[i][0]          <= pc_queue[i][0];
                                    rs1_addr_queue[i][0]    <= rs1_addr_queue[i][0];
                                    rs2_addr_queue[i][0]    <= rs2_addr_queue[i][0];
                                end
                                else if(pc_queue[i][2] == pc2ex[i])begin  //no-op
                                end
                                else if (pc_queue[i][2]=='0 && oh_queue[i][2]=='0)begin
                                    ins_queue[i][2]         <= ins[i];
                                    op1_queue[i][2]         <= op1[i];
                                    op2_queue[i][2]         <= op2[i];
                                    rd_addr2ex_queue[i][2]  <= rd_addr2ex[i];
                                    oh_queue[i][2]          <= oh[i];
                                    pc_queue[i][2]          <= pc2ex[i];
                                    rs1_addr_queue[i][2]    <= rs1_addr[i];
                                    rs2_addr_queue[i][2]    <= rs2_addr[i];

                                    ins_queue[i][1]         <= ins_queue[i][1];
                                    op1_queue[i][1]         <= op1_queue[i][1];
                                    op2_queue[i][1]         <= op2_queue[i][1];
                                    rd_addr2ex_queue[i][1]  <= rd_addr2ex_queue[i][1];
                                    oh_queue[i][1]          <= oh_queue[i][1];
                                    pc_queue[i][1]          <= pc_queue[i][1];
                                    rs1_addr_queue[i][1]    <= rs1_addr_queue[i][1];
                                    rs2_addr_queue[i][1]    <= rs2_addr_queue[i][1];

                                    ins_queue[i][0]         <= ins_queue[i][0];
                                    op1_queue[i][0]         <= op1_queue[i][0];
                                    op2_queue[i][0]         <= op2_queue[i][0];
                                    rd_addr2ex_queue[i][0]  <= rd_addr2ex_queue[i][0];
                                    oh_queue[i][0]          <= oh_queue[i][0];
                                    pc_queue[i][0]          <= pc_queue[i][0];
                                    rs1_addr_queue[i][0]    <= rs1_addr_queue[i][0];
                                    rs2_addr_queue[i][0]    <= rs2_addr_queue[i][0];
                                end
                                else begin //no-op
                                end
                          end
                      end

              end
        end
    
    logic [31:0] ins_to_ALU[NUM_ALUs-1:0];
	logic [31:0] ins_addr2ex_to_ALU[NUM_ALUs-1:0];
	logic [31:0] op1_to_ALU[NUM_ALUs-1:0];    
	logic [31:0] op2_to_ALU[NUM_ALUs-1:0];    
	logic [4:0]  rd_addr2ex_to_ALU[NUM_ALUs-1:0]; 
	logic [6:0]  oh_to_ALU[NUM_ALUs-1:0];
    logic        rd_wen2reg_ALU[NUM_ALUs-1:0];
    always @(*) begin
		for(i=0;i<NUM_ALUs;i++)begin
			if((pc_queue[dispatch_threads[i]][0]=='0 && oh_queue[dispatch_threads[i]][0]=='0))begin // queue is empty==> use input from id  or  first inst in queue equals inst from decode stage(use new decoded inst cause forwarding issue)
				ins_to_ALU[i] = ins[dispatch_threads[i]];
                ins_addr2ex_to_ALU[i] = pc2ex[dispatch_threads[i]];
				op1_to_ALU[i] = op1[dispatch_threads[i]];    
				op2_to_ALU[i] = op2[dispatch_threads[i]];    
				rd_addr2ex_to_ALU[i] = rd_addr2ex[dispatch_threads[i]]; 
				oh_to_ALU[i] = oh[dispatch_threads[i]];
			end
			else begin
				ins_to_ALU[i] = ins_queue[dispatch_threads[i]][0];
                ins_addr2ex_to_ALU[i] = pc_queue[dispatch_threads[i]][0];
				op1_to_ALU[i] = op1_queue[dispatch_threads[i]][0];    
				op2_to_ALU[i] = op2_queue[dispatch_threads[i]][0];    
				rd_addr2ex_to_ALU[i] = rd_addr2ex_queue[dispatch_threads[i]][0]; 
				oh_to_ALU[i] = oh_queue[dispatch_threads[i]][0];
			end
		end
	end
	reg [4:0]  rd_addr_ALU[NUM_ALUs-1:0];
	reg [31:0] rd_data_ALU[NUM_ALUs-1:0];
	reg [31:0] jump_addr2ctrl_ALU[NUM_ALUs-1:0];
	reg        jump_en2ctrl_ALU[NUM_ALUs-1:0];
	reg        hold2ctrl_ALU[NUM_ALUs-1:0];
	ALU ALU_thread0(
	.ins        (ins_to_ALU[0]),
	.ins_addr2ex(ins_addr2ex_to_ALU[0]),
	.op1(op1_to_ALU[0]),
	.op2(op2_to_ALU[0]),
	.rd_addr2ex(rd_addr2ex_to_ALU[0]),
	.oh(oh_to_ALU[0]),
	.rd_addr(rd_addr_ALU[0]),
	.rd_data(rd_data_ALU[0]),
	.rd_wen2reg(rd_wen2reg_ALU[0]),
	.jump_addr2ctrl(jump_addr2ctrl_ALU[0]),
	.jump_en2ctrl(jump_en2ctrl_ALU[0]),
	.hold2ctrl(hold2ctrl_ALU[0])
	);
	ALU ALU_thread1(
	.ins        (ins_to_ALU[1]),
	.ins_addr2ex(ins_addr2ex_to_ALU[1]),
	.op1(op1_to_ALU[1]),
	.op2(op2_to_ALU[1]),
	.rd_addr2ex(rd_addr2ex_to_ALU[1]),
	.oh(oh_to_ALU[1]),
	.rd_addr(rd_addr_ALU[1]),
	.rd_data(rd_data_ALU[1]),
	.rd_wen2reg(rd_wen2reg_ALU[1]),
	.jump_addr2ctrl(jump_addr2ctrl_ALU[1]),
	.jump_en2ctrl(jump_en2ctrl_ALU[1]),
	.hold2ctrl(hold2ctrl_ALU[1])
	);


    always @(*)begin
        for(i=0;i<NUM_Threads;i++)begin
			rd_addr[i] = '0;
			rd_data[i] = '0;
			rd_wen2reg[i] = '0;
			jump_addr2ctrl[i] = '0;
			jump_en2ctrl[i] = '0;
			hold2ctrl[i] = '0;
		end
        for(i=0;i<NUM_ALUs;i++)begin
		    if(dispatch_threads[i] != 3'd4)begin
				rd_addr[dispatch_threads[i]] = rd_addr_ALU[i];
				rd_data[dispatch_threads[i]] = rd_data_ALU[i];
				rd_wen2reg[dispatch_threads[i]] = rd_wen2reg_ALU[i];
				jump_addr2ctrl[dispatch_threads[i]] = jump_addr2ctrl_ALU[i];
				jump_en2ctrl[dispatch_threads[i]] = jump_en2ctrl_ALU[i];
				hold2ctrl[dispatch_threads[i]] = hold2ctrl_ALU[i];
			end
	   end
	end

endmodule

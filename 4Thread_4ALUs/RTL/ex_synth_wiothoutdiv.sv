import types::*;
module ex(
	input wire [31:0] ins[NUM_Threads-1:0],
	input wire [31:0] op1[NUM_Threads-1:0],    //op1_ex
	input wire [31:0] op2[NUM_Threads-1:0],    //op2_ex
	input wire [4:0]  rd_addr2ex[NUM_Threads-1:0], 
	input wire [6:0]  oh[NUM_Threads-1:0],
        input wire [31:0] pc2ex[NUM_Threads-1:0],
	output reg [4:0]  rd_addr[NUM_Threads-1:0],
	output reg [31:0] rd_data[NUM_Threads-1:0],
	output reg        rd_wen2reg[NUM_Threads-1:0],

	//to ctrl
	output reg [31:0] jump_addr2ctrl[NUM_Threads-1:0],
	output reg        jump_en2ctrl[NUM_Threads-1:0],
	output reg        hold2ctrl[NUM_Threads-1:0],

        input wire [2:0] dispatch_threads[NUM_ALUs-1:0]
);
        integer i;
       
        logic [31:0] ins_to_ALU[NUM_ALUs-1:0];
	logic [31:0] ins_addr2ex_to_ALU[NUM_ALUs-1:0];
	logic [31:0] op1_to_ALU[NUM_ALUs-1:0];    
	logic [31:0] op2_to_ALU[NUM_ALUs-1:0];    
	logic [4:0]  rd_addr2ex_to_ALU[NUM_ALUs-1:0]; 
	logic [6:0]  oh_to_ALU[NUM_ALUs-1:0];
    always @(*) begin
		for(i=0;i<NUM_ALUs;i++)begin
				ins_to_ALU[i] = ins[dispatch_threads[i]];
                                ins_addr2ex_to_ALU[i] = pc2ex[dispatch_threads[i]];
				op1_to_ALU[i] = op1[dispatch_threads[i]];    
				op2_to_ALU[i] = op2[dispatch_threads[i]];    
				rd_addr2ex_to_ALU[i] = rd_addr2ex[dispatch_threads[i]]; 
				oh_to_ALU[i] = oh[dispatch_threads[i]];
		end
	end
    


	ALU ALU_thread0(
	.ins        (ins_to_ALU[0]),
	.ins_addr2ex(ins_addr2ex_to_ALU[0]),
	.op1(op1_to_ALU[0]),
	.op2(op2_to_ALU[0]),
	.rd_addr2ex(rd_addr2ex_to_ALU[0]),
	.oh(oh_to_ALU[0]),
	.rd_addr(rd_addr[0]),
	.rd_data(rd_data[0]),
	.rd_wen2reg(rd_wen2reg[0]),
	.jump_addr2ctrl(jump_addr2ctrl[0]),
	.jump_en2ctrl(jump_en2ctrl[0]),
	.hold2ctrl(hold2ctrl[0])
	);

        	ALU ALU_thread1(
	.ins        (ins_to_ALU[1]),
	.ins_addr2ex(ins_addr2ex_to_ALU[1]),
	.op1(op1_to_ALU[1]),
	.op2(op2_to_ALU[1]),
	.rd_addr2ex(rd_addr2ex_to_ALU[1]),
	.oh(oh_to_ALU[1]),
	.rd_addr(rd_addr[1]),
	.rd_data(rd_data[1]),
	.rd_wen2reg(rd_wen2reg[1]),
	.jump_addr2ctrl(jump_addr2ctrl[1]),
	.jump_en2ctrl(jump_en2ctrl[1]),
	.hold2ctrl(hold2ctrl[1])
	);
	ALU ALU_thread2(
	.ins        (ins_to_ALU[2]),
	.ins_addr2ex(ins_addr2ex_to_ALU[2]),
	.op1(op1_to_ALU[2]),
	.op2(op2_to_ALU[2]),
	.rd_addr2ex(rd_addr2ex_to_ALU[2]),
	.oh(oh_to_ALU[2]),
	.rd_addr(rd_addr[2]),
	.rd_data(rd_data[2]),
	.rd_wen2reg(rd_wen2reg[2]),
	.jump_addr2ctrl(jump_addr2ctrl[2]),
	.jump_en2ctrl(jump_en2ctrl[2]),
	.hold2ctrl(hold2ctrl[2])
	);
    ALU ALU_thread3(
	.ins        (ins_to_ALU[3]),
	.ins_addr2ex(ins_addr2ex_to_ALU[3]),
	.op1(op1_to_ALU[3]),
	.op2(op2_to_ALU[3]),
	.rd_addr2ex(rd_addr2ex_to_ALU[3]),
	.oh(oh_to_ALU[3]),
	.rd_addr(rd_addr[3]),
	.rd_data(rd_data[3]),
	.rd_wen2reg(rd_wen2reg[3]),
	.jump_addr2ctrl(jump_addr2ctrl[3]),
	.jump_en2ctrl(jump_en2ctrl[3]),
	.hold2ctrl(hold2ctrl[3])
	);



endmodule

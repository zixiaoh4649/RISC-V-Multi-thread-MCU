import types::*;
module id_ex(
	input wire clk,
	input wire rst,

	//from id
	input wire [31:0] op1[NUM_Threads-1:0],
	input wire [31:0] op2[NUM_Threads-1:0],
	input wire [31:0] ins2ex[NUM_Threads-1:0],
	input wire [31:0] ins_addr[NUM_Threads-1:0],
	input wire [4:0]  rd_addr[NUM_Threads-1:0],
	input wire 	      rd_wen[NUM_Threads-1:0],
	input wire [6:0]  oh_in[NUM_Threads-1:0], //oh
    input wire [31:0] pc2id_ex[NUM_Threads-1:0],
	input wire [4:0] rs1_addr[NUM_Threads-1:0],
	input wire [4:0] rs2_addr[NUM_Threads-1:0],
	
	//to ex
	output wire [31:0] op1_ex[NUM_Threads-1:0],
	output wire [31:0] op2_ex[NUM_Threads-1:0],
	output wire [31:0] ins[NUM_Threads-1:0],
	output wire [31:0] ins_addr2ex[NUM_Threads-1:0],
	output wire [4:0]  rd_addr2ex[NUM_Threads-1:0],
	output wire        rd_wen2ex[NUM_Threads-1:0],
	output wire [6:0]  oh[NUM_Threads-1:0],
	output wire [4:0] rs1_addrtoex[NUM_Threads-1:0],
	output wire [4:0] rs2_addrtoex[NUM_Threads-1:0],
    output wire [31:0] pc2ex[NUM_Threads-1:0],

	//hold
	input wire hold[NUM_Threads-1:0]
);
generate
  for (genvar i = 0; i < NUM_Threads; i++) begin: all_dff_sets
        dff_set #(32) dff_pc(clk, rst, hold[i], 32'b0, pc2id_ex[i], pc2ex[i]);
        
	dff_set #(32) dff_op1(clk, rst, hold[i], 32'b0, op1[i], op1_ex[i]);
	
	dff_set #(32) dff_op2(clk, rst, hold[i], 32'b0, op2[i], op2_ex[i]);
	
	dff_set #(32) dff_ins(clk, rst, hold[i], 32'h0, ins2ex[i], ins[i]);
	
	dff_set #(32) dff_ins_addr(clk, rst, hold[i], 32'b0, ins_addr[i], ins_addr2ex[i]);
	
	dff_set #(7) dff_oh(clk, rst, hold[i], 7'b0, oh_in[i], oh[i]);
	
	dff_set #(5) dff_rd_addr(clk, rst, hold[i], 5'b0, rd_addr[i], rd_addr2ex[i]);
	
	dff_set #(1) dff_rd_wen(clk, rst, hold[i], 1'b0, rd_wen[i], rd_wen2ex[i]);

	dff_set #(5) dff_rs1_addr(clk, rst, hold[i], 5'b0, rs1_addr[i], rs1_addrtoex[i]);
	
	dff_set #(5) dff_rs2_addr(clk, rst, hold[i], 5'b0, rs2_addr[i], rs2_addrtoex[i]);
 end

endgenerate
	
	
	
	
endmodule
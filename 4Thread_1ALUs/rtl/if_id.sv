import types::*;
module if_id(
	input wire clk,
	input wire rst,
	input wire [31:0] ins2id[NUM_Threads-1:0],
	input wire [31:0] ins_addr[NUM_Threads-1:0],
        input wire [31:0] pc2rom[NUM_Threads-1:0],
	output wire [31:0] ins_addr2id[NUM_Threads-1:0],
	output wire [31:0] ins[NUM_Threads-1:0],
        output wire [31:0] pc2id_ex[NUM_Threads-1:0],

	//hold
	input wire hold[3:0]
);
integer i;
generate 
  for(genvar i=0; i<NUM_Threads; i++) begin: ifid_dff_set
    dff_set #(32) dff_pc(clk, rst, hold[i], 32'b0, pc2rom[i], pc2id_ex[i]); 
	dff_set #(32) dff1(clk, rst, hold[i], 32'b0, ins_addr[i], ins_addr2id[i]); 
	dff_set #(32) dff2(clk, rst, hold[i], 32'h0, ins2id[i], ins[i]);  //32'h13 is the ins for NOP
  end
endgenerate
endmodule
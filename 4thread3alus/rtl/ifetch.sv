import types::*;
module ifetch (
	input  wire [31:0] pc_o[NUM_Threads-1:0],
	input  wire [31:0] rom_ins[NUM_Threads-1:0],
	output wire [31:0] pc2rom[NUM_Threads-1:0],
	output wire [31:0] ins2id[NUM_Threads-1:0],
	output wire [31:0] ins_addr[NUM_Threads-1:0] //for later branch addr calculate
	
);

	assign pc2rom = pc_o;
	assign ins2id = rom_ins;
	assign ins_addr = pc_o;
	
	
endmodule

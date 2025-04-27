import types::*;
module rom(
	input wire [31:0] pc2rom[NUM_Threads-1:0],
	output reg [31:0] rom_ins[NUM_Threads-1:0]
);

	reg[31:0] rom_mem[0:NUM_Threads-1][0:1000];
                generate 
                for(genvar i=0; i<NUM_Threads; i++) begin: rom_generate
	        assign rom_ins[i] = rom_mem[i][pc2rom[i]>>2];
                end
                endgenerate

	
endmodule

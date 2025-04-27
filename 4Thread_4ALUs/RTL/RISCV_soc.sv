import types::*;
module RISCV_soc(
	input wire clk,
	input wire rst
);

    wire [31:0] pc2rom[NUM_Threads-1:0];
    wire [31:0] rom_ins[NUM_Threads-1:0];

	riscv riscv_inst(
    	.clk	(clk),
    	.rst	(rst),
    	.pc_o	(pc2rom),
    	.rom_ins (rom_ins)
	);




	rom rom_inst(
		.pc2rom  (pc2rom),
		.rom_ins (rom_ins)
	);

endmodule

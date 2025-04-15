import types::*;
module ctrl(
	input  wire 		hold2ctrl[NUM_Threads-1:0]		,
	input  wire 		jump_en2ctrl[NUM_Threads-1:0]	,
	input  wire [31:0] 	jump_addr2ctrl[NUM_Threads-1:0]	,
	output reg 			hold[NUM_Threads-1:0]			,
	output reg 			jump_en[NUM_Threads-1:0]		,
	output reg [31:0]  	jump_addr[NUM_Threads-1:0]
);
        integer i;
	always @(*) begin
	   for(i=0;i<NUM_Threads;i++)begin
		jump_addr[i] = jump_addr2ctrl[i];
		jump_en[i]	  = jump_en2ctrl[i];

		if(jump_en2ctrl[i] || hold2ctrl[i]) begin
			hold[i] = 1'b1;
		end else begin
			hold[i] = 1'b0;
		end
           end
	end


endmodule
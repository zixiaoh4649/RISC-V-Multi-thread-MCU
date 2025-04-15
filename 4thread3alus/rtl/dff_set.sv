import types::*;
module dff_set#(
	parameter DW=32
)(
	input wire clk,
	input wire rst,
	input wire hold,
	input wire [DW-1:0] rstdata,
	input wire [DW-1:0] data,
	output reg [DW-1:0] data_o
);

	always @(posedge clk)begin
		if(rst==1'b0||hold)begin 
			data_o<=rstdata;
			end else begin
			data_o<=data;
		end
	end

endmodule
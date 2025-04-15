import types::*;
module regs(
	input wire clk,
	input wire rst,
	
	//from id
	input wire [4:0]  rs1_addr[NUM_Threads-1:0],
	input wire [4:0]  rs2_addr[NUM_Threads-1:0],
	
	//forward and write back
	input wire [31:0] rd_forward_data[NUM_Threads-1:0],
	input wire [4:0]  rd_forward_addr[NUM_Threads-1:0],
	input wire        rd_wen[NUM_Threads-1:0],
	
	//to id
	output reg [31:0] rs1_data[NUM_Threads-1:0],
	output reg [31:0] rs2_data[NUM_Threads-1:0]
	
);

	reg [31:0] regs [0:31][0:NUM_Threads-1];
        integer k;
        integer j;
	//read
	always @(*) begin
            for(k=0;k<NUM_Threads;k++)begin
				if(rst==1'b0) begin
					rs1_data[k]=32'b0;		
				end else if(rs1_addr[k]==5'b0) begin
					rs1_data[k]=32'b0;	
				end else if(rd_wen[k]&&(rs1_addr[k]==rd_forward_addr[k]))begin
					rs1_data[k]=rd_forward_data[k]; 
				end else begin
					rs1_data[k]=regs[rs1_addr[k]][k];
				end	
            end
	end 

	always @(*) begin
            for(k=0;k<NUM_Threads;k++)begin
				if(rst==1'b0) begin
					rs2_data[k]=32'b0;		
				end else if(rs2_addr[k]==5'b0) begin
					rs2_data[k]=32'b0;	
				end else if(rd_wen[k]&&(rs2_addr[k]==rd_forward_addr[k]))begin
					rs2_data[k]=rd_forward_data[k];
				end else begin
					rs2_data[k]=regs[rs2_addr[k]][k];
				end	
            end
	end 
	
	
	integer i;
	always @(posedge clk)begin
            for(k=0;k<NUM_Threads;k++)begin
				if(rst==1'b0)begin
					for(i=0;i<32;i=i+1)begin 
						regs[i][k]<=32'b0;
					end
				end else if(rd_wen[k]&&(rd_forward_addr[k]!=5'b0))begin
					regs[rd_forward_addr[k]][k]<=rd_forward_data[k];
				end
			end
	end

endmodule
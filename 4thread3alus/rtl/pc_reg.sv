import types::*;
module pc_reg (
	input wire clk,
	input wire rst,
	output reg [31:0] pc_o[NUM_Threads-1:0],

	//jump
	input wire hold[NUM_Threads-1:0],
	input wire [31:0] jump_addr[NUM_Threads-1:0],
	input wire jump_en[NUM_Threads-1:0],
        input wire [2:0]  dispatch_threads[NUM_ALUs-1:0]
); 
        integer i;
        integer j;
        logic [2:0] jump_count [NUM_Threads-1:0];
        logic [2:0] rst_count;
        reg dispatch_all_zero;

        always @(*) begin
            dispatch_all_zero = 1'b1;
               for (i = 0; i < NUM_Threads; i++) begin
                   if (dispatch_threads[i] != 3'd4) begin
                        dispatch_all_zero = 1'b0;
                   end
               end
        end

	always @(posedge clk)begin
		if (rst==1'b0)begin
                        for(i=0;i<NUM_Threads;i++)begin
			pc_o[i] <= 32'd0;//i*32'd10;
                        rst_count <= 3'd2;
                        end
		end 
                else if(rst_count != 3'd0)begin  //2 cycles after reset, pipeline hasn't gone through execute stage(no dispatch)
                        for(i=0;i<NUM_Threads;i++)begin
                        pc_o[i] <= pc_o[i] + 3'd4;
                        rst_count <= rst_count - 3'd1;
                        end
                end
                /*else if(dispatch_all_zero)begin  //2 cycles after reset, pipeline hasn't gone through execute stage(no dispatch)
                        for(i=0;i<NUM_Threads;i++)begin
                        pc_o[i] <= pc_o[i] + 3'd4;
                        end
                end*/

                else begin
                    for(i=0;i<NUM_Threads;i++)begin
                       for(j=0;j<NUM_ALUs;j++)begin
                               if(jump_en[i])begin
			              pc_o[i] <= jump_addr[i];
                                      jump_count[i] <= 3'd2;
		               end 
                               else if(jump_count[i] != '0)begin
			              pc_o[i] <= pc_o[i] + 3'd4;
                                      jump_count[i] <= jump_count[i] - 3'd1;
		               end
                               else if(dispatch_threads[j]==i )begin
			              pc_o[i] <= pc_o[i] + 3'd4;
		               end
                       end
                    end
                end
	end
	
endmodule

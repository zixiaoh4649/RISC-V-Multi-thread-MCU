 import types::*;
 module dispatch(
    input  wire                      clk,
    input  wire                      rst,
    input  wire [6:0]  oh_in [NUM_Threads-1:0],
    input wire [31:0]  ins [NUM_Threads-1:0],
    output reg [2:0] dispatch_threads [NUM_ALUs-1:0]
);

    logic [3:0] weight_reg [NUM_Threads-1:0];
    logic [3:0] wait_cnt_reg [NUM_Threads-1:0];  // for division
    logic [3:0] weight_after_rotate [NUM_Threads-1:0];
    logic [3:0] weight_comb [NUM_Threads-1:0];
    logic used [NUM_Threads-1:0];
    integer i, j,k;
    int selected_count;
    logic [3:0] dont_dispatch;
    always_ff @(posedge clk) begin
        if (rst=='0) begin
            dont_dispatch <= 4'd2;
            weight_reg[0] <= 5;
            weight_reg[1] <= 3;
            weight_reg[2] <= 2;
            weight_reg[3] <= 1;
            for (k = 0; k < NUM_Threads; k++) begin
                wait_cnt_reg[k] <= 0;
            end

        end else begin
            if(dont_dispatch>0) begin
                        dont_dispatch <= dont_dispatch-4'd1;
            end
            else begin
                for (k = 0; k < NUM_Threads; k++) begin
                    if (ins[k][14:12] == 3'b100 && ins[k][31:25] == 7'b0000001 && oh_in[k]==7'h33)  // division
                        wait_cnt_reg[k] <= 4'd2;
                    else if (wait_cnt_reg[k] != 0)
                        wait_cnt_reg[k] <= wait_cnt_reg[k] - 1;
                end
                if(selected_count > 0)begin
                for (k = 1; k < NUM_Threads; k++) begin
                    weight_reg[k] <= weight_reg[k-1];
                end
                    weight_reg[0] <= weight_reg[NUM_Threads-1];

                end
            end
        end
    end
    logic [3:0] best_w[NUM_ALUs-1:0] ;
    logic [3:0] best_idx[NUM_Threads-1:0];
    always_comb begin
        selected_count ='0;
        for (i = 0; i < NUM_Threads; i++) begin
            if(oh_in[i] == '0 )begin
                weight_comb[i] ='0;
            end
            else if (ins[k][14:12] == 3'b100 && ins[k][31:25] == 7'b0000001 && oh_in[k]==7'h33) begin // division
                weight_comb[i] = weight_reg[i] + 4;
            end 
            else begin
                weight_comb[i] = weight_reg[i];
            end
        end
        for (j = 0; j < NUM_ALUs; j++) begin
            dispatch_threads[j] = 4;
        end

        for (j = 0; j < NUM_ALUs; j++) begin
                best_w[j]='0;
                best_idx[j]='0;
            for (i = 0; i < NUM_Threads; i++) begin
                if ( 
                     (wait_cnt_reg[i] == 0) &&
                     (weight_comb[i] > best_w[j])) begin
                    best_w[j]   = weight_comb[i];
                    best_idx[j] = i;
                end
            end
            if(dont_dispatch == 0) begin
                if (best_w[j] > 0) begin
                    dispatch_threads[j] = best_idx[j];
                    weight_comb[best_idx[j]] ='0;
                    selected_count++;
                end else begin
                    dispatch_threads[j] = 3'd4;
                end
            end
        end
    end

endmodule

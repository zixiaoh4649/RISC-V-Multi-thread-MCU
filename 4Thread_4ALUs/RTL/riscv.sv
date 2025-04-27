import types::*;
module riscv(
    input wire clk,
    input wire rst,
    
    output wire [31:0] pc_o[NUM_Threads-1:0],
    input  wire [31:0] rom_ins[NUM_Threads-1:0]
);

    // dispatch
    wire[2:0]  dispatch_threads[NUM_ALUs-1:0]; 
    //from if_id
    wire [31:0] ins[NUM_Threads-1:0]; 
    wire [31:0] pc2id_ex[NUM_Threads-1:0];
    //to id
    
    //from id to regs
    wire [4:0]  rs1_addr_regs[NUM_Threads-1:0];
    wire [4:0]  rs2_addr_regs[NUM_Threads-1:0];
    wire [31:0]  rs1_data[NUM_Threads-1:0];
    wire [31:0]  rs2_data[NUM_Threads-1:0];
    //from id
    wire [31:0] op1_ex[NUM_Threads-1:0];
    wire [31:0] op2_ex[NUM_Threads-1:0];
    wire [31:0] ins_addr2ex[NUM_Threads-1:0];
    wire [31:0] ins_ex_i[NUM_Threads-1:0];
    wire [4:0]  rd_addr_ex[NUM_Threads-1:0];
    wire [6:0]  oh_ex[NUM_Threads-1:0];
    wire [31:0] pc2ex[NUM_Threads-1:0];
    wire [4:0]  rs1_addrtoex[NUM_Threads-1:0];
    wire [4:0]  rs2_addrtoex[NUM_Threads-1:0];
    //to ex

    //from ex to regs
    wire [4:0]  rd_addr_ex2regs[NUM_Threads-1:0];
    wire [31:0] rd_data_o[NUM_Threads-1:0];
    wire        rd_wen_o[NUM_Threads-1:0];

    //from ex to ctrl
    wire        hold2ctrl[NUM_Threads-1:0];

    //from ctrl to other
    reg         hold[NUM_Threads-1:0];
    wire        jump_en[NUM_Threads-1:0];
    wire [31:0] jump_addr[NUM_Threads-1:0];

    //ctrl
    integer i;
	always @(*) begin
	    for(i=0;i<NUM_Threads;i++)begin
            if(jump_en[i] || hold2ctrl[i]) begin
                hold[i] = 1'b1;
            end else begin
                hold[i] = 1'b0;
            end
        end
	end
    assign dispatch_threads[0] = 3'd0;
    assign dispatch_threads[1] = 3'd1;
    assign dispatch_threads[2] = 3'd2;
    assign dispatch_threads[3] = 3'd3;



    ifetch ifetch_inst (
        .clk        (clk),
        .rst        (rst),
        .pc_o    (pc_o),
        .rom_ins (rom_ins),
        .ins        (ins),
        .pc2id_ex    (pc2id_ex),
        .hold       (hold),
        .jump_addr  (jump_addr),
	    .jump_en    (jump_en),
        .dispatch_threads(dispatch_threads)
    );
    id id_inst(
        .clk        (clk),
        .rst        (rst),

        .ins        (ins),
        .pc2id_ex   (pc2id_ex),
        .rs1_addr   (rs1_addr_regs),
        .rs2_addr   (rs2_addr_regs),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),


        //output
        .op1_ex      (op1_ex),
        .op2_ex      (op2_ex),
        .ins_2ex     (ins_ex_i),
        .rd_addr2ex  (rd_addr_ex),
        .oh_2ex      (oh_ex),
	    .rs1_addrtoex(rs1_addrtoex),
	    .rs2_addrtoex(rs2_addrtoex),
        .hold        (hold),
        .pc2ex       (pc2ex)
	    );


    regs regs_inst(
	    .clk             (clk),
	    .rst             (rst),
	    .rs1_addr        (rs1_addr_regs),
	    .rs2_addr        (rs2_addr_regs),
	    .rd_forward_data (rd_data_o),                     
	    .rd_forward_addr (rd_addr_ex2regs),
	    .rd_wen          (rd_wen_o),
	    .rs1_data        (rs1_data),
	    .rs2_data	     (rs2_data)
    );
    ex ex_inst(
        //input
	    .ins            (ins_ex_i),
	    .op1            (op1_ex),    
	    .op2            (op2_ex),    
	    .rd_addr2ex     (rd_addr_ex),  
	    .oh             (oh_ex),
        .pc2ex          (pc2ex),
        //output        
	    .rd_addr        (rd_addr_ex2regs),
	    .rd_data        (rd_data_o),
	    .rd_wen2reg     (rd_wen_o),
        .jump_addr2ctrl (jump_addr),
        .jump_en2ctrl   (jump_en),
        .dispatch_threads(dispatch_threads),
        .hold2ctrl      (hold2ctrl)
    );


endmodule

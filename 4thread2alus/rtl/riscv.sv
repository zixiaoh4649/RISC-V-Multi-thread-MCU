import types::*;
module riscv(
    input wire clki,
    input wire rsti,

    output wire [31:0] pc2rom[NUM_Threads-1:0],
    input  wire [31:0] rom_ins[NUM_Threads-1:0]
);

    wire [31:0] pc_o[NUM_Threads-1:0];
    // dispatch
    wire[2:0]  dispatch_threads[NUM_ALUs-1:0]; 
    wire [6:0] oh_dispatch[NUM_Threads-1:0];
    wire [31:0] ins_todispatch[NUM_Threads-1:0];
    //from ifetch 
    wire [31:0] ins2id[NUM_Threads-1:0];
    wire [31:0] ins_addr[NUM_Threads-1:0];
    //to if_id

    //from if_id
    wire [31:0] ins_addr2id[NUM_Threads-1:0];
    wire [31:0] ins[NUM_Threads-1:0]; 
    wire [31:0] pc2id_ex[NUM_Threads-1:0];
    //to id
    
    //from id to regs
    wire [4:0]  rs1_addr_regs[NUM_Threads-1:0];
    wire [4:0]  rs2_addr_regs[NUM_Threads-1:0];
    wire [31:0]  rs1_data[NUM_Threads-1:0];
    wire [31:0]  rs2_data[NUM_Threads-1:0];

    //from id
    wire [31:0] ins2ex[NUM_Threads-1:0];
    wire [31:0] ins_addr_id2idex[NUM_Threads-1:0];
    wire [31:0] op1[NUM_Threads-1:0];
    wire [31:0] op2[NUM_Threads-1:0];
    wire [4:0]  rd_addr[NUM_Threads-1:0];
    wire        rd_wen[NUM_Threads-1:0];
    wire [6:0]  oh_id2idex[NUM_Threads-1:0];
    //to id_ex

    //from id_ex
    wire [31:0] op1_ex[NUM_Threads-1:0];
    wire [31:0] op2_ex[NUM_Threads-1:0];
    wire [31:0] ins_addr2ex[NUM_Threads-1:0];
    wire [31:0] ins_ex_i[NUM_Threads-1:0];
    wire [4:0]  rd_addr_ex[NUM_Threads-1:0];
    wire        rd_wen_ex[NUM_Threads-1:0];
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
    wire        jump_en2ctrl[NUM_Threads-1:0];
    wire [31:0] jump_addr2ctrl[NUM_Threads-1:0];

    //from ctrl to other
    wire        hold[NUM_Threads-1:0];
    wire        jump_en[NUM_Threads-1:0];
    wire [31:0] jump_addr[NUM_Threads-1:0];



    pc_reg pc_reg_inst0 (
        .clk        (clki),
        .rst        (rsti),
        .pc_o       (pc_o),
        .hold       (hold),
	    .jump_addr  (jump_addr),
	    .jump_en    (jump_en),
        .dispatch_threads(dispatch_threads)
    );

    ifetch ifetch_inst (
        .pc_o    (pc_o),
        .rom_ins (rom_ins),
        .pc2rom  (pc2rom),
        .ins2id  (ins2id),
        .ins_addr(ins_addr) //for later branch addr calculate
        
    );


    if_id if_id_ins(
        .clk        (clki),
        .rst        (rsti),
        .ins2id     (ins2id),
        .ins_addr   (ins_addr),
        .ins_addr2id(ins_addr2id),
        .ins        (ins),
        .pc2rom  (pc2rom),
        .pc2id_ex    (pc2id_ex),
        .hold       (hold)
    );


    id id_inst(
        .ins_addr2id(ins_addr2id),
        .ins        (ins),
        .rs1_addr   (rs1_addr_regs),
        .rs2_addr   (rs2_addr_regs),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .op1        (op1),
        .op2        (op2),
        .ins2ex     (ins2ex),
        .ins_addr   (ins_addr_id2idex),
        .rd_addr    (rd_addr),    
        .rd_wen     (rd_wen),
        .oh         (oh_id2idex) 
	    );


    regs regs_inst(
	    .clk             (clki),
	    .rst             (rsti),
	    .rs1_addr        (rs1_addr_regs),
	    .rs2_addr        (rs2_addr_regs),
	    .rd_forward_data (rd_data_o),                     
	    .rd_forward_addr (rd_addr_ex2regs),
	    .rd_wen          (rd_wen_o),
	    .rs1_data        (rs1_data),
	    .rs2_data	     (rs2_data)
    );

    
    id_ex id_ex_inst(
        //input
        .clk         (clki),
        .rst         (rsti),
        .op1         (op1),
        .op2         (op2),
        .ins2ex      (ins2ex),
        .ins_addr    (ins_addr_id2idex),
        .rd_addr     (rd_addr),
        .rd_wen      (rd_wen),
        .oh_in       (oh_id2idex),
	    .rs1_addr        (rs1_addr_regs),
	    .rs2_addr        (rs2_addr_regs),
        //output
        .op1_ex      (op1_ex),
        .op2_ex      (op2_ex),
        .ins         (ins_ex_i),
        .ins_addr2ex (ins_addr2ex),
        .rd_addr2ex  (rd_addr_ex),
        .rd_wen2ex   (rd_wen_ex),
        .oh          (oh_ex),
        .pc2id_ex    (pc2id_ex),
        .pc2ex       (pc2ex),
	    .rs1_addrtoex        (rs1_addrtoex),
	    .rs2_addrtoex        (rs2_addrtoex),
        .hold        (hold)

    );

 
    ex ex_inst(
        //input
            .clk        (clki),
            .rst        (rsti),
	    .ins            (ins_ex_i),
	    .ins_addr2ex    (ins_addr2ex),
	    .op1            (op1_ex),    
	    .op2            (op2_ex),    
	    .rd_addr2ex     (rd_addr_ex), 
	    .rd_wen         (rd_wen_ex),  
	    .oh             (oh_ex),
        .rs1_addr       (rs1_addrtoex),
        .rs2_addr       (rs2_addrtoex),
        //output        
	    .rd_addr        (rd_addr_ex2regs),
	    .rd_data        (rd_data_o),
	    .rd_wen2reg     (rd_wen_o),
        .jump_addr2ctrl (jump_addr2ctrl),
        .jump_en2ctrl   (jump_en2ctrl),
        .hold2ctrl      (hold2ctrl),   
        .dispatch_threads (dispatch_threads),
        .oh_dispatch    (oh_dispatch),
        .ins_todispatch(ins_todispatch),
        .pc2ex          (pc2ex)
    );


    ctrl ctrl_inst(
        .hold2ctrl      (hold2ctrl),
        .jump_en2ctrl   (jump_en2ctrl),
        .jump_addr2ctrl (jump_addr2ctrl),
        .hold           (hold),
        .jump_en        (jump_en),
        .jump_addr      (jump_addr)
    );

     dispatch dispatch_ex(
        .clk         (clki),
        .rst         (rsti),
        .oh_in    (oh_dispatch),
        .ins      (ins_todispatch),
        .dispatch_threads(dispatch_threads)
    );

endmodule
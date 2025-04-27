`timescale 1ns/100ps
import types::*;
module Testbench;

	reg clk;
	reg rst;

wire [31:0] pc_t0 = Testbench.RISCV_soc_inst.riscv_inst.pc_o[0];
wire [31:0] pc_t1 = Testbench.RISCV_soc_inst.riscv_inst.pc_o[1];
wire [31:0] pc_t2 = Testbench.RISCV_soc_inst.riscv_inst.pc_o[2];
wire [31:0] pc_t3 = Testbench.RISCV_soc_inst.riscv_inst.pc_o[3];
wire [6:0]  oh[NUM_ALUs-1:0] = Testbench.RISCV_soc_inst.riscv_inst.ex_inst.oh_to_ALU[NUM_ALUs-1:0];
wire jump_en[NUM_ALUs-1:0]   = Testbench.RISCV_soc_inst.riscv_inst.ex_inst.jump_en2ctrl[NUM_ALUs-1:0];
wire [2:0] dispatch_threads[NUM_ALUs-1:0] = Testbench.RISCV_soc_inst.riscv_inst.dispatch_threads[NUM_ALUs-1:0];

//localparam END_PC = 32'h00004000;   




	integer exec_count;
	integer i,e,a;
	integer clk_count;
	integer branch_taken_count;


	always #3 clk = ~clk;

	RISCV_soc RISCV_soc_inst(
		.clk(clk),
		.rst(rst)
	);


	initial begin
		clk<= 1'b1;
		rst<= 1'b0;

		#12;

		rst <= 1'b1;
	end


	always @(posedge clk) begin	

		if (~rst)begin
		clk_count <= 0;      
		end else begin
				clk_count <= clk_count + 1; 
		end
	end

    always @(*)begin
		e=0;
        for (i = 0; i < NUM_ALUs; i = i + 1) begin
            if(dispatch_threads[i] < 3'd4 && (oh[i]!=7'd0))
               e++;
		end
	end
 
	always @(posedge clk) begin
      if (~rst)
		exec_count <= 0;
	  else 
	    exec_count <= exec_count + e;
   end
    always @(*) begin
		a=0;
		for(i=0;i<NUM_ALUs; i++)begin
			if(oh[i]>= 7'd5 && oh[i] <= 7'd10 && jump_en[i])
				a++;
			else if(oh[i]== 7'd3 || oh[i]== 7'd4)
			    a++;
		end
	end
    always @(posedge clk )begin
		if(~rst)
		branch_taken_count <= 0;
		else 
		branch_taken_count <= branch_taken_count + a;
	end

	real ipc;
	real branch_taken_rate;
	initial begin
		#3500
		ipc = exec_count * 1.0 / clk_count; 
		branch_taken_rate = branch_taken_count * 1.0  / exec_count;
		$display("Total branch count: %0d", branch_taken_count);
		$display("Total branch rate: %f", branch_taken_rate);
		$display("Total inst count: %0d", exec_count);
		$display("Total cycles: %0d", clk_count);
		$display("IPC = %0f", ipc);
        $finish;   
	end



	initial begin
		$readmemh("C:/VHDL practice/ECE511 final project/RISCV-main/inst_txt/bench_t50.hex", Testbench.RISCV_soc_inst.rom_inst.rom_mem[0]);
	end
	initial begin
		$readmemh("C:/VHDL practice/ECE511 final project/RISCV-main/inst_txt/bench_t70.hex", Testbench.RISCV_soc_inst.rom_inst.rom_mem[1]);
	end
	initial begin
		$readmemh("C:/VHDL practice/ECE511 final project/RISCV-main/inst_txt/bench_t70.hex", Testbench.RISCV_soc_inst.rom_inst.rom_mem[2]);
	end
	initial begin
		$readmemh("C:/VHDL practice/ECE511 final project/RISCV-main/inst_txt/bench_t90.hex", Testbench.RISCV_soc_inst.rom_inst.rom_mem[3]);
	end




	
    initial begin
		$display("Simulation Start: %0t", $time);
        $dumpfile("waveform.vcd");  
        $dumpvars(0, Testbench.RISCV_soc_inst.riscv_inst);     
    end




endmodule
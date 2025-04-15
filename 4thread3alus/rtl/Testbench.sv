`timescale 1ns/100ps
import types::*;
module Testbench;

	reg clk;
	reg rst;

	wire x3_thread0  = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[3][0];
	wire x26_thread0 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[26][0];
	wire x27_thread0 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[27][0];

	wire x3_thread1  = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[3][1];
	wire x26_thread1 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[26][1];
	wire x27_thread1 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[27][1];

	wire x3_thread2  = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[3][2];
	wire x26_thread2 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[26][2];
	wire x27_thread2 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[27][2];

	wire x3_thread3  = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[3][3];
	wire x26_thread3 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[26][3];
	wire x27_thread3 = Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[27][3];


	wire [2:0] dispatch_threads[NUM_ALUs-1:0] = Testbench.RISCV_soc_inst.riscv_inst.dispatch_threads[NUM_ALUs-1:0];

	integer exec_count;
	integer i;
	integer clk_count;
	integer a,b,c,d;

	// logic [2:0] dispatch_threads[NUM_ALUs-1:0];  //mod

	always #3 clk = ~clk;

	RISCV_soc RISCV_soc_inst(
		.clk(clk),
		.rst(rst)
		// .dispatch_threads(dispatch_threads)
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
		end else if (~(a==1 && b==1 && c==1 && d==1)) begin
				clk_count <= clk_count + 1; 
		end
	end



	always @(posedge clk) begin
      if (~rst)
		exec_count <= 0;
	  else 
        for (i = 0; i < NUM_ALUs; i = i + 1) begin
            if (dispatch_threads[i] < 3'd4)
               exec_count <= exec_count + 1;
        end     
   end



	real ipc;
	initial begin
		#10000;  
		ipc = exec_count * 1.0 / clk_count; 
		$display("Total inst count: %0d", exec_count);
		$display("Total cycles: %0d", clk_count);
		$display("IPC = %0f", ipc);

	end



	initial begin
		$readmemh("./inst_txt/current.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[0]);
	end
	initial begin
		$readmemh("./inst_txt/current.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[1]);
	end
	initial begin
		$readmemh("./inst_txt/current.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[2]);
	end
	initial begin
		$readmemh("./inst_txt/current.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[3]);
	end


	
	// initial begin
	// 	$readmemh("./inst_txt/rv32ui-p-addi.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[0]);
	// end
	// initial begin
	// 	$readmemh("./inst_txt/rv32ui-p-addi.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[1]);
	// end
	// initial begin
	// 	$readmemh("./inst_txt/rv32ui-p-addi.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[2]);
	// end
	// initial begin
	// 	$readmemh("./inst_txt/rv32ui-p-addi.txt", Testbench.RISCV_soc_inst.rom_inst.rom_mem[3]);
	// end

	
    initial begin
		$display("Simulation Start: %0t", $time);
        $dumpfile("waveform.vcd");  
        $dumpvars(0, Testbench.RISCV_soc_inst.riscv_inst);     
    end



initial begin
			a = 0;
			b=0;
			c=0;
			d=0;
end
	initial begin
			wait(x26_thread0 == 32'b1);
			
			#250;
			if(x27_thread0 == 32'b1)begin
				$display("@@@@ Thread0 pass @@@@");
				a = 1;
			end else begin
				$display("#########Thread0 fail#########");
				for(i=0;i<32;i=i+1)begin
					$display("Thread0: x%2d is %d", i, Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[i][0]);
				end
			end
			
	end
		initial begin
			wait(x26_thread1 == 32'b1);
			
			#250;
			if(x27_thread1 == 32'b1)begin
				$display("@@@@ Thread1 pass @@@@");
				b = 1;
			end else begin
				$display("#########Thread1 fail#########");
				for(i=0;i<32;i=i+1)begin
					$display("Thread1: x%2d is %d", i, Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[i][1]);
				end
			end
			
	end
			initial begin
			wait(x26_thread2 == 32'b1);
			
			#250;
			if(x27_thread2 == 32'b1)begin
				$display("@@@@ Thread2 pass @@@@");
				c = 1;
			end else begin
				$display("#########Thread2 fail#########");
				for(i=0;i<32;i=i+1)begin
					$display("Thread2: x%2d is %d", i, Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[i][2]);
				end
			end
			
	end
			initial begin
			wait(x26_thread3 == 32'b1);
			
			#250;
			if(x27_thread3 == 32'b1)begin
				$display("@@@@ Thread3 pass @@@@");
				d = 1;
			end else begin
				$display("#########Thread3 fail#########");
				for(i=0;i<32;i=i+1)begin
					$display("Thread13 x%2d is %d", i, Testbench.RISCV_soc_inst.riscv_inst.regs_inst.regs[i][3]);
				end
			end
			
	end



	time start_time, end_time;
	real elapsed_time;

	initial begin
    	start_time = $time; 
		wait(x26_thread0 == 32'b1);
		end_time = $time; 
		elapsed_time = (end_time - start_time) / 1000.0; 
		$display("Thread0 Time: %0f us", elapsed_time);
	end
	initial begin
    	start_time = $time; 
		wait(x26_thread1 == 32'b1);
		end_time = $time; 
		elapsed_time = (end_time - start_time) / 1000.0; 
		$display("Thread1 Time: %0f us", elapsed_time);
	end

	initial begin
    	start_time = $time; 
		wait(x26_thread2 == 32'b1);
		end_time = $time; 
		elapsed_time = (end_time - start_time) / 1000.0; 
		$display("Thread2 Time: %0f us", elapsed_time);
	end

	initial begin
    	start_time = $time; 
		wait(x26_thread3 == 32'b1);
		end_time = $time; 
		elapsed_time = (end_time - start_time) / 1000.0; 
		$display("Thread3 Time: %0f us", elapsed_time);
	end



endmodule
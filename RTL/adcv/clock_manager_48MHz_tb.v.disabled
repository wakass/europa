`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 us / 10 ns


module clockdcm_tb;
	parameter DURATION = 100;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		 # 17 reset = 1;
		 # 11 reset = 0;
		 # 29 reset = 1;
		 # 11 reset = 0;
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;
	always #5 clk = !clk;

	wire clk1;
	wire clk2;
	clockdcm c1(clk, clk1, clk2);

	initial
	 $monitor("At time %t, value = %h (%0d)",
			  $time, clk1, clk1);


	initial begin

	  //-- File were to store the simulation results
	  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
	  $dumpvars(0, clockdcm_tb);

	   #(DURATION) $display("End of simulation");
	  $finish;
	end
endmodule // test
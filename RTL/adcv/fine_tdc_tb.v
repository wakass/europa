`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 10 ns / 1 ps


module fine_tdc_tb;
	parameter DURATION = 100;
	parameter STAGES = 12;
	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		 # 50 reset = 1;
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;    //stop signal
	reg trigger =0; //start signal
	wire [STAGES-1:0] latched_output;

	always #5 clk = !clk;
	always #20 trigger = !trigger;

	wire clk1;
	wire clk2;
	fine_tdc #(.STAGES(STAGES)) c1(trigger, reset, clk, latched_output);

	initial
	 $monitor("At time %t, value = %h (%0d)",
			  $time, clk1, clk1);


	initial begin

	  //-- File were to store the simulation results
	  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
	  $dumpvars(0, fine_tdc_tb);

	   #(DURATION) $display("End of simulation");
	  $finish;
	end
endmodule // test
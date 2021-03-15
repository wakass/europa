`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 10 ns / 1 ps


module count_ones_tb;
	parameter DURATION = 100;
	// Parameters for one-counter
	parameter FROM_WIDTH = 16;
	parameter DOWNTO_WIDTH = 4;
	
	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		 # 10 bin = 16'b1111111;
		 # 15 bin = 16'b101010101010;
		 # 20 bin = 16'b100011100100;
		 # 25 bin = 16'b100100100000;
		 # 30 bin = 16'b000000000000;
		 # 50 reset = 1;
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;    //stop signal
	always #5 clk = !clk;

	reg  [FROM_WIDTH-1:0] bin = 16'hff;
	wire [DOWNTO_WIDTH-1:0] count;

	count_ones #(.from(FROM_WIDTH), .downto(DOWNTO_WIDTH)) cnt(bin, count);


	initial begin

	  //-- File were to store the simulation results
	  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
	  $dumpvars(0, count_ones_tb);

	   #(DURATION) $display("End of simulation");
	  $finish;
	end
endmodule // test
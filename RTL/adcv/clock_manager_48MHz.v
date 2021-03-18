module clock_dcm
	(
		// input  clk, reset,
		input  clk,
		input  reset,
		output clock_48MHz,
		output clock_48MHz_inv
	);
	
	// -- Generating a 48MHz clock using internal oscillator
	wire int_osc;
    SB_HFOSC u_SB_HFOSC (
    	.CLKHFPU(1'b1), 
    	.CLKHFEN(1'b1), 
    	.CLKHF(int_osc));

	// -- Output buffering
    wire clk_48MHz_dcm_buf;
	wire clk_48MHz_dcm_inv_buf;

	SB_GB clkout_48MHz_buf(int_osc, clk_48MHz_dcm_buf);
	SB_GB clkout_48MHz_inv_buf(~int_osc, clk_48MHz_dcm_inv_buf);
	
	//In simulation just take the regular clock.
	`ifdef SIMULATION
		assign clock_48MHz     = clk;
		assign clock_48MHz_inv = ~clk;

	`else
	assign clock_48MHz     = clk_48MHz_dcm_buf;
	assign clock_48MHz_inv = clk_48MHz_dcm_inv_buf;
	`endif
endmodule
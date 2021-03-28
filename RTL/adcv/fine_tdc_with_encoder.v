module fine_tdc_with_encoder 
	# (
		parameter STAGES    = 256, //Number of TDC carry stages
		parameter FINE_BITS	= 8,   //Bit-size of representation
		parameter Xoff		= 8,   //Layout parameters for Synthesis
		parameter Yoff		= 24)
	 (
		input clock,
		input reset,	
		input hit,	
		output [(FINE_BITS-1):0] value_fine
		);

	wire filtered_hit_1;
	wire filtered_hit_2;
	wire filtered_hit;
	wire fired;
	wire valid;

	wire [STAGES-1:0]    fine_value_reg;


	SB_DFFER input_filter1 (
			.Q(filtered_hit_1),
			.R(filtered_hit_1),
			.D(1'b1),
			.C(hit),
			.E(1'b1)
			);
			
	SB_DFFER input_filter2 (
			.Q(filtered_hit_2),
			.R(filtered_hit_1),
			.D(1'b1),
			.C(clock),
			.E(1'b1)
			);

	assign filtered_hit = ~filtered_hit_2;

	SB_DFFER input_filter_fired1 (
			.Q(fired),
			.R(1'b0),
			.D(filtered_hit),
			.C(clock),
			.E(1'b1)
			);
			
	SB_DFFER input_filter_fired2 (
			.Q(valid),
			.R(1'b0),
			.D(fired),
			.C(clock),
			.E(1'b1)
			);

	fine_tdc #(.STAGES(STAGES),.Xoff(Xoff),.Yoff(Yoff)) fine (
		.trigger(filtered_hit),
		.clock(clock),
		.reset(reset),
		.latched_output(fine_value_reg)
		);
	
	therm2bin_pipeline_count #(.b(FINE_BITS)) t2b
		(
			.clock(clock),
			.reset(reset),
			.valid(valid),
			.thermo(fine_value_reg),
			.bin(value_fine)
		);
	
endmodule

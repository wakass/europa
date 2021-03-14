
module therm2bin_pipeline_count
	#(parameter b = 8)
    (
		input clock,
		input reset,
		input valid,
		input [((2**b)-1):0] thermo,
		output [(b-1):0] bin
    );
    reg [((2**b)-1):0] data_reg;
	initial data_reg = ((2**b)-1)'b1;

	assign thermo = data_reg;

endmodule
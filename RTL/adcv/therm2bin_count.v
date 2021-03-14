
module therm2bin_pipeline_count
	#(parameter b = 8)
    (
		input clock,
		input reset,
		input valid,
		input [((2**b)-1):0] thermo,
		output [(b-1):0] bin
    );
    reg [((2**b)-1):0] thermo_reg;
    reg [(b-1):0] bin_reg;
	initial begin
		thermo_reg <= 'b1;
		bin_reg <= 'b1;
	end

	assign thermo = thermo_reg;
	assign bin = bin_reg;

endmodule
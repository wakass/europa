
module count_ones
	#(parameter from = 16, parameter downto = 4)
    (
		input [from-1:0] bin,
		output [downto-1:0] count_out
    );

reg [downto-1:0] count;
integer i;
always @(*) begin : counter
	count = 0;
	for (i = 0; i <= (from-1); i=i+1) begin
		if (bin[i])
			count = count+1;
		else
			count = count;
	end
end

assign count_out = count;
endmodule
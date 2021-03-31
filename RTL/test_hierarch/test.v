module top(input clk, input d, output wire q1, output wire q2);
    stuff #(.t(1)) lefti(clk, d, q1);
    stuff #(.t(2)) righti(clk, d, q2);
endmodule

(* keep_hierarchy *)
module stuff #(parameter t=2) (input clk, input d, output reg q);
    // always @(posedge clk)
        // q <= d;
genvar j;
    for (j=0; j <= 2; j=j+1) begin
	SB_DFFSR FDR_2 (
		.Q(q[0]),
		.C(clk),
		.D(d),
		.R(1'b0)
	);
end//latch

endmodule
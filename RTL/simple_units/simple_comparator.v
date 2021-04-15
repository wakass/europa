module simple_sens #(
  )(
  input EU_BUTTON1,
  output EU_AU_1,
  input EU_A1
);

wire clk;
wire lf_osc;
wire comp_out;
reg simple_latch;
reg  [4:0]  lf_counter_i;

always @(posedge lf_osc) begin
  if (simple_latch)
    lf_counter_i <= lf_counter_i + 1'b1;
end

// always @(posedge comp_out or negedge comp_out) begin
always @(comp_out) begin
  if (comp_out)
    simple_latch <= 'b1;
  else
    simple_latch <= 'b0;
end

assign EU_AU_1 = lf_counter_i[4]; 

SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

(*keep*)
SB_IO  comparator (
    .PACKAGE_PIN (EU_A1), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_1(comp_out)
    );



endmodule
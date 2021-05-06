module simple_clkout #(
  )(
  input EU_BUTTON1,
  output wire EU_AU_1,   //Output wire for audio on europa
  input  wire EU_A1,      //Analog in for measurement, VREF is hardware implied

  output wire EU_REF_CLK //CLK for ramp output
  // output wire digital_out
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

// always @(comp_out) begin
always @(posedge comp_out or posedge EU_BUTTON1) begin
    if (EU_BUTTON1)
      simple_latch <= 'b0;
  else if (comp_out)
    simple_latch <= 'b1;
end

always @(EU_BUTTON1) begin
    simple_latch <= ~EU_BUTTON1;
end

assign EU_AU_1 = lf_counter_i[4]; 

SB_HFOSC u_led_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
defparam u_led_osc.CLKHF_DIV = "0b11"; //6MHz
SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));


(*keep*)
SB_IO  comparator (
    .PACKAGE_PIN (EU_A1), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_0(comp_out)
    );

  defparam comparator.IO_STANDARD = "SB_LVDS_INPUT";
  defparam comparator.PIN_TYPE = 6'b000000;

  // ODDR buffer for the clock to create the reference ramp outside the FPGA
  SB_IO clk_buf ( 
      .D_OUT_0 (1'b1),                
      .D_OUT_1 (1'b0),
      .OUTPUT_CLK (clk),
      .PACKAGE_PIN (EU_REF_CLK)
    );
  defparam clk_buf.PULLUP = 1'b0;
  defparam clk_buf.PIN_TYPE = {4'b0100,2'b00};
  defparam clk_buf.IO_STANDARD = "SB_LVCMOS";

endmodule
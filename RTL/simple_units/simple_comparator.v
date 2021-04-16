module simple_comparator #(
  )(
  input EU_BUTTON1, //Simple button input
  input EU_BUTTON2, //Second button
  output EU_AU_1, //Audio output
  input EU_A0,     //Analog input
  output EU_REF_CLK   //External output for clk to generate ramp
);


wire lf_osc;
wire hf_osc;

wire trigger;
reg COMP_TRIGGERED;

reg  [5:0]  lf_counter_i;

always @(posedge lf_osc) begin
  if (COMP_TRIGGERED || EU_BUTTON1)
    lf_counter_i <= lf_counter_i + 1'b1;
end

always @(posedge trigger, posedge EU_BUTTON2) begin
  if (trigger)
    COMP_TRIGGERED <= 'b1;
  else
    COMP_TRIGGERED <= 'b0;
end

assign EU_AU_1 = lf_counter_i[5];

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(hf_osc));
defparam u_SB_HFOSC.CLKHF_DIV = "0b11"; //6MHz

SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

(*keep*)
SB_IO  comparator (
    .PACKAGE_PIN (EU_A0), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_0(trigger),
    //.INPUT_CLK(hf_osc),
    .LATCH_INPUT_VALUE(1'b0)
    );
defparam comparator.IO_STANDARD = "SB_LVDS_INPUT";
//This PIN_TYPE value routes the diff input value to the d_in_0
//it also conventiently bypasses the flipflops that are clock-driven. Bye bye input_clk
defparam comparator.PIN_TYPE = 6'b000001; 

// SB_IO clk_buf ( 
//     .D_OUT_0 (1'b1),
//     .D_OUT_1 (1'b0),
//     .OUTPUT_CLK (hf_osc),
//     .PACKAGE_PIN (EU_REF_CLK)
//   );
// defparam clk_buf.PIN_TYPE = {4'b0100,2'b00};

//Drop the clock down to 3 MHz for easier scoping
reg clk_3M;
always @(posedge hf_osc)
  clk_3M <= clk_3M + 1'b1;
SB_IO clk_buf ( 
    .D_OUT_0 (clk_3M),
    .OUTPUT_CLK (hf_osc),
    .PACKAGE_PIN (EU_REF_CLK)
  );
defparam clk_buf.PIN_TYPE = {4'b0101,2'b00};

defparam clk_buf.IO_STANDARD = "SB_LVCMOS";

endmodule
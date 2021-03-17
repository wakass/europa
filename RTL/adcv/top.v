module top #(
    parameter STAGES    =512,
    parameter FINE_BITS = 9,
    parameter Xoff_TDC1 = 34,
    parameter Xoff_TDC2 = 52,
    parameter Yoff      = 32
)
(
    input user_reset,  
    input clk_in,      // input 200 MHz clock
    output clk_out,    // clock to generate ramp 
    input V_IN,        // the analog input signal
    input V_REF,       // the reference input signal (ramp)
    output [FINE_BITS:0] digital_out
);

  wire comp_out;
  
  wire [FINE_BITS : 0] value_fine_1;
  wire [FINE_BITS : 0] value_fine_2;

  wire clock_200MHz;
  wire clock_200MHz_inv;

  SB_IO #(.IO_STANDARD("SB_LVDS_INPUT"), .PIN_TYPE(6'b000000)) comparator (
    .PACKAGE_PIN (V_REF), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_0(comp_out)
    );

endmodule
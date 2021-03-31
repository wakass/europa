module adcv #(
    parameter STAGES    = 64,//256,
    parameter FINE_BITS = 7,//9
    parameter Xoff_TDC1 = 34,
    parameter Xoff_TDC2 = 52,
    parameter Yoff      = 32
)
(
    `ifdef SIMULATION
    input hit,
    `endif
    input user_reset,  
    input  clk_in,      // input 200 MHz clock
    output clk_out,     // clock to generate ramp 
    input wire V_IN,         // the analog input signal, implied
    // input wire V_REF,        // the reference input signal (ramp)
    output [FINE_BITS:0] digital_out
);
  wire comp_out;  
  wire [FINE_BITS : 0] value_fine_1;
  wire [FINE_BITS : 0] value_fine_2;

  wire clock_48MHz;
  wire clock_48MHz_inv;

  // reg [FINE_BITS:0] temp = 9'd0;
  // always @(*)
    // digital_out[FINE_BITS:0] = 9'd255 - value_fine_2 + value_fine_1;
  // assign digital_out = temp;
  assign digital_out[6:0] = 255 - value_fine_2 + value_fine_1;

  `ifdef SIMULATION
  assign comp_out = hit;
  `else
  
  SB_IO  comparator (
    .PACKAGE_PIN (V_IN), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_1(comp_out)
    );

  defparam comparator.IO_STANDARD = "SB_LVDS_INPUT";
  defparam comparator.PIN_TYPE = 6'b000000;

  `endif
  fine_tdc_with_encoder #(
      .STAGES     (STAGES),
      .FINE_BITS  (FINE_BITS),
      .Xoff       (Xoff_TDC1),
      .Yoff       (Yoff)
      )
    TDC1 (  
      .clock      (clock_48MHz),
      .reset      (user_reset),
      .hit        (comp_out),
      .value_fine (value_fine_1[FINE_BITS-1 : 0]) 
      );

  fine_tdc_with_encoder #(
    .STAGES     (STAGES),
    .FINE_BITS  (FINE_BITS),
    .Xoff       (Xoff_TDC2),
    .Yoff       (Yoff)
    )
  TDC2 (  
    .clock      (clock_48MHz_inv),
    .reset      (user_reset),
    .hit        (~comp_out),
    .value_fine (value_fine_2[FINE_BITS-1 : 0]) 
    );

  // ODDR buffer for the clock to create the reference ramp outside the FPGA
  SB_IO clk_buf ( 
      .D_OUT_0 (1'b1),                
      .D_OUT_1 (1'b0),
      .OUTPUT_CLK (clock_48MHz_inv),
      .PACKAGE_PIN (clk_out)
    );
  defparam clk_buf.PULLUP = 1'b0;
  defparam clk_buf.PIN_TYPE = {4'b0100,2'b00};
  defparam clk_buf.IO_STANDARD = "SB_LVCMOS";

  clock_dcm clk_mapping
    (
     .clk            (clk_in),
     .reset          (user_reset),
     .clock_48MHz    (clock_48MHz),
     .clock_48MHz_inv(clock_48MHz_inv)
     );
endmodule
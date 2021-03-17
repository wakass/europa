module top #(
    parameter STAGES    =512,
    parameter FINE_BITS = 9,
    parameter Xoff_TDC1 = 34,
    parameter Xoff_TDC2 = 52,
    parameter Yoff      = 32
)
(
    //input user_reset,  
    //input clk_in,      // input 200 MHz clock
    //output clk_out,    // clock to generate ramp 
    //input V_IN,        // the analog input signal
    //input V_REF,       // the reference input signal (ramp)
    //output [FINE_BITS:0] digital_out
);
//To be defined physical wires/constraints
wire [FINE_BITS:0] digital_out;
wire user_reset;
wire clk_in;
wire clk_out;
wire V_IN;
wire V_REF;

  wire comp_out;  
  wire [FINE_BITS : 0] value_fine_1;
  wire [FINE_BITS : 0] value_fine_2;

  wire clock_48MHz;
  wire clock_48MHz_inv;

  assign digital_out  = FINE_BITS'd255 - value_fine_2 + value_fine_1;

  SB_IO #(.IO_STANDARD("SB_LVDS_INPUT"), .PIN_TYPE(6'b000000)) comparator (
    .PACKAGE_PIN (V_REF), //The second (differential) package pin is implied. The partner pin is determined by hardware.
    .D_IN_0(comp_out)
    );
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

  SB_GB_IO #(.PIN_TYPE(6'b010000)) clk_buf ( // ODDR buffer for the clock to create the reference ramp outside the FPGA
      .D_OUT_0 (1'b1),                
      .D_OUT_1 (1'b0),
      .OUTPUT_CLK (clock_48MHz_inv),
      .PACKAGE_PIN (clk_out)
      );

  clock_dcm clk_mapping
    (
     .clk            (clk_in),
     .reset          (user_reset),
     .clock_48MHz    (clock_48MHz),
     .clock_48MHz_inv(clock_48MHz_inv)
     );
endmodule
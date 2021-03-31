
module europa_blink #(
  parameter FINE_BITS = 7
  )(
  // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green,  // Green
  output wire EU_AU_1,   //Output wire for audio on europa
  
  output wire EU_REF_CLK, //CLK for ramp output
  input  wire EU_A1      //Analog in for measurement, VREF is hardware implied
  // output wire digital_out
);

  wire        int_osc            ;
  wire        lf_osc             ; 
  reg  [27:0] hf_counter_i;
  reg  [4:0]  lf_counter_i;

// (* keep *) 
  wire [FINE_BITS:0] digital_out;
  reg reset = 0;
  reg [FINE_BITS:0] latched;
  
  assign EU_AU_1[0] = digital_out[0]; //Hang this somewhere physical so it doesnt get optimized out

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillators                               --
//                                                                          --
//----------------------------------------------------------------------------
  SB_HFOSC u_led_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  defparam u_led_osc.CLKHF_DIV = "0b11"; //6MHz

  SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

  //clock at internal hf oscillator speed, reset at lf oscillator
  (* keep *) 
  adcv #(.FINE_BITS(FINE_BITS)) adc(reset, int_osc, EU_REF_CLK, EU_A1, digital_out);

//Drive all VREF input pins to one parameters
// SB_IO #(.PIN_TYPE(6'b000000)) all[2:0](
//   .PACKAGE_PIN ({  EU_AU_1_VREF,    EU_A1_VREF,    EU_A2_VREF})
//   );
//----------------------------------------------------------------------------
//                                                                          --
//                       Counters                                           --
//                                                                          --
//----------------------------------------------------------------------------

  always @(posedge int_osc) begin
    hf_counter_i <= hf_counter_i + 1'b1;
  end


always @(posedge lf_osc) begin
    lf_counter_i <= lf_counter_i + 3'd4;
end

// assign EU_AU_1 = lf_counter_i[4]; 

//----------------------------------------------------------------------------
//                                                                          --
//                       Instantiate RGB primitive                          --
//                                                                          --
//----------------------------------------------------------------------------
  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1                                            ),
    .RGB0PWM (hf_counter_i[25]&hf_counter_i[24] ),
    .RGB1PWM (hf_counter_i[25]&~hf_counter_i[24]),
    .RGB2PWM (~hf_counter_i[25]&hf_counter_i[24]),
    .CURREN  (1'b1                                            ),
    .RGB0    (led_green                                       ), //Actual Hardware connection
    .RGB1    (led_blue                                        ),
    .RGB2    (led_red                                         )
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule

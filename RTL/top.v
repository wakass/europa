
module europa_blink #(
  parameter FINE_BITS = 6,
  parameter STAGES = 64
  )(
  // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green,  // Green
  output wire EU_AU_0,   //Output wire for audio on europa
  
  output wire EU_REF_CLK, //CLK for ramp output
  input  wire EU_A0      //Analog in for measurement, VREF is hardware implied
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
  
//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillators                               --
//                                                                          --
//----------------------------------------------------------------------------
  SB_HFOSC u_led_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(hf_osc));
  defparam u_led_osc.CLKHF_DIV = "0b11"; //6MHz

  SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

  //clock at internal hf oscillator speed, reset at lf oscillator
  adcv #(.FINE_BITS(FINE_BITS), .STAGES(STAGES)) adc(reset, hf_osc, EU_REF_CLK, EU_A0, digital_out);
  // simple_ds #(.width(FINE_BITS)) dac(.din(digital_out),.clk(hf_osc), .bit_out(EU_AU_0));
//----------------------------------------------------------------------------
//                                                                          --
//                       Counters                                           --
//                                                                          --
//----------------------------------------------------------------------------

  always @(posedge int_osc) begin
    hf_counter_i <= hf_counter_i + 1'b1;
  end


always @(posedge lf_osc) begin
  if (reset) 
    reset <= 0;
  else 
    reset <= 1;

  if (digital_out[2])
    lf_counter_i <= lf_counter_i + 1'b1;
  else 
    lf_counter_i <= lf_counter_i + 2;
end

assign EU_AU_0 = lf_counter_i[4]; 

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

module simple_ds #(
    parameter width = 8
  )(
  input [width-1:0] din,
  input clk,
  output bit_out
);

reg [width + 1 : 0] accumulator;
wire[width + 1 : 0] delta;

wire[width - 1 : 0] ddc;

assign ddc = bit_out ? {(width){1'b1}} : {(width){1'b0}} ;
assign delta = din - ddc;

always @(posedge clk) begin
  accumulator <= accumulator + delta;
end

assign bit_out = accumulator[width+1]; //The significant bit acts as comparator

endmodule

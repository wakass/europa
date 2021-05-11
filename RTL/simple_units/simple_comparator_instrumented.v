module simple_comparator #(
  )(
    // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green,  // Green

  input EU_BUTTON0, //Simple button input
  input EU_BUTTON1, //Second button
  output EU_AU_0, //Audio output
  input  EU_A0,     //Analog input
  output EU_REF_CLK,   //External output for clk to generate ramp

  output serial_txd, 
  input serial_rxd
);


//**********
//
//  Logic analyser init and reset generation
//  
  wire     lareset;
  reg      por=1;
  reg      pordone=0;
  
  wire RS232_Tx, RS232_Rx;
  assign RS232_Tx=serial_txd;
  assign RS232_Rx=serial_rxd;

  // Generate a low sync edge on power up
  // If you have a user reset you could and/or it in the following assign
  assign lareset=por;

  always @(posedge hf_osc)
   if (pordone==1'b0)
     if (por==1'b1)
  begin
    por<=1'b0;
  end
     else
  begin
    por<=1'b1;
    pordone<=1'b1;
  end


//**********
//
//  Top definitions
//  
wire lf_osc;
wire hf_osc;

wire trigger;
reg COMP_TRIGGERED;

reg  [5:0]  lf_counter_i;

//**********
//
//  Oscillations, TRIGGERING from comparator high, reset by pressing button1
//  
always @(posedge lf_osc) begin
  if (COMP_TRIGGERED || EU_BUTTON0)
    lf_counter_i <= lf_counter_i + 1'b1;
end

always @(posedge trigger, posedge EU_BUTTON1) begin
  if (trigger)
    COMP_TRIGGERED <= 'b1;
  else
    COMP_TRIGGERED <= 'b0;
end

assign EU_AU_0 = lf_counter_i[5];

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(hf_osc));
// defparam u_SB_HFOSC.CLKHF_DIV = "0b11"; //6MHz

SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

wire la_armed, la_triggered;
// logic analyzer
top_of_verifla verifla(.clk(hf_osc),.cqual(1'b1),.rst_l(lareset), .sys_run(1'b0),
        .data_in({trigger,lf_counter_i}),
        .armed(la_armed),
        .triggered(la_triggered),
        .uart_XMIT_dataH(RS232_Tx),
        .uart_REC_dataH(RS232_Rx));

SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1                                            ),
    .RGB0PWM ((la_armed || la_triggered) ? lf_counter_i[4] : 1'b0),
    .RGB1PWM (~la_armed ? lf_counter_i[5] : 1'b0),
    .RGB2PWM (lareset ? lf_counter_i[4] : 1'b0),
    .CURREN  (1'b1                                            ),
    .RGB0    (led_green                                       ), //Actual Hardware connection
    .RGB1    (led_blue                                        ),
    .RGB2    (led_red                                         )
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

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
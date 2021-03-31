
module sbio_test (
  output wire gpio_2
);

  wire        int_osc;
  reg  [27:0] outreg;
  assign gpio_2 = outreg;

  SB_HFOSC u_led_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

  wire test;
  
  SB_IO 
    #(.IO_STANDARD("SB_LVDS_INPUT"),
      .PIN_TYPE(6'b000000)
      ) 
    comparator (.PACKAGE_PIN (gpio_31), .D_IN_1(test));

  always @(posedge int_osc) begin
    outreg[0] <= test;
  end


endmodule

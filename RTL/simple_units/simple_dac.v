//Demonstration module to show a swept Triangle wave being output on a delta sigma modulated DAC. A low pass filter might be required, but generally audio circuits already have a limited response. Plus..it's fun to hear weird sounds.

module top (
  output EU_AU_1,
  input EU_A1
  );
  parameter bit_width = 16;

  wire hf_osc;
  wire lf_osc;

  reg [bit_width - 1 : 0] lf_counter;
  reg [4:0] sweep_counter;
  reg [15:0] sweep;
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(hf_osc));
  SB_LFOSC u_SB_LFOSC (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(lf_osc));

  //Generate a sawtooth
  always @(posedge lf_osc) begin
    lf_counter <= lf_counter + sweep;
    sweep_counter <= sweep_counter + 1'b1;

    if (sweep_counter == 0) begin
      if (sweep > 'hFFF) begin
        sweep <= 'h0;
      end
      else begin
        sweep <= sweep + 1'b1;  
      end
    end

  end

  simple_dac #(.width(bit_width)) daccy(.din(lf_counter),.clk(hf_osc), .bit_out(EU_AU_1));

endmodule

module simple_dac #(
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
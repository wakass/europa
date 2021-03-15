
module therm2bin_pipeline_count
	#(parameter b = 8)
    (
		input clock,
		input reset,
		input valid,
		input [((2**b)-1):0] thermo,
		output [(b-1):0] bin
    );

	reg [b-1:0] stage_final_bin;
	reg [15:0]  stage_final;     //final bit counter, 16bit
	reg  [b-3:0] data_valid;
	
	// TYPE decoder_array IS ARRAY (0 TO b-4) OF std_logic_vector(((2**b)-2) DOWNTO 0);
    reg [(2**b)-2:0] decoding [0:b-4];
	
	// TYPE binary_array IS ARRAY (0 TO b-4) OF std_logic_vector(b DOWNTO 0);
    reg [b:0] binary [0:b-4];

	genvar i;
    for (i=0; i <= b-5; i=i+1) begin : generate_stages
	    always @(posedge clock, posedge reset)
	    begin
	    	if (reset == 'b1) begin
	    		decoding[i+1]   <= 0;
	    		binary[i+1]     <= 0;
	    		data_valid[i+1] <= 0;
     		end
     		else begin
     			binary[i+1][b : b-1-i] <=  binary[i][b : b-i] & decoding[i][((2**(b-i))-2)/2];
				data_valid[i+1]        <= data_valid[i];
				
				if (decoding[i][((2**(b-i))-2)/2] == 'b1)
					decoding[i+1][((2**(b-i))-2)/2-1 : 0] <= decoding[i][((2**(b-i))-2) : ((2**(b-i))-2)/2+1];
				else
					decoding[i+1][((2**(b-i))-2)/2-1 : 0] <= decoding[i][((2**(b-i))-2)/2-1 : 0];
	  		end
	    end
    end
	
	assign stage_final = decoding[b-4][15 : 0];

	wire [b-1:0] final_count;
	count_ones #(.from((2**b)), .downto(b)) cnt(stage_final, final_count);

	always @(posedge clock, posedge reset) begin
		if (reset == 1) begin
			stage_final_bin <= 'b0;
			data_valid[b-3] <= 'b0;
		end
		else begin
			stage_final_bin <=  binary[b-4][b-1 : 4] & final_count;
			data_valid[b-3] <= data_valid[b-4];

		end
	end

	always @(posedge clock) begin
		if (data_valid[b-3])
			bin <= stage_final_bin;
		else 
			bin <= 'b0;
			
	end

endmodule
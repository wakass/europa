

module fine_tdc 
	#(
		parameter STAGES = 5,
		parameter Xoff = 5,
		parameter Yoff = 5
		)
	(
		input trigger,	    // START signal input (triggers carrychain)
		input reset,		
		input clock,		// STOP signal input (assumed to be clock synchronous)
		output [(STAGES-1):0] latched_output //Carrychain output, to be converted to binary
	);

genvar i,j;
//reg SamplePhase_90 /* synthesis COMP= SamplePhase_90 LOC="R2C14B" */;
wire [STAGES-1:0] unreg;
wire [STAGES-1:0] register;

//generate carry_delay_line
for (i = 0; i <= (STAGES-1); i=i+1) begin

	if (i == 0)
		SB_CARRY my_carry_inst (
		      .CO(unreg[0]),
		      .I0(1'b0),
		      .I1(1'b1),
		      .CI(trigger));
	
	if (i > 0)
		SB_CARRY my_carry_inst (
		      .CO(unreg[i]),
		      .I0(1'b0),
		      .I1(1'b1),
		      .CI(unreg[i-1]));

end //carry_delay_line

//latch for stability
for (j=0; j <= STAGES-1; j=j+1) begin
	SB_DFFR FDR_1 (
		.Q(register[j]),
		.C(clock),
		.D(unreg[j]),
		.R(reset)
	);
	SB_DFFR FDR_2 (
		.Q(latched_output[j]),
		.C(clock),
		.D(register[j]),
		.R(reset)
	);
end//latch

endmodule
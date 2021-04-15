(* keep_hierarchy *)
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
for (i = 0; i <= (STAGES-1); i=i+1) begin : carry_delay_line

	if (i == 0)(* BEL="X9/Y1/lc5", keep *) //As good a place as any to start
		SB_CARRY my_carry_inst (
		      .CO(unreg[0]), //Carry out
		      .I0(1'b0),     //I0
		      .I1(1'b1),     //I1
		      .CI(trigger)); //Carry in
	
	if (i > 0) (*  keep *)
		SB_CARRY my_carry_inst (
		      .CO(unreg[i]),
		      .I0(1'b0),
		      .I1(1'b1),
		      .CI(unreg[i-1]));

end //carry_delay_line

//latch for stability
for (j=0; j <= STAGES-1; j=j+1) begin
	SB_DFFSR FDR_1 (
		.Q(register[j]),
		.C(clock),
		.D(unreg[j]),
		.R(reset)
	);
	SB_DFFSR FDR_2 (
		.Q(latched_output[j]),
		.C(clock),
		.D(register[j]),
		.R(reset)
	);
end//latch

endmodule
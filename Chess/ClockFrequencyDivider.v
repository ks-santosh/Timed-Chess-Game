module ClockFrequencyDivider #(
	parameter INPUT_FREQUENCY = 50000000,
	parameter FREQUENCY_WIDTH = 26,
	parameter OUTPUT_FREQUENCY = 1,
	parameter COUNT_MAX = INPUT_FREQUENCY/OUTPUT_FREQUENCY
) (

   /* INPUTS */
    input InClock,
	input reset,
   /* OUTPUTS */
    output reg OutClock
); 

wire [FREQUENCY_WIDTH - 1:0] ClockCount;

// CounterNBit module to count to Max_Value
UpCounterNbit #(
	.WIDTH			(FREQUENCY_WIDTH   	),
	.MAX_VALUE	  	(COUNT_MAX			)

) ClockCounter (
	.clock		  	(InClock		),
	.reset	  		(reset		),
	.enable      	(1'b1		),
	.countValue	    (ClockCount	)
);

// Clock division logic
always @(posedge InClock or posedge reset) begin
	if(reset) begin
		OutClock <= 1'b0;
	end else begin
		if (ClockCount == COUNT_MAX-1) begin
			OutClock <= ~ OutClock; // Toggle output clock
		end
    end
end
endmodule

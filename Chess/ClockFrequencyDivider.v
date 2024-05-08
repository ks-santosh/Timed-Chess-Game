/*
 * ClockFrequencyDivider
 * ----------------
 * By: Yuehan You
 * Date: 26/04/2024
 *
 * Short Description
 * -----------------
 * The ClockFrequencyDivider module is responsible for dividing 
 * the input clock frequency by a specified factor to generate 
 * a reduced frequency output clock signal. 
 *
 */
module ClockFrequencyDivider #(
	parameter INPUT_FREQUENCY = 50000000,
	parameter FREQUENCY_WIDTH = 26,
	parameter OUTPUT_FREQUENCY = 1,
	parameter COUNT_MAX = (INPUT_FREQUENCY/OUTPUT_FREQUENCY)/2
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
	.WIDTH			(FREQUENCY_WIDTH),
	.MAX_VALUE	  	(      COUNT_MAX)

) ClockCounter (
	// connection for UpCounterNbit
	.clock		  	(       InClock),	// clock
	.reset	  		(         reset),	// reset counter
	.enable      	(          1'b1),	// enable counter
	.countValue	   (    ClockCount)	// count value
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

module CountdownTimer #( 
	parameter MINUTES = 5;
	parameter SECONDS = 0;
)(
    input clock,  // Clock input
    input reset,  // Asynchronous reset input
    input flag,  // Start/pause control signal
    output [6:0] SegMins,  // Seven-segment display output for minutes
    output [6:0] SegSecTens,  // Seven-segment display output for tens of seconds
    output [6:0] SegSecUnits  // Seven-segment display output for units of seconds
);

ClockFrequencyDivider #(
	.OUTPUT_FREQUENCY(1)
) ClockFrequencyDivider (

    .InClock(clock),
	.reset(reset),
    .OutClock(OutClock)
); 

endmodule

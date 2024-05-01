module CountdownTimer #( 
	parameter MINUTES = 5;
	parameter SECONDS = 0;
	parameter TOTAL_SECONDS = MINUTES*60 + SECONDS;
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
) ClockSeconds (

   .InClock(clock),
	.reset(reset),
   .OutClock(OutClock)
); 
	
reg [9:0] SecondsLeft;
reg [6:0] Minutes;
reg [6:0] Seconds;

    always @(posedge OutClock or posedge reset) begin
        if (reset) begin
            // Asynchronous reset logic
				SecondsLeft <= TOTAL_SECONDS;
            Minutes <= MINUTES;  // Reset minutes
            Seconds <= SECONDS;  // Reset seconds
				SegMins <= MINUTES;
				SegSecTens <= SECONDS/10;
				SegSecUnits <= SECONDS % 10;
        end else if (flag) begin
				// Countdown logic when flag is high
				SecondsLeft <= SecondsLeft - 1;
				Minutes <= SecondsLeft/60;
				Seconds <= SecondsLeft - (Minutes * 60);
				
				SegMins <= Minutes;
				SegSecTens <= Seconds/10;
				SegSecUnits <= Seconds % 10;
		  end
    end
	 
endmodule

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
	reg [6:0] Seconds, SecondsTens, SecondsUnits;

    // Instantiate seven-segment decoder modules
    SevenSegmentDisplay DisplayMins(
        .DecimalDigit(Minutes),
        .SegOutput(SegMins)
    );

    SevenSegmentDisplay DisplaySecTens(
        .DecimalDigit(SecondsTens),
        .SegOutput(SegSecTens)
    );

    SevenSegmentDisplay DisplaySecUnits(
        .DecimalDigit(SecondsUnits),
        .SegOutput(SegSecUnits)
    );


    always @(posedge OutClock or posedge reset) begin
        if (reset) begin
            // Asynchronous reset logic
				SecondsLeft <= TOTAL_SECONDS;
            Minutes <= MINUTES;  // Reset minutes
            Seconds <= SECONDS;  // Reset seconds
				SecondsTens <= SECONDS/10;
				SecondsUnits <= SECONDS % 10;
        end else if (flag) begin
				// Countdown logic when flag is high
				SecondsLeft <= SecondsLeft - 1;
				Minutes <= SecondsLeft/60;
				Seconds <= SecondsLeft - (Minutes * 60);
				
				SecondsTens <= Seconds/10;
				SecondsUnits <= Seconds % 10;
		  end
    end
	 
endmodule

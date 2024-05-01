module CountdownTimer #( 
	parameter MINUTES = 5,
	parameter SECONDS = 0
) (
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
	
	reg [6:0] Minutes;
	reg [6:0] Seconds;
	reg [6:0] SecondsTens; 
	reg [6:0] SecondsUnits;

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
            Minutes <= MINUTES;  // Reset minutes
            Seconds <= SECONDS;  // Reset seconds
				SecondsTens <= SECONDS/10;
				SecondsUnits <= SECONDS % 10;
        end else if (flag) begin
				// Countdown logic when flag is high
				if(Seconds == 0) begin
					Minutes <= Minutes - 1;
					Seconds <= 7'd59;
				end else begin
					Seconds <= Seconds - 1;
				end
				
				SecondsTens <= Seconds/10;
				SecondsUnits <= Seconds % 10;
		  end
    end
	 
endmodule

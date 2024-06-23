/*
 * CountdownTimer
 * ----------------
 * Date: 26/04/2024
 *
 * Short Description
 * -----------------
 * The SevenSegmentDisplay module is responsible for driving 
 * a seven-segment display to represent numeric digits from 0 to 9. 
 * It takes a 4-bit input representing the decimal value to be displayed 
 * and outputs the appropriate signals to illuminate the segments of the 
 * display accordingly. The module includes logic to decode the input value 
 * into the corresponding segment patterns required to display the digit. 
 * Each segment of the display is individually controlled, allowing for 
 * the visualization of various numerical values. 
 */
module CountdownTimer #( 
	parameter MINUTES = 5,
	parameter SECONDS = 0
) (
    input clock,  // Clock input
    input reset,  // Asynchronous reset input
    input flag,  // Start/pause control signal
    output [6:0] SegMins,  // Seven-segment display output for minutes
    output [6:0] SegSecTens,  // Seven-segment display output for tens of seconds
    output [6:0] SegSecUnits,  // Seven-segment display output for units of seconds
	 output reg Timeout
);

wire OutClock;

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
        .SegOutput   (SegMins)
    );

    SevenSegmentDisplay DisplaySecTens(
        .DecimalDigit(SecondsTens),
        .SegOutput   ( SegSecTens)
    );

    SevenSegmentDisplay DisplaySecUnits(
        .DecimalDigit(SecondsUnits),
        .SegOutput   ( SegSecUnits)
    );


    always @(posedge OutClock or posedge reset) begin
        if (reset) begin
            // Asynchronous reset logic
            Minutes <= MINUTES;  // Reset minutes
            Seconds <= SECONDS;  // Reset seconds
				SecondsTens <= SECONDS/10;
				SecondsUnits <= SECONDS % 10;
				Timeout <= 1'b0;
        end else if (flag) begin
				// Countdown logic when flag is high
				if((Seconds == 0) && (Minutes == 0)) begin
					Timeout <= 1'b1;	// Set timeout if timer reaches 0
				end else if(Seconds == 0) begin
					Minutes <= Minutes - 1;	// decrement minutes by 1 if 60 seconds passed
					Seconds <= 7'd59;
				end else begin
					Seconds <= Seconds - 1; // decrement seconds every second
				end
				
				SecondsTens <= Seconds/10;    // value at tens place of seconds
				SecondsUnits <= Seconds % 10;	// valua at units place of seconds
		  end
    end
	 
endmodule

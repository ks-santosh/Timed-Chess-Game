/*
 * SevenSegmentDisplay
 * ----------------
 * By: Yuehan You
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
module SevenSegmentDisplay(
    input      [3:0] DecimalDigit,  // 4-bit binary input representing a decimal digit
    output reg [6:0] SegOutput      // 7-bit output for seven-segment display
);

    // Map the binary input to the corresponding seven-segment display code
    always @(*) begin
        case (DecimalDigit)
            4'd0: SegOutput = 7'b1000000; // Display "0"
            4'd1: SegOutput = 7'b1111001; // Display "1"
            4'd2: SegOutput = 7'b0100100; // Display "2"
            4'd3: SegOutput = 7'b0110000; // Display "3"
            4'd4: SegOutput = 7'b0011001; // Display "4"
            4'd5: SegOutput = 7'b0010010; // Display "5"
            4'd6: SegOutput = 7'b0000010; // Display "6"
            4'd7: SegOutput = 7'b1111000; // Display "7"
            4'd8: SegOutput = 7'b0000000; // Display "8"
            4'd9: SegOutput = 7'b0010000; // Display "9"
            default: SegOutput = 7'b1111111; // Turn off all segments
        endcase
    end

endmodule


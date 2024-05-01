module CountdownTimer(
    input clk,  // Clock input
    input reset,  // Asynchronous reset input
    input flag,  // Start/pause control signal
    output [6:0] seg_min,  // Seven-segment display output for minutes
    output [6:0] seg_sec_tens,  // Seven-segment display output for tens of seconds
    output [6:0] seg_sec_units  // Seven-segment display output for units of seconds
);


endmodule

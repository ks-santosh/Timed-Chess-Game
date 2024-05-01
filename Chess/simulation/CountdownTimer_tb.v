`timescale 1 ns/1 ps

module CountdownTimer_tb();

	// Inputs
	reg clock;
	reg reset;
	reg flag;

	// Outputs
	wire [6:0] SegMins;
	wire [6:0] SegSecTens;
	wire [6:0] SegSecUnits;
	wire       Timeout;

    // Instantiate the CountdownTimer module
    CountdownTimer CountdownTimer_dut (
        .clock(clock),
        .reset(reset),
        .flag(flag),
        .SegMins(SegMins),
        .SegSecTens(SegSecTens),
        .SegSecUnits(SegSecUnits),
		.Timeout(Timeout)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock;  // Clock period of 20ns for 50MHz
    end

    // Test scenarios
    initial begin
        // Initialize Inputs
        reset = 1;  // Apply reset
        flag = 0;  // Ensure timer is paused
        #50;  // Wait 50ns for system to stabilize

        reset = 0;  // Release reset
        #50;  // Wait for some time

        // Start the countdown
        flag = 1;  // Start counting
        #1000000;  // Simulate for 1ms (should be adjusted based on clock cycles and expected output)

        // Pause the countdown
        flag = 0;  // Pause the timer
        #200000;  // Observe output for 200us while paused

        // Resume the countdown
        flag = 1;
        #500000;  // Continue for another 500us

        // Final pause before reset
        flag = 0;
        #100000;

        // Reset to initial conditions
        reset = 1;
        #100;  // Apply reset briefly

        $finish;  // Stop simulation
    end

    // Optional: Display the outputs to observe changes
    initial begin
        $monitor("Time = %t, SegMins = %b, SegSecTens = %b, SegSecUnits = %b", $time, SegMins, SegSecTens, SegSecUnits);
    end

endmodule

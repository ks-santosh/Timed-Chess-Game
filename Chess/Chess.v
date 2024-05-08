/*
 * Chess
 * ----------------
 * By: Santosh K S
 * Date: 22/04/2024
 *
 * Short Description
 * -----------------
 * The Chess module serves as the top-level entity which includes 
 * the functionality of the chess game implemented on an FPGA platform. 
 * It manages user inputs, game state transitions, and interfaces with 
 * external peripherals such as the LT24 display and countdown timers.
 * Internally, the Chess module instantiates the ChessEngine submodule,
 * which encapsulates the main game logic and processing. 
 *
 */
module Chess (

   /* INPUTS */
    input         clock,         // Clock
    input         globalReset,   // Global reset
    input         PlaySwitch,    // Switch to start and stop the game
    input         TimerSwitch,   // Switch to enable timer
    input         LockSwitch,    // Switch to lock a chess piece
    input         KeyLeft,       // Key to move left
    input         KeyUp,         // Key to move up
    input         KeyDown,       // Key to move down
    input         KeyRight,      // Key to move right
    
   /* OUTPUTS */
   /* LT24 Interfaces */
    output        LT24Wr_n,      // - Write Strobe (inverted)
    output        LT24Rd_n,      // - Read Strobe (inverted)
    output        LT24CS_n,      // - Chip Select (inverted)
    output        LT24RS,        // - Register Select
    output        LT24Reset_n,   // - LCD Reset
    output [15:0] LT24Data,      // - LCD Data
    output        LT24LCDOn,     // - LCD Backlight On/Off
    output        resetApp,      // - Application Reset
   
   /* Seven Segment Display Interfaces */ 
    output [ 6:0] WhiteClockMins,      // Hex[2]
    output [ 6:0] WhiteClockTensSec,   // Hex[1]
    output [ 6:0] WhiteClockUnitsSec,  // Hex[0]
    output [ 6:0] BlackClockMins,      // Hex[5]
    output [ 6:0] BlackClockTensSec,   // Hex[4]
    output [ 6:0] BlackClockUnitsSec   // Hex[3]
); 

/* ChessEngine Module Instantiation
*  Contains the main game logic.
*/
ChessEngine ChessEngine (
    // Clock and Reset In
    .clock              (clock             ),  // clock
    .globalReset        (globalReset       ),  // global reset
    .resetApp           (resetApp          ),  // Application reset
    
    // Game Controls
    .PlaySwitch         (PlaySwitch        ),  // Switch to start and stop the game
    .LockSwitch         (LockSwitch        ),  // Switch to lock a chess piece 
    .TimerSwitch        (TimerSwitch       ),  // Switch to enable timer
    .KeyLeft            (KeyLeft           ),  // Key to move left
    .KeyUp              (KeyUp             ),  // Key to move up
    .KeyDown            (KeyDown           ),  // Key to move down
    .KeyRight           (KeyRight          ),  // key to move right
    
    // LT24 Display Connections
    .LT24Wr_n           (LT24Wr_n          ),  // - Write Strobe (inverted)
    .LT24Rd_n           (LT24Rd_n          ),  // - Read Strobe (inverted)
    .LT24CS_n           (LT24CS_n          ),  // - Chip Select (inverted)
    .LT24RS             (LT24RS            ),  // - Register Select
    .LT24Reset_n        (LT24Reset_n       ),  // - LCD Reset
    .LT24Data           (LT24Data          ),  // - LCD Data
    .LT24LCDOn          (LT24LCDOn         ),  // - LCD Backlight On/Off
    
    // Seven Segment Display connections
    .WhiteClockMins     (WhiteClockMins    ),  // Hex[2]
    .WhiteClockTensSec  (WhiteClockTensSec ),  // Hex[1]
    .WhiteClockUnitsSec (WhiteClockUnitsSec),  // Hex[0]
    .BlackClockMins     (BlackClockMins    ),  // Hex[5]
    .BlackClockTensSec  (BlackClockTensSec ),  // Hex[4]
    .BlackClockUnitsSec (BlackClockUnitsSec)   // Hex[3]
);

endmodule

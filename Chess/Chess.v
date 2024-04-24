module Chess (

   /* INPUTS */
    input         clock,
    input         globalReset,
    input         StartStopSwitch,
    input         LockSwitch,
    input         KeyLeft,
    input         KeyUp,
    input         KeyDown,
    input         KeyRight,
    
   /* OUTPUTS */
    output        LT24Wr_n,
    output        LT24Rd_n,
    output        LT24CS_n,
    output        LT24RS,
    output        LT24Reset_n,
    output [15:0] LT24Data,
    output        LT24LCDOn,
    output        resetApp
); 

ChessEngine ChessEngine (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (globalReset),
    
	 .StartStopSwitch (StartStopSwitch),
	 .LockSwitch (LockSwitch),
	 .KeyLeft (KeyLeft),
	 .KeyUp (KeyUp),
	 .KeyDown (KeyDown),
	 .KeyRight (KeyRight),
	 
	 .resetApp (resetApp),
	 
	 //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);


endmodule

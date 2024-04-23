module Chess (

   /* INPUTS */
    input         clock,
    input         globalReset,
	 input         StartStopSwitch,
    input         MoveSwitch,
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

wire       pixelReady;
wire [3:0] TaskEnd;
reg         pixelWrite;

wire [15:0] pixelData;
wire [ 7:0] xAddr;
wire [ 8:0] yAddr;	 

//State-Machine Registers
reg [2:0] State;

ChessStartScreen ShowStartScreen (
    .clock         (clock      ), 
    .resetApp      (resetApp   ),
	 .pixelReady    (pixelReady ),
	 .pixelData     (pixelData  ),
	 .xAddr         (xAddr      ),
	 .yAddr         (yAddr      ),
	 .TaskEnd       (TaskEnd[0] ) 
);

LT24Display Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (globalReset),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

//
// Pixel Write
//
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        pixelWrite <= 1'b1;
    end
end

//Local Parameters used to define State names
localparam ST_START  = 3'b000;
localparam ST_CHESS  = 3'b001;
localparam ST_WHITE  = 3'b010;
localparam ST_BLACK  = 3'b011;
localparam ST_END    = 3'b100;

//Define the outputs for each State, which are only dependent on the state
always @(State) begin
   
   case (State)
      
      ST_START: begin
      end
      
      ST_CHESS: begin
      end
      
      ST_WHITE: begin
      end
      
      ST_BLACK: begin
      end
   
      ST_END: begin
      end
      
   endcase
end

//Define state transitions, which are synchronous
always @(posedge clock or posedge resetApp) begin
   if (resetApp) begin
      //Reset the state machine
      State <= ST_START;
   end else begin
   
   case (State)
      
      ST_START: begin
      end
      
      ST_CHESS: begin
      end      
      
      ST_WHITE: begin
      end
      
      ST_BLACK: begin
      end
      
      ST_END: begin
      end
      
      default: begin
          State <= ST_START;
      end
      endcase
    end
end

endmodule

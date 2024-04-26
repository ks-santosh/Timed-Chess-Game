module ChessEngine (

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

localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
localparam LCD_SIZE   = LCD_WIDTH * LCD_HEIGHT;

reg [15:0] StartScreenImg [LCD_SIZE - 1:0];

initial begin
    $readmemh("MemInitFiles/SpriteSheet.hex", StartScreenImg);
end

//
// Local Variables
//
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;
reg  [16:0] PixelIdx;
reg  [1:0]  State;

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
// X Counter
//
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(LCD_WIDTH-1),
    .OFFSET   (          0)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);

//
// Y Counter
//
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
UpCounterNbit #(
    .WIDTH    (             9),
    .MAX_VALUE(LCD_HEIGHT - 1),
    .OFFSET   (             0)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);

//
// Pixel Write
//
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        //In this example we always set write high, and use pixelReady to detect when
        //to update the data.
        pixelWrite <= 1'b1;
        //You could also control pixelWrite and pixelData in a State Machine.
    end
end

parameter CHESS_SQUARES	=	64;
parameter SQUARE_WIDTH  =  4;
parameter MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH;

wire [MATRIX_WIDTH - 1:0] ChessMatrix;

ChessLayoutMatrix ChessLayoutMatrix(

    .KeyLeft(KeyLeft),
    .KeyUp(KeyUp),
    .KeyDown(KeyDown),
    .KeyRight(KeyRight),
	 .resetApp(resetApp),
    .Matrix(ChessMatrix)
);

localparam START_STATE = 3'd0;
localparam PLAY_STATE  = 3'd1;

localparam ON = 1'b1;
localparam OFF = 1'b0;


always @ (posedge clock or posedge resetApp) begin 
    if (resetApp) begin
        pixelData <= 16'b0;
        xAddr     <= 8'b0;
        yAddr     <= 9'b0;
		  State     <= START_STATE;
    end else if (pixelReady) begin
		 xAddr <= xCount;
	    yAddr <= yCount;
    	 PixelIdx = (yCount * LCD_WIDTH) + xCount;

		case (State)
			START_STATE: begin
				pixelData <= StartScreenImg[PixelIdx];
				if(StartStopSwitch == ON) begin
					State <= PLAY_STATE;
				end
			end
			PLAY_STATE: begin
				pixelData <= StartScreenImg[PixelIdx];
				if(StartStopSwitch == OFF) begin
					State <= START_STATE;
				end
			end
			default : begin
				State <= START_STATE;
			end
		endcase
    end
    
end


endmodule
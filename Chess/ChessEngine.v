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
    output        resetApp,
	 output [ 6:0] WhiteClockMins,
	 output [ 6:0] WhiteClockTensSec,
	 output [ 6:0] WhiteClockUnitsSec
);

// LCD
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
localparam LCD_SIZE   = LCD_WIDTH * LCD_HEIGHT;

// Banner
localparam BANNER_HEIGHT = 40;
localparam BANNER_SIZE = BANNER_HEIGHT * LCD_WIDTH;

// chess pieces
localparam DARK_CHESSMEN_START = LCD_SIZE + BANNER_SIZE;
localparam SQUARE_SIZE = 30;
localparam CHESSMEN_SIZE = SQUARE_SIZE*SQUARE_SIZE*6*2;
localparam LIGHT_CHESSMEN_START = DARK_CHESSMEN_START + CHESSMEN_SIZE;

// chess square
localparam LIGHT_IDX = LIGHT_CHESSMEN_START + CHESSMEN_SIZE;
localparam DARK_IDX = LIGHT_IDX + 1;
localparam PRESELECT_IDX = DARK_IDX + 1;
localparam SELECT_IDX = PRESELECT_IDX + 1;
localparam POSTSELECT_IDX = SELECT_IDX + 1;

localparam DARK_COLOUR = 16'h7A69;
localparam LIGHT_COLOUR = 16'hEF9B;
localparam PRESELECT_COLOUR = 16'hFd26; // orange 
localparam SELECT_COLOUR = 16'h347F; //blue
localparam POSTSELECT_COLOUR = 16'h37E7; // green


// total size
localparam SHEET_SIZE = POSTSELECT_IDX;

reg [15:0] SpriteSheet [0:SHEET_SIZE];

initial begin
    $readmemh("MemInitFiles/StartScreenImg.hex", SpriteSheet, 0, LCD_SIZE-1);
	 $readmemh("MemInitFiles/ClockImg.hex", SpriteSheet, LCD_SIZE, LCD_SIZE + BANNER_SIZE - 1);
	 $readmemh("MemInitFiles/DarkChessmen.hex", SpriteSheet, DARK_CHESSMEN_START, DARK_CHESSMEN_START + CHESSMEN_SIZE - 1);
	 $readmemh("MemInitFiles/LightChessmen.hex", SpriteSheet, LIGHT_CHESSMEN_START, LIGHT_CHESSMEN_START + CHESSMEN_SIZE - 1);

	 SpriteSheet[LIGHT_IDX] = LIGHT_COLOUR;
	 SpriteSheet[DARK_IDX] = DARK_COLOUR;
	 SpriteSheet[PRESELECT_IDX] = PRESELECT_COLOUR;
	 SpriteSheet[SELECT_IDX] = SELECT_COLOUR;
	 SpriteSheet[POSTSELECT_IDX] = POSTSELECT_COLOUR;
end

//
// Local Variables
//
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;
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

localparam CHESS_SQUARES	=	64;
localparam SQUARE_WIDTH  =  8;
localparam MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH;

wire [MATRIX_WIDTH - 1:0] ChessMatrix;
wire Player;

ChessLayoutMatrix ChessLayoutMatrix(
	 .clock(clock),
	 .LockSwitch(LockSwitch),
    .KeyLeft(KeyLeft),
    .KeyUp(KeyUp),
    .KeyDown(KeyDown),
    .KeyRight(KeyRight),
	 .resetApp(resetApp),
    .Layout(ChessMatrix),
	 .Player(Player)
);

CountdownTimer WhiteTimer(
	.clock(clock),
	.reset(resetApp),
	.flag(Player),
	.SegMins		(WhiteClockMins    ),
	.SegSecTens (WhiteClockTensSec ),
	.SegSecUnits(WhiteClockUnitsSec)	
);

localparam START_STATE = 3'd0;
localparam PLAY_STATE  = 3'd1;

localparam ON = 1'b1;
localparam OFF = 1'b0;

function [16:0] ChessPixelIdx;
	input [7:0] x;
	input [8:0] y;
	input [1:0] State;
	begin
		reg [16:0] PixelIdx;
		reg [2:0] XQuotient;
		reg [2:0] YQuotient;
		reg [5:0] SquareIdx;
		reg [2:0] Chessman;
		reg ChessmanColour;
		reg SquareColour;
		reg [3:0] SelectType;
		
		reg [7:0] RelativeX;
		reg [8:0] RelativeY;
		
		
		PixelIdx = (y * LCD_WIDTH) + x;
		ChessPixelIdx = PixelIdx;
		
		XQuotient = x / SQUARE_SIZE;
		YQuotient = (y - BANNER_HEIGHT) / SQUARE_SIZE;
		SquareIdx =	(YQuotient * 8) + XQuotient;
		RelativeY = y - BANNER_HEIGHT - SQUARE_SIZE*YQuotient;
		RelativeX = x - SQUARE_SIZE*XQuotient;
		
		Chessman = ChessMatrix[SquareIdx*SQUARE_WIDTH +: 3];
		ChessmanColour =  ChessMatrix[(SquareIdx+1)*SQUARE_WIDTH - 5];
		SelectType = ChessMatrix[SquareIdx*SQUARE_WIDTH + 4 +: 4]; 
		
		if(State == START_STATE) begin
			ChessPixelIdx = PixelIdx;
		end else begin
			if((y < BANNER_HEIGHT) || (y >= LCD_HEIGHT - BANNER_HEIGHT))begin
				ChessPixelIdx = PixelIdx;
			
			end else begin
				if (YQuotient % 2 == 0) begin
					if(XQuotient % 2 == 0) begin
						ChessPixelIdx	= LIGHT_IDX;
						SquareColour = 1;
					end else begin
						ChessPixelIdx	= DARK_IDX;
						SquareColour = 0;
					end
				
				end else begin
					if(XQuotient % 2 == 0) begin
						ChessPixelIdx	= DARK_IDX;
						SquareColour = 0;
					end else begin
						ChessPixelIdx	= LIGHT_IDX;
						SquareColour = 1;
					end
				
				end
				if((RelativeY < 2) || (RelativeY >= SQUARE_SIZE - 2) || (RelativeX < 2) || (RelativeX >= SQUARE_SIZE - 2)) begin
					if(SelectType[1]) begin
						ChessPixelIdx = SELECT_IDX;
					end else if(SelectType[2]) begin
						ChessPixelIdx = POSTSELECT_IDX;
					end else if(SelectType[0]) begin
						ChessPixelIdx = PRESELECT_IDX;
					end
				end else if(Chessman != 0) begin
					ChessPixelIdx = DARK_CHESSMEN_START + (CHESSMEN_SIZE * ChessmanColour) + (CHESSMEN_SIZE/2)*SquareColour + RelativeY*180 + (RelativeX + (Chessman - 1)*SQUARE_SIZE);
				end
			end	
		end
	end
endfunction

always @ (posedge clock or posedge resetApp) begin 
    if (resetApp) begin
        pixelData <= 16'b0;
        xAddr     <= 8'b0;
        yAddr     <= 9'b0;
		  State     <= START_STATE;
    end else if (pixelReady) begin
		 xAddr <= xCount;
	    yAddr <= yCount;
		pixelData <= SpriteSheet[ChessPixelIdx(xCount, yCount, State)];

		case (State)
			START_STATE: begin
				if(StartStopSwitch == ON) begin
					State <= PLAY_STATE;
				end
			end
			PLAY_STATE: begin
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
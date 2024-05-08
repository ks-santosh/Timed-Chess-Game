/*
 * ChessEngine
 * ----------------
 * By: Santosh K S
 * Date: 24/04/2024
 *
 * Short Description
 * -----------------
 * The ChessEngine module serves as the core processing unit 
 * for the chess game implementation. It coordinates various functionalities 
 * such as game logic, user input processing, and display control. 
 * The module interfaces with the Chess module to receive user input and 
 * control game state transitions. Additionally, it communicates with the 
 * display module to update the graphical representation of the chessboard and 
 * game status. The ChessEngine module encapsulates the intelligence required 
 * for move validation, checkmate detection, and game state management, 
 * ensuring smooth and accurate gameplay.
 *
 */
module ChessEngine (

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

// LCD Dimensions
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
localparam LCD_SIZE   = LCD_WIDTH * LCD_HEIGHT;

// Banner Dimensions
localparam BANNER_HEIGHT = 40;
localparam BANNER_SIZE = BANNER_HEIGHT * LCD_WIDTH;

// Chess pieces Dimensions and array start Index
localparam DARK_CHESSMEN_START = LCD_SIZE + BANNER_SIZE;
localparam SQUARE_SIZE = 30;
localparam CHESSMEN_SIZE = SQUARE_SIZE*SQUARE_SIZE*6*2;
localparam LIGHT_CHESSMEN_START = DARK_CHESSMEN_START + CHESSMEN_SIZE;

// WIN text image Dimensions and array start index 
localparam WIN_IMG_START = LIGHT_CHESSMEN_START + CHESSMEN_SIZE;
localparam WIN_IMG_HEIGHT = 20;
localparam WIN_IMG_WIDTH = 116;
localparam WIN_IMG_SIZE = WIN_IMG_HEIGHT*WIN_IMG_WIDTH;

// Pixel colour of chess square stored in array index
localparam LIGHT_IDX = WIN_IMG_START + WIN_IMG_SIZE;
localparam DARK_IDX = LIGHT_IDX + 1;
localparam PRESELECT_IDX = DARK_IDX + 1;
localparam SELECT_IDX = PRESELECT_IDX + 1;
localparam POSTSELECT_IDX = SELECT_IDX + 1;

// RGB565 colours of dark and light chess squares
localparam DARK_COLOUR = 16'h7A69;
localparam LIGHT_COLOUR = 16'hEF9B;
localparam PRESELECT_COLOUR = 16'hFd26; // orange 
localparam SELECT_COLOUR = 16'h347F; //blue
localparam POSTSELECT_COLOUR = 16'h37E7; // green


// Total size of the initialised reg variable
localparam SHEET_SIZE = POSTSELECT_IDX;

// Stores all the chessman images, banners and text images 
reg [15:0] SpriteSheet [0:SHEET_SIZE];

// Initialised SpriteSheet with all the MIF hex files containing RGB565 pixel array
initial begin
    $readmemh("MemInitFiles/StartScreenImg.hex", SpriteSheet, 0, LCD_SIZE-1);
    $readmemh("MemInitFiles/ClockImg.hex", SpriteSheet, LCD_SIZE, LCD_SIZE + BANNER_SIZE - 1);
    $readmemh("MemInitFiles/DarkChessmen.hex", SpriteSheet, DARK_CHESSMEN_START, DARK_CHESSMEN_START + CHESSMEN_SIZE - 1);
    $readmemh("MemInitFiles/LightChessmen.hex", SpriteSheet, LIGHT_CHESSMEN_START, LIGHT_CHESSMEN_START + CHESSMEN_SIZE - 1);
    $readmemh("MemInitFiles/WinnerTextImg.hex", SpriteSheet, WIN_IMG_START, WIN_IMG_START + WIN_IMG_SIZE - 1);
    
    SpriteSheet[LIGHT_IDX] = LIGHT_COLOUR;
    SpriteSheet[DARK_IDX] = DARK_COLOUR;
    SpriteSheet[PRESELECT_IDX] = PRESELECT_COLOUR;
    SpriteSheet[SELECT_IDX] = SELECT_COLOUR;
    SpriteSheet[POSTSELECT_IDX] = POSTSELECT_COLOUR;
end

// Local Variables
reg  [ 7:0] xAddr;      // x address on LT24
reg  [ 8:0] yAddr;      // y address on LT24
reg  [15:0] pixelData;  // RGB565 colour pixel to display
wire        pixelReady; // Ready to see when to update the data
reg         pixelWrite; // To enable pixel write
reg  [2:0]  State;      // Game states

/* LT24Display Module Instantiation
*  Driver to control the LT24 display 
*/
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

/* X Counter
*/
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),  // x counter bit-width
    .MAX_VALUE(LCD_WIDTH-1),  // count till LCD width
    .OFFSET   (          0)   // Start count from 0
) xCounter (
   // Counter connection
    .clock     (clock     ),  // clock
    .reset     (resetApp  ),  // reset
    .enable    (pixelReady),  // enable when pixel ready
    .countValue(xCount    )   // x counter value
);

/* Y Counter
*/
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
UpCounterNbit #(
    .WIDTH     (             9),
    .MAX_VALUE (LCD_HEIGHT - 1),
    .OFFSET    (             0)
) yCounter (
   // Counter connection
    .clock     (clock         ), // clock
    .reset     (resetApp      ), // reset
    .enable    (yCntEnable    ), // enable when y count enabled
    .countValue(yCount        )  // y counter value
);

/* Pixel Write
*/
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        // always set write high, and use pixelReady to detect when
        // to update the data.
        pixelWrite <= 1'b1;
    end
end

// Local parameters
localparam CHESS_SQUARES = 64;   // Number of squares in chess
localparam SQUARE_WIDTH  =  8;   // Bit-Width of the number representing data in each square
localparam MATRIX_WIDTH  = CHESS_SQUARES * SQUARE_WIDTH; // Layout size

// Wires for ChessLayoutMatrix
wire [MATRIX_WIDTH - 1:0] ChessMatrix;
wire Player;
wire [1:0] Checkmate;

// Signal to reset the game - reset from LT24 or in start state
assign GameReset = resetApp | State[0];

/* ChessLayoutMatrix Module Instantiated
*  Gives the board layout informaition.
*/
ChessLayoutMatrix ChessLayoutMatrix(
    // ChessLayoutMatrix interface connections
    .clock      (      clock),   // clock
    .LockSwitch ( LockSwitch),   // Wwitch to lock a chess piece
    .KeyLeft    (    KeyLeft),   // Key to move left
    .KeyUp      (      KeyUp),   // Key to move up
    .KeyDown    (    KeyDown),   // Key to move down
    .KeyRight   (   KeyRight),   // Key to move right
    .reset      (  GameReset),   // Flag to reset the game
    .Layout     (ChessMatrix),   // Output chess layout matrix
    .Player     (     Player),   // Current player playing
    .Checkmate  (  Checkmate)    // Checkmate 00 - no checkmate, 11 - White wins 01 - Black wins
);

// States of the game state
localparam START_STATE = 3'b001;
localparam PLAY_STATE  = 3'b010;
localparam END_STATE   = 3'b100;

// Wires for CountdownTimer
wire WhiteTimeout;
wire BlackTimeout;
wire WhiteTimerFlag;
wire BlackTimerFlag;

// signals to enable the white and black timer
assign WhiteTimerFlag = Player & (~Checkmate[0]) & (~BlackTimeout) & State[1] & TimerSwitch;
assign BlackTimerFlag = (~Player) & (~Checkmate[0]) & (~WhiteTimeout) & State[1] & TimerSwitch;

/* CountdownTimer Module Instantiated
*  Timer for White Team
*/
CountdownTimer WhiteTimer(
   // Countdown timer connections
   .clock      (             clock),   // clock
   .reset      (         GameReset),   // to reset the game
   .flag       (    WhiteTimerFlag),   // to enable timer
   // Seven segment interface
   .SegMins    (    WhiteClockMins),   // display minutes
   .SegSecTens ( WhiteClockTensSec),   // display value at tens place of seconds
   .SegSecUnits(WhiteClockUnitsSec),   // display value at units place of seconds
   
   .Timeout    (      WhiteTimeout)    // Timeout flag for white timer
);

/* CountdownTimer Module Instantiated
*  Timer for Black Team
*/
CountdownTimer BlackTimer(
   // Countdown timer connections
   .clock      (             clock),   // clock
   .reset      (         GameReset),   // to reset the game
   .flag       (    BlackTimerFlag),   // to enable timer
   // seven segment interface
   .SegMins    (    BlackClockMins),   // display minutes
   .SegSecTens ( BlackClockTensSec),   // display value at tens place of seconds
   .SegSecUnits(BlackClockUnitsSec),   // display value at units place of seconds
   
   .Timeout    (      BlackTimeout)    // Timeout flag for black timer
);

// local parameters for switch/key On and Off status
localparam ON = 1'b1;
localparam OFF = 1'b0;

/* The ChessPixelIdx function calculates the pixel index 
* for a given (x, y) coordinate pair on LT24 display.
* The pixel index gives the location of colour in SpriteSheet
*/
function [16:0] ChessPixelIdx;
   input [7:0] x;       // x address
   input [8:0] y;       // y address
   input [1:0] State;   // game state
   begin
   
      // Function local variables
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
      
      // LT24 pixel index
      PixelIdx = (y * LCD_WIDTH) + x;
      ChessPixelIdx = PixelIdx;
      
      // Position of square on chess board
      XQuotient = x / SQUARE_SIZE;  // x-position of chess square. Range: 0-7
      YQuotient = (y - BANNER_HEIGHT) / SQUARE_SIZE;  // y-position of chess square. Range: 0-7
      
      SquareIdx = (YQuotient * 8) + XQuotient; // Index in ChessMatrix
      
      // Relative y and x address for displaying top and bottom banner images
      RelativeY = y - BANNER_HEIGHT - SQUARE_SIZE*YQuotient;
      RelativeX = x - SQUARE_SIZE*XQuotient;
      
      // Chessman type and its colour
      Chessman = ChessMatrix[SquareIdx*SQUARE_WIDTH +: 3];
      ChessmanColour =  ChessMatrix[(SquareIdx+1)*SQUARE_WIDTH - 5];
      
      // Selection type extracted from the last 4 bits
      SelectType = ChessMatrix[SquareIdx*SQUARE_WIDTH + 4 +: 4]; 
      
      if(State == START_STATE) begin // Display StartScreenImage in start state
         ChessPixelIdx = PixelIdx;
         
      end else begin // In all the other states
         // Display top and bottom banner images which is extracted from the StartScreenImage
         if((y < BANNER_HEIGHT) || (y >= LCD_HEIGHT - BANNER_HEIGHT))begin
            // Display 'WINNER' text on bottom banner if White wins 
            if(WhiteTimeout || (Checkmate[0] && (Checkmate[1] == 1'b0))) begin
               // To coorectly position the text image on the banner
               if((x >= 63) && (x <= 63 + WIN_IMG_WIDTH - 1) && (y >= 12) && (y <= 12 + WIN_IMG_HEIGHT - 1)) begin
                  // Index for 'WINNER' text image
                  ChessPixelIdx = WIN_IMG_START + (y - 12)*WIN_IMG_WIDTH + (x - 63);
               end else begin
                  ChessPixelIdx = PixelIdx;
               end
            // Display 'WINNER' text on bottom banner if black wins
            end else if(BlackTimeout || (Checkmate[0] && (Checkmate[1] == 1'b1))) begin 
               // To coorectly position the text image on the banner
               if((x >= 63) && (x <= 63 + WIN_IMG_WIDTH - 1) && (y >= 288) && (y <= 288 + WIN_IMG_HEIGHT - 1)) begin
                  // Index for 'WINNER' text image
                  ChessPixelIdx = WIN_IMG_START + (y - 290)*WIN_IMG_WIDTH + (x - 63);
               end else begin
                  ChessPixelIdx = PixelIdx;
               end               
            end else begin
               // Just display normal top and bottom banner from StartScreenImage
               ChessPixelIdx = PixelIdx;
            end
            
         end else begin // For the chess board display
            // If square row is even
            if (YQuotient % 2 == 0) begin
               // If square in even column
               if(XQuotient % 2 == 0) begin
                  ChessPixelIdx  = LIGHT_IDX; // display light colour square
                  SquareColour = 1;
               end else begin
               // If square in odd column
                  ChessPixelIdx  = DARK_IDX; // display dark colour square
                  SquareColour = 0;
               end
            // If square row is odd
            end else begin
               // If square in even column
               if(XQuotient % 2 == 0) begin
                  ChessPixelIdx  = DARK_IDX; // display dark colour square
                  SquareColour = 0;
               // If square in odd column
               end else begin
                  ChessPixelIdx  = LIGHT_IDX; // display light colour square
                  SquareColour = 1;
               end
            
            end
            
            // To display different selection border and chess pieces 
            if((RelativeY < 2) || (RelativeY >= SQUARE_SIZE - 2) || (RelativeX < 2) || (RelativeX >= SQUARE_SIZE - 2)) begin
               if(SelectType[1]) begin
                  // border over square containing chess piece selected
                  ChessPixelIdx = SELECT_IDX;
               end else if(SelectType[2]) begin
                  // border over square to move the chess piece to 
                  ChessPixelIdx = POSTSELECT_IDX;
               end else if(SelectType[0]) begin
                  // border over square to 
                  ChessPixelIdx = PRESELECT_IDX;
               end
            // If square contains chess piece
            end else if(Chessman != 0) begin
               // Display the correct chess piece according to the square colour
               ChessPixelIdx = DARK_CHESSMEN_START + (CHESSMEN_SIZE * ChessmanColour) + (CHESSMEN_SIZE/2)*SquareColour + RelativeY*180 + (RelativeX + (Chessman - 1)*SQUARE_SIZE);
            end
         end   
      end
   end
endfunction

// Main state machine logic
always @ (posedge clock or posedge resetApp or posedge globalReset) begin 
    if (resetApp || globalReset) begin
        pixelData <= 16'b0;
        xAddr     <= 8'b0;
        yAddr     <= 9'b0;
        State     <= START_STATE;
    end else if (pixelReady) begin
       xAddr <= xCount;
       yAddr <= yCount;
       
       // Pixel colour sent from SpriteSheet which is indexed by ChessPixelIdx function
       pixelData <= SpriteSheet[ChessPixelIdx(xCount, yCount, State)];

      case (State)
         // Start state is default start state
         START_STATE: begin
            if(PlaySwitch == ON) begin
               State <= PLAY_STATE;
            end
         end
         // Play state when play swith is on
         PLAY_STATE: begin
            if(PlaySwitch == OFF) begin
               // go to start state if the PlaySwitch is off
               State <= START_STATE;
            end else if(Checkmate[0] || WhiteTimeout || BlackTimeout) begin
               // If checkmate or timeout go to end state
               State <= END_STATE;
            end
         end
         // End state when game is over
         END_STATE: begin
            if(PlaySwitch == OFF) begin
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
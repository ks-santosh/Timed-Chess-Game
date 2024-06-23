/*
 * ChessKLayoutMatrix
 * ----------------
 * Date: 24/04/2024
 *
 * Short Description
 * -----------------
 * The ChessLayoutMatrix module defines the layout of the chessboard 
 * and the initial positions of the chess pieces. It represents the 
 * configuration of the chessboard using a matrix of values, where each element 
 * of the matrix corresponds to the data related to square on the chessboard. 
 * The data encodes chess piece, its colour, square selected and chess piece 
 * selected to be moved. The module initializes the matrix with the starting 
 * positions of the chess pieces according to the rules of chess. It updates 
 * the layout according to key controls and switches. 
 */
module ChessLayoutMatrix #(
   parameter CHESS_SQUARES =  64,
   parameter SQUARE_WIDTH  =  8,
   parameter MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH
) (

   /* INPUTS */
    input         clock,      // clock
    input         LockSwitch, // Switch to lock the selected chess piece
    input         KeyLeft,    // Key to move left
    input         KeyUp,      // Key to move up
    input         KeyDown,    // Key to move down
    input         KeyRight,   // Key to move right
    input         reset,      // to reset the layout
    
   /* OUTPUTS */
    output reg [MATRIX_WIDTH - 1:0] Layout,     // Layout of the chess board  
    output reg                      Player,     // Player who is playing. 0 - Black, 1 - White
    output reg [               1:0] Checkmate   // Flag if checkmate
);

// registers to initialise and store the layout matrix value
reg [SQUARE_WIDTH - 1:0] LayoutMatrix [0:CHESS_SQUARES - 1];
reg [SQUARE_WIDTH - 1:0] InitMatrix [0:CHESS_SQUARES - 1];
reg [MATRIX_WIDTH - 1:0] InitLayout;
reg [MATRIX_WIDTH - 1:0] FlatLayout;
integer i;

// Initialise the matrix with starting chess board layout
initial begin
   $readmemh("MemInitFiles/ChessLayoutMatrix.hex", LayoutMatrix);
   $readmemh("MemInitFiles/ChessLayoutMatrix.hex", InitMatrix);
   
   // flatten the array into string of bits
   for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
      InitLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = InitMatrix[i];
   end
end 

// wire for low frequency clock
wire OutClock;

/* ClockFrequencyDivider Module Instantiation
* For a lower frequency clock signal to make the 
* key press responce more controllable.
*/
ClockFrequencyDivider #(
   .OUTPUT_FREQUENCY(5)    // desired frequency
) ClockFrequencyDivider (
   // Connections for ClockFrequencyDivider
    .InClock (   clock),   // clock
    .reset   (   reset),   // reset
    .OutClock(OutClock)    // lower frequency clock
); 

// x, y and index position of square selected
reg [2:0] SelectSquareX; 
reg [2:0] SelectSquareY;
reg [5:0] SelectSquareIdx;

// square index with a chess piece that is selected and locked
reg [5:0] LockSquareIdx;

// Flag to store lock status
reg LockFlag;

// local parameters for white and black player encoded
localparam WHITE_PLAYER = 1'b1;
localparam BLACK_PLAYER = 1'b0;

// local parameters for boolean true-false and switch/key on-off
localparam ON = 1'b0;
localparam OFF = 1'b1;
localparam TRUE = 1'b1;
localparam FALSE = 1'b0;

// encodings for all chess pieces
localparam PAWN = 3'd1;
localparam KNIGHT = 3'd2;
localparam ROOK = 3'd3;
localparam BISHOP = 3'd4;
localparam QUEEN = 3'd5;
localparam KING = 3'd6;

// to store chess piece source and destination position
reg [3:0] SourceX;
reg [3:0] SourceY;
reg [3:0] DestX;
reg [3:0] DestY;

// Chess piece that is locked and moved
reg [2:0] Chessman;

/* The ChessmanInPath function checks if there is any chessman in the path 
* between two specified squares on the chessboard. It takes the coordinates of 
* two squares (source and destination) as inputs and returns a boolean value 
* indicating whether there is any chessman obstructing the path between them. 
*/
function ChessmanInPath;
   // Arguments - source and destination square positions
   input [3:0] SourceX;
   input [3:0] SourceY;
   input [3:0] DestX;
   input [3:0] DestY;   
   begin
      reg [5:0] SquareIdx;
      reg [3:0] x, y;
      
      // stores the distance between source and destination
      // DS - number of squares from source to destination. Source position is lesser than destination. 
      // SD - number of square from destination to source. Source position is greater than destination.

      reg [3:0] LenSDy, LenDSy, LenSDx, LenDSx;

      LenSDy = DestY - SourceY;
      LenDSy = SourceY - DestY;
      LenSDx = DestX - SourceX;
      LenDSx = SourceX - DestX;
      
      // False if chessman not in path
      ChessmanInPath = FALSE;
      
      // If destination is adjacent there are no chess piece in path
      if((LenSDx == 1) || (LenDSx == 1) || (LenSDy == 1) || (LenDSy == 1)) begin
               ChessmanInPath = FALSE;
      // if path is vertical
      end else if((SourceX == DestX) && (SourceY != DestY)) begin
         for(y = 0; y < 8; y = y + 1) begin
            SquareIdx = y*8 + SourceX;
            if(((y > SourceY) || (y > DestY)) && ((y < SourceY) || (y < DestY))) begin
               if(LayoutMatrix[SquareIdx][2:0]) begin
                  ChessmanInPath = TRUE;
               end
            end
         end
      // If path is horizontal
      end else if((SourceY == DestY) && (SourceX != DestX)) begin
         for(x = 0; x < 8; x = x + 1) begin
            SquareIdx = SourceY*8 + x;
            if(((x > SourceX) || (x > DestX)) && ((x < SourceX) || (x < DestX))) begin
               if(LayoutMatrix[SquareIdx][2:0]) begin
                  ChessmanInPath = TRUE;
               end
            end
         end
      // If path is diagonal
      end else if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
         for(y = 0; y < 8; y = y + 1) begin
            for(x = 0; x < 8; x = x + 1) begin
               SquareIdx = y*8 + x;
               // If the square in the range
               if ((((x > SourceX) || (x > DestX)) && ((x < SourceX) || (x < DestX)))
                  && (((y > SourceY) || (y > DestY)) && ((y < SourceY) || (y < DestY)))) begin
                  // If square is diagonal to the source
                  LenSDy = y - SourceY;
                  LenDSy = SourceY - y;
                  LenSDx = x - SourceX;
                  
						LenDSx = SourceX - x;
                  if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
                     if(LayoutMatrix[SquareIdx][2:0]) begin
                        ChessmanInPath = TRUE;
                     end
                  end
               end
            end
         end
      end
   end
endfunction

/* The ValidMove function is responsible for determining whether a move in a 
* chess game is valid or not. It takes as input the current state of the 
* chessboard, the coordinates of the piece to be moved, and the destination 
* coordinates, and returns a boolean value indicating whether the move is valid 
* according to the rules of chess. This function considers factors such as piece type, 
* movement restrictions, and the presence of obstructing pieces in determining the 
* validity of the move.
*/
function ValidMove;
// function arguments
   input Player;                 // Player currently playing the game
   input [2:0] Chessman;         // Chessman selected to move
   input [2:0] TargetChessman;   // Chessman in the destination square
   
   // source and destination square's x and y positions
   input [3:0] SourceX;
   input [3:0] SourceY;
   input [3:0] DestX;
   input [3:0] DestY;
   begin
      // stores the distance between source and destination
      // DS - number of squares from source to destination. Source position is lesser than destination. 
      // SD - number of square from destination to source. Source position is greater than destination.
      reg [3:0] LenSDy, LenDSy, LenSDx, LenDSx;
      
      LenSDy = DestY - SourceY;
      LenDSy = SourceY - DestY;
      LenSDx = DestX - SourceX;
      LenDSx = SourceX - DestX;
   
      // False if move is not valid. True otherwise.
      ValidMove = FALSE;
      
      // check for move based on the chessman moved
      case (Chessman)
         PAWN: begin
            // if white player, pawn can only move up
            if(Player == WHITE_PLAYER) begin
               if((((DestY == SourceY - 1) && (DestX == SourceX)) || (DestY == 4'd4))
                  && (TargetChessman == 3'd0)) begin
                  ValidMove = TRUE;
               // diagonally adjacet movement allowed to capture a piece
               end else if((DestY == SourceY - 1) && ((DestX == SourceX - 1) || (DestX == SourceX + 1))
                           && (TargetChessman != 3'd0)) begin
                  ValidMove = TRUE;                         
               end
            // if black player, pawn can only move down
            end else 
               if((((DestY == SourceY + 1)  && (DestX == SourceX))|| (DestY == 4'd3))
                  && (TargetChessman == 3'd0)) begin
                  ValidMove = TRUE;
               // diagonally adjacet movement allowed to capture a piece
               end else if((DestY == SourceY + 1) && ((DestX == SourceX - 1) || (DestX == SourceX + 1))
                           && (TargetChessman != 3'd0)) begin
                  ValidMove = TRUE;                         
               end
            end
         
         KNIGHT: begin
            // Check if Knight moves 2 squares vertically and 1 square horizontally
            if(((LenSDy == 2) || (LenDSy == 2)) && ((LenSDx == 1) || (LenDSx == 1))) begin
               ValidMove = TRUE;
            // Check if Knight moves 1 square vertically and 2 squares horizontally 
            end else if(((LenSDy == 1) || (LenDSy == 1)) && ((LenSDx == 2) || (LenDSx == 2))) begin
               ValidMove = TRUE;
            end
         end
         
         ROOK: begin
            // Check if the move is either vertical or horizontal
            if((DestY == SourceY) ^ (DestX == SourceX)) begin
               ValidMove = TRUE;
            end
         end
         
         BISHOP: begin
            // Check if the move is diagonal. Vertical and horizontal disance will be same.
            if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
               ValidMove = TRUE;
            end
         end         
         
         QUEEN: begin
            // Check if the move is diagonal. Vertical and horizontal disance will be same.
            if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
               ValidMove = TRUE;
            // Check if the move is either vertical or horizontal
            end else if((DestY == SourceY) ^ (DestX == SourceX)) begin
               ValidMove = TRUE;
            end
         end

         KING: begin
            // Check if the move is to the adjacent square.
            if((LenSDx == 1) || (LenDSx == 1) || (LenSDy == 1) || (LenDSy == 1)) begin
               ValidMove = TRUE;
            end
         end
         
         default: begin
            ValidMove = FALSE;
         end
         
      endcase
   end
endfunction


always @ (posedge OutClock or posedge reset) begin
    if (reset) begin
      
      Layout <= InitLayout; // reset the layout of board
      
      // flatten the array to string of bits
      for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
          LayoutMatrix[i] = InitMatrix[i];
      end
      
      // reset the position of square selected.
      SelectSquareX = 3'd2;
      SelectSquareY = 3'd3;
      SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
      LockSquareIdx = SelectSquareIdx;

      // white starts the game
      Player <= 1'b1; // 1 - White 0 - Black player
      
      // reset lock flag
      LockFlag = 1'b0;
      
      // set the selected square in the layout
      LayoutMatrix[SelectSquareIdx][4] = 1'b1;
      
      // reset checkmate status
      Checkmate <= 2'd0;
    end else begin
      
      // reset the selected squares.
      // 4th bit when normally selected
      LayoutMatrix[SelectSquareIdx][4] = 1'b0;
      LayoutMatrix[SelectSquareIdx][6] = 1'b0;
      
      // Move the selected square position based on key press
      if(KeyLeft == ON) begin
         SelectSquareX = SelectSquareX - 1;
      end else if(KeyRight == ON) begin
         SelectSquareX = SelectSquareX + 1;
      end else if(KeyUp == ON) begin
         SelectSquareY = SelectSquareY - 1;
      end else if(KeyDown == ON) begin
         SelectSquareY = SelectSquareY + 1;
      end
      
      // Selected square index in the array
      SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
      
      // Encode the information abouyt selected square in the matrix
      LayoutMatrix[SelectSquareIdx][4] = 1'b1;
      
      // 6th bit set after a chess piece is selected and
      // now target square is being selected 
      if(LockFlag) begin
         LayoutMatrix[SelectSquareIdx][6] = 1'b1;
      end
            
      // If lock switch is enabled no lock flag set
      if((LockSwitch) && (!LockFlag)) begin
         // set the source positon and encode the selection in layout
         if((Player == WHITE_PLAYER) && (LayoutMatrix[SelectSquareIdx][3]))begin
            LockSquareIdx = SelectSquareIdx;
            LayoutMatrix[LockSquareIdx][5] = 1'b1;
            SourceX = {1'b0, SelectSquareX};
            SourceY = {1'b0, SelectSquareY};
            LockFlag = 1'b1;
         end else if((Player == BLACK_PLAYER) && (!LayoutMatrix[SelectSquareIdx][3]))begin
            LockSquareIdx = SelectSquareIdx;
            LayoutMatrix[LockSquareIdx][5] = 1'b1;
            SourceX = {1'b0, SelectSquareX};
            SourceY = {1'b0, SelectSquareY};
            LockFlag = 1'b1;
         end 
      end
      
      // If lock switch is off and a chess piece was selected for moving
      if((!LockSwitch) && (LockFlag)) begin
         // get the chess piece locked
         Chessman = LayoutMatrix[LockSquareIdx][2:0];
         
         // set the destination square
         DestX = {1'b0, SelectSquareX};
         DestY = {1'b0, SelectSquareY};
         
         // If the chessman to be captured is different colour
         if((LayoutMatrix[LockSquareIdx][3] != LayoutMatrix[SelectSquareIdx][3]) || (LayoutMatrix[SelectSquareIdx][2:0] == 3'd0)) begin
            // If the path from source to destination is valid and follows the rules of chess
            if(ValidMove(Player, Chessman, LayoutMatrix[SelectSquareIdx][2:0], SourceX, SourceY, DestX, DestY)) begin
               // If there is no chess piece in tha path. Only a Knight can jump over other pieces.
               if(!ChessmanInPath(SourceX, SourceY, DestX, DestY)) begin
                  // If the piece captured is a King 
                  if(LayoutMatrix[SelectSquareIdx][2:0] == KING) begin
                     // Set Checkmate status in 0th bit and Player who won in the 1st bit
                     Checkmate[0] <= 1;
                     Checkmate[1] <= Player;
                  end else begin
                     // Give the turn to other player
                     Player <= ~Player;
                  end
                  
                  // Clear the locked source square and replace the chess piece in the destination
                  LayoutMatrix[SelectSquareIdx][3:0] = LayoutMatrix[LockSquareIdx][3:0];
                  LayoutMatrix[LockSquareIdx][3:0] = 4'd0;
               end
            end
         end
         
         // reset the lock flag and the locked square in the layuout
         LayoutMatrix[LockSquareIdx][5] = 1'b0;
         LockFlag = 1'b0;
      end
      
      // Flatten the array into string of bits.
      for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
         FlatLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = LayoutMatrix[i];
      end      

      // Update the layout in the output port
      Layout <= FlatLayout;

    end
end

endmodule

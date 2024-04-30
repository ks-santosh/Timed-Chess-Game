module ChessLayoutMatrix #(
	parameter CHESS_SQUARES	=	64,
	parameter SQUARE_WIDTH  =  8,
	parameter MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH
) (

   /* INPUTS */
	 input			clock,
	 input			LockSwitch,
    input         KeyLeft,
    input         KeyUp,
    input         KeyDown,
    input         KeyRight,
	 input         resetApp,
    
   /* OUTPUTS */
    output reg [MATRIX_WIDTH - 1:0]	Layout
);

reg [SQUARE_WIDTH - 1:0] LayoutMatrix [0:CHESS_SQUARES - 1];
reg [MATRIX_WIDTH - 1:0] InitLayout;
reg [MATRIX_WIDTH - 1:0] FlatLayout;
integer i;


initial begin
	$readmemh("MemInitFiles/ChessLayoutMatrix.hex", LayoutMatrix);
	for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
		InitLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = LayoutMatrix[i];
	end
end 

wire OutClock;

ClockFrequencyDivider #(
	.OUTPUT_FREQUENCY(10)
) ClockFrequencyDivider (

    .InClock(clock),
	 .reset(resetApp),
    .OutClock(OutClock)
); 

reg [2:0] SelectSquareX; 
reg [2:0] SelectSquareY;
reg [5:0] SelectSquareIdx;

reg [5:0] LockSquareIdx; 
reg LockFlag;
reg Player;

localparam WHITE_PLAYER = 1'b1;
localparam BLACK_PLAYER = 1'b0;

localparam ON = 1'b0;
localparam OFF = 1'b1;

localparam TRUE = 1'b1;
localparam FALSE = 1'b0;

localparam PAWN = 3'd1;
localparam KNIGHT = 3'd2;
localparam ROOK = 3'd3;
localparam BISHOP = 3'd4;
localparam QUEEN = 3'd5;
localparam KING = 3'd6;

reg [3:0] SourceX;
reg [3:0] SourceY;
reg [3:0] DestX;
reg [3:0] DestY;
reg [2:0] Chessman;

function ValidMove;
	input Player;
	input [2:0] Chessman;
	input [3:0] SourceX;
	input [3:0] SourceY;
	input [3:0] DestX;
	input [3:0] DestY;
	begin
		reg [3:0] LenSDy, LenDSy, LenSDx, LenDSx;
		
		LenSDy = DestY - SourceY;
		LenDSy = SourceY - DestY;
		LenSDx = DestX - SourceX;
		LenDSx = SourceX - DestX;

		ValidMove = FALSE;
		case (Chessman)
			PAWN: begin
				if(Player == WHITE_PLAYER) begin
					if(DestY == SourceY - 1)
						ValidMove = TRUE;
				end else if(DestY == SourceY + 1) begin
						ValidMove = TRUE;
				end
			end
			
			KNIGHT: begin
				if(((LenSDy == 2) || (LenDSy == 2)) && ((LenSDx == 1) || (LenDSx == 1))) begin
					ValidMove = TRUE;
				end else if(((LenSDy == 1) || (LenDSy == 1)) && ((LenSDx == 2) || (LenDSx == 2))) begin
					ValidMove = TRUE;
				end
			end
			
			ROOK: begin
				if((DestY == SourceY) ^ (DestX == SourceX)) begin
					ValidMove = TRUE;
				end
			end
			
			BISHOP: begin
				if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
					ValidMove = TRUE;
				end
			end			
			
			QUEEN: begin
				if((LenSDx == LenSDy) || (LenSDx == LenDSy) || (LenDSx == LenSDy) || (LenSDx == LenDSy)) begin
					ValidMove = TRUE;
				end else if((DestY == SourceY) ^ (DestX == SourceX)) begin
					ValidMove = TRUE;
				end
			end

			KING: begin
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


always @ (posedge OutClock or posedge resetApp) begin
    if (resetApp) begin
		Layout <= InitLayout;
		SelectSquareX = 3'd2;
		SelectSquareY = 3'd3;
		SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
		LockSquareIdx = SelectSquareIdx;

		Player = 1'b1; // 1 - White 0 - Black player
		LockFlag = 1'b0;
		
		LayoutMatrix[SelectSquareIdx][4] = 1'b1;		
    end else begin
		
		LayoutMatrix[SelectSquareIdx][4] = 1'b0;
		LayoutMatrix[SelectSquareIdx][6] = 1'b0;
		
		if(KeyLeft == ON) begin
			SelectSquareX = SelectSquareX - 1;
		end else if(KeyRight == ON) begin
			SelectSquareX = SelectSquareX + 1;
		end else if(KeyUp == ON) begin
			SelectSquareY = SelectSquareY - 1;
		end else if(KeyDown == ON) begin
			SelectSquareY = SelectSquareY + 1;
		end
		
		SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
		LayoutMatrix[SelectSquareIdx][4] = 1'b1;
		if(LockFlag) begin
			LayoutMatrix[SelectSquareIdx][6] = 1'b1;
		end
				
		
		if((LockSwitch) && (!LockFlag)) begin
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
		
		if((!LockSwitch) && (LockFlag)) begin
			Chessman = LayoutMatrix[LockSquareIdx][2:0];
			DestX = {1'b0, SelectSquareX};
			DestY = {1'b0, SelectSquareY};
			
			// If the chessman to be captured is different colour
			if((LayoutMatrix[LockSquareIdx][3] != LayoutMatrix[SelectSquareIdx][3]) || (LayoutMatrix[SelectSquareIdx][2:0] == 3'd0)) begin
				if(ValidMove(Player, Chessman, SourceX, SourceY, DestX, DestY)) begin
					LayoutMatrix[SelectSquareIdx][3:0] = LayoutMatrix[LockSquareIdx][3:0];
					LayoutMatrix[LockSquareIdx][3:0] = 4'd0;
					Player = ~ Player;
				end
			end

			LayoutMatrix[LockSquareIdx][5] = 1'b0;
			LockFlag = 1'b0;
		end
		
		for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
			FlatLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = LayoutMatrix[i];
		end		

		Layout <= FlatLayout;

	 end
end

endmodule

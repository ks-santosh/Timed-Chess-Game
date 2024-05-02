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
	 input         reset,
    
   /* OUTPUTS */
    output reg [MATRIX_WIDTH - 1:0]	Layout,
	 output reg Player,
	 output reg [1:0] Checkmate
);

reg [SQUARE_WIDTH - 1:0] LayoutMatrix [0:CHESS_SQUARES - 1];
reg [SQUARE_WIDTH - 1:0] InitMatrix [0:CHESS_SQUARES - 1];
reg [MATRIX_WIDTH - 1:0] InitLayout;
reg [MATRIX_WIDTH - 1:0] FlatLayout;
integer i;


initial begin
	$readmemh("MemInitFiles/ChessLayoutMatrix.hex", LayoutMatrix);
	$readmemh("MemInitFiles/ChessLayoutMatrix.hex", InitMatrix);
	
	for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
		InitLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = InitMatrix[i];
	end
end 

wire OutClock;

ClockFrequencyDivider #(
	.OUTPUT_FREQUENCY(5)
) ClockFrequencyDivider (

    .InClock(clock),
	 .reset(reset),
    .OutClock(OutClock)
); 

reg [2:0] SelectSquareX; 
reg [2:0] SelectSquareY;
reg [5:0] SelectSquareIdx;

reg [5:0] LockSquareIdx; 
reg LockFlag;

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

function ChessmanInPath;
	input [3:0] SourceX;
	input [3:0] SourceY;
	input [3:0] DestX;
	input [3:0] DestY;	
	begin
		reg [5:0] SquareIdx;
		reg [3:0] x, y;
		
		reg [3:0] LenSDy, LenDSy, LenSDx, LenDSx;
		
		LenSDy = DestY - SourceY;
		LenDSy = SourceY - DestY;
		LenSDx = DestX - SourceX;
		LenDSx = SourceX - DestX;
		
		ChessmanInPath = FALSE;
		
		// If destination is adjacent
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

function ValidMove;
	input Player;
	input [2:0] Chessman;
	input [2:0] TargetChessman;
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
					if((((DestY == SourceY - 1) && (DestX == SourceX)) || (DestY == 4'd4))
						&& (TargetChessman == 3'd0)) begin
						ValidMove = TRUE;
					end else if((DestY == SourceY - 1) && ((DestX == SourceX - 1) || (DestX == SourceX + 1))
									&& (TargetChessman != 3'd0)) begin
						ValidMove = TRUE;									
					end
				end else 
					if((((DestY == SourceY + 1)  && (DestX == SourceX))|| (DestY == 4'd3))
						&& (TargetChessman == 3'd0)) begin
						ValidMove = TRUE;
					end else if((DestY == SourceY + 1) && ((DestX == SourceX - 1) || (DestX == SourceX + 1))
									&& (TargetChessman != 3'd0)) begin
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


always @ (posedge OutClock or posedge reset) begin
    if (reset) begin
		Layout <= InitLayout;
		
		for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
			 LayoutMatrix[i] = InitMatrix[i];
		end
		
		SelectSquareX = 3'd2;
		SelectSquareY = 3'd3;
		SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
		LockSquareIdx = SelectSquareIdx;

		Player <= 1'b1; // 1 - White 0 - Black player
		LockFlag = 1'b0;
		
		LayoutMatrix[SelectSquareIdx][4] = 1'b1;

		Checkmate <= 2'd0;
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
				if(ValidMove(Player, Chessman, LayoutMatrix[SelectSquareIdx][2:0], SourceX, SourceY, DestX, DestY)) begin
					if(!ChessmanInPath(SourceX, SourceY, DestX, DestY)) begin
						if(LayoutMatrix[SelectSquareIdx][2:0] == KING) begin
							Checkmate[0] <= 1;
							Checkmate[1] <= Player;
						end else begin
							Player <= ~Player;
						end
						LayoutMatrix[SelectSquareIdx][3:0] = LayoutMatrix[LockSquareIdx][3:0];
						LayoutMatrix[LockSquareIdx][3:0] = 4'd0;
					end
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

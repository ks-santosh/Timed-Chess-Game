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
				LockFlag = 1'b1;
			end
		end
		
		if(!LockSwitch) begin
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

module ChessLayoutMatrix #(
	parameter CHESS_SQUARES	=	64,
	parameter SQUARE_WIDTH  =  8,
	parameter MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH
) (

   /* INPUTS */
	 input			clock,
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

localparam ON = 1'b0;
localparam OFF = 1'b1;

always @ (posedge OutClock or posedge resetApp) begin
    if (resetApp) begin
		Layout <= InitLayout;
		SelectSquareX = 3'd2;
		SelectSquareY = 3'd3;
		SelectSquareIdx = SelectSquareY*8 + SelectSquareX;
		LayoutMatrix[SelectSquareIdx][7:4] = 4'd1;
		
    end else begin
		LayoutMatrix[SelectSquareIdx][7:4] = 4'd0;
		
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
		LayoutMatrix[SelectSquareIdx][7:4] = 4'd1;
		
		for(i = 0; i < CHESS_SQUARES; i = i + 1) begin
			FlatLayout[i*SQUARE_WIDTH +: SQUARE_WIDTH] = LayoutMatrix[i];
		end		

		Layout <= FlatLayout;
	 end
end

endmodule

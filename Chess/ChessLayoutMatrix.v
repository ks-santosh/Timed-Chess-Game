module ChessLayoutMatrix #(
	parameter CHESS_SQUARES	=	64,
	parameter SQUARE_WIDTH  =  4,
	parameter MATRIX_WIDTH = CHESS_SQUARES * SQUARE_WIDTH
) (

   /* INPUTS */
    input         KeyLeft,
    input         KeyUp,
    input         KeyDown,
    input         KeyRight,
	 input         resetApp,
    
   /* OUTPUTS */
    output reg [MATRIX_WIDTH - 1:0]	Matrix
);

reg [MATRIX_WIDTH - 1:0] InitMatrix [0:0];

initial begin
	$readmemh("MemInitFiles/ChessLayoutMatrix.hex", InitMatrix);
	
end 

always @ (posedge KeyLeft or posedge KeyUp or posedge KeyDown or posedge KeyRight or posedge resetApp) begin
    if (resetApp) begin
		Matrix <= InitMatrix[0];
    end else begin
		Matrix <= InitMatrix[0];
	 end
end

endmodule

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

endmodule

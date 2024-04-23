module ChessStartScreen (
    input         clock,
    input         pixelReady,
    input         resetApp,
    
    output reg [15:0] pixelData,
    output reg [ 7:0] xAddr,
    output reg [ 8:0] yAddr,      
    output reg        TaskEnd
);

reg [15:0] StartScreenImg [76799:0];
reg [16:0] PixelIdx; 

localparam IMG_WIDTH  = 240;
localparam IMG_HEIGHT = 320;

initial begin
    $readmemh("MemInitFiles/StartScreenImg.hex", StartScreenImg);
end

//
// X Counter
//
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(IMG_WIDTH-1),
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
wire yCntEnable = pixelReady && (xCount == (IMG_WIDTH-1));
UpCounterNbit #(
    .WIDTH    (             9),
    .MAX_VALUE(IMG_HEIGHT - 1),
    .OFFSET   (             0)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);


always @ (posedge clock or posedge resetApp) begin 
    if (resetApp) begin
        pixelData <= 16'b0;
        xAddr     <= 8'b0;
        yAddr     <= 9'b0;
        TaskEnd   <= 1'b0;
    end else if (pixelReady) begin
        xAddr <= xCount;
        yAddr <= yCount;
        PixelIdx = (yCount * IMG_WIDTH) + xCount;
		  pixelData <= StartScreenImg[PixelIdx];
		  if(PixelIdx == (IMG_WIDTH * IMG_HEIGHT - 1)) begin
		      TaskEnd <= 1'b1;
		  end
    end
    
end

endmodule
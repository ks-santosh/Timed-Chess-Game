module Chess (

   /* Inputs */
   input         Clock, 
   input         Reset,

   input         Switch,
   input         KeyLeft,
   input         KeyUp,
   input         KeyDown,
   input         KeyRight,
    
   /* Outputs */
   output        LT24Wr_n,
   output        LT24Rd_n,
   output        LT24CS_n,
   output        LT24RS,
   output        LT24Reset_n,
   output [15:0] LT24Data,
   output        LT24LCDOn

); 

//State-Machine Registers
reg [2:0] State;

//Local Parameters used to define State names
localparam ST_START  = 2'b000;
localparam ST_CHESS  = 2'b001;
localparam ST_WHITE  = 2'b010;
localparam ST_BLACK  = 2'b011;
localparam ST_END    = 2'b100;

//Define the outputs for each State, which are only dependent on the state
always @(State) begin
   z = 1'b0; // Default value for output
   
   case (State)
      
      ST_START: begin
      end
      
      ST_CHESS: begin
      end
      
      ST_WHITE: begin
      end
      
      ST_BLACK: begin
      end
   
      ST_END: begin
      end
      
   endcase
end

//Define state transitions, which are synchronous
always @(posedge clock or posedge reset) begin
   if (reset) begin
      //Reset the state machine
      State <= ST_START;
   end else begin
   
   case (State)
      
      ST_START: begin
      end
      
      ST_CHESS: begin
      end      
      
      ST_WHITE: begin
      end
      
      ST_BLACK: begin
      end
      
      ST_END: begin
      end
      
      default: begin
          State <= ST_START;
      end
      endcase
    end
end

endmodule

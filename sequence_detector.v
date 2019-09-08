// Code your design here
// Verilog design code for the Moore FSM Sequence Detector
// This Moore FSM would give a value of "1" when the sequence "1100"
module sequence_detector(data_in,clock,reset,data_out);
  input logic data_in,clock,reset;
  output logic data_out;

  // Initial parameters which will be used as future references
  parameter Zero = 3'b000,
   One = 3'b001,
   OneOne = 3'b011,
   OneOneZero = 3'b010,
   OneOneZeroZero = 3'b110;

  // Create a reg for the current state and for the next state
  reg [2:0] current_state,next_state;

  // Use always block to check the current state when the reset is high
  // and when the reset is low
   always@(clock , posedge reset)
  begin
    if(reset)
      current_state <= Zero;
    else
      current_state <= next_state;
  end


  //Use always block again for checking the current state when
  // the sequence given changes
  always@(current_state , data_in)
    begin
      case(current_state)
        Zero : begin
          if(data_in == 0)
            next_state <= Zero;
          else
            next_state <= One;
        end
        One : begin
          if(data_in == 1)
            next_state <= OneOne;
          else
            next_state <= Zero;
        end
        OneOne : begin
          if (data_in == 0)
            next_state <= OneOneZero;
          else
            next_state <= One;
        end
        OneOneZero : begin
          if(data_in == 0)
            next_state <= OneOneZeroZero;
          else
            next_state <= One;
        end
        OneOneZeroZero : begin
          if(data_in == 0)
            next_state <= Zero;
          else
            next_state <= One;
        end
      default : next_state <= Zero;
      endcase
    end

  // Use always block to get the output based only on the current state
  always@(current_state)
    begin
      case(current_state)
        Zero : data_out <= 0;
        One : data_out <= 0;
        OneOne : data_out <= 0;
        OneOneZero : data_out <= 0;
        OneOneZeroZero : data_out <= 1;
        default : data_out <= 0;
      endcase
    end
endmodule

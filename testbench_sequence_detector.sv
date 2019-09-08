`timescale 1ns/1ns
module test_sequence_detector;

  // Give the inputs of logic type
  logic data_in;
  logic clock;
  logic reset;

  // Give the output as wire type
  logic data_out;

  // Instantiate the module sequence_detector
  sequence_detector detectorOne(data_in,clock,reset,data_out);

  // Give initial values to the inputs
  initial
  begin
    clock = 0;
    #10;
    forever #10 clock = !clock;
  end

  initial
  begin
    data_in = 0;
    #10;
    reset = 0;
    #10;
    data_in = 1;
    #10;
    data_in = 1;
    #10;
    data_in = 0;
    #10;
    data_in = 0;
  end
endmodule

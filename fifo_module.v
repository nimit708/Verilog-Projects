// We will create 4 modules
// Create a top level module
module fifo_top_module(rdEn,wrEn,data_in,data_out,fifo_threshold,fifo_empty,fifo_overflow,fifo_underflow,fifo_full,reset,clk);
  parameter Zero_4_Bit = 4'b0000, One_4_Bit = 4'b0001;
  input clk,reset,rdEn,wrEn;
  input [7:0] data_in;
  output [7:0] data_out;
  output fifo_overflow,fifo_underflow,fifo_full,fifo_empty,fifo_threshold;
  // Take the pointer for reading and writing as a wire
  wire [3:0]rdPtr;
  wire [3:0]wrPtr;

  // Take another pair of wires for reading and writing from the fifo
  // using the rdEn and wrEn
  wire fifo_rd, fifo_wr;

  // Instantiate the other four modules for the different operations done
  // in fifo
  array_in_memory mArray(data_out,data_in,clk,wrPtr,rdPtr,fifo_wr);
  read_ptr pointer_1(rdPtr,fifo_rd,rdEn,clk,fifo_empty,reset);
  write_ptr pointer_2(wrPtr,fifo_wr,wrEn,clk,fifo_full,reset);
  status_signal signal_found(clk,reset,fifo_rd,fifo_wr,rdPtr,wrPtr,fifo_full,fifo_empty,fifo_threshold,fifo_overflow,fifo_underflow,rdEn,wrEn);
  // this module is used to tell the status for all of the signals being send to the fifo
endmodule
  // Beginning of the storing of the data in the fifo by creating a multi
  // dimensional array
  module array_in_memory(data_out,data_in,clk,wrPtr,rdPtr,fifo_wr);
    input [7:0]data_in;
    output [7:0] data_out;
    input [3:0] rdPtr,wrPtr;
    input clk,fifo_wr;
    // Creating a multi-dimensional array which can take 8 bit data in 16     // places
    reg[7:0] data_out_2[15:0];
    wire[7:0] data_out;
    always @(posedge clk)
      begin
       if(fifo_wr)
         data_out_2[wrPtr[3:0]] <= data_in;
      end
    assign data_out = data_out_2[rdPtr[3:0]];
  endmodule

  // Module for reading data using reading pointer
  module read_ptr(rdPtr,fifo_rd,rdEn,clk,fifo_empty,reset);
    input clk,reset,fifo_empty,rdEn;
    output reg [3:0] rdPtr;
    output fifo_rd;
    assign fifo_rd = (~fifo_empty) & rdEn;

    // Use always block to read from the memory when the reset is not
    //enabled and when the clock is going towards positive edge
    always @(posedge clk or negedge reset)begin
      if(~reset) rdPtr <= 0;
    else if(fifo_rd)
     rdPtr <= rdPtr + 1;
    else
    rdPtr <= rdPtr;
    end
  endmodule

  // Module for writing in the memory
  module write_ptr(wrPtr,fifo_wr,wrEn,clk,fifo_full,reset);
    input wrEn,clk,reset,fifo_full;
    output reg [3:0] wrPtr;
    output fifo_wr;
    assign fifo_wr = (~fifo_full) & wrEn;

    always@(posedge clk or negedge reset)begin
    if(~reset) wrPtr <= 0;
    else if (fifo_wr)
        wrPtr <= wrPtr + 1;
    else
        wrPtr <= wrPtr;

    end
  endmodule

  // Module for checking the signals given as inputs in top module
module status_signal(clk,reset,fifo_rd,fifo_wr,rdPtr,wrPtr,fifo_full,fifo_empty,fifo_threshold,fifo_overflow,fifo_underflow,rdEn,wrEn);
    input rdEn,wrEn,clk,fifo_rd,fifo_wr,reset;
    input[3:0] rdPtr,wrPtr;
    output reg fifo_full,fifo_empty,fifo_threshold,
    									fifo_overflow,fifo_underflow;
    wire fbit_comp, overflow_set,underflow_set;
    wire pointer_equal;
    wire[3:0] pointer_result;
    assign fbit_comp = rdPtr[3] ^ wrPtr[3];
  assign pointer_equal = (wrPtr[2:0] - rdPtr[2:0]) ? 0 : 1;
  assign pointer_result = wrPtr[3:0] - rdPtr[3:0];
    assign overflow_set = fifo_full & wrEn;
    assign underflow_set = fifo_empty & rdEn;
    always@(*)
      begin
        fifo_full = fbit_comp & pointer_equal;
        fifo_empty = (~fbit_comp) & pointer_equal;
        fifo_threshold = (pointer_result[3] || pointer_result[2]) ? 1 : 0;
      end

    always@(posedge clk or posedge reset)
      begin
        if(reset) fifo_overflow <= 0;
        else if ((overflow_set == 1) & (fifo_rd == 0))
          fifo_overflow <= 1;
        else if (fifo_rd)
          fifo_overflow <= 0;
        else
          fifo_overflow <= fifo_overflow;
      end
    always@(posedge clk or posedge reset)
      begin
        if(reset) fifo_underflow <= 0;
        else if((underflow_set == 1) & (fifo_wr == 0))
          fifo_underflow <= 1;
        else if(fifo_wr)
          fifo_underflow <= 0;
        else
          fifo_underflow <= fifo_underflow;
      end
  endmodule

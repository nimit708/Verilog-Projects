// 1. The timescale directive
 `timescale     10 ps/ 10 ps
// Verilog Testbench code for FIFO memory
 // 2. Preprocessor Directives
 `define          DELAY 10
 // 3. Include Statements
 //`include     "counter_define.h"
 module     tb_fifo;
 // 4. Parameter definitions
 parameter     ENDTIME      = 40000;
 // 5. Take inputs as reg type
 reg     clk;
 reg     reset;
 reg     wrEn;
 reg     rdEn;
 reg     [7:0] data_in;
 // 6. Take outputs as wire type
 wire     [7:0] data_out;
 wire     fifo_empty;
 wire     fifo_full;
 wire     fifo_threshold;
 wire     fifo_overflow;
 wire     fifo_underflow;
 integer i;
 // 7. Instantiation of the DUT module
 fifo_top_module tb (/*AUTOARG*/
   rdEn,wrEn,data_in,data_out,fifo_threshold,fifo_empty,fifo_overflow,
   fifo_underflow,fifo_full,reset,clk
 );
 // 8. Initial Conditions : take every input to be 0
 initial
      begin
           clk     = 1'b0;
           reset     = 1'b0;
           wrEn     = 1'b0;
           rdEn     = 1'b0;
           data_in     = 8'd0;
      end
 // 9. Generating Test Vectors
 initial
      begin
           main;
      end
 task main;
      fork
           clock_generator;
           reset_generator;
           operation_process;
           debug_fifo;
           endsimulation;
      join
 endtask
 task clock_generator;
      begin
           forever #`DELAY clk = !clk;
      end
 endtask
 task reset_generator;
      begin
           #(`DELAY*2)
           reset = 1'b1;
           # 7.9
           reset = 1'b0;
           # 7.09
           reset= 1'b1;
      end
 endtask
 task operation_process;
      begin
           for (i = 0; i < 17; i = i + 1) begin: WRE
                #(`DELAY*5)
                wrEn = 1'b1;
                data_in = data_in + 8'd1;
                #(`DELAY*2)
                wrEn = 1'b0;
           end
           #(`DELAY)
           for (i = 0; i < 17; i = i + 1) begin: RDE
                #(`DELAY*2)
                rdEn = 1'b1;
                #(`DELAY*2)
                rdEn = 1'b0;
           end
      end
 endtask
 // 10. Debug fifo
 task debug_fifo;
      begin
           $display("----------------------------------------------");
           $display("------------------   -----------------------");
           $display("----------- SIMULATION RESULT ----------------");
           $display("--------------       -------------------");
           $display("----------------     ---------------------");
           $display("----------------------------------------------");
        $monitor("TIME = %d, wrEn = %b, rdEn = %b, data_in = %h",$time, wrEn, rdEn, data_in);
      end
 endtask
 // 11. Self-Checking
 reg [5:0] waddr, raddr;
 reg [7:0] mem[64:0];
 always @ (posedge clk) begin
   if (~reset) begin
           waddr     <= 6'd0;
      end
   else if (wrEn) begin
           mem[waddr] <= data_in;
           waddr <= waddr + 1;
      end
  $display("TIME = %d, data_out = %d, mem = %d",$time, data_out,mem[raddr]);
   if (~reset) raddr     <= 6'd0;
   else if (rdEn & (~fifo_empty)) raddr <= raddr + 1;
   if (rdEn & (~fifo_empty)) begin
           if (mem[raddr]
            == data_out) begin
                $display("=== PASS ===== PASS ==== PASS ==== PASS ===");
                if (raddr == 16) $finish;
           end
           else begin
                $display ("=== FAIL ==== FAIL ==== FAIL ==== FAIL ===");
                $display("-------------- THE SIMUALTION FINISHED ------------");
                $finish;
           end
      end
 end
 //12. Determines the simulation limit
 task endsimulation;
      begin
           #ENDTIME
           $display("-------------- THE SIMUALTION FINISHED ------------");
           $finish;
      end
 endtask
 initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  #10000 $finish;
end

endmodule

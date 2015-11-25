`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware

//////////////////////////////////////////////////////////////////////////////////

module clock_divider_testbench;

	// Inputs (reg)
   reg clk_in;
   reg[31:0] divider; 
   reg reset;

   // Outputs (wire)
   wire clk_out;

   // Instantiate the Unit Under Test (UUT)
   clock_divider quad_clock_div (
   .clk_in(clk_in),
   .divider(divider),
   .clk_out(clk_out),
   .reset(reset)
   );
 
   // Clock Generation
   always #1 clk_in = !clk_in;


   initial begin
      // Initialize Inputs
      clk_in = 0;
      divider = 0;
      reset = 0;

      // Wait 100 ns for global reset to finish
      #100;
      
      divider = 32'd4;

      #1000000;
      $stop;
      

   end

endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Signal_Processing
// Description: Lowpass filter, match filter, and peak detection

//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//
// 31-tap FIR filter, 8-bit signed data, 10-bit signed coefficients.
// ready is asserted whenever there is a new sample on the X input,
// the Y output should also be sampled at the same time.  Assumes at
// least 32 clocks between ready assertions.  Note that since the
// coefficients have been scaled by 2**10, so has the output (it's
// expanded from 8 bits to 18 bits).  To get an 8-bit result from the
// filter just divide by 2**10, ie, use Y[17:10].
//
///////////////////////////////////////////////////////////////////////////////

module fir31_lp(
  input wire clock,reset,ready,
  input wire signed [7:0] x,
  output reg signed [17:0] y
);

  //declare and initialize regs
  reg signed [17:0] accumulator; initial accumulator = 0;
  reg signed [17:0] intermediate;
  reg [4:0] index; initial index = 0;
  wire signed [9:0] coeff_lp_x;
  reg signed [7:0] sample [31:0];
  reg [4:0] offset; initial offset = 0;
  initial y = 0;
  
  //make coeffs module
  coeffs31_lp_x coeffs(.index(index),.coeff(coeff_lp_x));
  //coeffs31_lp_y coeffs(.index(index),.coeff(coeff_lp_y));
  
  always @(posedge clock) begin
	 //if reset, set filter output to zero
	 if (reset) y <= {18'd0};
	 //reset variables on ready
	 else begin
		 if(ready) begin
			sample[offset] <= x;
			offset <= offset+1;
			accumulator <= 0;
			index <= 0;
		 end
		 //incrementally accumulate values for 31 samples
		 if(index<=30) begin		
			intermediate <= coeff_lp_x*sample[(offset-index)];
			accumulator <= accumulator+intermediate;
			index <= index+1;
		 end
		 //after 31 samples set output value to accumulator value
		 else if(index>30) begin
		    y <= accumulator;
		 end
	 end
  end
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Coefficients for a 31-tap low-pass FIR filter with Wn=.125 (eg, 3kHz for a
// 48kHz sample rate).  Since we're doing integer arithmetic, we've scaled
// the coefficients by 2**10
// Matlab command: round(fir1(30,.125)*1024)
//
///////////////////////////////////////////////////////////////////////////////

module coeffs31_lp_x(
  input wire [4:0] index,
  output reg signed [9:0] coeff
);
  // tools will turn this into a 31x10 ROM
  always @(index)
    case (index)
      5'd0:  coeff = -10'sd1;
      5'd1:  coeff = -10'sd1;
      5'd2:  coeff = -10'sd3;
      5'd3:  coeff = -10'sd5;
      5'd4:  coeff = -10'sd6;
      5'd5:  coeff = -10'sd7;
      5'd6:  coeff = -10'sd5;
      5'd7:  coeff = 10'sd0;
      5'd8:  coeff = 10'sd10;
      5'd9:  coeff = 10'sd26;
      5'd10: coeff = 10'sd46;
      5'd11: coeff = 10'sd69;
      5'd12: coeff = 10'sd91;
      5'd13: coeff = 10'sd110;
      5'd14: coeff = 10'sd123;
      5'd15: coeff = 10'sd128;
      5'd16: coeff = 10'sd123;
      5'd17: coeff = 10'sd110;
      5'd18: coeff = 10'sd91;
      5'd19: coeff = 10'sd69;
      5'd20: coeff = 10'sd46;
      5'd21: coeff = 10'sd26;
      5'd22: coeff = 10'sd10;
      5'd23: coeff = 10'sd0;
      5'd24: coeff = -10'sd5;
      5'd25: coeff = -10'sd7;
      5'd26: coeff = -10'sd6;
      5'd27: coeff = -10'sd5;
      5'd28: coeff = -10'sd3;
      5'd29: coeff = -10'sd1;
      5'd30: coeff = -10'sd1;
      default: coeff = 10'hXXX;
    endcase
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 128-tap FIR filter, 8-bit signed data, 8-bit coefficients from match filter.
// ready is asserted whenever there is a new sample on the X input,
// the Y output should also be sampled at the same time.  Assumes at
// least 32 clocks between ready assertions.  Note that since the
// coefficients have been scaled by 2**10, so has the output (it's
// expanded from 8 bits to 18 bits).  To get an 8-bit result from the
// filter just divide by 2**10, ie, use Y[17:10].
//
///////////////////////////////////////////////////////////////////////////////

module fir128_match(
  input wire clock,reset,ready,
  input wire [7:0] coeff_mf,
  input wire [6:0] index,
  input wire [6:0] offset,
  input wire signed [7:0] x,
  output reg signed [15:0] y
);

  //declare and initialize regs
  reg signed [17:0] accumulator; initial accumulator = 0;
  reg signed [17:0] intermediate;
  reg signed [7:0] sample [100:0];
  initial y = 0;
  
  always @(posedge clock) begin
	 //if reset, set filter output to zero
	 if (reset) y <= {18'd0};
	 //reset variables on ready
	 else begin
		 if(ready) begin
			sample[offset] <= x;
			accumulator <= 0;
		 end
		 //incrementally accumulate values for 31 samples
		 if(index<=30) begin		
			intermediate <= coeff_mf*sample[(offset-index)];
			accumulator <= accumulator+intermediate;
		 end
		 //after 31 samples set output value to accumulator value
		 else if(index>100) y <= accumulator;
	 end
  end
endmodule

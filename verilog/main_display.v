`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Main_Display
// Description: Top Level Display Module

//////////////////////////////////////////////////////////////////////////////////


module main_display(
    input [10:0] hcount,
    input [9:0] vcount,
    input at_display_area,
    input [7:0] signal_in,
    output [10:0] signal_pix,
    output in_region,
    output [3:0] r_out,
    output [3:0] g_out,
    output [3:0] b_out);

	parameter WAVEFORM_WIDTH= 3;
    
	wire [11:0] waveform_pixel;
    waveform #(.THICKNESS(WAVEFORM_WIDTH),.COLOR(12'hF00)) // red
          waveform1(.signal_in(signal_in),.signal_pix(signal_pix),.hcount(hcount),.vcount(vcount),
                     .pixel(waveform_pixel));  
                            
                     
    assign r_out = at_display_area ? waveform_pixel[11:8] : 0;
    assign g_out = at_display_area ? waveform_pixel[7:4] : 0;
    assign b_out = at_display_area ? waveform_pixel[3:0] : 0;
endmodule


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
    output [3:0] r_out,
    output [3:0] g_out,
    output [3:0] b_out);
    
    assign r_out = at_display_area ? {4{hcount[7]}} : 0;
    assign g_out = at_display_area ? {4{hcount[6]}} : 0;
    assign b_out = at_display_area ? {4{hcount[5]}} : 0;

endmodule


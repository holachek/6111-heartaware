`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Display_Modules
// Description: Individual Display Modules

//////////////////////////////////////////////////////////////////////////////////
module waveform
   #(parameter WIDTH = 1024,            // default: full screen
               THICKNESS = 3,
               TOP = 0,
               BOTTOM =768,
               COLOR = 12'hF00)       // default color: red
   (input [10:0] hcount,
    input [9:0] vcount,
    input [7:0] signal_in,
    output reg [10:0] signal_pix,
    output reg [11:0] pixel);
   
   reg [10:0] x_begin;
   reg [10:0] signal_pix; 
   
   always @ * begin
      x_begin <= 0+296;
      signal_pix <= BOTTOM-(((BOTTOM-TOP)*signal_in)>>8)+35;
      if ((hcount >= x_begin && hcount < (x_begin+WIDTH)) &&
			(vcount >= signal_pix && vcount < (signal_pix+THICKNESS)))
	   pixel = COLOR;
      else pixel = 12'hFFF;
   end
endmodule

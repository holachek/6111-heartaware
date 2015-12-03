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
               THICKNESS = 5,
               TOP = 0,
               BOTTOM =768)       // default color: red
   (input [10:0] hcount,
    input [9:0] vcount,
    input [7:0] signal_in,
    input [11:0] color,
    input enable,
    output reg [10:0] signal_pix,
    output reg [11:0] pixel);
   
   reg [10:0] x_begin;
   reg [10:0] signal_pix; 
   
   always @ * begin
      x_begin <= 0;
      signal_pix <= BOTTOM-(((BOTTOM-TOP)*signal_in)>>8);
      if (enable) begin
            if ((hcount >= x_begin && hcount < (x_begin+WIDTH)) &&
			 (vcount >= signal_pix && vcount < (signal_pix+THICKNESS)))
	           pixel = color;
            else pixel = 0;
      end
   end
endmodule

//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module blob
   #(parameter WIDTH = 64,            // default width: 64 pixels
               HEIGHT = 64)  // default color: white
   (input [10:0] x,hcount,
    input [9:0] y,vcount,
    input [11:0] color,
    input enable,
    output reg [11:0] pixel);

   always @ * begin
      if (enable) begin
            if ((hcount >= x && hcount < (x+WIDTH)) &&
	       (vcount >= y && vcount < (y+HEIGHT)))
	           pixel = color;
            else pixel = 0;
      end else begin
        pixel = 0;
      end
   end
endmodule


module blob_animated
   (input [10:0] width,
    input [9:0] height,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    input [11:0] color,
    input enable,
    output reg [11:0] pixel);

   always @ * begin
      if (enable) begin
            if ((hcount >= x && hcount < (x+width)) &&
	       (vcount >= y && vcount < (y+height)))
	           pixel = color;
            else pixel = 0;
      end else begin
        pixel = 0;
      end
   end
endmodule


module sprite
   (input [10:0] x,width,hcount,
    input [9:0] y,height,vcount,
    input [15:0] sprite_start_adr,
    input [11:0] pixel_data,
    input [11:0] color,
    input enable,
    output reg [15:0] bram_read_adr,
    output reg [11:0] pixel);
    
    parameter BRAM_HEIGHT = 127;
    
   always @ * begin
   
      if ((hcount >= x && hcount < (x+width)) &&
	 (vcount >= y && vcount < (y+height))) begin
	       bram_read_adr <= sprite_start_adr + BRAM_HEIGHT*(height-y) + (width-x);
	       if (enable) pixel = pixel_data;
      end else pixel = 0;
   end
endmodule
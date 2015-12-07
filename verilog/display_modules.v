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
   
   always @ * begin
      x_begin <= 0;
      signal_pix <= BOTTOM-(((BOTTOM-TOP)*signal_in)>>8);
      if (enable) begin
            if ((hcount >= x_begin && hcount < (x_begin+WIDTH)) &&
			 (vcount >= signal_pix && vcount < (signal_pix+THICKNESS)))
	           pixel = color;
            else pixel = 0;
      end else begin
        pixel = 0;
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
    #(parameter TOTAL_SPRITE_WIDTH = 610) // important to get this right! get this width from COE file
   (input clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    input [10:0] sprite_x_left,
    input [10:0] sprite_x_right,
    input [9:0] sprite_y_top,
    input [9:0] sprite_y_bottom,
    input pixel_data,
    input [11:0] color,
    input enable,
    output reg [17:0] bram_read_adr,
    output reg [11:0] pixel);
        
   always @ (posedge clk) begin

    if (enable) begin

        if ((hcount >= x && hcount < (x+(sprite_x_right-sprite_x_left))) &&
             (vcount >= y && vcount < (y+(sprite_y_bottom-sprite_y_top)))) begin
                
                bram_read_adr <= TOTAL_SPRITE_WIDTH*(vcount-y+sprite_y_top) + (hcount-x+sprite_x_left); // go to BRAM address with related sprite image
                
                if (pixel_data) pixel = color;
                else pixel = 0;
     
          end else begin
          
            bram_read_adr <= 0; // to not interfere with other sprites
             pixel = 0;
           
             end
         
         end
   end
endmodule
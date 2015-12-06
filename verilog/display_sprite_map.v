`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Display Sprite Map
// Description: Given a 0-9 number, return sprite map coordinates

//////////////////////////////////////////////////////////////////////////////////

module display_sprite_map(input clk, input [3:0] number,
output reg [10:0] sprite_x_left,
output reg [10:0] sprite_x_right,
output reg [10:0] sprite_y_top,
output reg [10:0] sprite_y_bottom,
input reset);

    always @(posedge clk) begin
	
		if (reset) begin
		
                sprite_x_left <=0;
        sprite_x_right <= 0;
        sprite_y_top <= 0;
        sprite_y_bottom <= 0;
        
		end else		    if (number == 0) begin
                sprite_x_left <= 567;
                sprite_x_right <= 608;
                sprite_y_top <= 281;
                sprite_y_bottom <= 355;
			end else if (number == 1) begin
          sprite_x_left <= 143;
          sprite_x_right <= 172;
          sprite_y_top <= 281;
          sprite_y_bottom <= 355;
      end
        else if (number == 2) begin
             sprite_x_left <= 172;
             sprite_x_right <= 222;
             sprite_y_top <= 281;
             sprite_y_bottom <= 355;
         end
                                        
        else if (number == 3) begin
             sprite_x_left <= 222;
               sprite_x_right <= 269;
               sprite_y_top <= 281;
               sprite_y_bottom <= 355;
           end
           else if (number == 4) begin
               sprite_x_left <= 269;
               sprite_x_right <= 319;
               sprite_y_top <= 281;
               sprite_y_bottom <= 355;
           end
           else if (number == 5) begin
           sprite_x_left <= 319;
           sprite_x_right <= 367;
           sprite_y_top <= 281;
           sprite_y_bottom <= 355;
           end
           else if (number == 6) begin
             sprite_x_left <= 367;
             sprite_x_right <= 419;
             sprite_y_top <= 281;
             sprite_y_bottom <= 355;
         end
         
         else if (number == 7) begin
           sprite_x_left <= 419;
           sprite_x_right <= 464;
           sprite_y_top <= 281;
           sprite_y_bottom <= 355;
         end
                     
         else if (number == 8) begin
             sprite_x_left <= 464;
            sprite_x_right <= 515;
            sprite_y_top <= 281;
             sprite_y_bottom <= 355;
       end else if (number == 9) begin
            sprite_x_left <= 515;
            sprite_x_right <= 567;
            sprite_y_top <= 281;
            sprite_y_bottom <= 355;

		end // reset check

    end // always @
        
endmodule
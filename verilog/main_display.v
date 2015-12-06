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
    input clk_100mhz,
    input clk_65mhz,
    input [10:0] hcount,
    input [9:0] vcount,
    
    // bram
    output [15:0] bram_sprite_adr,
    input bram_sprite_data,
    
    input at_display_area,
    input [7:0] signal_in,
    input [2:0] system_status,
    output [10:0] signal_pix,
    output in_region,
    output [3:0] r_out,
    output [3:0] g_out,
    output [3:0] b_out);


    reg [11:0] waveform_color;
    reg [11:0] top_menubar_color;
    reg [11:0] bottom_menubar_color;
    reg [11:0] error_box_color;
    
    reg [11:0] background_color;
    
    reg [18:0] progress_bar_counter;

    always @ (posedge clk_100mhz) begin
    
    
        if (system_status == 0) begin // paused
        
            waveform_display_enable <= 1;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 0;
            waveform_color <= 'h666;
            top_menubar_color <= 'h666;
            bottom_menubar_color <= 'h666;
            error_box_color <= 'hFFF;
            progress_bar_width <= 0;
            background_color <= 'h000;
        
        end else if (system_status == 1) begin // running
        
        waveform_display_enable <= 1;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 0;
            waveform_color <= 'hFFF;
            top_menubar_color <= 'hF22;
            bottom_menubar_color <= 'h17A;
            error_box_color <= 'hFFF;
            progress_bar_width <= 0;
            background_color <= 'h000;
        
        end else if (system_status == 2) begin // error
        
            waveform_display_enable <= 0;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 1;
            waveform_color <= 'hFFF;
            top_menubar_color <= 'h666;
            bottom_menubar_color <= 'h666;
            error_box_color <= 'hF22;
            progress_bar_width <= 0;
            background_color <= 'h000;
        
        end else if (system_status == 3) begin //boot
        
            progress_bar_display_enable <= 1;
            progress_bar_counter <= progress_bar_counter + 1;
            
            if (progress_bar_counter == 0 && progress_bar_width < 1024) begin
                progress_bar_width <= progress_bar_width + 1;
            end
        
            waveform_display_enable <= 0;
            top_menubar_display_enable <= 0;
            bottom_menubar_display_enable <= 0;
            error_box_display_enable <= 0;
            background_color <= 'h000;
            
        
        end
    
    end

	parameter WAVEFORM_WIDTH= 5;
    
    reg waveform_display_enable;
	wire [11:0] waveform_pixel;
    waveform #(.THICKNESS(WAVEFORM_WIDTH),.TOP(192),.BOTTOM(576))
          waveform1(.color(waveform_color),.signal_in(signal_in),.signal_pix(signal_pix),.hcount(hcount),.vcount(vcount),
                     .pixel(waveform_pixel), .enable(waveform_display_enable));  
    
    // menubars
    reg top_menubar_display_enable;
    wire [11:0] top_menubar_pixel;
       blob #(.WIDTH(250),.HEIGHT(170))
         top_menubar(.color(top_menubar_color), .x(700),.y(0),.hcount(hcount),.vcount(vcount), .pixel(top_menubar_pixel), .enable(top_menubar_display_enable));
    
    reg bottom_menubar_display_enable;
    wire [11:0] bottom_menubar_pixel;
       blob #(.WIDTH(1024),.HEIGHT(100))
         bottom_menubar(.color(bottom_menubar_color),.x(0),.y(768-100),.hcount(hcount),.vcount(vcount), .pixel(bottom_menubar_pixel), .enable(bottom_menubar_display_enable));
         
     reg error_box_display_enable;
        wire [11:0] error_box_pixel;
            blob #(.WIDTH(700),.HEIGHT(300))
              error_box(.color(error_box_color), .x(512-350),.y(384-150),.hcount(hcount),.vcount(vcount), .pixel(error_box_pixel), .enable(error_box_display_enable));
    
      reg progress_bar_display_enable;
      reg [10:0] progress_bar_width = 0;
      wire [11:0] progress_bar_pixel;
            blob_animated progress_bar(.width(progress_bar_width), .height(20), .color('hFFF), .x(0),.y(384-10),.hcount(hcount),.vcount(vcount),
            .pixel(progress_bar_pixel), .enable(progress_bar_display_enable));
    



    wire [11:0] combined_sprite_pixels;
        
       wire sprite_enable1 =1, sprite_enable2 = 1, sprite_enable3 =1 , sprite_enable4=1, sprite_enable5=1, sprite_enable6=1, sprite_enable7=1, sprite_enable8=1, sprite_enable9=1, sprite_enable10=1;
       
       wire [15:0] bram_sprite_adr1, bram_sprite_adr2, bram_sprite_adr3, bram_sprite_adr4, bram_sprite_adr5, bram_sprite_adr6, bram_sprite_adr7, bram_sprite_adr8, bram_sprite_adr9, bram_sprite_adr10;
       wire [11:0] sprite_pixel1, sprite_pixel2, sprite_pixel3, sprite_pixel4, sprite_pixel5, sprite_pixel6, sprite_pixel7, sprite_pixel8, sprite_pixel9, sprite_pixel10;
       
    assign bram_sprite_adr = (bram_sprite_adr1 + bram_sprite_adr2 + bram_sprite_adr3 + bram_sprite_adr4 + bram_sprite_adr5 + bram_sprite_adr6 + bram_sprite_adr7 + bram_sprite_adr8 + bram_sprite_adr9 + bram_sprite_adr10);
      assign combined_sprite_pixels = (sprite_pixel1 + sprite_pixel2 + sprite_pixel3 + sprite_pixel4 + sprite_pixel5 + sprite_pixel6 + sprite_pixel7 + sprite_pixel8 + sprite_pixel9 + sprite_pixel10);
       

            // HeartAware logo icon
                      sprite sprite1(.color('hF00), .x(20), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(0), .sprite_x_right(143), .sprite_y_top(223), .sprite_y_bottom(355),
                .pixel(sprite_pixel1), .enable(sprite_enable1), .bram_read_adr(bram_sprite_adr1), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                
//                // HeartAware text
                        sprite sprite2(.color('hF00), .x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(610), .sprite_y_top(0), .sprite_y_bottom(61),
                 .pixel(sprite_pixel2), .enable(sprite_enable2), .bram_read_adr(bram_sprite_adr2), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                 
//                 // status text  collecting data...
//                         sprite sprite3(.color('hF00), .x(1024-400), .y(768-70-70), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(610), .sprite_y_top(61), .sprite_y_bottom(134),
//                  .pixel(sprite_pixel3), .enable(sprite_enable3), .bram_read_adr(bram_sprite_adr3), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                  
//                  // status text  paused.
//                          sprite sprite4(.color('hF00), .x(1024-400), .y(768-70-200), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(437), .sprite_y_top(134), .sprite_y_bottom(205),
//                   .pixel(sprite_pixel4), .enable(sprite_enable4), .bram_read_adr(bram_sprite_adr4), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                   
//                   // status text  error.
//                           sprite sprite5(.color('hF00), .x(1024-400), .y(768-70-400), .hcount(hcount), .vcount(vcount), .sprite_x_left(437), .sprite_x_right(576), .sprite_y_top(134), .sprite_y_bottom(205),
//                    .pixel(sprite_pixel5), .enable(sprite_enable5), .bram_read_adr(bram_sprite_adr5), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                    
//                    // BPM
//                            sprite sprite6(.color('hFFF), .x(700+125-50), .y(170+10), .hcount(hcount), .vcount(vcount), .sprite_x_left(178), .sprite_x_right(245), .sprite_y_top(229), .sprite_y_bottom(265),
//                     .pixel(sprite_pixel6), .enable(sprite_enable6), .bram_read_adr(bram_sprite_adr6), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                     
//                     // 100s place
//                             sprite sprite7(.color('hFFF), .x(700+20), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(143), .sprite_x_right(172), .sprite_y_top(281), .sprite_y_bottom(355),
//                      .pixel(sprite_pixel7), .enable(sprite_enable7), .bram_read_adr(bram_sprite_adr7), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                      
//                      // 10s place
//                              sprite sprite8(.color('hFFF), .x(700+20+60), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(222), .sprite_x_right(269), .sprite_y_top(281), .sprite_y_bottom(355),
//                       .pixel(sprite_pixel8), .enable(sprite_enable8), .bram_read_adr(bram_sprite_adr8), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                       
//                       // 1s place
//                               sprite sprite9(.color('hFFF), .x(700+20+40+60), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(515), .sprite_x_right(567), .sprite_y_top(281), .sprite_y_bottom(355),
//                        .pixel(sprite_pixel9), .enable(sprite_enable9), .bram_read_adr(bram_sprite_adr9), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
      
                       //          sprite sprite1(.color('hF00), .x(500), .y(500), .hcount(hcount), .vcount(vcount), .sprite_x_left(0), .sprite_x_right(610), .sprite_y_top(0), .sprite_y_bottom(355),
                  //      .pixel(sprite_pixel10), .enable(sprite_enable10), .bram_read_adr(bram_sprite_adr10), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
            
    assign r_out = at_display_area ? (background_color[11:8] + waveform_pixel[11:8] + top_menubar_pixel[11:8] + bottom_menubar_pixel[11:8] + error_box_pixel[11:8] + progress_bar_pixel[11:8] + combined_sprite_pixels[11:8]) : 0;
    assign g_out = at_display_area ? (background_color[7:4] + waveform_pixel[7:4] + top_menubar_pixel[7:4] + bottom_menubar_pixel[7:4] + error_box_pixel[7:4] + progress_bar_pixel[7:4] + combined_sprite_pixels[7:4]) : 0;
    assign b_out = at_display_area ? (background_color[3:0] + waveform_pixel[3:0] + top_menubar_pixel[3:0] + bottom_menubar_pixel[3:0] + error_box_pixel[3:0] + progress_bar_pixel[3:0] + combined_sprite_pixels[3:0]) : 0;
endmodule


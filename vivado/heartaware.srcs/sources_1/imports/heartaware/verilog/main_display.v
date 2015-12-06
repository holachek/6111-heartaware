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
    input clk_1hz,
    input [10:0] hcount,
    input [9:0] vcount,
    
    // bram
    output [17:0] bram_sprite_adr,
    input bram_sprite_input_data,
    output [17:0] bram_sprite_adrb,
    input bram_sprite_datab,
    
    input [7:0] number,
    
    output reg [7:0] debug1,
    output reg [7:0] debug2,
    
    input at_display_area,
    input [7:0] signal_in,
    input [2:0] system_status,
    output [10:0] signal_pix,
    output in_region,
    output reg [3:0] r_out,
    output reg [3:0] g_out,
    output reg [3:0] b_out);


    reg [11:0] waveform_color;
    reg [11:0] top_menubar_color;
    reg [11:0] bottom_menubar_color;
    reg [11:0] error_box_color;
    
    reg [11:0] background_color;
    
    reg [18:0] progress_bar_counter;
    reg [7:0] last_number;
    reg bcd_start;
    
    reg bram_sprite_data;

    // simple_binary_to_BCD BCDmodule(.clock(clk_100mhz), .start(bcd_start), .data(number), .d1(sprite_1s_number), .d10(sprite_10s_number));

    reg last_clk_1hz;

    always @ (posedge clk_100mhz) begin
    
    last_clk_1hz <= clk_1hz;
    

    if (last_clk_1hz == 0 && clk_1hz == 1) begin
    
        sprite_1s_number <= sprite_1s_number + 1;
        sprite_10s_number <= sprite_10s_number + 1;
        
        if (sprite_1s_number > 9) sprite_1s_number <= 0;
        if (sprite_10s_number > 9) sprite_10s_number <= 0;
    
    end
    
        debug1 <= sprite_1s_number;
    debug2[0] <= bcd_start;
    debug2[1] <= sprite_enable3;
    
        last_number <= number;
    
        if (last_number != number) bcd_start <= 1;
        else bcd_start <= 0;
    
        if (number > 99 && system_status == 1) begin
            sprite_enable3 <= 1;
        end else if (number < 99 || system_status != 1) begin
            sprite_enable3 <= 0;
       end
       
       
       
       

       
    
    
        if (system_status == 0) begin // paused
        
            sprite_enable10 <= 0;
            sprite_enable9 <= 1;
            sprite_enable8 <= 0;
            sprite_enable2 <= 0;
            
            sprite_enable5 <= 1;
            sprite_enable6 <= 1;
            sprite_enable4 <= 1;
        
            waveform_display_enable <= 1;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 0;
            waveform_color <= 'h666;
            top_menubar_color <= 'h666;
            bottom_menubar_color <= 'h666;
            error_box_color <= 'hFFF;
            progress_bar_width <= 0;
        
        end else if (system_status == 1) begin // running
        
        sprite_enable10 <= 0;
        sprite_enable9 <= 0;
        sprite_enable8 <= 0;
        sprite_enable2 <= 1;
        
        sprite_enable5 <= 1;
        sprite_enable6 <= 1;
        sprite_enable4 <= 1;
        
        waveform_display_enable <= 1;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 0;
            waveform_color <= 'h000;
            top_menubar_color <= 'hF22;
            bottom_menubar_color <= 'h17A;
            error_box_color <= 'hFFF;
            progress_bar_width <= 0;
        
        end else if (system_status == 2) begin // error
        
            sprite_enable10 <= 0;
            sprite_enable9 <= 0;
            sprite_enable8 <= 1;
            sprite_enable2 <= 0;
            
            sprite_enable5 <= 0;
            sprite_enable6 <= 0;
            sprite_enable4 <= 0;
        
            waveform_display_enable <= 0;
                    top_menubar_display_enable <= 1;
                    bottom_menubar_display_enable <= 1;
                    error_box_display_enable <= 1;
            waveform_color <= 'hFFF;
            top_menubar_color <= 'h666;
            bottom_menubar_color <= 'h666;
            error_box_color <= 'hF22;
            progress_bar_width <= 0;
        
        end else if (system_status == 3) begin //boot
            
            sprite_enable10 <= 1;
            sprite_enable9 <= 0;
            sprite_enable8 <= 0;
            sprite_enable2 <= 0;
        
            sprite_enable5 <= 0;
            sprite_enable6 <= 0;
            sprite_enable4 <= 0;
        
            progress_bar_display_enable <= 1;
            progress_bar_counter <= progress_bar_counter + 1;
            
            if (progress_bar_counter == 0 && progress_bar_width < 1024) begin
                progress_bar_width <= progress_bar_width + 1;
            end
        
            waveform_display_enable <= 0;
            top_menubar_display_enable <= 0;
            bottom_menubar_display_enable <= 0;
            error_box_display_enable <= 0;
            
        
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
       blob #(.WIDTH(250),.HEIGHT(100))
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
            blob_animated progress_bar(.width(progress_bar_width), .height(20), .color('h000), .x(0),.y(384-10),.hcount(hcount),.vcount(vcount),
            .pixel(progress_bar_pixel), .enable(progress_bar_display_enable));
    

    wire [10:0] sprite_10s_x_left, sprite_10s_x_right, sprite_10s_y_top, sprite_10s_y_bottom;
     wire [10:0] sprite_1s_x_left, sprite_1s_x_right, sprite_1s_y_top, sprite_1s_y_bottom;

    reg [3:0] sprite_10s_number;
    reg [3:0] sprite_1s_number;

display_sprite_map tens(.clk(clk_65mhz), .number(sprite_10s_number), .sprite_x_left(sprite_10s_x_left), .sprite_x_right(sprite_10s_x_right), .sprite_y_top(sprite_10s_y_top), .sprite_y_bottom(sprite_10s_y_bottom), .reset(0));
display_sprite_map ones(.clk(clk_65mhz), .number(sprite_1s_number), .sprite_x_left(sprite_1s_x_left), .sprite_x_right(sprite_1s_x_right), .sprite_y_top(sprite_1s_y_top), .sprite_y_bottom(sprite_1s_y_bottom), .reset(0));



    reg [11:0] combined_sprite_pixels;
    reg [17:0] bram_read_adr;
    
    reg [11:0] pixel_shaded;
    
    assign bram_sprite_adr = bram_read_adr;
        
       reg sprite_enable1 =1, sprite_enable2 = 1, sprite_enable3=1, sprite_enable4=1, sprite_enable5=1, sprite_enable6=1, sprite_enable7=1, sprite_enable8=1, sprite_enable9=1, sprite_enable10=1;
   //    wire [17:0] bram_sprite_adr1, bram_sprite_adr2, bram_sprite_adr3, bram_sprite_adr4, bram_sprite_adr5, bram_sprite_adr6, bram_sprite_adr7, bram_sprite_adr8, bram_sprite_adr9, bram_sprite_adr10;
   //    wire [11:0] sprite_pixel1, sprite_pixel2, sprite_pixel3, sprite_pixel4, sprite_pixel5, sprite_pixel6, sprite_pixel7, sprite_pixel8, sprite_pixel9, sprite_pixel10;
       
   // assign bram_sprite_adr = (bram_sprite_adr1 + bram_sprite_adr2 + bram_sprite_adr3 + bram_sprite_adr4 + bram_sprite_adr5 + bram_sprite_adr6 + bram_sprite_adr10);
   // assign bram_sprite_adrb = ( bram_sprite_adr7 + bram_sprite_adr8 + bram_sprite_adr9);
     // assign combined_sprite_pixels = (sprite_pixel1 + sprite_pixel2 + sprite_pixel3 + sprite_pixel4 + sprite_pixel5 + sprite_pixel6 + sprite_pixel7 + sprite_pixel8 + sprite_pixel9 + sprite_pixel10);
       
       reg [11:0] sprite_write_color;
       
       // this is really ugly and bad code practice, but we have to display sprites this way for the code to compile
       // TODO: fix parallel instantiation of sprite module
       parameter MASTER_SPRITE_WIDTH = 610;
       
       // HeartAware logo
       parameter SPRITE_X1 = 10;
       parameter SPRITE_Y1 = 20;
       parameter SPRITE_X_LEFT1 = 0;
       parameter SPRITE_X_RIGHT1 = 143;
       parameter SPRITE_Y_TOP1 = 223;
       parameter SPRITE_Y_BOTTOM1 = 355;
       
       // collecting data....
       parameter SPRITE_X2 = 1024-400;
       parameter SPRITE_Y2 = 768-70-20;
       parameter SPRITE_X_LEFT2 = 251;
       parameter SPRITE_X_RIGHT2 = 610;
       parameter SPRITE_Y_TOP2 = 61;
       parameter SPRITE_Y_BOTTOM2 = 134;
       
       // 100s place
       parameter SPRITE_X3 = 700+20+40;  // .sprite_x_left(144), .sprite_x_right(172), .sprite_y_top(281), .sprite_y_bottom(355),
       parameter SPRITE_Y3 = 100-80;
       parameter SPRITE_X_LEFT3 = 144;
       parameter SPRITE_X_RIGHT3 = 172;
       parameter SPRITE_Y_TOP3 = 281;
       parameter SPRITE_Y_BOTTOM3 = 355;
       
       // 10s place
       parameter SPRITE_X5 = 700+20+20+50;  // .sprite_x_left(144), .sprite_x_right(172), .sprite_y_top(281), .sprite_y_bottom(355),
       parameter SPRITE_Y5 = 100-80;
//       parameter SPRITE_X_LEFT5 = 367;
//       parameter SPRITE_X_RIGHT5 = 419;
//       parameter SPRITE_Y_TOP5 = 281;
//       parameter SPRITE_Y_BOTTOM5 = 355;
       
       // 1s place
       parameter SPRITE_X6 = 700+20+20+50+50;  // .sprite_x_left(144), .sprite_x_right(172), .sprite_y_top(281), .sprite_y_bottom(355),
       parameter SPRITE_Y6 = 100-80;
//       parameter SPRITE_X_LEFT6 = 515;
//       parameter SPRITE_X_RIGHT6 = 567;
//       parameter SPRITE_Y_TOP6 = 281;
//       parameter SPRITE_Y_BOTTOM6 = 355;
       
       // BPM
       parameter SPRITE_X4 = 700+125-40; // BPM .x(700+125-50), .y(170+10), .hcount(hcount), .vcount(vcount), .sprite_x_left(178), .sprite_x_right(245), .sprite_y_top(229), .sprite_y_bottom(265),
       parameter SPRITE_Y4 = 100+10;
       parameter SPRITE_X_LEFT4 = 178;
       parameter SPRITE_X_RIGHT4 = 245;
       parameter SPRITE_Y_TOP4 = 229;
       parameter SPRITE_Y_BOTTOM4 = 265;
       
       // HeartAware text
       parameter SPRITE_X7 = 143+20+5; // x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(580), .sprite_y_top(0), .sprite_y_bottom(61),
       parameter SPRITE_Y7 = 20+50;
       parameter SPRITE_X_LEFT7 = 261;
       parameter SPRITE_X_RIGHT7 = 580;
       parameter SPRITE_Y_TOP7 = 0;
       parameter SPRITE_Y_BOTTOM7 = 61;

        // error
       parameter SPRITE_X8 =400; // x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(580), .sprite_y_top(0), .sprite_y_bottom(61),
       parameter SPRITE_Y8 = 300;
       parameter SPRITE_X_LEFT8 = 437;
       parameter SPRITE_X_RIGHT8 = 576;
       parameter SPRITE_Y_TOP8 = 134;
       parameter SPRITE_Y_BOTTOM8 = 195;

        // paused
       parameter SPRITE_X9 = 1024-400; // x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(580), .sprite_y_top(0), .sprite_y_bottom(61),
       parameter SPRITE_Y9 = 768-70-20;
       parameter SPRITE_X_LEFT9 = 251;
       parameter SPRITE_X_RIGHT9 = 437;
       parameter SPRITE_Y_TOP9 = 134;
       parameter SPRITE_Y_BOTTOM9 = 205;

       // booting...
       parameter SPRITE_X10 = 400; // x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(580), .sprite_y_top(0), .sprite_y_bottom(61),
       parameter SPRITE_Y10 = 200;
       parameter SPRITE_X_LEFT10 = 251;
       parameter SPRITE_X_RIGHT10 = 463;
       parameter SPRITE_Y_TOP10 = 205;
       parameter SPRITE_Y_BOTTOM10 = 281;
       
       always @ (posedge clk_65mhz) begin
       
       r_out <= (background_color[11:8] + waveform_pixel[11:8] + pixel_shaded[11:8]);
      g_out <= (background_color[7:4] + waveform_pixel[7:4] + pixel_shaded[7:4]);
      b_out <= (background_color[3:0] + waveform_pixel[3:0] + pixel_shaded[3:0]);
      
      bram_sprite_data <= bram_sprite_input_data;
  
       
        if (combined_sprite_pixels)
            pixel_shaded <= combined_sprite_pixels;
        else
            pixel_shaded <= top_menubar_pixel + bottom_menubar_pixel + error_box_pixel + progress_bar_pixel;
       
        if (waveform_pixel + pixel_shaded)
            background_color = 0;
        else
            background_color = 'h0; // eventually should be white
            //////////////////////////
            //////////////////////////
            /////////////////////////
            // TODO: fix background color
       
           if (sprite_enable1 && ((hcount >= SPRITE_X1 && hcount < (SPRITE_X1+(SPRITE_X_RIGHT1-SPRITE_X_LEFT1))) &&
                   (vcount >= SPRITE_Y1 && vcount < (SPRITE_Y1+(SPRITE_Y_BOTTOM1-SPRITE_Y_TOP1))))) begin
                   
                   bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y1+SPRITE_Y_TOP1) + (hcount-SPRITE_X1+SPRITE_X_LEFT1);
                   sprite_write_color <= 'hF00;
                   
       end else if (sprite_enable2 && ((hcount >= SPRITE_X2 && hcount < (SPRITE_X2+(SPRITE_X_RIGHT2-SPRITE_X_LEFT2))) &&
                                          (vcount >= SPRITE_Y2 && vcount < (SPRITE_Y2+(SPRITE_Y_BOTTOM2-SPRITE_Y_TOP2))))) begin
                                          
             bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y2+SPRITE_Y_TOP2) + (hcount-SPRITE_X2+SPRITE_X_LEFT2);
             sprite_write_color <= 'hFFF;
                                          
       end else if (sprite_enable3 && ((hcount >= SPRITE_X3 && hcount < (SPRITE_X3+(SPRITE_X_RIGHT3-SPRITE_X_LEFT3))) &&
                                          (vcount >= SPRITE_Y3 && vcount < (SPRITE_Y3+(SPRITE_Y_BOTTOM3-SPRITE_Y_TOP3))))) begin
                                          
             bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y3+SPRITE_Y_TOP3) + (hcount-SPRITE_X3+SPRITE_X_LEFT3);
             sprite_write_color <= 'hFFF;
       
       end else if (sprite_enable4 && ((hcount >= SPRITE_X4 && hcount < (SPRITE_X4+(SPRITE_X_RIGHT4-SPRITE_X_LEFT4))) &&
                                          (vcount >= SPRITE_Y4 && vcount < (SPRITE_Y4+(SPRITE_Y_BOTTOM4-SPRITE_Y_TOP4))))) begin
                                          
             bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y4+SPRITE_Y_TOP4) + (hcount-SPRITE_X4+SPRITE_X_LEFT4);
             sprite_write_color <= 'hF00;
             
       end else if (sprite_enable5 && ((hcount >= SPRITE_X5 && hcount < (SPRITE_X5+(sprite_10s_x_right-sprite_10s_x_left))) &&
                                                      (vcount >= SPRITE_Y5 && vcount < (SPRITE_Y5+(sprite_10s_y_bottom-sprite_10s_y_top))))) begin
                                                      
                         bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y5+sprite_10s_y_top) + (hcount-SPRITE_X5+sprite_10s_x_left);
                         sprite_write_color <= 'hFFF;
            
                                end
                                
                                else if (sprite_enable6 && ((hcount >= SPRITE_X6 && hcount < (SPRITE_X6+(sprite_1s_x_right-sprite_1s_x_left))) &&
                                                                                      (vcount >= SPRITE_Y6 && vcount < (SPRITE_Y6+(sprite_1s_y_bottom-sprite_1s_y_top))))) begin
                                                                                      
                                                         bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y6+sprite_1s_y_top) + (hcount-SPRITE_X6+sprite_1s_x_left);
                                                         sprite_write_color <= 'hFFF;
                                            
                           end else if (sprite_enable7 && ((hcount >= SPRITE_X7 && hcount < (SPRITE_X7+(SPRITE_X_RIGHT7-SPRITE_X_LEFT7))) &&
                              (vcount >= SPRITE_Y7 && vcount < (SPRITE_Y7+(SPRITE_Y_BOTTOM7-SPRITE_Y_TOP7))))) begin
                                                      
                         bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y7+SPRITE_Y_TOP7) + (hcount-SPRITE_X7+SPRITE_X_LEFT7);
                         sprite_write_color <= 'hF00;
       
       
                                       end else if (sprite_enable8 && ((hcount >= SPRITE_X8 && hcount < (SPRITE_X8+(SPRITE_X_RIGHT8-SPRITE_X_LEFT8))) &&
                                               (vcount >= SPRITE_Y8 && vcount < (SPRITE_Y8+(SPRITE_Y_BOTTOM8-SPRITE_Y_TOP8))))) begin
                                               
                  bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y8+SPRITE_Y_TOP8) + (hcount-SPRITE_X8+SPRITE_X_LEFT8);
                  sprite_write_color <= 'hFFF;

                                                  end else if (sprite_enable9 && ((hcount >= SPRITE_X9 && hcount < (SPRITE_X9+(SPRITE_X_RIGHT9-SPRITE_X_LEFT9))) &&
                                               (vcount >= SPRITE_Y9 && vcount < (SPRITE_Y9+(SPRITE_Y_BOTTOM9-SPRITE_Y_TOP9))))) begin
                                               
                  bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y9+SPRITE_Y_TOP9) + (hcount-SPRITE_X9+SPRITE_X_LEFT9);
                  sprite_write_color <= 'hFFF;

                                                  end else if (sprite_enable10 && ((hcount >= SPRITE_X10 && hcount < (SPRITE_X10+(SPRITE_X_RIGHT10-SPRITE_X_LEFT10))) &&
                                               (vcount >= SPRITE_Y10 && vcount < (SPRITE_Y10+(SPRITE_Y_BOTTOM10-SPRITE_Y_TOP10))))) begin
                                               
                  bram_read_adr <= MASTER_SPRITE_WIDTH*(vcount-SPRITE_Y10+SPRITE_Y_TOP10) + (hcount-SPRITE_X10+SPRITE_X_LEFT10);
                  sprite_write_color <= 'hFFF;
                  
        end else begin
        
            bram_read_adr <= 0;
       
       end
       
           
           if (bram_sprite_data) combined_sprite_pixels <= sprite_write_color;
           else combined_sprite_pixels <= 0;

        end        
        

            // HeartAware logo icon
          //            sprite sprite1(.color('hF3F), .x(20), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(0), .sprite_x_right(610), .sprite_y_top(0), .sprite_y_bottom(355),
            //    .pixel(sprite_pixel1), .enable(sprite_enable1), .bram_read_adr(bram_sprite_adr1), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                
//                // HeartAware text
//                        sprite sprite2(.color('hF00), .x(143+20+30), .y(20), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(580), .sprite_y_top(0), .sprite_y_bottom(61),
//                 .pixel(sprite_pixel2), .enable(sprite_enable2), .bram_read_adr(bram_sprite_adr2), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                 
////                 // status text  collecting data...
//                         sprite sprite3(.color('hF00), .x(1024-400), .y(768-70-70), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(610), .sprite_y_top(61), .sprite_y_bottom(134),
//                  .pixel(sprite_pixel3), .enable(sprite_enable3), .bram_read_adr(bram_sprite_adr3), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                  
//                  // status text  paused.
//                          sprite sprite4(.color('hF00), .x(1024-400), .y(768-70-200), .hcount(hcount), .vcount(vcount), .sprite_x_left(251), .sprite_x_right(437), .sprite_y_top(134), .sprite_y_bottom(205),
//                   .pixel(sprite_pixel4), .enable(sprite_enable4), .bram_read_adr(bram_sprite_adr4), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                   
////                   // status text  error.
//                           sprite sprite5(.color('hF00), .x(1024-400), .y(768-70-400), .hcount(hcount), .vcount(vcount), .sprite_x_left(437), .sprite_x_right(576), .sprite_y_top(134), .sprite_y_bottom(205),
//                    .pixel(sprite_pixel5), .enable(sprite_enable5), .bram_read_adr(bram_sprite_adr5), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                    
//                    // BPM
//                            sprite sprite6(.color('hFFF), .x(700+125-50), .y(170+10), .hcount(hcount), .vcount(vcount), .sprite_x_left(178), .sprite_x_right(245), .sprite_y_top(229), .sprite_y_bottom(265),
//                     .pixel(sprite_pixel6), .enable(sprite_enable6), .bram_read_adr(bram_sprite_adr6), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
                     
//                     // 100s place
//                             sprite sprite7(.color('hFFF), .x(700+20), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(144), .sprite_x_right(172), .sprite_y_top(281), .sprite_y_bottom(355),
//                      .pixel(sprite_pixel7), .enable(sprite_enable7), .bram_read_adr(bram_sprite_adr7), .pixel_data(bram_sprite_datab), .clk(clk_65mhz));
                      
//                      // 10s place
//                              sprite sprite8(.color('hFFF), .x(700+20+60), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(222), .sprite_x_right(269), .sprite_y_top(281), .sprite_y_bottom(355),
//                       .pixel(sprite_pixel8), .enable(sprite_enable8), .bram_read_adr(bram_sprite_adr8), .pixel_data(bram_sprite_datab), .clk(clk_65mhz));
                       
//                       // 1s place
//                               sprite sprite9(.color('hFFF), .x(700+20+40+60), .y(170-100), .hcount(hcount), .vcount(vcount), .sprite_x_left(515), .sprite_x_right(567), .sprite_y_top(281), .sprite_y_bottom(355),
//                        .pixel(sprite_pixel9), .enable(sprite_enable9), .bram_read_adr(bram_sprite_adr9), .pixel_data(bram_sprite_datab), .clk(clk_65mhz));
      
                       //          sprite sprite1(.color('hF00), .x(500), .y(500), .hcount(hcount), .vcount(vcount), .sprite_x_left(0), .sprite_x_right(610), .sprite_y_top(0), .sprite_y_bottom(355),
                  //      .pixel(sprite_pixel10), .enable(sprite_enable10), .bram_read_adr(bram_sprite_adr10), .pixel_data(bram_sprite_data), .clk(clk_65mhz));
            
//    assign r_out = at_display_area ? (background_color[11:8] + waveform_pixel[11:8] + top_menubar_pixel[11:8] + bottom_menubar_pixel[11:8] + error_box_pixel[11:8] + progress_bar_pixel[11:8] + combined_sprite_pixels[11:8]) : 0;
//    assign g_out = at_display_area ? (background_color[7:4] + waveform_pixel[7:4] + top_menubar_pixel[7:4] + bottom_menubar_pixel[7:4] + error_box_pixel[7:4] + progress_bar_pixel[7:4] + combined_sprite_pixels[7:4]) : 0;
//    assign b_out = at_display_area ? (background_color[3:0] + waveform_pixel[3:0] + top_menubar_pixel[3:0] + bottom_menubar_pixel[3:0] + error_box_pixel[3:0] + progress_bar_pixel[3:0] + combined_sprite_pixels[3:0]) : 0;

     //   assign r_out = (background_color[11:8] + waveform_pixel[11:8] + pixel_shaded[11:8]);
       // assign g_out = (background_color[7:4] + waveform_pixel[7:4] + pixel_shaded[7:4]);
       // assign b_out = (background_color[3:0] + waveform_pixel[3:0] + pixel_shaded[3:0]);
    

endmodule


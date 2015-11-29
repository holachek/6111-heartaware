`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Main
// Description: Top Level HeartAware Module

//////////////////////////////////////////////////////////////////////////////////


// MODULE DEFINITION
//////////////////////////////////////////////////////////////////////////////////
module heartaware(

  // For hardware mapping constraints, see XDC file.

  // master clock
  input CLK100MHZ,

  // switches
  input [15:0] SW, 

  // directional buttons
  input BTNU,
  input BTND,
  input BTNL,
  input BTNR,
  input BTNC,

  // RGB LED
  output reg LED16_R, LED16_G, LED16_B, 
  output reg LED17_R, LED17_G, LED17_B, 

  // debug LEDs
  output reg [15:0] LED,

  // analog input module
  input [7:0] JA, // level shifted ADC_OUT[7:0]
  inout [7:0] JB,
  // JB[0] active low CS for ADC,
  // JB[2] active low RD for ADC,
  // JB[4] active low WR for ADC,
  // JB[6] active low INTR for ADC,
  // sensor connect detection
  // pins JB[3], JB[5], JB[7] disconnected. to use, edit constraints file.

  // 7-segment LED
  output [7:0] SEG,
  output [7:0] AN,

  // video
  output [3:0] VGA_R,
  output [3:0] VGA_G,
  output [3:0] VGA_B,
  output VGA_HS,
  output VGA_VS,

  // audio
  output AUD_PWM,
  output AUD_SD, // PWM audio enable

  // SD card
  input SD_CD,
  output SD_RESET,
  output SD_SCK,
  output SD_CMD, 
  inout [3:0] SD_DAT
  );

// CLOCKS, SYNC, & RESET
//////////////////////////////////////////////////////////////////////////////////
// create system and peripheral clocks, synced switches, master system reset

    wire master_reset;
    wire master_test;

    wire clk_100mhz = CLK100MHZ; // master clock
    wire clk_65mhz; // VGA clock
    wire clk_25mhz; // SD clock
    wire clk_48khz; // audio sample rate clock
    wire clk_1hz;
    
    wire clk_tone;
    reg [31:0] tone_divider = 32'd250_000;
    
    clk_wiz_0 clk_65mhz_inst(.clk_100mhz(clk_100mhz), .clk_65mhz(clk_65mhz), .reset(master_reset));
    clock_divider clk_25mhz_inst(.clk_in(clk_100mhz), .clk_out(clk_25mhz), .divider(32'd2), .reset(master_reset)); // (100_000_000 / 25_000_000) / 2 = 2
    clock_divider clk_48khz_inst(.clk_in(clk_100mhz), .clk_out(clk_48khz), .divider(32'd1042), .reset(master_reset)); // (100_000_000 / 48_000) / 2 = 1041.66
    clock_divider clk_tone_inst(.clk_in(clk_100mhz), .clk_out(clk_tone), .divider(tone_divider), .reset(master_reset));
    clock_divider clk_1hz_inst(.clk_in(clk_100mhz), .clk_out(clk_1hz), .divider(32'd50_000_000), .reset(master_reset));

    wire [15:0] sw_synced;
    genvar i;
    generate   for(i=0; i<16; i=i+1) 
      begin: gen_modules  // generate 16 synchronize modules
        synchronize s(clk_25mhz, SW[i], sw_synced[i]);
      end
    endgenerate

    assign master_reset = SW[15];
    


// DEBOUNCE OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create a synchronous, debounced pulse from async inputs

  wire btn_up, btn_down, btn_center, btn_left, btn_right;

  debounce up(.reset(master_reset), .clock(clk_25mhz), .noisy(BTNU), .clean(btn_up));
  debounce down(.reset(master_reset), .clock(clk_25mhz), .noisy(BTND), .clean(btn_down));
  debounce center(.reset(master_reset), .clock(clk_25mhz), .noisy(BTNC), .clean(btn_center));
  debounce left(.reset(master_reset), .clock(clk_25mhz), .noisy(BTNL), .clean(btn_left));
  debounce right(.reset(master_reset), .clock(clk_25mhz), .noisy(BTNR), .clean(btn_right));



// FSM OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// main user interface FSM



// 7 SEGMENT DISPLAY
//////////////////////////////////////////////////////////////////////////////////
// 7 segment display related utilities

  reg [31:0] display_data;
  


  // assign data = {'hFFFF, 'b0, SW[14:0]};

  wire [6:0] segments;
  display_8hex display(.clk(clk_100mhz), .data(display_data), .seg(segments), .strobe(AN));     // digit strobe
  assign SEG[6:0] = segments;
  assign SEG[7] = 1'b1;   // decimal point off






// VIDEO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to VGA video display
    
    wire [10:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, at_display_area;
    xvga xvga1(.vga_clock(clk_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.at_display_area(at_display_area));
    
    wire [3:0] r_out;
    wire [3:0] g_out;
    wire [3:0] b_out;
    
    main_display xvga_display(.hcount(hcount),.vcount(vcount),.at_display_area(at_display_area),.r_out(r_out),.g_out(g_out),.b_out(b_out));
          
    assign VGA_R = r_out; 
    assign VGA_G = g_out;
    assign VGA_B = b_out;
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
    
//    wire bram_sprite_en;
//    wire [3:0] bram_sprite_we;
//    wire [31:0] bram_sprite__addr;
//    wire [31:0] bram_sprite__din;
//    wire [31:0] bram_sprite_dout;
    
//    wire bram_font_en;
//    wire [3:0] bram_font_we;
//    wire [31:0] bram_font_addr;
//    wire [31:0] bram_font_din;
//    wire [31:0] bram_font_dout;

//    blk_mem_gen_0 sprite_memory_module(.clka(clk_100mhz), .ena(bram_sprite_en),
//        .wea(bram_sprite_we), .addra(bram_sprite_addr), .dina(bram_sprite_din), .douta(bram_sprite_dout));
        
//    blk_mem_gen_1 font_memory_module(.clka(clk_100mhz), .ena(bram_font_en),
//        .wea(bram_font_we), .addra(bram_font_addr), .dina(bram_font_din), .douta(bram_font_dout));
                                

// AUDIO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to PWM audio output

  wire [7:0] audio_data;
  reg [7:0] audio_data_modified;
  wire pwm_en = 1;
  
  assign AUD_SD = pwm_en;

  audio_PWM audio_PWM_module(.clk(clk_100mhz), .reset(master_reset),
        .music_data(audio_data_modified), .PWM_out(AUD_PWM));



// SD CARD
//////////////////////////////////////////////////////////////////////////////////
// SD card objects

//  wire spiMiso = 1;
//  reg rd; // when ready is high, asserting rd will begin a read
//  wire wr = 0;
//  wire rst = master_reset;
//  reg [31:0] adr; // address of read operation
//  wire [7:0] sd_din;
//  wire [7:0] sd_dout; // data output for read operation
//  wire byte_available; // signal that a new byte has been presented on dout
//  wire ready_for_next_byte;
//  wire [4:0] state; // for debug purposes

//  sd_controller sd_controller_module(.cs(SD_DAT[3]), .mosi(SD_CMD), .miso(spiMiso),
//        .sclk(SD_SCK), .rd(rd), .wr(wr), .reset(rst),
//        .din(sd_din), .dout(sd_dout), .byte_available(byte_available),
//        .ready(ready), .address(adr), 
//        .ready_for_next_byte(ready_for_next_byte), .clk(clk_25mhz), 
//        .status(state));

  reg [7:0] sd_dout;
  reg wr_en;
  reg rd_en;

  wire fifo_full;
  wire fifo_empty;
  wire [10:0] fifo_count;
  reg [7:0] counter;

  fifo_generator_0 audio_sample_buffer(.clk(clk_100mhz), .rst(master_reset), .din(sd_dout), .wr_en(wr_en),
        .rd_en(rd_en), .dout(audio_data), .full(fifo_full), .empty(fifo_empty), .data_count(fifo_count));

    reg last_btn_left = 0;
    reg last_btn_right = 0;
    
  
  always @ (posedge clk_tone) begin
  
      if (audio_data_modified)
         audio_data_modified <= 0;
      else
         audio_data_modified <= audio_data;
  
  end
  


  always @ (posedge clk_100mhz) begin
  
    if (master_reset) begin
        counter <= 0;
    end
  
    // display_data[7:0] <= audio_data[7:0];  
    // display_data[15:8] <= counter;
    //display_data[31:0] <= tone_divider;
    // LED[10:0] <= fifo_count[10:0];
  
    LED16_R <= fifo_full;
    LED16_B <= fifo_empty;
  
    last_btn_left <= btn_left;
    last_btn_right <= btn_right;

  
    // WRITE TO FIFO
    if (btn_left) begin
        if (last_btn_left == 0) begin
            tone_divider <= tone_divider - 5000;
            LED17_R <= 1;
            counter <= counter + 1;
            if (SW[7:0] == 0) begin
                sd_dout <= counter[7:0];
            end else begin
                sd_dout <= SW[7:0];
            end
            wr_en <= 1;
        end else begin
            wr_en <= 0;
            LED17_R <= 0;
        end
    end
        
    // READ FROM FIFO
    if (btn_right) begin
        if (last_btn_right == 0) begin
            tone_divider <= tone_divider + 5000;
            LED17_G <= 1;
            rd_en <= 1;
        end else begin
            rd_en <= 0;
            LED17_G <= 0;
        end
    end
                    
  
  
  end


// TESTING
//////////////////////////////////////////////////////////////////////////////////
// for testing purposes

//   always @ (clk_1hz) begin
   
//     // toggle red LED
//     if (clk_1hz == 1) LED16_R <= 0;
//     else LED16_R <= 1;
   
//   end

//  always @ (posedge clk_25mhz) begin
//    //if (btn_up) begin
//        LED16_R <= 1;
//        LED16_G <= 1;
//        LED16_B <= 1;
//        LED17_R <= 1;
//        LED17_G <= 1;
//        LED17_B <= 1;
//   // end else if (btn_up == 0) begin
////        LED16_R <= 0;
////        LED16_G <= 0;
////        LED16_B <= 0;
////        LED17_R <= 0;
////        LED17_G <= 0;
////        LED17_B <= 0;
////        LED[15:0] <= 'h0000;
////        data <= 'h0000_0000;
////        master_test_last_state <= 0;
////    end
//  end

    // assign LED = SW;     
    // assign JA[7:0] = 8'b0;
    



endmodule
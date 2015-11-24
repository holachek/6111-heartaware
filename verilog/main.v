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
    
    clk_wiz_0 clk_65mhz_inst(.clk_100mhz(clk_100mhz), .clk_65mhz(clk_65mhz), .reset(master_reset));
    clock_divider clk_25mhz_inst(.clk_in(clk_100mhz), .clk_out(clk_25mhz), .divider(32'd4), .reset(master_reset)); // 100_000_000 / 25_000_000 = 4
    clock_divider clk_48khz_inst(.clk_in(clk_100mhz), .clk_out(clk_48khz), .divider(32'd2083), .reset(master_reset)); // 100_000_000 / 48_000 = 2083.33
    clock_divider clk_1hz_inst(.clk_in(clk_100mhz), .clk_out(clk_1hz), .divider(32'd100_000_000), .reset(master_reset));

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

  wire btn_up;
  wire btn_down;

  debounce up(.reset(master_reset), .clock(clk_25mhz), .noisy(BTNU), .clean(btn_up));
  debounce down(.reset(master_reset), .clock(clk_25mhz), .noisy(BTND), .clean(btn_down));
  



// FSM OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// main user interface FSM




// VIDEO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to VGA video display





// AUDIO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to PWM audio output

  wire [7:0] audio_data = 'h2F;
  wire pwm_en = 1;
  
  assign AUD_SD = pwm_en;

  audio_PWM audio_PWM_module(.clk(clk_100mhz), .reset(master_reset), .music_data(audio_data), .PWM_out(AUD_PWM));



// SD CARD
//////////////////////////////////////////////////////////////////////////////////
// SD card objects

  wire spiMiso = 1;
  wire rd;
  wire wr;
  wire rst;
  wire [31:0] adr = 32'h0000_0000;
  wire [7:0] sd_din;
  wire [7:0] sd_dout;
  wire byte_available;
  wire ready_for_next_byte;
  wire [4:0] state;

  sd_controller sdcont(.cs(SD_DAT[3]), .mosi(SD_CMD), .miso(spiMiso),
            .sclk(SD_SCK), .rd(rd), .wr(wr), .reset(rst),
            .din(sd_din), .dout(sd_dout), .byte_available(byte_available),
            .ready(ready), .address(adr), 
            .ready_for_next_byte(ready_for_next_byte), .clk(clk_25mhz), 
            .status(state));

  wire fifo_full;
  wire fifo_empty;

  fifo_generator_0 audio_sample_buffer(.clk(clk_25mhz), .rst(master_reset), .din(sd_dout), .wr_en(byte_available), .rd_en(clk_48khz), .dout(audio_data), .full(fifo_full), .empty(fifo_empty));

// 7 SEGMENT DISPLAY
//////////////////////////////////////////////////////////////////////////////////
// 7 segment display related utilities

  wire [31:0] data;

  assign data = {'hFFFF, 'b0, SW[14:0]};

  wire [6:0] segments;
  display_8hex display(.clk(clk_100mhz), .data(data), .seg(segments), .strobe(AN));     // digit strobe
  assign SEG[6:0] = segments;
  assign SEG[7] = 1'b1;   // decimal point off



// TESTING
//////////////////////////////////////////////////////////////////////////////////
// for testing purposes

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
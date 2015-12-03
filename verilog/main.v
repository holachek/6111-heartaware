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
  output [7:0] JA, // level shifted ADC_OUT[7:0]
  output [7:0] JB,
  // JB[0] active low CS for ADC,
  // JB[2] active low RD for ADC,
  // JB[4] active low WR for ADC,
  // JB[6] active low INTR for ADC,
  // sensor connect detection
  // pins JB[3], JB[5], JB[7] disconnected. to use, edit constraints file.
  output [7:0] JC,
  output [7:0] JD,

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
  wire master_halt;

  wire clk_100mhz = CLK100MHZ; // master clock, connected to hardware crystal oscillator
  wire clk_65mhz; // VGA clock
  wire clk_25mhz; // SD clock
  wire clk_32khz; // audio sample rate clock
  wire clk_1hz;
      
  clk_wiz_0 clk_65mhz_module(.clk_100mhz(clk_100mhz), .clk_65mhz(clk_65mhz), .reset(master_clock_reset));
  clock_divider clk_25mhz_module(.clk_in(clk_100mhz), .clk_out(clk_25mhz), .divider(32'd2), .reset(master_clock_reset)); // 100_000_000 / (25_000_000*2) = 2
  clock_divider clk_32khz_module(.clk_in(clk_100mhz), .clk_out(clk_32khz), .divider(32'd1563), .reset(master_clock_reset)); // 100_000_000 / (32_000*2) = 1563
  clock_divider clk_1hz_module(.clk_in(clk_100mhz), .clk_out(clk_1hz), .divider(32'd200_000_000), .reset(master_clock_reset));

  wire [15:0] sw_synced;
  genvar i;
  generate   for(i=0; i<16; i=i+1) 
    begin: gen_modules  // generate 16 synchronize modules
      synchronize s(clk_100mhz, SW[i], sw_synced[i]); // WARNING! must be synced to master 100 MHz clock
                                                      // otherwise reset will stop clocks and halt CPU in reset state
    end
  endgenerate

    

  assign master_reset = sw_synced[15];
  assign master_halt = sw_synced[14];

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
  wire [6:0] display_segments;
  
  display_8hex display(.clk(clk_100mhz), .data(display_data), .seg(display_segments), .strobe(AN));
  
  assign SEG[6:0] = display_segments;
  assign SEG[7] = 1'b1;   // decimal point off

// assign data = {...}



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

  wire [7:0] pwm_audio_sample_data;
  reg pwm_en;
  assign AUD_SD = pwm_en;
  
  // use unsigned 8 bit uncompressed WAV file!
  audio_PWM audio_PWM_module(.clk(clk_100mhz), .reset(master_reset),
        .music_data(pwm_audio_sample_data), .PWM_out(AUD_PWM));


  reg [7:0] number_map_input_number;
  wire [7:0] number_map_output_number;
  wire [31:0] number_map_start_adr;
  wire [31:0] number_map_stop_adr;

  audio_number_map audio_number_map_module(.clk(clk_100mhz), .reset(master_reset),
        .number(number_map_input_number), .out_number(number_map_output_number),
        .start_adr(number_map_start_adr), .stop_adr(number_map_stop_adr));

// SD CARD
//////////////////////////////////////////////////////////////////////////////////
// SD card objects

  // general SD signals
  reg sd_rd; // when ready is high, asserting rd will begin a read
  wire sd_wr = 0;
  wire sd_ready;
  wire [4:0] sd_state; // for debug purposes
  
  // set SPI mode
  assign SD_DAT[2] = 1;
  assign SD_DAT[1] = 1;
  assign SD_RESET = 0;
    
  // read SD signals
  reg [31:0] sd_adr; // address of read operation
  wire [7:0] sd_dout; // data output for read operation
  wire sd_byte_available; // signal that a new byte has been presented on dout
  
  // write SD signals
  wire [7:0] sd_din = 0;
  wire sd_ready_for_next_byte = 0;
  
  
  sd_controller sd_controller_module(.cs(SD_DAT[3]), .mosi(SD_CMD), .miso(SD_DAT[0]),
        .sclk(SD_SCK), .rd(sd_rd), .wr(sd_wr), .reset(master_reset),
        .din(sd_din), .dout(sd_dout), .byte_available(sd_byte_available),
        .ready(sd_ready), .address(sd_adr), .clk(clk_25mhz), 
        .ready_for_next_byte(sd_ready_for_next_byte), .status(sd_state));



  reg fifo_wr_en;
  reg fifo_rd_en;
  
  wire [7:0] fifo_dout;
  assign fifo_dout = pwm_audio_sample_data;
  
  wire [7:0] fifo_din;
  assign fifo_din = sd_dout;

  wire fifo_full;
  wire fifo_empty;
  wire fifo_almost_empty;
  wire [13:0] fifo_count;
  

  fifo_generator_0 audio_sample_buffer(.clk(clk_100mhz), .rst(master_reset), .din(fifo_din), .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en), .dout(fifo_dout), .full(fifo_full), .empty(fifo_empty),
        .data_count(fifo_count), .almost_empty(fifo_almost_empty));



  reg last_clk_32khz;
  reg last_btn_up;
  reg last_btn_down;
  reg last_btn_center;
  reg last_btn_left;
  reg last_btn_right;
  reg last_last_btn_left;
  reg last_sd_byte_available;
  reg [5:0] read_counter;
  reg read_new_sample;
  reg sd_state_changed;
  reg [4:0] last_sd_state;
  reg [14:0] sd_rd_counter;
  reg [31:0] sample_increment;
  reg last_audio_playing;
  reg last_fifo_empty;
  
  reg [3:0] audio_number_loop_count;
  
  reg last_audio_announcer;
  reg begin_audio_announcer = 0;
  
  reg audio_announcer_state;
  
  reg last_clk_1hz;
  
  reg audio_number_loop_playing;
  reg last_audio_number_loop_playing;
  
  reg audio_playing_done;
  
  reg end_of_number_sample = 0;
  
  
  reg audio_playing;
  
  reg [15:0] exit_count;
  
  
  // must end in 00
  reg [31:0] sd_start_adr = 'hcd_000;
  reg [31:0] sd_stop_adr = 'h100_000;
  reg [31:0] internal_sd_stop_adr;
  
  reg audio_play_lockout;
  
  reg [15:0] audio_beep_counter;



    assign JA[7:0] = sd_start_adr[23:16];
    
    assign JB[7:0] = sd_stop_adr[23:16];
    
    assign JC[0] = audio_playing;
    assign JC[1] = audio_playing_done;
    assign JC[2] = audio_number_loop_playing;
    assign JC[6:3] = audio_number_loop_count[3:0];
    assign JC[7] = master_reset;


  always @ (posedge clk_100mhz) begin
  
    if (master_reset) begin
        read_counter <= 0;
        sd_rd <= 0;
        fifo_rd_en <= 0;
        audio_playing <= 0;
        sd_adr <= 'hcd_000;
        sd_start_adr <= 'hcd_000;
        sd_stop_adr <= 'h100_000;
        LED16_R <= 1;
        LED16_G <= 0;
        LED16_B <= 0;
        LED17_R <= 0;
        LED17_G <= 0;
        LED17_B <= 0;
        LED[15] <= 1;
    end else if (master_halt) begin
        // do nothing! used for capturing address of SD card when writing number map
    end else begin
        LED16_R <= 0;
        LED[15] <= 0;
        last_clk_32khz <= clk_32khz;
        last_clk_1hz <= clk_1hz;
        
        // mtn press history used for btn edge triggers
         last_btn_up <= btn_up;
         last_btn_down <= btn_down;
         last_btn_center <= btn_center;
         last_btn_left <= btn_left;
         last_btn_right <= btn_right;
         
        // misc edge triggers
         last_audio_playing <= audio_playing;
         last_sd_byte_available <= sd_byte_available;
         last_audio_number_loop_playing <= audio_number_loop_playing;
         last_fifo_empty <= fifo_empty;
    

    // play windows startup tone
    if (last_btn_right == 0 && btn_right == 1) begin
        sd_start_adr <= 'hcd_000;
        sd_stop_adr <= 'h100_000;
        audio_playing <= 1;
    end
    
    // play system error
    if (last_btn_left == 0 && btn_left == 1) begin
        sd_start_adr <= 'hbf_a00;
        sd_stop_adr <= 'hcc_000;
        audio_playing <= 1;
    end
    
    // play number from switch
    if (last_btn_center == 0 && btn_center == 1) begin
        audio_number_loop_playing <= 1;
    end
    
    
    if (clk_1hz == 1 && last_clk_1hz == 0) begin
    
        audio_beep_counter <= 1;
        audio_playing <= 0;
        
    //    // flatline
    //    sd_start_adr <= 'h114_e00;
    //    sd_stop_adr <= 'h150_e00;
    
    end
    
    
    if (audio_beep_counter == 1) begin
            //    // beep
            sd_start_adr <= 'h111_600;
            sd_stop_adr <= 'h114_e00;
            audio_playing <= 1;
            audio_beep_counter <= 0;
    end
    
    // KNOWN BUG:
    // FIRST SAMPLE PLAYED MIGHT BUZZ AT START
    // Possible fix is to check sample fifo buffer and make sure it contains real audio data, not just buzz
        
        
    /// WORKING CODE TO PLAY NUMBER FROM SWITCH INPUT
    // DO NOT MODIFY
    
    if (audio_number_loop_playing == 1 && audio_play_lockout == 0) begin
    
       // check if number is zero after playing, play beats per minute
       if (number_map_input_number == 0 && audio_number_loop_count > 0) begin
             audio_number_loop_playing <= 0;
             audio_number_loop_count <= 0;
       end
    
       // init number from switches, load first adrs
       else if (audio_number_loop_count == 0) begin
             number_map_input_number <= SW[7:0];
             audio_playing <= 1;
             sd_start_adr <= number_map_start_adr;
             sd_stop_adr <= number_map_stop_adr;
            audio_number_loop_count <= audio_number_loop_count + 1;
        end
        
        // play first number
        else if (audio_number_loop_count == 1) begin
             audio_playing <= 1;
             sd_start_adr <= number_map_start_adr;
             sd_stop_adr <= number_map_stop_adr;
            audio_number_loop_count <= audio_number_loop_count + 1;        
        end
        
        // play next numbers
        else if (audio_number_loop_count > 1 && audio_playing_done == 1) begin
            number_map_input_number <= number_map_output_number;
            sd_start_adr <= number_map_start_adr;
             sd_stop_adr <= number_map_stop_adr;
             audio_playing <= 1; 
             audio_number_loop_count <= audio_number_loop_count + 1;
        end
       
        // if number is zero before playing, quit
        else if (number_map_input_number == 0) begin
            audio_number_loop_playing <= 0;
            audio_number_loop_count <= 0;
        end

                  
    end
    
    


     // WORKING CODE FOR AUDIO PLAYBACK
     // provide sd_start_addr, sd_stop_addr, audio_playing_en
     // DO NOT MODIFY-

    // sd_byte_available can trigger high multiple cycles for one byte
    // we use this to ensure a positive clock edge
    // do not use fifo_wr_en <= sd_byte_available
    if (last_sd_byte_available == 0 && sd_byte_available == 1) begin
          fifo_wr_en <= 1;
    end else begin
          fifo_wr_en <= 0;
    end
    

      if (audio_playing) begin
      
         // load correct start address if beginning playback
         if (last_audio_playing == 0) begin
            sd_adr <= sd_start_adr;
            internal_sd_stop_adr <= sd_stop_adr;
            pwm_en <= 1;
         end
         
         else begin
                  
              // load samples from SD
             if (fifo_count < 'd50 && sd_adr <= internal_sd_stop_adr) begin // fifo_count < 'd50
                 sd_rd <= 1;
             end else begin
                 sd_rd <= 0;
             end
          
              // read samples from FIFO
              if (clk_32khz == 1 && last_clk_32khz == 0 && fifo_empty == 0) begin
                  fifo_rd_en <= 1; // will output a new sample on fifo_dout
                  sample_increment <= sample_increment + 1;
              end else begin
                  fifo_rd_en <= 0;
              end
              
              // used for continuous playback
              if (sample_increment >= 511) begin
                 sd_adr <= sd_adr + 32'h200;
                 sample_increment <= 0;
              end
              
              if (sd_adr >= internal_sd_stop_adr && last_audio_playing == 1) begin // not the best way to do this! but it works. in future use conditional fifo_empty check
                pwm_en <= 0;
                audio_playing <= 0;
                audio_playing_done <= 1;
              end
          
          end
                  
      end else begin

            sd_adr <= 0;
            pwm_en <= 0;
            audio_playing_done <= 0;

      end // audio_playing
      
      



  
  // display_data[7:0] <= audio_data[7:0];  
  // display_data[15:8] <= counter;
  // display_data[7:0] <= fifo_dout[7:0];
  // display_data[23:8] <= sd_adr[23:8];
  // LED[7:0] <= fifo_count[7:0];
  // display_data[31:24] <= sd_state;
  
 // display_data[7:0] <= number_map_input_number;
  // display_data[15:8] <= number_map_output_number;
  //display_data[15:8] <= input_number;

 // display_data[23:16] <= sd_start_adr[15:8]; 
  display_data[31:0] <= sd_adr[31:0];

  LED[3:0] <= audio_number_loop_count;
  // LED16_R <= fifo_full;
  // LED16_B <= fifo_empty;
  // LED17_G <= sd_ready;
  // LED17_B <= sd_byte_available;
  
  
  end // reset
end // always @




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
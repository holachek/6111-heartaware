`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: System FSM
// Description: Four state FSM for program user interface control

//////////////////////////////////////////////////////////////////////////////////


// MODULE DEFINITION
//////////////////////////////////////////////////////////////////////////////////
module heartaware_fsm(

  // master clock
  input CLK100MHZ,

  // not finished
  );


// CLOCKS, SYNC, & RESET
//////////////////////////////////////////////////////////////////////////////////
// create 25mhz system clock, switch syncs, reset assignment

    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

    wire [15:0] switch_synced;
    genvar i;
    generate   for(i=0; i<16; i=i+1) 
      begin: gen_modules  // generate 16 synchronize modules
        synchronize s(clock_25mhz, SW[i], switch_synced[i]);
      end
    endgenerate

    wire system_reset;
    assign system_reset = switched_synced[15];
 
    
// DEBOUNCE OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create a synchronous, debounced pulse from async inputs

  wire button_volume_up;
  wire button_volume_down;

  debounce volume_up(.reset(system_reset), .clock(clock_25mhz), .noisy(BTNU), .clean(button_volume_up));
  debounce volume_down(.reset(system_reset), .clock(clock_25mhz), .noisy(BTND), .clean(button_volume_down));


// TIMING OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create necessary timers to run all modules, based on 25 MHz master clock

  wire clock_1hz;
  wire expired;
  wire start_timer;
  wire [1:0] timer_interval;
  wire [3:0] timer_value;
  wire [3:0] timer_counter;

  wire [31:0] cycle_divider_count;
  // assign cycle_divider_count = (SW[14] ? 'd3 : 'd12_500_000);

  assign cycle_divider_count = 12_500_000;

  clock_divider clock_1hz_divider(.clock_25mhz(clock_25mhz), .reset(system_reset), .cycles(cycle_divider_count), .clock_divided(clock_1hz));
  // reset timer upon system reset switch, ignition switch, or reprogram switch activation
  timer2 timer_module(.clock_25mhz(clock_25mhz), .clock_1hz(clock_1hz), .reset(system_reset || ignition_switch_signal || reprogram_switch_signal), .value(timer_value), .expired(expired), .start_timer(start_timer), .external_counter(timer_counter));
  time_parameters time_parameters_module(.clock_25mhz(clock_25mhz), .reset(system_reset), .time_parameter_selector(switch_sync[5:4]), .new_value(switch_sync[3:0]), .reprogram_switch(reprogram_switch_signal), .interval(timer_interval), .value(timer_value));


  // timer debug
  assign LED16_R = expired;
  assign LED17_G = start_timer;



// FSM OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// main user interface FSM

  wire status_indicator;
  wire [3:0] fsm_state;
  wire siren_enable;

  // reg red = 0;
  // reg green = 0;
  // reg blue = 0;

  // assign LED16_R = red;
  // assign LED16_G = green;
  // assign LED16_B = blue;

  assign LED[0] = status_indicator;



// VIDEO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to VGA video display

  wire fuel_pump_power;

  fuel_pump fuel_pump_module(.clock_25mhz(clock_25mhz), .reset(system_reset), .ignition_switch(ignition_switch_signal), .hidden_switch(hidden_switch_signal), .brake_switch(brake_switch_signal), .fuel_pump_power(fuel_pump_power));

  assign LED[1] = fuel_pump_power;



// AUDIO
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to PWM audio output

  wire [7:0] audio_data;
  // AUD_SD enable

  audio_PWM audio_PWM_module(.clk(CLK100MHZ), .reset(system_reset), .music_data(audio_data), .PWM_out(AUD_PWM));



// 7 SEGMENT DISPLAY
//////////////////////////////////////////////////////////////////////////////////
// 7 segment display related utilities

  wire [31:0] data;

  assign data = 'hFFFFFFFF;

  wire [6:0] segments;
  display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));     // digit strobe
  assign SEG[6:0] = segments;
  assign SEG[7] = 1'b1;   // decimal point off



// TESTING
//////////////////////////////////////////////////////////////////////////////////
// for testing purposes

    assign LED[7] = switch_sync[7];

    assign LED[15:10] = {6{system_reset}};

    // assign LED = SW;     
    // assign JA[7:0] = 8'b0;
    
    // assign LED16_R=BTNL;
    // assign LED16_G=BTNC;
    // assign LED16_B=BTNR;
    
    // assign LED17_R=BTNL;
    // assign LED17_G=BTNC;
    // assign LED17_B=BTNR;


endmodule



module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule
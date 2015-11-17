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
  input BTNC, BTNU, BTNL, BTNR, BTND,

  // RGB LED
  output LED16_R, LED16_G, LED16_B, 
  output LED17_R, LED17_G, LED17_B, 

  // input module
  input [7:0] JA, // level shifted ADC_OUT[7:0]
  output JB[0], // active low CS for ADC,
  output JB[2], // active low RD for ADC,
  output JB[4], // active low WR for ADC,
  input JB[6], // active low INTR for ADC,
  input JB[1], // sensor connect detection
  // pins JB[3], JB[5], JB[7] disconnected. to use, edit constraints file.

  // video
  output [3:0] VGA_R,
  output [3:0] VGA_G,
  output [3:0] VGA_B,
  output VGA_HS,
  output VGA_VS,

  // audio
  output AUD_PWM,
  output AUD_SD,

  // SD card
  input SD_CD,
  output SD_RESET,
  output SD_SCK,
  output SD_CMD, 
  inout [3:0] SD_DAT
  );



// CLOCKS, SYNC, & RESET
//////////////////////////////////////////////////////////////////////////////////
// create 25mhz system clock, switch syncs, reset assignment

    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

    wire [15:0] switch_sync;
    genvar i;
    generate   for(i=0; i<16; i=i+1) 
      begin: gen_modules  // generate 16 synchronize modules
        synchronize s(clock_25mhz, SW[i], switch_sync[i]);
      end
    endgenerate

    wire system_reset;
    assign system_reset = switch_sync[15];
 
    
// DEBOUNCE OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create a synchronous, debounced pulse from async inputs

  wire brake_switch_signal;
  wire hidden_switch_signal;
  wire ignition_switch_signal;
  wire driver_door_signal;
  wire passenger_door_signal;
  wire reprogram_switch_signal;

  debounce brake_switch_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(BTND), .clean(brake_switch_signal));
  debounce hidden_switch_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(BTNU), .clean(hidden_switch_signal));
  debounce ignition_switch_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(switch_sync[7]), .clean(ignition_switch_signal));
  debounce driver_door_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(BTNL), .clean(driver_door_signal));
  debounce passenger_door_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(BTNR), .clean(passenger_door_signal));
  debounce reprogram_switch_debounce(.reset(system_reset), .clock(clock_25mhz), .noisy(BTNC), .clean(reprogram_switch_signal));



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
// main anti theft state machine and related objects

  wire status_indicator;
  wire [3:0] fsm_state;
  wire siren_enable;

  anti_theft anti_theft_fsm(.clock_25mhz(clock_25mhz), .clock_1hz(clock_1hz), .reset(system_reset), .ignition_switch(ignition_switch_signal), .driver_door(driver_door_signal), .passenger_door(passenger_door_signal), .reprogram_switch(reprogram_switch_signal), .expired(expired), .interval(timer_interval), .start_timer(start_timer), .siren_enable(siren_enable), .status_indicator(status_indicator), .state(fsm_state));

  // reg red = 0;
  // reg green = 0;
  // reg blue = 0;

  // assign LED16_R = red;
  // assign LED16_G = green;
  // assign LED16_B = blue;

  assign LED[0] = status_indicator;



// FUEL PUMP OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to fuel pump control

  wire fuel_pump_power;

  fuel_pump fuel_pump_module(.clock_25mhz(clock_25mhz), .reset(system_reset), .ignition_switch(ignition_switch_signal), .hidden_switch(hidden_switch_signal), .brake_switch(brake_switch_signal), .fuel_pump_power(fuel_pump_power));

  assign LED[1] = fuel_pump_power;



// SIREN SOUND OBJECTS
//////////////////////////////////////////////////////////////////////////////////
// create all objects related to siren feature

  wire speaker_pin;

  siren siren_module(.clock_25mhz(clock_25mhz), .clock_1hz(clock_1hz), .enable(siren_enable), .speaker_pin(speaker_pin));

  assign JA[0] = speaker_pin;



// 7 SEGMENT DISPLAY
//////////////////////////////////////////////////////////////////////////////////
// 7 segment display related utilities

  wire [31:0] data;

  // left display: [state] [] [] []
  // right display: [] [time_param] [time_param_value] [current_timer_value]

  wire [7:0] system_debug_data;
  wire [11:0] timer_debug_data;

  assign system_debug_data = {fsm_state[3:0], 4'b0};
  assign timer_debug_data = {2'b0, timer_interval[1:0], timer_value[3:0], timer_counter[3:0]};

  assign data = {system_debug_data, 12'h0, timer_debug_data};

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
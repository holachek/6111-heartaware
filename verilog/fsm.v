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
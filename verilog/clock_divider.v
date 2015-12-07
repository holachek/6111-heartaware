`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Clock Divider
// Description: Generate custom clock

//////////////////////////////////////////////////////////////////////////////////


// note on choosing a divider number
// clk_in_frequency / (clk_out_frequency*2) = divider

// ex, with a 100 MHz input clock, to make a 32 kHz clock, we get a clock divider of
// 100_000_000 / (32_000*2) = 1563


module clock_divider(input clk_in, input [31:0] divider, output reg clk_out = 0, input reset);
    // divider const max = 2^32 - 1

    reg [31:0] counter = 0;

    always @(posedge clk_in) begin
        if (reset == 1) begin
            counter <= 0;
            clk_out <= 0;
        end else if (counter == divider - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
            clk_out <= clk_out;
        end

    end // always @
        
endmodule
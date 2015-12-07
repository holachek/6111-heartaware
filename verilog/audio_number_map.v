`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware
// M. Holachek and N. Singh
// 6.111 Final Project, Fall 2015
// https://github.com/holachek/heartaware

// Module: Audio Number Map
// Description: Generate start/stop addresses of audio files from number that needs to be spoken

//////////////////////////////////////////////////////////////////////////////////

module audio_number_map(input clk, input [7:0] number, output reg [31:0] start_adr,
output reg [31:0] stop_adr, output reg [7:0] out_number, input reset);

    // capable of playing numbers 1-199
    // special number 230 for "beats per minute"

    always @(posedge clk) begin
	
		if (reset) begin
		
			out_number <= 0;
			start_adr <= 0;
			stop_adr <= 0;
			
		end else begin
		
		    if (number == 230) begin // say beats per minute
                start_adr <= 'hb2_800;
                stop_adr <= 'hbf_a00;
                out_number <= 0;
			end
			
			else if (number >= 100 && number < 200) begin // say one hundred
				start_adr <= 'h3_600;
				stop_adr <= 'hd_000;
				if (number == 100) out_number <= 230;
				else out_number <= number - 100;
			end
			
			else if (number >= 90 && number < 100) begin // say ninety
				start_adr <= 'hd_600;
				stop_adr <= 'h12_400;
				if (number == 90) out_number <= 230;
                else out_number <= number - 90;
			end
			
			else if (number >= 80 && number < 90) begin // say eighty
				start_adr <= 'h12_400;
				stop_adr <= 'h17_c00;
				if (number == 80) out_number <= 230;
                else out_number <= number - 80;
			end
			
			else if (number >= 70 && number < 80) begin // say seventy
				start_adr <= 'h17_c00;
				stop_adr <= 'h1e_c00;
				if (number == 70) out_number <= 230;
                else out_number <= number - 70;
			end
			
			else if (number >= 60 && number < 70) begin // say sixty
				start_adr <= 'h1e_c00;
				stop_adr <= 'h24_800;
				if (number == 60) out_number <= 230;
                 else out_number <= number - 60;
			end
			
			else if (number >= 50 && number < 60) begin // say fifty
				start_adr <= 'h24_800;
				stop_adr <= 'h2b_600;
				if (number == 50) out_number <= 230;
                else out_number <= number - 50;
			end
			
			else if (number >= 40 && number < 50) begin // say fourty
				start_adr <= 'h2b_600;
				stop_adr <= 'h32_800;
				if (number == 40) out_number <= 230;
                else out_number <= number - 40;
			end
			
			else if (number >= 30 && number < 40) begin // say thirty
				start_adr <= 'h31_800;
				stop_adr <= 'h37_400;
				if (number == 30) out_number <= 230;
                else out_number <= number - 30;
			end
			
			else if (number >= 20 && number < 30) begin // say twenty
				start_adr <= 'h37_400;
				stop_adr <= 'h3d_000;
				if (number == 20) out_number <= 230;
                else out_number <= number - 20;
			end
			
			else if (number == 19) begin // say nineteen
				start_adr <= 'h43_000;
				stop_adr <= 'h4a_800;
				out_number <= 230;
			end
			
			else if (number == 18) begin // say eighteen
				start_adr <= 'h4a_800;
				stop_adr <= 'h51_400;
				out_number <= 230;
			end

			else if (number == 17) begin // say seventeen
				start_adr <= 'h51_400;
				stop_adr <= 'h57_200;
				out_number <= 230;
			end

			else if (number == 16) begin // say sixteen
				start_adr <= 'h57_200;
				stop_adr <= 'h5d_400;
				out_number <= 230;
			end

			else if (number == 15) begin // say fifteen
				start_adr <= 'h5d_400;
				stop_adr <= 'h63_e00;
				out_number <= 230;
			end		
			
			else if (number == 14) begin // say fourteen
				start_adr <= 'h63_e00;
				stop_adr <= 'h69_400;
				out_number <= 230;
			end		
			
			else if (number == 13) begin // say thirteen
				start_adr <= 'h69_400;
				stop_adr <= 'h6f_400;
				out_number <= 230;
			end		
			
			else if (number == 12) begin // say twelve
				start_adr <= 'h6f_400;
				stop_adr <= 'h75_e00;
				out_number <= 230;
			end		
			
			else if (number == 11) begin // say eleven
				start_adr <= 'h75_e00;
				stop_adr <= 'h7b_400;
				out_number <= 230;
			end		
			
			else if (number == 10) begin // say ten
				start_adr <= 'h3d_000;
				stop_adr <= 'h43_000;
				out_number <= 230;
			end		
			
			else if (number == 9) begin // say nine
				start_adr <= 'h7b_400;
				stop_adr <= 'h83_400;
				out_number <= 230;
			end		
			
			else if (number == 8) begin // say eight
				start_adr <= 'h83_400;
				stop_adr <= 'h88_e00;
				out_number <= 230;
			end		
			
			else if (number == 7) begin // say seven
				start_adr <= 'h88_e00;
				stop_adr <= 'h8e_800;
				out_number <= 230;
			end		
			
			else if (number == 6) begin // say six
				start_adr <= 'h8e_800;
				stop_adr <= 'h95_000;
				out_number <= 230;
			end		
			
			else if (number == 5) begin // say five
				start_adr <= 'h95_000;
				stop_adr <= 'h9a_200;
				out_number <= 230;
			end		
			
			else if (number == 4) begin // say four
				start_adr <= 'h9a_200;
				stop_adr <= 'ha0_c00;
				out_number <= 230;
			end		
			
			else if (number == 3) begin // say three
				start_adr <= 'ha0_c00;
				stop_adr <= 'ha7_c00;
				out_number <= 230;
			end		
			
			else if (number == 2) begin // say two
				start_adr <= 'ha7_c00;
				stop_adr <= 'hae_600;
				out_number <= 230;
			end	

			else if (number == 1) begin // say one
				start_adr <= 'hae_600;
				stop_adr <= 'hb2_800;
				out_number <= 230;
			end
			
			else begin
                start_adr <= 0;
                stop_adr <= 0;
                out_number <= 0;
            end
		
		end // reset check

    end // always @
        
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 6.111 Lecture Pset 8, Problem 1
// Simple binary to BCD converter
// Michael Holachek
//////////////////////////////////////////////////////////////////////////////////

module simple_binary_to_BCD(
	input clock,
	input start,
	input [7:0] data,
	output reg [3:0] d1,
	output reg [3:0] d10,
	output reg [3:0] d100
	);

	reg started = 0;
	reg [7:0] last_number;
	reg [7:0] binary_number = 0;

	always @ (posedge clock) begin

		if (start == 1 && started == 0 && last_number != data) begin
		    d1 <= 0;
		    d10 <= 0;
		    d100 <= 0;
			started <= 1;
			last_number <= data;
			binary_number <= data;
		end

		if (started) begin
		
			if (binary_number > 99) begin
				binary_number <= binary_number - 100;
				d100 <= d100 + 1;
			end else if (binary_number > 9) begin
				binary_number <= binary_number - 10;
				d10 <= d10 + 1;
			end else if (binary_number > 0) begin
				binary_number <= binary_number - 1;
				d1 <= d1 + 1;
			end else if (binary_number == 0) begin
			     started <= 0;
			end

		end // end started block

	end // end always @ block

endmodule



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
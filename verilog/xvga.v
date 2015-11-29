////////////////////////////////////////////////////////////////////////////////
//
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)
//
////////////////////////////////////////////////////////////////////////////////

module xvga(input vga_clock,
            output reg [10:0] hcount = 0,    // pixel number on current line
            output reg [9:0] vcount = 0,	 // line number
            output vsync, hsync, at_display_area);
    // Counters.
    always @(posedge vga_clock) begin
        if (hcount == 1343) begin
            hcount <= 0;
        end
        else begin
            hcount <= hcount +  1;
        end
        if (vcount == 805) begin
            vcount <= 0;
        end
        else if(hcount == 1343) begin
            vcount <= vcount + 1;
        end
    end
    
    assign hsync = (hcount < 136);
    assign vsync = (vcount < 6);
    assign at_display_area = (hcount >= 296 && hcount < 1320 && vcount >= 35 && vcount < 803);
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// vga: Generate VGA display signals (640 x 480 @ 25Hz)
//
////////////////////////////////////////////////////////////////////////////////
module vga(input vga_clock,
            output reg [9:0] hcount = 0,    // pixel number on current line
            output reg [9:0] vcount = 0,	 // line number
            output vsync, hsync, at_display_area);
    // Counters.
    always @(posedge vga_clock) begin
        if (hcount == 799) begin
            hcount <= 0;
        end
        else begin
            hcount <= hcount +  1;
        end
        if (vcount == 524) begin
            vcount <= 0;
        end
        else if(hcount == 799) begin
            vcount <= vcount + 1;
        end
    end
    
    assign hsync = (hcount < 96);
    assign vsync = (vcount < 2);
    assign at_display_area = (hcount >= 144 && hcount < 784 && vcount >= 35 && vcount < 515);
endmodule
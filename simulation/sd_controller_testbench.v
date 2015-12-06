`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// HeartAware

//////////////////////////////////////////////////////////////////////////////////

module sd_controller_testbench;

	// Inputs (reg)
   reg miso;
   reg rd; 
   reg wr;
   reg [7:0] din;
   reg reset;
   reg [31:0] address;
   reg clk;

   // Outputs (wire)
   wire cs;
   wire mosi;
   wire sclk;
   wire [7:0] dout;
   wire byte_available;
   wire ready_for_next_byte;
   wire ready;
   wire [4:0] status;

   // Instantiate the Unit Under Test (UUT)
   sd_controller sd_controller_uut(
       .cs(cs), // Connect to SD_DAT[3].
       .mosi(mosi), // Connect to SD_CMD.
       .miso(miso), // Connect to SD_DAT[0].
       .sclk(sclk), // Connect to SD_SCK.
                   // For SPI mode, SD_DAT[2] and SD_DAT[1] should be held HIGH. 
                   // SD_RESET should be held LOW.
   
       .rd(rd),   
                   // begin a 512-byte READ operation at [address]. 
                   // [byte_available] will transition HIGH as a new byte has been
                   // read from the SD card. The byte is presented on [dout].
       .dout(dout), // Data .for READ operation.
       .byte_available(byte_available), // A new byte has been presented on [dout].
   
       .wr(wr),   
                   // begin a 512-byte WRITE operation at [address].
                   // [ready_for_next_byte] will transition HIGH to request that
                   // the next byte to be written should be presentaed on [din].
       .din(din), // Data input for WRITE operation.
       .ready_for_next_byte(ready_for_next_byte), // A new byte should be presented on [din].
   
       .reset(reset), // Resets controller on assertion.
       .ready(ready), // HIGH if the SD card is ready for a read or write operation.
       .address(address),   // Memory address for read/write operation. This MUST 
                               // be a multiple of 512 bytes, due to SD sectoring.
       .clk(clk),  // 25 MHz clock.
       .status(status) // For debug purposes: Current state of controller.
   );
 
   // Clock Generation
   always #4 clk = !clk;


   initial begin
      // Initialize Inputs
      clk = 0;
      address = 0;
      reset = 0;

      // Wait 100 ns for global reset to finish
      #100;
      
      rd = 1;
      #10;
      rd = 0;

      #1000000;
      

   end

endmodule



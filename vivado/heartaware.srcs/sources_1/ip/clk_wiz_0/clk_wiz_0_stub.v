// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2.1 (win64) Build 1302555 Wed Aug  5 13:06:02 MDT 2015
// Date        : Sun Dec 06 23:28:21 2015
// Host        : PolarMarquis-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub {C:/Users/Polar
//               Marquis/Desktop/heartaware-master/heartaware-master/vivado/heartaware.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v}
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_100mhz, clk_65mhz, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_100mhz,clk_65mhz,reset,locked" */;
  input clk_100mhz;
  output clk_65mhz;
  input reset;
  output locked;
endmodule

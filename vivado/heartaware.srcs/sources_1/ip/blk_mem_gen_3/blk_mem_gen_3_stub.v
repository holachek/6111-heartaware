// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2.1 (win64) Build 1302555 Wed Aug  5 13:06:02 MDT 2015
// Date        : Sun Dec 06 23:26:19 2015
// Host        : PolarMarquis-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub {c:/Users/Polar
//               Marquis/Desktop/heartaware-master/heartaware-master/vivado/heartaware.srcs/sources_1/ip/blk_mem_gen_3/blk_mem_gen_3_stub.v}
// Design      : blk_mem_gen_3
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2015.2.1" *)
module blk_mem_gen_3(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[16:0],clkb,enb,addrb[9:0],doutb[16:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [16:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [16:0]doutb;
endmodule

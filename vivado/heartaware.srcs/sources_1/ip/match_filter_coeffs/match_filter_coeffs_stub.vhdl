-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2.1 (win64) Build 1302555 Wed Aug  5 13:06:02 MDT 2015
-- Date        : Sun Dec 06 23:27:33 2015
-- Host        : PolarMarquis-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub {c:/Users/Polar
--               Marquis/Desktop/heartaware-master/heartaware-master/vivado/heartaware.srcs/sources_1/ip/match_filter_coeffs/match_filter_coeffs_stub.vhdl}
-- Design      : match_filter_coeffs
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity match_filter_coeffs is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 8 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 6 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 8 downto 0 )
  );

end match_filter_coeffs;

architecture stub of match_filter_coeffs is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[6:0],dina[8:0],clkb,enb,addrb[6:0],doutb[8:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_2,Vivado 2015.2.1";
begin
end;

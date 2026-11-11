-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Mon Sep 28 17:43:31 2026
-- Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/user1/x_prj/T7_MSDR/t7_fpga_v0.5/src/ip/ila_fsm_dbg/ila_fsm_dbg_stub.vhdl
-- Design      : ila_fsm_dbg
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcau15p-sbvb484-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_fsm_dbg is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe4 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe7 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe8 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe9 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe10 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe12 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe13 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe14 : in STD_LOGIC_VECTOR ( 64 downto 0 );
    probe15 : in STD_LOGIC_VECTOR ( 64 downto 0 );
    probe16 : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end ila_fsm_dbg;

architecture stub of ila_fsm_dbg is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[3:0],probe1[3:0],probe2[3:0],probe3[0:0],probe4[3:0],probe5[31:0],probe6[31:0],probe7[31:0],probe8[26:0],probe9[26:0],probe10[26:0],probe11[26:0],probe12[26:0],probe13[23:0],probe14[64:0],probe15[64:0],probe16[15:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2024.1";
begin
end;

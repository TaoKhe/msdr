-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Sat Oct 17 14:24:55 2026
-- Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/user1/v_0_6_1_d_I_Claudio/FPGA/src/ip/ila_deframer_meta_ip/ila_deframer_meta_ip_stub.vhdl
-- Design      : ila_deframer_meta_ip
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcau15p-sbvb484-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_deframer_meta_ip is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe7 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe8 : in STD_LOGIC_VECTOR ( 47 downto 0 );
    probe9 : in STD_LOGIC_VECTOR ( 47 downto 0 )
  );

end ila_deframer_meta_ip;

architecture stub of ila_deframer_meta_ip is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[0:0],probe1[63:0],probe2[26:0],probe3[26:0],probe4[3:0],probe5[3:0],probe6[7:0],probe7[7:0],probe8[47:0],probe9[47:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2024.1";
begin
end;

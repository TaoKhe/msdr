-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Tue Nov 10 08:26:56 2026
-- Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/taokhe/Projects/in/msdr/msdr_gen/msdr.gen/sources_1/bd/system/ip/system_util_dac_1_upack_0/system_util_dac_1_upack_0_stub.vhdl
-- Design      : system_util_dac_1_upack_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu15eg-ffvb1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_util_dac_1_upack_0 is
  Port ( 
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    enable_0 : in STD_LOGIC;
    enable_1 : in STD_LOGIC;
    enable_2 : in STD_LOGIC;
    enable_3 : in STD_LOGIC;
    fifo_rd_en : in STD_LOGIC;
    fifo_rd_valid : out STD_LOGIC;
    fifo_rd_underflow : out STD_LOGIC;
    fifo_rd_data_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    fifo_rd_data_1 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    fifo_rd_data_2 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    fifo_rd_data_3 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_valid : in STD_LOGIC;
    s_axis_ready : out STD_LOGIC;
    s_axis_data : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );

end system_util_dac_1_upack_0;

architecture stub of system_util_dac_1_upack_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,reset,enable_0,enable_1,enable_2,enable_3,fifo_rd_en,fifo_rd_valid,fifo_rd_underflow,fifo_rd_data_0[15:0],fifo_rd_data_1[15:0],fifo_rd_data_2[15:0],fifo_rd_data_3[15:0],s_axis_valid,s_axis_ready,s_axis_data[63:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "util_upack2,Vivado 2024.1";
begin
end;

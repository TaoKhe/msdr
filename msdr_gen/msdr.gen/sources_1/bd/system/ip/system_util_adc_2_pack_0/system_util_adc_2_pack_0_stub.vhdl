-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Tue Nov 10 08:25:49 2026
-- Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/taokhe/Projects/in/msdr/msdr_gen/msdr.gen/sources_1/bd/system/ip/system_util_adc_2_pack_0/system_util_adc_2_pack_0_stub.vhdl
-- Design      : system_util_adc_2_pack_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu15eg-ffvb1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_util_adc_2_pack_0 is
  Port ( 
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    enable_0 : in STD_LOGIC;
    enable_1 : in STD_LOGIC;
    fifo_wr_en : in STD_LOGIC;
    fifo_wr_overflow : out STD_LOGIC;
    fifo_wr_data_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    fifo_wr_data_1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    packed_fifo_wr_en : out STD_LOGIC;
    packed_fifo_wr_overflow : in STD_LOGIC;
    packed_fifo_wr_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    packed_sync : out STD_LOGIC
  );

end system_util_adc_2_pack_0;

architecture stub of system_util_adc_2_pack_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,reset,enable_0,enable_1,fifo_wr_en,fifo_wr_overflow,fifo_wr_data_0[15:0],fifo_wr_data_1[15:0],packed_fifo_wr_en,packed_fifo_wr_overflow,packed_fifo_wr_data[31:0],packed_sync";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "util_cpack2,Vivado 2024.1";
begin
end;

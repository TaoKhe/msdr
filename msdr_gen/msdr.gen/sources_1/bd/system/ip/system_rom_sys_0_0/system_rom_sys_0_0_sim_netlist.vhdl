-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Tue Nov 10 08:23:34 2026
-- Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode funcsim
--               /home/taokhe/Projects/in/msdr/msdr_gen/msdr.gen/sources_1/bd/system/ip/system_rom_sys_0_0/system_rom_sys_0_0_sim_netlist.vhdl
-- Design      : system_rom_sys_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu15eg-ffvb1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_rom_sys_0_0_sysid_rom is
  port (
    rom_data : out STD_LOGIC_VECTOR ( 28 downto 0 );
    rom_addr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    clk : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of system_rom_sys_0_0_sysid_rom : entity is "sysid_rom";
end system_rom_sys_0_0_sysid_rom;

architecture STRUCTURE of system_rom_sys_0_0_sysid_rom is
  signal \rom_data[0]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[0]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[10]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[10]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[11]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[11]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[12]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[12]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[13]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[13]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[14]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[14]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[16]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[16]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[17]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[17]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[18]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[18]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[19]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[19]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[1]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[1]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[20]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[20]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[21]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[21]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[22]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[22]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[24]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[24]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[24]_i_3_n_0\ : STD_LOGIC;
  signal \rom_data[25]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[25]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[25]_i_3_n_0\ : STD_LOGIC;
  signal \rom_data[26]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[26]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[27]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[27]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[27]_i_3_n_0\ : STD_LOGIC;
  signal \rom_data[28]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[28]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[29]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[29]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[29]_i_3_n_0\ : STD_LOGIC;
  signal \rom_data[2]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[2]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[30]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[30]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[30]_i_3_n_0\ : STD_LOGIC;
  signal \rom_data[3]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[3]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[4]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[4]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[5]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[5]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[6]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[6]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[7]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[7]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[8]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[8]_i_2_n_0\ : STD_LOGIC;
  signal \rom_data[9]_i_1_n_0\ : STD_LOGIC;
  signal \rom_data[9]_i_2_n_0\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \rom_data[11]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \rom_data[16]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \rom_data[20]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \rom_data[27]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \rom_data[29]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \rom_data[4]_i_1\ : label is "soft_lutpair1";
begin
\rom_data[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[0]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[0]_i_1_n_0\
    );
\rom_data[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0515000100002020"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[0]_i_2_n_0\
    );
\rom_data[10]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[24]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[10]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[10]_i_1_n_0\
    );
\rom_data[10]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"01054000000000A2"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[10]_i_2_n_0\
    );
\rom_data[11]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \rom_data[11]_i_2_n_0\,
      I1 => rom_addr(6),
      O => \rom_data[11]_i_1_n_0\
    );
\rom_data[11]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000040000000"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(1),
      I3 => rom_addr(0),
      I4 => rom_addr(4),
      I5 => rom_addr(7),
      O => \rom_data[11]_i_2_n_0\
    );
\rom_data[12]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[30]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[12]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[12]_i_1_n_0\
    );
\rom_data[12]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4004444002220002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(1),
      I4 => rom_addr(2),
      I5 => rom_addr(4),
      O => \rom_data[12]_i_2_n_0\
    );
\rom_data[13]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[13]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[13]_i_1_n_0\
    );
\rom_data[13]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5444444502202202"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(4),
      O => \rom_data[13]_i_2_n_0\
    );
\rom_data[14]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[14]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[14]_i_1_n_0\
    );
\rom_data[14]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1041400100000800"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(1),
      I2 => rom_addr(2),
      I3 => rom_addr(0),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[14]_i_2_n_0\
    );
\rom_data[16]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => rom_addr(7),
      I1 => \rom_data[16]_i_2_n_0\,
      I2 => rom_addr(6),
      O => \rom_data[16]_i_1_n_0\
    );
\rom_data[16]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4511400100002020"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(1),
      I2 => rom_addr(2),
      I3 => rom_addr(0),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[16]_i_2_n_0\
    );
\rom_data[17]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[27]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[17]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[17]_i_1_n_0\
    );
\rom_data[17]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0144400000000082"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[17]_i_2_n_0\
    );
\rom_data[18]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[18]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[18]_i_1_n_0\
    );
\rom_data[18]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0404440000002000"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(1),
      I4 => rom_addr(2),
      I5 => rom_addr(4),
      O => \rom_data[18]_i_2_n_0\
    );
\rom_data[19]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[27]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[19]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[19]_i_1_n_0\
    );
\rom_data[19]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000100000200"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(1),
      I3 => rom_addr(2),
      I4 => rom_addr(0),
      I5 => rom_addr(4),
      O => \rom_data[19]_i_2_n_0\
    );
\rom_data[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[27]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[1]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[1]_i_1_n_0\
    );
\rom_data[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0404004440222001"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[1]_i_2_n_0\
    );
\rom_data[20]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => rom_addr(7),
      I1 => \rom_data[20]_i_2_n_0\,
      I2 => rom_addr(6),
      O => \rom_data[20]_i_1_n_0\
    );
\rom_data[20]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"05004000000000A2"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[20]_i_2_n_0\
    );
\rom_data[21]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[21]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[21]_i_1_n_0\
    );
\rom_data[21]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5444444500202202"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(4),
      O => \rom_data[21]_i_2_n_0\
    );
\rom_data[22]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[22]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[22]_i_1_n_0\
    );
\rom_data[22]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5055000100000800"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[22]_i_2_n_0\
    );
\rom_data[24]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[24]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[24]_i_3_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[24]_i_1_n_0\
    );
\rom_data[24]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000400000002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(1),
      I3 => rom_addr(2),
      I4 => rom_addr(0),
      I5 => rom_addr(4),
      O => \rom_data[24]_i_2_n_0\
    );
\rom_data[24]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1440400440002002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[24]_i_3_n_0\
    );
\rom_data[25]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[25]_i_3_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[25]_i_1_n_0\
    );
\rom_data[25]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0005000100000002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[25]_i_2_n_0\
    );
\rom_data[25]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1044444200202004"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[25]_i_3_n_0\
    );
\rom_data[26]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[27]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[26]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[26]_i_1_n_0\
    );
\rom_data[26]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5101400100002020"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(1),
      I2 => rom_addr(2),
      I3 => rom_addr(0),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[26]_i_2_n_0\
    );
\rom_data[27]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[27]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[27]_i_3_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[27]_i_1_n_0\
    );
\rom_data[27]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00020000"
    )
        port map (
      I0 => rom_addr(3),
      I1 => rom_addr(1),
      I2 => rom_addr(2),
      I3 => rom_addr(0),
      I4 => rom_addr(4),
      O => \rom_data[27]_i_2_n_0\
    );
\rom_data[27]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000100200008"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(1),
      I3 => rom_addr(2),
      I4 => rom_addr(0),
      I5 => rom_addr(4),
      O => \rom_data[27]_i_3_n_0\
    );
\rom_data[28]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[30]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[28]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[28]_i_1_n_0\
    );
\rom_data[28]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000400400002200"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(4),
      O => \rom_data[28]_i_2_n_0\
    );
\rom_data[29]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[29]_i_3_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[29]_i_1_n_0\
    );
\rom_data[29]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"03010000"
    )
        port map (
      I0 => rom_addr(0),
      I1 => rom_addr(2),
      I2 => rom_addr(1),
      I3 => rom_addr(3),
      I4 => rom_addr(4),
      O => \rom_data[29]_i_2_n_0\
    );
\rom_data[29]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5444444440202206"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[29]_i_3_n_0\
    );
\rom_data[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[2]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[2]_i_1_n_0\
    );
\rom_data[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"040140010000080A"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(1),
      I2 => rom_addr(2),
      I3 => rom_addr(0),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[2]_i_2_n_0\
    );
\rom_data[30]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[30]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[30]_i_3_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[30]_i_1_n_0\
    );
\rom_data[30]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0004000100000002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(0),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(3),
      I5 => rom_addr(4),
      O => \rom_data[30]_i_2_n_0\
    );
\rom_data[30]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5444044040200006"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[30]_i_3_n_0\
    );
\rom_data[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[30]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[3]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[3]_i_1_n_0\
    );
\rom_data[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000080011000"
    )
        port map (
      I0 => rom_addr(3),
      I1 => rom_addr(2),
      I2 => rom_addr(1),
      I3 => rom_addr(0),
      I4 => rom_addr(4),
      I5 => rom_addr(5),
      O => \rom_data[3]_i_2_n_0\
    );
\rom_data[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => rom_addr(7),
      I1 => \rom_data[4]_i_2_n_0\,
      I2 => rom_addr(6),
      O => \rom_data[4]_i_1_n_0\
    );
\rom_data[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4040404403212122"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(0),
      I5 => rom_addr(3),
      O => \rom_data[4]_i_2_n_0\
    );
\rom_data[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[5]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[5]_i_1_n_0\
    );
\rom_data[5]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4444444442222306"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(0),
      I3 => rom_addr(2),
      I4 => rom_addr(1),
      I5 => rom_addr(3),
      O => \rom_data[5]_i_2_n_0\
    );
\rom_data[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[25]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[6]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[6]_i_1_n_0\
    );
\rom_data[6]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0404040043000314"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(0),
      I5 => rom_addr(3),
      O => \rom_data[6]_i_2_n_0\
    );
\rom_data[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000010"
    )
        port map (
      I0 => rom_addr(7),
      I1 => rom_addr(4),
      I2 => \rom_data[7]_i_2_n_0\,
      I3 => rom_addr(5),
      I4 => rom_addr(6),
      O => \rom_data[7]_i_1_n_0\
    );
\rom_data[7]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0046"
    )
        port map (
      I0 => rom_addr(2),
      I1 => rom_addr(1),
      I2 => rom_addr(0),
      I3 => rom_addr(3),
      O => \rom_data[7]_i_2_n_0\
    );
\rom_data[8]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20002000000F0000"
    )
        port map (
      I0 => \rom_data[29]_i_2_n_0\,
      I1 => rom_addr(5),
      I2 => rom_addr(8),
      I3 => rom_addr(7),
      I4 => \rom_data[8]_i_2_n_0\,
      I5 => rom_addr(6),
      O => \rom_data[8]_i_1_n_0\
    );
\rom_data[8]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4444000043200136"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(4),
      I2 => rom_addr(2),
      I3 => rom_addr(1),
      I4 => rom_addr(0),
      I5 => rom_addr(3),
      O => \rom_data[8]_i_2_n_0\
    );
\rom_data[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80800300"
    )
        port map (
      I0 => \rom_data[30]_i_2_n_0\,
      I1 => rom_addr(8),
      I2 => rom_addr(7),
      I3 => \rom_data[9]_i_2_n_0\,
      I4 => rom_addr(6),
      O => \rom_data[9]_i_1_n_0\
    );
\rom_data[9]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0440000400220002"
    )
        port map (
      I0 => rom_addr(5),
      I1 => rom_addr(3),
      I2 => rom_addr(0),
      I3 => rom_addr(1),
      I4 => rom_addr(2),
      I5 => rom_addr(4),
      O => \rom_data[9]_i_2_n_0\
    );
\rom_data_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[0]_i_1_n_0\,
      Q => rom_data(0),
      R => '0'
    );
\rom_data_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[10]_i_1_n_0\,
      Q => rom_data(10),
      R => '0'
    );
\rom_data_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[11]_i_1_n_0\,
      Q => rom_data(11),
      R => rom_addr(8)
    );
\rom_data_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[12]_i_1_n_0\,
      Q => rom_data(12),
      R => '0'
    );
\rom_data_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[13]_i_1_n_0\,
      Q => rom_data(13),
      R => '0'
    );
\rom_data_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[14]_i_1_n_0\,
      Q => rom_data(14),
      R => '0'
    );
\rom_data_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[16]_i_1_n_0\,
      Q => rom_data(15),
      R => rom_addr(8)
    );
\rom_data_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[17]_i_1_n_0\,
      Q => rom_data(16),
      R => '0'
    );
\rom_data_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[18]_i_1_n_0\,
      Q => rom_data(17),
      R => '0'
    );
\rom_data_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[19]_i_1_n_0\,
      Q => rom_data(18),
      R => '0'
    );
\rom_data_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[1]_i_1_n_0\,
      Q => rom_data(1),
      R => '0'
    );
\rom_data_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[20]_i_1_n_0\,
      Q => rom_data(19),
      R => rom_addr(8)
    );
\rom_data_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[21]_i_1_n_0\,
      Q => rom_data(20),
      R => '0'
    );
\rom_data_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[22]_i_1_n_0\,
      Q => rom_data(21),
      R => '0'
    );
\rom_data_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[24]_i_1_n_0\,
      Q => rom_data(22),
      R => '0'
    );
\rom_data_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[25]_i_1_n_0\,
      Q => rom_data(23),
      R => '0'
    );
\rom_data_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[26]_i_1_n_0\,
      Q => rom_data(24),
      R => '0'
    );
\rom_data_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[27]_i_1_n_0\,
      Q => rom_data(25),
      R => '0'
    );
\rom_data_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[28]_i_1_n_0\,
      Q => rom_data(26),
      R => '0'
    );
\rom_data_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[29]_i_1_n_0\,
      Q => rom_data(27),
      R => '0'
    );
\rom_data_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[2]_i_1_n_0\,
      Q => rom_data(2),
      R => '0'
    );
\rom_data_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[30]_i_1_n_0\,
      Q => rom_data(28),
      R => '0'
    );
\rom_data_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[3]_i_1_n_0\,
      Q => rom_data(3),
      R => '0'
    );
\rom_data_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[4]_i_1_n_0\,
      Q => rom_data(4),
      R => rom_addr(8)
    );
\rom_data_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[5]_i_1_n_0\,
      Q => rom_data(5),
      R => '0'
    );
\rom_data_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[6]_i_1_n_0\,
      Q => rom_data(6),
      R => '0'
    );
\rom_data_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[7]_i_1_n_0\,
      Q => rom_data(7),
      R => rom_addr(8)
    );
\rom_data_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[8]_i_1_n_0\,
      Q => rom_data(8),
      R => '0'
    );
\rom_data_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \rom_data[9]_i_1_n_0\,
      Q => rom_data(9),
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_rom_sys_0_0 is
  port (
    clk : in STD_LOGIC;
    rom_addr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    rom_data : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of system_rom_sys_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of system_rom_sys_0_0 : entity is "system_rom_sys_0_0,sysid_rom,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of system_rom_sys_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of system_rom_sys_0_0 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of system_rom_sys_0_0 : entity is "sysid_rom,Vivado 2024.1";
end system_rom_sys_0_0;

architecture STRUCTURE of system_rom_sys_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^rom_data\ : STD_LOGIC_VECTOR ( 30 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, FREQ_HZ 99999992, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_sys_ps8_0_pl_clk0, INSERT_VIP 0";
begin
  rom_data(31) <= \<const0>\;
  rom_data(30 downto 24) <= \^rom_data\(30 downto 24);
  rom_data(23) <= \<const0>\;
  rom_data(22 downto 16) <= \^rom_data\(22 downto 16);
  rom_data(15) <= \<const0>\;
  rom_data(14 downto 0) <= \^rom_data\(14 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.system_rom_sys_0_0_sysid_rom
     port map (
      clk => clk,
      rom_addr(8 downto 0) => rom_addr(8 downto 0),
      rom_data(28 downto 22) => \^rom_data\(30 downto 24),
      rom_data(21 downto 15) => \^rom_data\(22 downto 16),
      rom_data(14 downto 0) => \^rom_data\(14 downto 0)
    );
end STRUCTURE;

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Tue Nov 10 01:01:07 2026
// Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/taokhe/Projects/in/msdr/msdr_gen/msdr.gen/sources_1/bd/system/ip/system_rom_sys_0_0/system_rom_sys_0_0_sim_netlist.v
// Design      : system_rom_sys_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_rom_sys_0_0,sysid_rom,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "package_project" *) 
(* X_CORE_INFO = "sysid_rom,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module system_rom_sys_0_0
   (clk,
    rom_addr,
    rom_data);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 99999992, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_sys_ps8_0_pl_clk0, INSERT_VIP 0" *) input clk;
  input [8:0]rom_addr;
  output [31:0]rom_data;

  wire \<const0> ;
  wire clk;
  wire [8:0]rom_addr;
  wire [31:0]\^rom_data ;

  assign rom_data[31:24] = \^rom_data [31:24];
  assign rom_data[23] = \<const0> ;
  assign rom_data[22:16] = \^rom_data [22:16];
  assign rom_data[15] = \<const0> ;
  assign rom_data[14:12] = \^rom_data [14:12];
  assign rom_data[11] = \<const0> ;
  assign rom_data[10:0] = \^rom_data [10:0];
  GND GND
       (.G(\<const0> ));
  system_rom_sys_0_0_sysid_rom inst
       (.clk(clk),
        .rom_addr(rom_addr),
        .rom_data({\^rom_data [31:24],\^rom_data [22:16],\^rom_data [14:12],\^rom_data [10:0]}));
endmodule

(* ORIG_REF_NAME = "sysid_rom" *) 
module system_rom_sys_0_0_sysid_rom
   (rom_data,
    rom_addr,
    clk);
  output [28:0]rom_data;
  input [8:0]rom_addr;
  input clk;

  wire clk;
  wire [8:0]rom_addr;
  wire [28:0]rom_data;
  wire \rom_data[0]_i_1_n_0 ;
  wire \rom_data[0]_i_2_n_0 ;
  wire \rom_data[10]_i_1_n_0 ;
  wire \rom_data[10]_i_2_n_0 ;
  wire \rom_data[12]_i_1_n_0 ;
  wire \rom_data[12]_i_2_n_0 ;
  wire \rom_data[13]_i_1_n_0 ;
  wire \rom_data[13]_i_2_n_0 ;
  wire \rom_data[14]_i_1_n_0 ;
  wire \rom_data[14]_i_2_n_0 ;
  wire \rom_data[16]_i_1_n_0 ;
  wire \rom_data[16]_i_2_n_0 ;
  wire \rom_data[17]_i_1_n_0 ;
  wire \rom_data[17]_i_2_n_0 ;
  wire \rom_data[18]_i_1_n_0 ;
  wire \rom_data[18]_i_2_n_0 ;
  wire \rom_data[19]_i_1_n_0 ;
  wire \rom_data[19]_i_2_n_0 ;
  wire \rom_data[1]_i_1_n_0 ;
  wire \rom_data[1]_i_2_n_0 ;
  wire \rom_data[20]_i_1_n_0 ;
  wire \rom_data[20]_i_2_n_0 ;
  wire \rom_data[21]_i_1_n_0 ;
  wire \rom_data[21]_i_2_n_0 ;
  wire \rom_data[22]_i_1_n_0 ;
  wire \rom_data[22]_i_2_n_0 ;
  wire \rom_data[24]_i_1_n_0 ;
  wire \rom_data[24]_i_2_n_0 ;
  wire \rom_data[24]_i_3_n_0 ;
  wire \rom_data[25]_i_1_n_0 ;
  wire \rom_data[25]_i_2_n_0 ;
  wire \rom_data[25]_i_3_n_0 ;
  wire \rom_data[26]_i_1_n_0 ;
  wire \rom_data[26]_i_2_n_0 ;
  wire \rom_data[27]_i_1_n_0 ;
  wire \rom_data[27]_i_2_n_0 ;
  wire \rom_data[27]_i_3_n_0 ;
  wire \rom_data[28]_i_1_n_0 ;
  wire \rom_data[28]_i_2_n_0 ;
  wire \rom_data[29]_i_1_n_0 ;
  wire \rom_data[29]_i_2_n_0 ;
  wire \rom_data[29]_i_3_n_0 ;
  wire \rom_data[2]_i_1_n_0 ;
  wire \rom_data[2]_i_2_n_0 ;
  wire \rom_data[30]_i_1_n_0 ;
  wire \rom_data[30]_i_2_n_0 ;
  wire \rom_data[30]_i_3_n_0 ;
  wire \rom_data[31]_i_1_n_0 ;
  wire \rom_data[31]_i_2_n_0 ;
  wire \rom_data[3]_i_1_n_0 ;
  wire \rom_data[3]_i_2_n_0 ;
  wire \rom_data[4]_i_1_n_0 ;
  wire \rom_data[4]_i_2_n_0 ;
  wire \rom_data[5]_i_1_n_0 ;
  wire \rom_data[5]_i_2_n_0 ;
  wire \rom_data[6]_i_1_n_0 ;
  wire \rom_data[6]_i_2_n_0 ;
  wire \rom_data[7]_i_1_n_0 ;
  wire \rom_data[7]_i_2_n_0 ;
  wire \rom_data[7]_i_3_n_0 ;
  wire \rom_data[8]_i_1_n_0 ;
  wire \rom_data[8]_i_2_n_0 ;
  wire \rom_data[9]_i_1_n_0 ;
  wire \rom_data[9]_i_2_n_0 ;

  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[0]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[0]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1040000010010202)) 
    \rom_data[0]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[10]_i_1 
       (.I0(\rom_data[24]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[10]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0F000000000000B0)) 
    \rom_data[10]_i_2 
       (.I0(rom_addr[2]),
        .I1(rom_addr[0]),
        .I2(rom_addr[5]),
        .I3(rom_addr[3]),
        .I4(rom_addr[4]),
        .I5(rom_addr[1]),
        .O(\rom_data[10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[12]_i_1 
       (.I0(\rom_data[30]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[12]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h14000500402000A2)) 
    \rom_data[12]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[2]),
        .I3(rom_addr[4]),
        .I4(rom_addr[0]),
        .I5(rom_addr[3]),
        .O(\rom_data[12]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[13]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[13]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5450020850510A02)) 
    \rom_data[13]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[14]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[14]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4010000850010000)) 
    \rom_data[14]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[14]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h04)) 
    \rom_data[16]_i_1 
       (.I0(rom_addr[7]),
        .I1(\rom_data[16]_i_2_n_0 ),
        .I2(rom_addr[6]),
        .O(\rom_data[16]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4400020010410200)) 
    \rom_data[16]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[16]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[17]_i_1 
       (.I0(\rom_data[27]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[17]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[17]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4400500000200000)) 
    \rom_data[17]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[0]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[3]),
        .O(\rom_data[17]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[18]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[18]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[18]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0510000000002800)) 
    \rom_data[18]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[2]),
        .I2(rom_addr[1]),
        .I3(rom_addr[0]),
        .I4(rom_addr[4]),
        .I5(rom_addr[3]),
        .O(\rom_data[18]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[19]_i_1 
       (.I0(\rom_data[27]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[19]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[19]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000122)) 
    \rom_data[19]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[3]),
        .I2(rom_addr[2]),
        .I3(rom_addr[4]),
        .I4(rom_addr[0]),
        .I5(rom_addr[1]),
        .O(\rom_data[19]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[1]_i_1 
       (.I0(\rom_data[27]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[1]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1010020810400809)) 
    \rom_data[1]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \rom_data[20]_i_1 
       (.I0(rom_addr[7]),
        .I1(\rom_data[20]_i_2_n_0 ),
        .I2(rom_addr[6]),
        .O(\rom_data[20]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h115500004000008A)) 
    \rom_data[20]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[2]),
        .I2(rom_addr[0]),
        .I3(rom_addr[1]),
        .I4(rom_addr[4]),
        .I5(rom_addr[3]),
        .O(\rom_data[20]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[21]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[21]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[21]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5450020850510202)) 
    \rom_data[21]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[21]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[22]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[22]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[22]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4400000000000180)) 
    \rom_data[22]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[0]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[3]),
        .O(\rom_data[22]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[24]_i_1 
       (.I0(\rom_data[24]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[24]_i_3_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[24]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000402)) 
    \rom_data[24]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[3]),
        .I2(rom_addr[2]),
        .I3(rom_addr[4]),
        .I4(rom_addr[0]),
        .I5(rom_addr[1]),
        .O(\rom_data[24]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h4540100040200000)) 
    \rom_data[24]_i_3 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[2]),
        .I3(rom_addr[4]),
        .I4(rom_addr[0]),
        .I5(rom_addr[3]),
        .O(\rom_data[24]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[25]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[25]_i_3_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[25]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000500012)) 
    \rom_data[25]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[0]),
        .I2(rom_addr[4]),
        .I3(rom_addr[2]),
        .I4(rom_addr[3]),
        .I5(rom_addr[1]),
        .O(\rom_data[25]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h1400400810110000)) 
    \rom_data[25]_i_3 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[25]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[26]_i_1 
       (.I0(\rom_data[27]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[26]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[26]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4450000050510222)) 
    \rom_data[26]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[26]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[27]_i_1 
       (.I0(\rom_data[27]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[27]_i_3_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[27]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \rom_data[27]_i_2 
       (.I0(rom_addr[3]),
        .I1(rom_addr[2]),
        .I2(rom_addr[4]),
        .I3(rom_addr[0]),
        .I4(rom_addr[1]),
        .O(\rom_data[27]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0002000000000100)) 
    \rom_data[27]_i_3 
       (.I0(rom_addr[5]),
        .I1(rom_addr[3]),
        .I2(rom_addr[2]),
        .I3(rom_addr[4]),
        .I4(rom_addr[0]),
        .I5(rom_addr[1]),
        .O(\rom_data[27]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[28]_i_1 
       (.I0(\rom_data[30]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[28]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[28]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00550000400000A0)) 
    \rom_data[28]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[0]),
        .I2(rom_addr[2]),
        .I3(rom_addr[1]),
        .I4(rom_addr[4]),
        .I5(rom_addr[3]),
        .O(\rom_data[28]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[29]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[29]_i_3_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[29]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00000C04)) 
    \rom_data[29]_i_2 
       (.I0(rom_addr[0]),
        .I1(rom_addr[4]),
        .I2(rom_addr[2]),
        .I3(rom_addr[3]),
        .I4(rom_addr[1]),
        .O(\rom_data[29]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5450420850510202)) 
    \rom_data[29]_i_3 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[29]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[2]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[2]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5010000800410808)) 
    \rom_data[2]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[30]_i_1 
       (.I0(\rom_data[30]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[30]_i_3_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[30]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000400012)) 
    \rom_data[30]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[0]),
        .I2(rom_addr[4]),
        .I3(rom_addr[2]),
        .I4(rom_addr[3]),
        .I5(rom_addr[1]),
        .O(\rom_data[30]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h4440440000000182)) 
    \rom_data[30]_i_3 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[0]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[3]),
        .O(\rom_data[30]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000010000000)) 
    \rom_data[31]_i_1 
       (.I0(rom_addr[7]),
        .I1(rom_addr[1]),
        .I2(\rom_data[31]_i_2_n_0 ),
        .I3(rom_addr[3]),
        .I4(rom_addr[5]),
        .I5(rom_addr[6]),
        .O(\rom_data[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \rom_data[31]_i_2 
       (.I0(rom_addr[2]),
        .I1(rom_addr[4]),
        .I2(rom_addr[0]),
        .O(\rom_data[31]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[3]_i_1 
       (.I0(\rom_data[30]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[3]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000061800010)) 
    \rom_data[3]_i_2 
       (.I0(rom_addr[3]),
        .I1(rom_addr[2]),
        .I2(rom_addr[4]),
        .I3(rom_addr[0]),
        .I4(rom_addr[1]),
        .I5(rom_addr[5]),
        .O(\rom_data[3]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \rom_data[4]_i_1 
       (.I0(rom_addr[7]),
        .I1(\rom_data[4]_i_2_n_0 ),
        .I2(rom_addr[6]),
        .O(\rom_data[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1450020D40100A06)) 
    \rom_data[4]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[2]),
        .I4(rom_addr[4]),
        .I5(rom_addr[0]),
        .O(\rom_data[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[5]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[5]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h54025008500B510A)) 
    \rom_data[5]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[0]),
        .O(\rom_data[5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[6]_i_1 
       (.I0(\rom_data[25]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[6]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4000000C1001410C)) 
    \rom_data[6]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[0]),
        .O(\rom_data[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000005404)) 
    \rom_data[7]_i_1 
       (.I0(rom_addr[7]),
        .I1(\rom_data[7]_i_2_n_0 ),
        .I2(rom_addr[1]),
        .I3(\rom_data[7]_i_3_n_0 ),
        .I4(rom_addr[5]),
        .I5(rom_addr[6]),
        .O(\rom_data[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \rom_data[7]_i_2 
       (.I0(rom_addr[0]),
        .I1(rom_addr[2]),
        .I2(rom_addr[4]),
        .I3(rom_addr[3]),
        .O(\rom_data[7]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h01)) 
    \rom_data[7]_i_3 
       (.I0(rom_addr[2]),
        .I1(rom_addr[4]),
        .I2(rom_addr[3]),
        .O(\rom_data[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h20002000000F0000)) 
    \rom_data[8]_i_1 
       (.I0(\rom_data[29]_i_2_n_0 ),
        .I1(rom_addr[5]),
        .I2(rom_addr[8]),
        .I3(rom_addr[7]),
        .I4(\rom_data[8]_i_2_n_0 ),
        .I5(rom_addr[6]),
        .O(\rom_data[8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5000000C10034104)) 
    \rom_data[8]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[1]),
        .I2(rom_addr[3]),
        .I3(rom_addr[4]),
        .I4(rom_addr[2]),
        .I5(rom_addr[0]),
        .O(\rom_data[8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h80800300)) 
    \rom_data[9]_i_1 
       (.I0(\rom_data[30]_i_2_n_0 ),
        .I1(rom_addr[8]),
        .I2(rom_addr[7]),
        .I3(\rom_data[9]_i_2_n_0 ),
        .I4(rom_addr[6]),
        .O(\rom_data[9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000004440020)) 
    \rom_data[9]_i_2 
       (.I0(rom_addr[5]),
        .I1(rom_addr[3]),
        .I2(rom_addr[2]),
        .I3(rom_addr[0]),
        .I4(rom_addr[4]),
        .I5(rom_addr[1]),
        .O(\rom_data[9]_i_2_n_0 ));
  FDRE \rom_data_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[0]_i_1_n_0 ),
        .Q(rom_data[0]),
        .R(1'b0));
  FDRE \rom_data_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[10]_i_1_n_0 ),
        .Q(rom_data[10]),
        .R(1'b0));
  FDRE \rom_data_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[12]_i_1_n_0 ),
        .Q(rom_data[11]),
        .R(1'b0));
  FDRE \rom_data_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[13]_i_1_n_0 ),
        .Q(rom_data[12]),
        .R(1'b0));
  FDRE \rom_data_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[14]_i_1_n_0 ),
        .Q(rom_data[13]),
        .R(1'b0));
  FDRE \rom_data_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[16]_i_1_n_0 ),
        .Q(rom_data[14]),
        .R(rom_addr[8]));
  FDRE \rom_data_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[17]_i_1_n_0 ),
        .Q(rom_data[15]),
        .R(1'b0));
  FDRE \rom_data_reg[18] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[18]_i_1_n_0 ),
        .Q(rom_data[16]),
        .R(1'b0));
  FDRE \rom_data_reg[19] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[19]_i_1_n_0 ),
        .Q(rom_data[17]),
        .R(1'b0));
  FDRE \rom_data_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[1]_i_1_n_0 ),
        .Q(rom_data[1]),
        .R(1'b0));
  FDRE \rom_data_reg[20] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[20]_i_1_n_0 ),
        .Q(rom_data[18]),
        .R(rom_addr[8]));
  FDRE \rom_data_reg[21] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[21]_i_1_n_0 ),
        .Q(rom_data[19]),
        .R(1'b0));
  FDRE \rom_data_reg[22] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[22]_i_1_n_0 ),
        .Q(rom_data[20]),
        .R(1'b0));
  FDRE \rom_data_reg[24] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[24]_i_1_n_0 ),
        .Q(rom_data[21]),
        .R(1'b0));
  FDRE \rom_data_reg[25] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[25]_i_1_n_0 ),
        .Q(rom_data[22]),
        .R(1'b0));
  FDRE \rom_data_reg[26] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[26]_i_1_n_0 ),
        .Q(rom_data[23]),
        .R(1'b0));
  FDRE \rom_data_reg[27] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[27]_i_1_n_0 ),
        .Q(rom_data[24]),
        .R(1'b0));
  FDRE \rom_data_reg[28] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[28]_i_1_n_0 ),
        .Q(rom_data[25]),
        .R(1'b0));
  FDRE \rom_data_reg[29] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[29]_i_1_n_0 ),
        .Q(rom_data[26]),
        .R(1'b0));
  FDRE \rom_data_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[2]_i_1_n_0 ),
        .Q(rom_data[2]),
        .R(1'b0));
  FDRE \rom_data_reg[30] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[30]_i_1_n_0 ),
        .Q(rom_data[27]),
        .R(1'b0));
  FDRE \rom_data_reg[31] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[31]_i_1_n_0 ),
        .Q(rom_data[28]),
        .R(rom_addr[8]));
  FDRE \rom_data_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[3]_i_1_n_0 ),
        .Q(rom_data[3]),
        .R(1'b0));
  FDRE \rom_data_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[4]_i_1_n_0 ),
        .Q(rom_data[4]),
        .R(rom_addr[8]));
  FDRE \rom_data_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[5]_i_1_n_0 ),
        .Q(rom_data[5]),
        .R(1'b0));
  FDRE \rom_data_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[6]_i_1_n_0 ),
        .Q(rom_data[6]),
        .R(1'b0));
  FDRE \rom_data_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[7]_i_1_n_0 ),
        .Q(rom_data[7]),
        .R(rom_addr[8]));
  FDRE \rom_data_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[8]_i_1_n_0 ),
        .Q(rom_data[8]),
        .R(1'b0));
  FDRE \rom_data_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\rom_data[9]_i_1_n_0 ),
        .Q(rom_data[9]),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif

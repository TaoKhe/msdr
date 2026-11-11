// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Sat Oct 17 14:24:55 2026
// Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/user1/v_0_6_1_d_I_Claudio/FPGA/src/ip/ila_deframer_meta_ip/ila_deframer_meta_ip_stub.v
// Design      : ila_deframer_meta_ip
// Purpose     : Stub declaration of top-level module interface
// Device      : xcau15p-sbvb484-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2024.1" *)
module ila_deframer_meta_ip(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9)
/* synthesis syn_black_box black_box_pad_pin="probe0[0:0],probe1[63:0],probe2[26:0],probe3[26:0],probe4[3:0],probe5[3:0],probe6[7:0],probe7[7:0],probe8[47:0],probe9[47:0]" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input [0:0]probe0;
  input [63:0]probe1;
  input [26:0]probe2;
  input [26:0]probe3;
  input [3:0]probe4;
  input [3:0]probe5;
  input [7:0]probe6;
  input [7:0]probe7;
  input [47:0]probe8;
  input [47:0]probe9;
endmodule

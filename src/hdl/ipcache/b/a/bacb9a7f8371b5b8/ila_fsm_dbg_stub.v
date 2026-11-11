// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Mon Nov  9 13:14:45 2026
// Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ ila_fsm_dbg_stub.v
// Design      : ila_fsm_dbg
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2024.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, probe14, probe15, probe16)
/* synthesis syn_black_box black_box_pad_pin="probe0[3:0],probe1[3:0],probe2[3:0],probe3[0:0],probe4[3:0],probe5[31:0],probe6[31:0],probe7[31:0],probe8[26:0],probe9[26:0],probe10[26:0],probe11[26:0],probe12[26:0],probe13[23:0],probe14[64:0],probe15[64:0],probe16[15:0]" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input [3:0]probe0;
  input [3:0]probe1;
  input [3:0]probe2;
  input [0:0]probe3;
  input [3:0]probe4;
  input [31:0]probe5;
  input [31:0]probe6;
  input [31:0]probe7;
  input [26:0]probe8;
  input [26:0]probe9;
  input [26:0]probe10;
  input [26:0]probe11;
  input [26:0]probe12;
  input [23:0]probe13;
  input [64:0]probe14;
  input [64:0]probe15;
  input [15:0]probe16;
endmodule

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Mon Nov  9 14:11:23 2026
// Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ aurora_64b66b_0_stub.v
// Design      : aurora_64b66b_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "aurora_64b66b_v12_0_15, Coregen v14.3_ip3, Number of lanes = 1, Line rate is double10.3125Gbps, Reference Clock is double156.25MHz, Interface is Framing, Flow Control is None and is operating in DUPLEX configuration" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(s_axi_tx_tdata, s_axi_tx_tlast, 
  s_axi_tx_tkeep, s_axi_tx_tvalid, s_axi_tx_tready, m_axi_rx_tdata, m_axi_rx_tlast, 
  m_axi_rx_tkeep, m_axi_rx_tvalid, rxp, rxn, txp, txn, refclk1_in, hard_err, soft_err, channel_up, 
  lane_up, user_clk_out, mmcm_not_locked_out, sync_clk_out, reset_pb, gt_rxcdrovrden_in, 
  power_down, loopback, pma_init, gt_pll_lock, gt0_drpaddr, gt0_drpdi, gt0_drpdo, gt0_drprdy, 
  gt0_drpen, gt0_drpwe, init_clk, link_reset_out, gt_rxusrclk_out, gt_eyescandataerror, 
  gt_eyescanreset, gt_eyescantrigger, gt_rxcdrhold, gt_rxdfelpmreset, gt_rxlpmen, 
  gt_rxpmareset, gt_rxpcsreset, gt_rxrate, gt_rxbufreset, gt_rxpmaresetdone, gt_rxprbssel, 
  gt_rxprbserr, gt_rxprbscntreset, gt_rxresetdone, gt_rxbufstatus, gt_txpostcursor, 
  gt_txdiffctrl, gt_txprecursor, gt_txpolarity, gt_txinhibit, gt_txpmareset, gt_txpcsreset, 
  gt_txprbssel, gt_txprbsforceerr, gt_txbufstatus, gt_txresetdone, gt_pcsrsvdin, 
  gt_dmonitorout, gt_cplllock, gt_qplllock, gt_powergood, gt_qpllclk_quad1_out, 
  gt_qpllrefclk_quad1_out, gt_qplllock_quad1_out, gt_qpllrefclklost_quad1_out, 
  sys_reset_out, gt_reset_out, tx_out_clk)
/* synthesis syn_black_box black_box_pad_pin="s_axi_tx_tdata[0:63],s_axi_tx_tlast,s_axi_tx_tkeep[0:7],s_axi_tx_tvalid,s_axi_tx_tready,m_axi_rx_tdata[0:63],m_axi_rx_tlast,m_axi_rx_tkeep[0:7],m_axi_rx_tvalid,rxp[0:0],rxn[0:0],txp[0:0],txn[0:0],refclk1_in,hard_err,soft_err,channel_up,lane_up[0:0],mmcm_not_locked_out,reset_pb,gt_rxcdrovrden_in,power_down,loopback[2:0],pma_init,gt_pll_lock,gt0_drpaddr[9:0],gt0_drpdi[15:0],gt0_drpdo[15:0],gt0_drprdy,gt0_drpen,gt0_drpwe,link_reset_out,gt_eyescandataerror[0:0],gt_eyescanreset[0:0],gt_eyescantrigger[0:0],gt_rxcdrhold[0:0],gt_rxdfelpmreset[0:0],gt_rxlpmen[0:0],gt_rxpmareset[0:0],gt_rxpcsreset[0:0],gt_rxrate[2:0],gt_rxbufreset[0:0],gt_rxpmaresetdone[0:0],gt_rxprbssel[3:0],gt_rxprbserr[0:0],gt_rxprbscntreset[0:0],gt_rxresetdone[0:0],gt_rxbufstatus[2:0],gt_txpostcursor[4:0],gt_txdiffctrl[4:0],gt_txprecursor[4:0],gt_txpolarity[0:0],gt_txinhibit[0:0],gt_txpmareset[0:0],gt_txpcsreset[0:0],gt_txprbssel[3:0],gt_txprbsforceerr[0:0],gt_txbufstatus[1:0],gt_txresetdone[0:0],gt_pcsrsvdin[15:0],gt_dmonitorout[15:0],gt_cplllock[0:0],gt_qplllock,gt_powergood[0:0],gt_qpllclk_quad1_out,gt_qpllrefclk_quad1_out,gt_qplllock_quad1_out,gt_qpllrefclklost_quad1_out,sys_reset_out,gt_reset_out" */
/* synthesis syn_force_seq_prim="user_clk_out" */
/* synthesis syn_force_seq_prim="sync_clk_out" */
/* synthesis syn_force_seq_prim="init_clk" */
/* synthesis syn_force_seq_prim="gt_rxusrclk_out" */
/* synthesis syn_force_seq_prim="tx_out_clk" */;
  input [0:63]s_axi_tx_tdata;
  input s_axi_tx_tlast;
  input [0:7]s_axi_tx_tkeep;
  input s_axi_tx_tvalid;
  output s_axi_tx_tready;
  output [0:63]m_axi_rx_tdata;
  output m_axi_rx_tlast;
  output [0:7]m_axi_rx_tkeep;
  output m_axi_rx_tvalid;
  input [0:0]rxp;
  input [0:0]rxn;
  output [0:0]txp;
  output [0:0]txn;
  input refclk1_in;
  output hard_err;
  output soft_err;
  output channel_up;
  output [0:0]lane_up;
  output user_clk_out /* synthesis syn_isclock = 1 */;
  output mmcm_not_locked_out;
  output sync_clk_out /* synthesis syn_isclock = 1 */;
  input reset_pb;
  input gt_rxcdrovrden_in;
  input power_down;
  input [2:0]loopback;
  input pma_init;
  output gt_pll_lock;
  input [9:0]gt0_drpaddr;
  input [15:0]gt0_drpdi;
  output [15:0]gt0_drpdo;
  output gt0_drprdy;
  input gt0_drpen;
  input gt0_drpwe;
  input init_clk /* synthesis syn_isclock = 1 */;
  output link_reset_out;
  output gt_rxusrclk_out /* synthesis syn_isclock = 1 */;
  output [0:0]gt_eyescandataerror;
  input [0:0]gt_eyescanreset;
  input [0:0]gt_eyescantrigger;
  input [0:0]gt_rxcdrhold;
  input [0:0]gt_rxdfelpmreset;
  input [0:0]gt_rxlpmen;
  input [0:0]gt_rxpmareset;
  input [0:0]gt_rxpcsreset;
  input [2:0]gt_rxrate;
  input [0:0]gt_rxbufreset;
  output [0:0]gt_rxpmaresetdone;
  input [3:0]gt_rxprbssel;
  output [0:0]gt_rxprbserr;
  input [0:0]gt_rxprbscntreset;
  output [0:0]gt_rxresetdone;
  output [2:0]gt_rxbufstatus;
  input [4:0]gt_txpostcursor;
  input [4:0]gt_txdiffctrl;
  input [4:0]gt_txprecursor;
  input [0:0]gt_txpolarity;
  input [0:0]gt_txinhibit;
  input [0:0]gt_txpmareset;
  input [0:0]gt_txpcsreset;
  input [3:0]gt_txprbssel;
  input [0:0]gt_txprbsforceerr;
  output [1:0]gt_txbufstatus;
  output [0:0]gt_txresetdone;
  input [15:0]gt_pcsrsvdin;
  output [15:0]gt_dmonitorout;
  output [0:0]gt_cplllock;
  output gt_qplllock;
  output [0:0]gt_powergood;
  output gt_qpllclk_quad1_out;
  output gt_qpllrefclk_quad1_out;
  output gt_qplllock_quad1_out;
  output gt_qpllrefclklost_quad1_out;
  output sys_reset_out;
  output gt_reset_out;
  output tx_out_clk /* synthesis syn_isclock = 1 */;
endmodule

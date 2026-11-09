// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2020-2023, 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  inout       [ 3:0]      rfsw_ctrl,
  inout       [ 4:0]      lbf_ctrl,
  input       [ 3:0]      rfsw_ctrl_sense,
  input       [ 4:0]      lbf_ctrl_sense,
  inout                   hb_lna_byp,
  inout                   lb_lna_byp,
  inout                   hb_trx_ctrl,
  inout                   lb_trx_ctrl,
  inout                   gb_lb_byp_ctrl,
  inout                   gb1_hb_byp_ctrl,
  inout                   gb2_hb_byp_ctrl,
  inout                   rx_test_en,
  inout                   rx_gb_ctrl,
  inout       [ 2:0]      tx_gb_ctrl,
  inout       [ 1:0]      led_id,
  inout                   bbu_gpio_0,
  inout                   tx_dsa_si,
  inout                   tx_dsa_clk,
  inout                   tx_dsa_le,
  inout                   rx_dsa_si,
  inout                   rx_dsa_clk,
  inout                   rx_dsa_le,
  inout                   orx_dsa_si,
  inout                   orx_dsa_clk,
  inout                   orx_dsa_le,
  inout                   bbu_gpio_1,
  inout                   bbu_gpio_2,
  inout                   bbu_gpio_3,
  inout                   trx_sclk,
  inout                   trx_mosi,
  inout                   trx_miso,
  inout                   lb_tft_sfl,
  inout                   hb_tft_sfl,
  inout       [ 7:0]      tft_ctrl_a,
  inout       [ 7:0]      tft_ctrl_b,
  inout       [ 3:0]      sw_ctrl_a,
  inout       [ 3:0]      sw_ctrl_b,
  inout                   hb_tft_reset,
  inout                   lb_tft_reset,

  output                  spi_clk,
  output                  spi_dio,
  input                   spi_do,
  output                  spi_en,

  output                  dcosc_sclk,
  output                  dcosc_mosi,
  input                   dcosc_miso,
  output                  dcosc_csn,

  output                  lb_tft_sclk,
  output                  lb_tft_mosi,
  input                   lb_tft_miso,
  output       [ 1:0]      lb_tft_csn,
  output                  hb_tft_sclk,
  output                  hb_tft_mosi,
  input                   hb_tft_miso,
  output       [ 3:0]      hb_tft_csn,

  // Device clock
  input                   fpga_ref_clk,

  inout                   dgpio_0,
  inout                   dgpio_1,
  inout                   dgpio_2,
  inout                   dgpio_3,
  inout                   dgpio_4,
  inout                   dgpio_5,
  inout                   dgpio_6,
  inout                   dgpio_7,
  inout                   dgpio_8,
  inout                   dgpio_9,
  inout                   dgpio_10,
  inout                   dgpio_11,

  inout                   gp_int,
  inout                   reset_trx,

  input                   rx1_dclk_in_n,
  input                   rx1_dclk_in_p,
  output                  rx1_enable,
  input                   rx1_idata_in_n,
  input                   rx1_idata_in_p,
  input                   rx1_qdata_in_n,
  input                   rx1_qdata_in_p,
  input                   rx1_strobe_in_n,
  input                   rx1_strobe_in_p,

  input                   rx2_dclk_in_n,
  input                   rx2_dclk_in_p,
  output                  rx2_enable,
  input                   rx2_idata_in_n,
  input                   rx2_idata_in_p,
  input                   rx2_qdata_in_n,
  input                   rx2_qdata_in_p,
  input                   rx2_strobe_in_n,
  input                   rx2_strobe_in_p,

  output                  tx1_dclk_out_n,
  output                  tx1_dclk_out_p,
  input                   tx1_dclk_in_n,
  input                   tx1_dclk_in_p,
  output                  tx1_enable,
  output                  tx1_idata_out_n,
  output                  tx1_idata_out_p,
  output                  tx1_qdata_out_n,
  output                  tx1_qdata_out_p,
  output                  tx1_strobe_out_n,
  output                  tx1_strobe_out_p,

  output                  tx2_dclk_out_n,
  output                  tx2_dclk_out_p,
  input                   tx2_dclk_in_n,
  input                   tx2_dclk_in_p,
  output                  tx2_enable,
  output                  tx2_idata_out_n,
  output                  tx2_idata_out_p,
  output                  tx2_qdata_out_n,
  output                  tx2_qdata_out_p,
  output                  tx2_strobe_out_n,
  output                  tx2_strobe_out_p
);

  // internal signals
  wire        [94:0]      gpio_i;
  wire        [94:0]      gpio_o;
  wire        [94:0]      gpio_t;
  wire                    gpio_rx1_enable_in;
  wire                    gpio_rx2_enable_in;
  wire                    gpio_tx1_enable_in;
  wire                    gpio_tx2_enable_in;
  wire        [ 2:0]      spi_csn;
  wire        [ 2:0]      spi1_csn;

  wire mssi_sync;
  wire        [31:0]      t12_gpio0_i;
  wire        [31:0]      t12_gpio0_o;
  wire        [31:0]      t12_gpio0_t;
  wire        [26:0]      t12_gpio1_i;
  wire        [26:0]      t12_gpio1_o;
  wire        [26:0]      t12_gpio1_t;
  wire        [16:0]      t12_aux_gpio_i;
  wire        [16:0]      t12_aux_gpio_o;
  wire        [16:0]      t12_aux_gpio_t;

  // The second pads on the same PCB nets are input-only, never second drivers.
  assign t12_gpio0_i[31:24] = {lbf_ctrl_sense[3:0], rfsw_ctrl_sense};
  assign t12_gpio1_i[26] = lbf_ctrl_sense[4];

  ad_iobuf #(
    .DATA_WIDTH(24)
  ) i_t12_gpio0 (
    .dio_t (t12_gpio0_t[23:0]),
    .dio_i (t12_gpio0_o[23:0]),
    .dio_o (t12_gpio0_i[23:0]),
    .dio_p ({bbu_gpio_0, led_id, tx_gb_ctrl, rx_gb_ctrl, rx_test_en,
             gb2_hb_byp_ctrl, gb1_hb_byp_ctrl, gb_lb_byp_ctrl,
             lb_trx_ctrl, hb_trx_ctrl, lb_lna_byp, hb_lna_byp,
             lbf_ctrl, rfsw_ctrl}));

  ad_iobuf #(
    .DATA_WIDTH(26)
  ) i_t12_gpio1 (
    .dio_t (t12_gpio1_t[25:0]),
    .dio_i (t12_gpio1_o[25:0]),
    .dio_o (t12_gpio1_i[25:0]),
    .dio_p ({lb_tft_reset, hb_tft_reset,
             sw_ctrl_b[3], sw_ctrl_a[3], sw_ctrl_b[2], sw_ctrl_a[2],
             sw_ctrl_b[1], sw_ctrl_a[1], sw_ctrl_b[0], sw_ctrl_a[0],
             tft_ctrl_b[7], tft_ctrl_a[7], tft_ctrl_b[6], tft_ctrl_a[6],
             tft_ctrl_b[5], tft_ctrl_a[5], tft_ctrl_b[4], tft_ctrl_a[4],
             tft_ctrl_b[3], tft_ctrl_a[3], tft_ctrl_b[2], tft_ctrl_a[2],
             tft_ctrl_b[1], tft_ctrl_a[1], tft_ctrl_b[0], tft_ctrl_a[0]}));

  ad_iobuf #(
    .DATA_WIDTH(17)
  ) i_t12_aux_gpio (
    .dio_t (t12_aux_gpio_t),
    .dio_i (t12_aux_gpio_o),
    .dio_o (t12_aux_gpio_i),
    .dio_p ({hb_tft_sfl, lb_tft_sfl, trx_miso, trx_mosi, trx_sclk,
             bbu_gpio_3, bbu_gpio_2, bbu_gpio_1,
             orx_dsa_le, orx_dsa_clk, orx_dsa_si,
             rx_dsa_le, rx_dsa_clk, rx_dsa_si,
             tx_dsa_le, tx_dsa_clk, tx_dsa_si}));

  // instantiations

  // multi-ssi synchronization
  //
  assign mssi_sync = gpio_o[54];

  ad_iobuf #(
    .DATA_WIDTH(14)
  ) i_iobuf (
    .dio_t ({gpio_t[46], gpio_t[44:32]}),
    .dio_i ({gpio_o[46], gpio_o[44:32]}),
    .dio_o ({gpio_i[46], gpio_i[44:32]}),
    .dio_p ({reset_trx,    // 46
             gp_int,       // 44
             dgpio_11,     // 43
             dgpio_10,     // 42
             dgpio_9,      // 41
             dgpio_8,      // 40
             dgpio_7,      // 39
             dgpio_6,      // 38
             dgpio_5,      // 37
             dgpio_4,      // 36
             dgpio_3,      // 35
             dgpio_2,      // 34
             dgpio_1,      // 33
             dgpio_0 }));  // 32

  assign gpio_rx1_enable_in = gpio_o[48];
  assign gpio_rx2_enable_in = gpio_o[49];
  assign gpio_tx1_enable_in = gpio_o[50];
  assign gpio_tx2_enable_in = gpio_o[51];

  assign gpio_i[ 7: 0] = gpio_o[ 7: 0];
  assign gpio_i[20: 8] = 13'b0;
  // MODE and DGPIO_11 share one physical pin; DGPIO_11 owns its output driver.
  assign gpio_i[45] = gpio_i[43];
  assign gpio_i[47] = 1'b0;

  assign gpio_i[54:48] = gpio_o[54:48];
  assign gpio_i[55] = 1'b0;
  assign gpio_i[94:56] = gpio_o[94:56];
  assign gpio_i[31:21] = gpio_o[31:21];

  assign spi_en = spi_csn[0];

  system_wrapper i_system_wrapper (
    .t12_gpio0_i (t12_gpio0_i),
    .t12_gpio0_o (t12_gpio0_o),
    .t12_gpio0_t (t12_gpio0_t),
    .t12_gpio1_i (t12_gpio1_i),
    .t12_gpio1_o (t12_gpio1_o),
    .t12_gpio1_t (t12_gpio1_t),
    .ref_clk (fpga_ref_clk),
    .mcs_in (1'b0),
    .mcs_out (),
    .mssi_sync (mssi_sync),

    .tx_output_enable (1'b1),

    .rx1_dclk_in_n (rx1_dclk_in_n),
    .rx1_dclk_in_p (rx1_dclk_in_p),
    .rx1_idata_in_n (rx1_idata_in_n),
    .rx1_idata_in_p (rx1_idata_in_p),
    .rx1_qdata_in_n (rx1_qdata_in_n),
    .rx1_qdata_in_p (rx1_qdata_in_p),
    .rx1_strobe_in_n (rx1_strobe_in_n),
    .rx1_strobe_in_p (rx1_strobe_in_p),

    .rx2_dclk_in_n (rx2_dclk_in_n),
    .rx2_dclk_in_p (rx2_dclk_in_p),
    .rx2_idata_in_n (rx2_idata_in_n),
    .rx2_idata_in_p (rx2_idata_in_p),
    .rx2_qdata_in_n (rx2_qdata_in_n),
    .rx2_qdata_in_p (rx2_qdata_in_p),
    .rx2_strobe_in_n (rx2_strobe_in_n),
    .rx2_strobe_in_p (rx2_strobe_in_p),

    .tx1_dclk_out_n (tx1_dclk_out_n),
    .tx1_dclk_out_p (tx1_dclk_out_p),
    .tx1_dclk_in_n (tx1_dclk_in_n),
    .tx1_dclk_in_p (tx1_dclk_in_p),
    .tx1_idata_out_n (tx1_idata_out_n),
    .tx1_idata_out_p (tx1_idata_out_p),
    .tx1_qdata_out_n (tx1_qdata_out_n),
    .tx1_qdata_out_p (tx1_qdata_out_p),
    .tx1_strobe_out_n (tx1_strobe_out_n),
    .tx1_strobe_out_p (tx1_strobe_out_p),

    .tx2_dclk_out_n (tx2_dclk_out_n),
    .tx2_dclk_out_p (tx2_dclk_out_p),
    .tx2_dclk_in_n (tx2_dclk_in_n),
    .tx2_dclk_in_p (tx2_dclk_in_p),
    .tx2_idata_out_n (tx2_idata_out_n),
    .tx2_idata_out_p (tx2_idata_out_p),
    .tx2_qdata_out_n (tx2_qdata_out_n),
    .tx2_qdata_out_p (tx2_qdata_out_p),
    .tx2_strobe_out_n (tx2_strobe_out_n),
    .tx2_strobe_out_p (tx2_strobe_out_p),

    .rx1_enable (rx1_enable),
    .rx2_enable (rx2_enable),
    .tx1_enable (tx1_enable),
    .tx2_enable (tx2_enable),

    .gpio_rx1_enable_in (gpio_rx1_enable_in),
    .gpio_rx2_enable_in (gpio_rx2_enable_in),
    .gpio_tx1_enable_in (gpio_tx1_enable_in),
    .gpio_tx2_enable_in (gpio_tx2_enable_in),

    .tdd_sync (1'b0),
    .tdd_sync_cntr (),

    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .spi0_sclk (spi_clk),
    .spi0_csn (spi_csn),
    .spi0_miso (spi_do),
    .spi0_mosi (spi_dio),
    .spi1_sclk (dcosc_sclk),
    .spi1_csn (spi1_csn),
    .spi1_miso (dcosc_miso),
    .spi1_mosi (dcosc_mosi),
    .t12_aux_gpio_i (t12_aux_gpio_i),
    .t12_aux_gpio_o (t12_aux_gpio_o),
    .t12_aux_gpio_t (t12_aux_gpio_t),
    .lb_tft_sclk (lb_tft_sclk),
    .lb_tft_mosi (lb_tft_mosi),
    .lb_tft_miso (lb_tft_miso),
    .lb_tft_csn (lb_tft_csn),
    .hb_tft_sclk (hb_tft_sclk),
    .hb_tft_mosi (hb_tft_mosi),
    .hb_tft_miso (hb_tft_miso),
    .hb_tft_csn (hb_tft_csn));

  assign dcosc_csn = spi1_csn[0];

endmodule

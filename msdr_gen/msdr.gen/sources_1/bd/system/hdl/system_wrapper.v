//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
//Date        : Tue Nov 10 00:59:38 2026
//Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (dcosc_miso,
    dcosc_mosi,
    dcosc_sclk,
    fpga_ref_clk,
    gpio_i,
    gpio_o,
    gpio_rx1_enable_in,
    gpio_rx2_enable_in,
    gpio_t,
    gpio_tx1_enable_in,
    gpio_tx2_enable_in,
    hb_tft_csn,
    hb_tft_miso,
    hb_tft_mosi,
    hb_tft_sclk,
    lb_tft_csn,
    lb_tft_miso,
    lb_tft_mosi,
    lb_tft_sclk,
    mcs_in,
    mcs_out,
    mssi_sync,
    rx1_dclk_in_n,
    rx1_dclk_in_p,
    rx1_enable,
    rx1_idata_in_n,
    rx1_idata_in_p,
    rx1_qdata_in_n,
    rx1_qdata_in_p,
    rx1_strobe_in_n,
    rx1_strobe_in_p,
    rx2_dclk_in_n,
    rx2_dclk_in_p,
    rx2_enable,
    rx2_idata_in_n,
    rx2_idata_in_p,
    rx2_qdata_in_n,
    rx2_qdata_in_p,
    rx2_strobe_in_n,
    rx2_strobe_in_p,
    spi0_csn,
    spi1_csn,
    spi_clk,
    spi_dio,
    spi_do,
    t12_aux_gpio_i,
    t12_aux_gpio_o,
    t12_aux_gpio_t,
    t12_gpio0_i,
    t12_gpio0_o,
    t12_gpio0_t,
    t12_gpio1_i,
    t12_gpio1_o,
    t12_gpio1_t,
    tdd_sync,
    tdd_sync_cntr,
    tx1_dclk_in_n,
    tx1_dclk_in_p,
    tx1_dclk_out_n,
    tx1_dclk_out_p,
    tx1_enable,
    tx1_idata_out_n,
    tx1_idata_out_p,
    tx1_qdata_out_n,
    tx1_qdata_out_p,
    tx1_strobe_out_n,
    tx1_strobe_out_p,
    tx2_dclk_in_n,
    tx2_dclk_in_p,
    tx2_dclk_out_n,
    tx2_dclk_out_p,
    tx2_enable,
    tx2_idata_out_n,
    tx2_idata_out_p,
    tx2_qdata_out_n,
    tx2_qdata_out_p,
    tx2_strobe_out_n,
    tx2_strobe_out_p,
    tx_output_enable);
  input dcosc_miso;
  output dcosc_mosi;
  output dcosc_sclk;
  input fpga_ref_clk;
  input [94:0]gpio_i;
  output [94:0]gpio_o;
  input gpio_rx1_enable_in;
  input gpio_rx2_enable_in;
  output [94:0]gpio_t;
  input gpio_tx1_enable_in;
  input gpio_tx2_enable_in;
  output [3:0]hb_tft_csn;
  input hb_tft_miso;
  output hb_tft_mosi;
  output hb_tft_sclk;
  output [1:0]lb_tft_csn;
  input lb_tft_miso;
  output lb_tft_mosi;
  output lb_tft_sclk;
  input mcs_in;
  output mcs_out;
  input mssi_sync;
  input rx1_dclk_in_n;
  input rx1_dclk_in_p;
  output rx1_enable;
  input rx1_idata_in_n;
  input rx1_idata_in_p;
  input rx1_qdata_in_n;
  input rx1_qdata_in_p;
  input rx1_strobe_in_n;
  input rx1_strobe_in_p;
  input rx2_dclk_in_n;
  input rx2_dclk_in_p;
  output rx2_enable;
  input rx2_idata_in_n;
  input rx2_idata_in_p;
  input rx2_qdata_in_n;
  input rx2_qdata_in_p;
  input rx2_strobe_in_n;
  input rx2_strobe_in_p;
  output [2:0]spi0_csn;
  output [2:0]spi1_csn;
  output spi_clk;
  output spi_dio;
  input spi_do;
  input [16:0]t12_aux_gpio_i;
  output [16:0]t12_aux_gpio_o;
  output [16:0]t12_aux_gpio_t;
  input [31:0]t12_gpio0_i;
  output [31:0]t12_gpio0_o;
  output [31:0]t12_gpio0_t;
  input [26:0]t12_gpio1_i;
  output [26:0]t12_gpio1_o;
  output [26:0]t12_gpio1_t;
  input tdd_sync;
  output tdd_sync_cntr;
  input tx1_dclk_in_n;
  input tx1_dclk_in_p;
  output tx1_dclk_out_n;
  output tx1_dclk_out_p;
  output tx1_enable;
  output tx1_idata_out_n;
  output tx1_idata_out_p;
  output tx1_qdata_out_n;
  output tx1_qdata_out_p;
  output tx1_strobe_out_n;
  output tx1_strobe_out_p;
  input tx2_dclk_in_n;
  input tx2_dclk_in_p;
  output tx2_dclk_out_n;
  output tx2_dclk_out_p;
  output tx2_enable;
  output tx2_idata_out_n;
  output tx2_idata_out_p;
  output tx2_qdata_out_n;
  output tx2_qdata_out_p;
  output tx2_strobe_out_n;
  output tx2_strobe_out_p;
  input tx_output_enable;

  wire dcosc_miso;
  wire dcosc_mosi;
  wire dcosc_sclk;
  wire fpga_ref_clk;
  wire [94:0]gpio_i;
  wire [94:0]gpio_o;
  wire gpio_rx1_enable_in;
  wire gpio_rx2_enable_in;
  wire [94:0]gpio_t;
  wire gpio_tx1_enable_in;
  wire gpio_tx2_enable_in;
  wire [3:0]hb_tft_csn;
  wire hb_tft_miso;
  wire hb_tft_mosi;
  wire hb_tft_sclk;
  wire [1:0]lb_tft_csn;
  wire lb_tft_miso;
  wire lb_tft_mosi;
  wire lb_tft_sclk;
  wire mcs_in;
  wire mcs_out;
  wire mssi_sync;
  wire rx1_dclk_in_n;
  wire rx1_dclk_in_p;
  wire rx1_enable;
  wire rx1_idata_in_n;
  wire rx1_idata_in_p;
  wire rx1_qdata_in_n;
  wire rx1_qdata_in_p;
  wire rx1_strobe_in_n;
  wire rx1_strobe_in_p;
  wire rx2_dclk_in_n;
  wire rx2_dclk_in_p;
  wire rx2_enable;
  wire rx2_idata_in_n;
  wire rx2_idata_in_p;
  wire rx2_qdata_in_n;
  wire rx2_qdata_in_p;
  wire rx2_strobe_in_n;
  wire rx2_strobe_in_p;
  wire [2:0]spi0_csn;
  wire [2:0]spi1_csn;
  wire spi_clk;
  wire spi_dio;
  wire spi_do;
  wire [16:0]t12_aux_gpio_i;
  wire [16:0]t12_aux_gpio_o;
  wire [16:0]t12_aux_gpio_t;
  wire [31:0]t12_gpio0_i;
  wire [31:0]t12_gpio0_o;
  wire [31:0]t12_gpio0_t;
  wire [26:0]t12_gpio1_i;
  wire [26:0]t12_gpio1_o;
  wire [26:0]t12_gpio1_t;
  wire tdd_sync;
  wire tdd_sync_cntr;
  wire tx1_dclk_in_n;
  wire tx1_dclk_in_p;
  wire tx1_dclk_out_n;
  wire tx1_dclk_out_p;
  wire tx1_enable;
  wire tx1_idata_out_n;
  wire tx1_idata_out_p;
  wire tx1_qdata_out_n;
  wire tx1_qdata_out_p;
  wire tx1_strobe_out_n;
  wire tx1_strobe_out_p;
  wire tx2_dclk_in_n;
  wire tx2_dclk_in_p;
  wire tx2_dclk_out_n;
  wire tx2_dclk_out_p;
  wire tx2_enable;
  wire tx2_idata_out_n;
  wire tx2_idata_out_p;
  wire tx2_qdata_out_n;
  wire tx2_qdata_out_p;
  wire tx2_strobe_out_n;
  wire tx2_strobe_out_p;
  wire tx_output_enable;

  system system_i
       (.dcosc_miso(dcosc_miso),
        .dcosc_mosi(dcosc_mosi),
        .dcosc_sclk(dcosc_sclk),
        .fpga_ref_clk(fpga_ref_clk),
        .gpio_i(gpio_i),
        .gpio_o(gpio_o),
        .gpio_rx1_enable_in(gpio_rx1_enable_in),
        .gpio_rx2_enable_in(gpio_rx2_enable_in),
        .gpio_t(gpio_t),
        .gpio_tx1_enable_in(gpio_tx1_enable_in),
        .gpio_tx2_enable_in(gpio_tx2_enable_in),
        .hb_tft_csn(hb_tft_csn),
        .hb_tft_miso(hb_tft_miso),
        .hb_tft_mosi(hb_tft_mosi),
        .hb_tft_sclk(hb_tft_sclk),
        .lb_tft_csn(lb_tft_csn),
        .lb_tft_miso(lb_tft_miso),
        .lb_tft_mosi(lb_tft_mosi),
        .lb_tft_sclk(lb_tft_sclk),
        .mcs_in(mcs_in),
        .mcs_out(mcs_out),
        .mssi_sync(mssi_sync),
        .rx1_dclk_in_n(rx1_dclk_in_n),
        .rx1_dclk_in_p(rx1_dclk_in_p),
        .rx1_enable(rx1_enable),
        .rx1_idata_in_n(rx1_idata_in_n),
        .rx1_idata_in_p(rx1_idata_in_p),
        .rx1_qdata_in_n(rx1_qdata_in_n),
        .rx1_qdata_in_p(rx1_qdata_in_p),
        .rx1_strobe_in_n(rx1_strobe_in_n),
        .rx1_strobe_in_p(rx1_strobe_in_p),
        .rx2_dclk_in_n(rx2_dclk_in_n),
        .rx2_dclk_in_p(rx2_dclk_in_p),
        .rx2_enable(rx2_enable),
        .rx2_idata_in_n(rx2_idata_in_n),
        .rx2_idata_in_p(rx2_idata_in_p),
        .rx2_qdata_in_n(rx2_qdata_in_n),
        .rx2_qdata_in_p(rx2_qdata_in_p),
        .rx2_strobe_in_n(rx2_strobe_in_n),
        .rx2_strobe_in_p(rx2_strobe_in_p),
        .spi0_csn(spi0_csn),
        .spi1_csn(spi1_csn),
        .spi_clk(spi_clk),
        .spi_dio(spi_dio),
        .spi_do(spi_do),
        .t12_aux_gpio_i(t12_aux_gpio_i),
        .t12_aux_gpio_o(t12_aux_gpio_o),
        .t12_aux_gpio_t(t12_aux_gpio_t),
        .t12_gpio0_i(t12_gpio0_i),
        .t12_gpio0_o(t12_gpio0_o),
        .t12_gpio0_t(t12_gpio0_t),
        .t12_gpio1_i(t12_gpio1_i),
        .t12_gpio1_o(t12_gpio1_o),
        .t12_gpio1_t(t12_gpio1_t),
        .tdd_sync(tdd_sync),
        .tdd_sync_cntr(tdd_sync_cntr),
        .tx1_dclk_in_n(tx1_dclk_in_n),
        .tx1_dclk_in_p(tx1_dclk_in_p),
        .tx1_dclk_out_n(tx1_dclk_out_n),
        .tx1_dclk_out_p(tx1_dclk_out_p),
        .tx1_enable(tx1_enable),
        .tx1_idata_out_n(tx1_idata_out_n),
        .tx1_idata_out_p(tx1_idata_out_p),
        .tx1_qdata_out_n(tx1_qdata_out_n),
        .tx1_qdata_out_p(tx1_qdata_out_p),
        .tx1_strobe_out_n(tx1_strobe_out_n),
        .tx1_strobe_out_p(tx1_strobe_out_p),
        .tx2_dclk_in_n(tx2_dclk_in_n),
        .tx2_dclk_in_p(tx2_dclk_in_p),
        .tx2_dclk_out_n(tx2_dclk_out_n),
        .tx2_dclk_out_p(tx2_dclk_out_p),
        .tx2_enable(tx2_enable),
        .tx2_idata_out_n(tx2_idata_out_n),
        .tx2_idata_out_p(tx2_idata_out_p),
        .tx2_qdata_out_n(tx2_qdata_out_n),
        .tx2_qdata_out_p(tx2_qdata_out_p),
        .tx2_strobe_out_n(tx2_strobe_out_n),
        .tx2_strobe_out_p(tx2_strobe_out_p),
        .tx_output_enable(tx_output_enable));
endmodule

//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
//Date        : Tue Nov 10 17:16:40 2026
//Host        : taokhe running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (CFG_LUT_addr,
    CFG_LUT_clk,
    CFG_LUT_din,
    CFG_LUT_dout,
    CFG_LUT_en,
    CFG_LUT_rst,
    CFG_LUT_we,
    GFP_UB_IN_tdata,
    GFP_UB_IN_tlast,
    GFP_UB_IN_tready,
    GFP_UB_IN_tvalid,
    GFP_UB_OUT_tdata,
    GFP_UB_OUT_tlast,
    GFP_UB_OUT_tready,
    GFP_UB_OUT_tvalid,
    M_AXI_REGS_araddr,
    M_AXI_REGS_arprot,
    M_AXI_REGS_arready,
    M_AXI_REGS_arvalid,
    M_AXI_REGS_awaddr,
    M_AXI_REGS_awprot,
    M_AXI_REGS_awready,
    M_AXI_REGS_awvalid,
    M_AXI_REGS_bready,
    M_AXI_REGS_bresp,
    M_AXI_REGS_bvalid,
    M_AXI_REGS_rdata,
    M_AXI_REGS_rready,
    M_AXI_REGS_rresp,
    M_AXI_REGS_rvalid,
    M_AXI_REGS_wdata,
    M_AXI_REGS_wready,
    M_AXI_REGS_wstrb,
    M_AXI_REGS_wvalid,
    M_AXI_SYS_araddr,
    M_AXI_SYS_arprot,
    M_AXI_SYS_arready,
    M_AXI_SYS_arvalid,
    M_AXI_SYS_awaddr,
    M_AXI_SYS_awprot,
    M_AXI_SYS_awready,
    M_AXI_SYS_awvalid,
    M_AXI_SYS_bready,
    M_AXI_SYS_bresp,
    M_AXI_SYS_bvalid,
    M_AXI_SYS_rdata,
    M_AXI_SYS_rready,
    M_AXI_SYS_rresp,
    M_AXI_SYS_rvalid,
    M_AXI_SYS_wdata,
    M_AXI_SYS_wready,
    M_AXI_SYS_wstrb,
    M_AXI_SYS_wvalid,
    adc_1_clk,
    adc_1_data_i0,
    adc_1_data_q0,
    adc_1_rst,
    adc_1_valid,
    adc_2_clk,
    adc_2_data_i0,
    adc_2_data_q0,
    adc_2_rst,
    adc_2_valid,
    aurora_sample_clk,
    dac_1_clk,
    dac_1_data_i0,
    dac_1_data_i1,
    dac_1_data_q0,
    dac_1_data_q1,
    dac_1_rd_en,
    dac_1_rst,
    gpio_1_tri_i,
    gpio_1_tri_o,
    gpio_i,
    gpio_o,
    gpio_rx1_enable_in,
    gpio_rx2_enable_in,
    gpio_t,
    gpio_tx1_enable_in,
    gpio_tx2_enable_in,
    hb_tft_csn,
    hb_tft_sclk,
    hb_tft_sdi,
    hb_tft_sdo,
    init_clk,
    initclk_rstn,
    lb_tft_csn,
    lb_tft_sclk,
    lb_tft_sdi,
    lb_tft_sdo,
    mcs_in,
    mcs_out,
    mssi_sync,
    ps_gpio0_o,
    ps_gpio0_t,
    ps_gpio1_o,
    ps_gpio1_t,
    ref_clk,
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
    spi0_miso,
    spi0_mosi,
    spi0_sclk,
    spi1_csn,
    spi1_miso,
    spi1_mosi,
    spi1_sclk,
    t12_aux_gpio_i,
    t12_aux_gpio_o,
    t12_aux_gpio_t,
    t12_gpio0_i,
    t12_gpio1_i,
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
  input [31:0]CFG_LUT_addr;
  input CFG_LUT_clk;
  input [31:0]CFG_LUT_din;
  output [31:0]CFG_LUT_dout;
  input CFG_LUT_en;
  input CFG_LUT_rst;
  input [3:0]CFG_LUT_we;
  input [7:0]GFP_UB_IN_tdata;
  input GFP_UB_IN_tlast;
  output GFP_UB_IN_tready;
  input GFP_UB_IN_tvalid;
  output [7:0]GFP_UB_OUT_tdata;
  output GFP_UB_OUT_tlast;
  input GFP_UB_OUT_tready;
  output GFP_UB_OUT_tvalid;
  output [31:0]M_AXI_REGS_araddr;
  output [2:0]M_AXI_REGS_arprot;
  input [0:0]M_AXI_REGS_arready;
  output [0:0]M_AXI_REGS_arvalid;
  output [31:0]M_AXI_REGS_awaddr;
  output [2:0]M_AXI_REGS_awprot;
  input [0:0]M_AXI_REGS_awready;
  output [0:0]M_AXI_REGS_awvalid;
  output [0:0]M_AXI_REGS_bready;
  input [1:0]M_AXI_REGS_bresp;
  input [0:0]M_AXI_REGS_bvalid;
  input [31:0]M_AXI_REGS_rdata;
  output [0:0]M_AXI_REGS_rready;
  input [1:0]M_AXI_REGS_rresp;
  input [0:0]M_AXI_REGS_rvalid;
  output [31:0]M_AXI_REGS_wdata;
  input [0:0]M_AXI_REGS_wready;
  output [3:0]M_AXI_REGS_wstrb;
  output [0:0]M_AXI_REGS_wvalid;
  output [31:0]M_AXI_SYS_araddr;
  output [2:0]M_AXI_SYS_arprot;
  input [0:0]M_AXI_SYS_arready;
  output [0:0]M_AXI_SYS_arvalid;
  output [31:0]M_AXI_SYS_awaddr;
  output [2:0]M_AXI_SYS_awprot;
  input [0:0]M_AXI_SYS_awready;
  output [0:0]M_AXI_SYS_awvalid;
  output [0:0]M_AXI_SYS_bready;
  input [1:0]M_AXI_SYS_bresp;
  input [0:0]M_AXI_SYS_bvalid;
  input [31:0]M_AXI_SYS_rdata;
  output [0:0]M_AXI_SYS_rready;
  input [1:0]M_AXI_SYS_rresp;
  input [0:0]M_AXI_SYS_rvalid;
  output [31:0]M_AXI_SYS_wdata;
  input [0:0]M_AXI_SYS_wready;
  output [3:0]M_AXI_SYS_wstrb;
  output [0:0]M_AXI_SYS_wvalid;
  output adc_1_clk;
  output [15:0]adc_1_data_i0;
  output [15:0]adc_1_data_q0;
  output adc_1_rst;
  output adc_1_valid;
  output adc_2_clk;
  output [15:0]adc_2_data_i0;
  output [15:0]adc_2_data_q0;
  output adc_2_rst;
  output adc_2_valid;
  output aurora_sample_clk;
  output dac_1_clk;
  input [15:0]dac_1_data_i0;
  input [15:0]dac_1_data_i1;
  input [15:0]dac_1_data_q0;
  input [15:0]dac_1_data_q1;
  output dac_1_rd_en;
  output dac_1_rst;
  input [31:0]gpio_1_tri_i;
  output [31:0]gpio_1_tri_o;
  input [94:0]gpio_i;
  output [94:0]gpio_o;
  input gpio_rx1_enable_in;
  input gpio_rx2_enable_in;
  output [94:0]gpio_t;
  input gpio_tx1_enable_in;
  input gpio_tx2_enable_in;
  output [3:0]hb_tft_csn;
  output hb_tft_sclk;
  output hb_tft_sdi;
  input hb_tft_sdo;
  output init_clk;
  output [0:0]initclk_rstn;
  output [1:0]lb_tft_csn;
  output lb_tft_sclk;
  output lb_tft_sdi;
  input lb_tft_sdo;
  input mcs_in;
  output mcs_out;
  input mssi_sync;
  output [31:0]ps_gpio0_o;
  output [31:0]ps_gpio0_t;
  output [26:0]ps_gpio1_o;
  output [26:0]ps_gpio1_t;
  input ref_clk;
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
  input spi0_miso;
  output spi0_mosi;
  output spi0_sclk;
  output [2:0]spi1_csn;
  input spi1_miso;
  output spi1_mosi;
  output spi1_sclk;
  input [16:0]t12_aux_gpio_i;
  output [16:0]t12_aux_gpio_o;
  output [16:0]t12_aux_gpio_t;
  input [31:0]t12_gpio0_i;
  input [26:0]t12_gpio1_i;
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

  wire [31:0]CFG_LUT_addr;
  wire CFG_LUT_clk;
  wire [31:0]CFG_LUT_din;
  wire [31:0]CFG_LUT_dout;
  wire CFG_LUT_en;
  wire CFG_LUT_rst;
  wire [3:0]CFG_LUT_we;
  wire [7:0]GFP_UB_IN_tdata;
  wire GFP_UB_IN_tlast;
  wire GFP_UB_IN_tready;
  wire GFP_UB_IN_tvalid;
  wire [7:0]GFP_UB_OUT_tdata;
  wire GFP_UB_OUT_tlast;
  wire GFP_UB_OUT_tready;
  wire GFP_UB_OUT_tvalid;
  wire [31:0]M_AXI_REGS_araddr;
  wire [2:0]M_AXI_REGS_arprot;
  wire [0:0]M_AXI_REGS_arready;
  wire [0:0]M_AXI_REGS_arvalid;
  wire [31:0]M_AXI_REGS_awaddr;
  wire [2:0]M_AXI_REGS_awprot;
  wire [0:0]M_AXI_REGS_awready;
  wire [0:0]M_AXI_REGS_awvalid;
  wire [0:0]M_AXI_REGS_bready;
  wire [1:0]M_AXI_REGS_bresp;
  wire [0:0]M_AXI_REGS_bvalid;
  wire [31:0]M_AXI_REGS_rdata;
  wire [0:0]M_AXI_REGS_rready;
  wire [1:0]M_AXI_REGS_rresp;
  wire [0:0]M_AXI_REGS_rvalid;
  wire [31:0]M_AXI_REGS_wdata;
  wire [0:0]M_AXI_REGS_wready;
  wire [3:0]M_AXI_REGS_wstrb;
  wire [0:0]M_AXI_REGS_wvalid;
  wire [31:0]M_AXI_SYS_araddr;
  wire [2:0]M_AXI_SYS_arprot;
  wire [0:0]M_AXI_SYS_arready;
  wire [0:0]M_AXI_SYS_arvalid;
  wire [31:0]M_AXI_SYS_awaddr;
  wire [2:0]M_AXI_SYS_awprot;
  wire [0:0]M_AXI_SYS_awready;
  wire [0:0]M_AXI_SYS_awvalid;
  wire [0:0]M_AXI_SYS_bready;
  wire [1:0]M_AXI_SYS_bresp;
  wire [0:0]M_AXI_SYS_bvalid;
  wire [31:0]M_AXI_SYS_rdata;
  wire [0:0]M_AXI_SYS_rready;
  wire [1:0]M_AXI_SYS_rresp;
  wire [0:0]M_AXI_SYS_rvalid;
  wire [31:0]M_AXI_SYS_wdata;
  wire [0:0]M_AXI_SYS_wready;
  wire [3:0]M_AXI_SYS_wstrb;
  wire [0:0]M_AXI_SYS_wvalid;
  wire adc_1_clk;
  wire [15:0]adc_1_data_i0;
  wire [15:0]adc_1_data_q0;
  wire adc_1_rst;
  wire adc_1_valid;
  wire adc_2_clk;
  wire [15:0]adc_2_data_i0;
  wire [15:0]adc_2_data_q0;
  wire adc_2_rst;
  wire adc_2_valid;
  wire aurora_sample_clk;
  wire dac_1_clk;
  wire [15:0]dac_1_data_i0;
  wire [15:0]dac_1_data_i1;
  wire [15:0]dac_1_data_q0;
  wire [15:0]dac_1_data_q1;
  wire dac_1_rd_en;
  wire dac_1_rst;
  wire [31:0]gpio_1_tri_i;
  wire [31:0]gpio_1_tri_o;
  wire [94:0]gpio_i;
  wire [94:0]gpio_o;
  wire gpio_rx1_enable_in;
  wire gpio_rx2_enable_in;
  wire [94:0]gpio_t;
  wire gpio_tx1_enable_in;
  wire gpio_tx2_enable_in;
  wire [3:0]hb_tft_csn;
  wire hb_tft_sclk;
  wire hb_tft_sdi;
  wire hb_tft_sdo;
  wire init_clk;
  wire [0:0]initclk_rstn;
  wire [1:0]lb_tft_csn;
  wire lb_tft_sclk;
  wire lb_tft_sdi;
  wire lb_tft_sdo;
  wire mcs_in;
  wire mcs_out;
  wire mssi_sync;
  wire [31:0]ps_gpio0_o;
  wire [31:0]ps_gpio0_t;
  wire [26:0]ps_gpio1_o;
  wire [26:0]ps_gpio1_t;
  wire ref_clk;
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
  wire spi0_miso;
  wire spi0_mosi;
  wire spi0_sclk;
  wire [2:0]spi1_csn;
  wire spi1_miso;
  wire spi1_mosi;
  wire spi1_sclk;
  wire [16:0]t12_aux_gpio_i;
  wire [16:0]t12_aux_gpio_o;
  wire [16:0]t12_aux_gpio_t;
  wire [31:0]t12_gpio0_i;
  wire [26:0]t12_gpio1_i;
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
       (.CFG_LUT_addr(CFG_LUT_addr),
        .CFG_LUT_clk(CFG_LUT_clk),
        .CFG_LUT_din(CFG_LUT_din),
        .CFG_LUT_dout(CFG_LUT_dout),
        .CFG_LUT_en(CFG_LUT_en),
        .CFG_LUT_rst(CFG_LUT_rst),
        .CFG_LUT_we(CFG_LUT_we),
        .GFP_UB_IN_tdata(GFP_UB_IN_tdata),
        .GFP_UB_IN_tlast(GFP_UB_IN_tlast),
        .GFP_UB_IN_tready(GFP_UB_IN_tready),
        .GFP_UB_IN_tvalid(GFP_UB_IN_tvalid),
        .GFP_UB_OUT_tdata(GFP_UB_OUT_tdata),
        .GFP_UB_OUT_tlast(GFP_UB_OUT_tlast),
        .GFP_UB_OUT_tready(GFP_UB_OUT_tready),
        .GFP_UB_OUT_tvalid(GFP_UB_OUT_tvalid),
        .M_AXI_REGS_araddr(M_AXI_REGS_araddr),
        .M_AXI_REGS_arprot(M_AXI_REGS_arprot),
        .M_AXI_REGS_arready(M_AXI_REGS_arready),
        .M_AXI_REGS_arvalid(M_AXI_REGS_arvalid),
        .M_AXI_REGS_awaddr(M_AXI_REGS_awaddr),
        .M_AXI_REGS_awprot(M_AXI_REGS_awprot),
        .M_AXI_REGS_awready(M_AXI_REGS_awready),
        .M_AXI_REGS_awvalid(M_AXI_REGS_awvalid),
        .M_AXI_REGS_bready(M_AXI_REGS_bready),
        .M_AXI_REGS_bresp(M_AXI_REGS_bresp),
        .M_AXI_REGS_bvalid(M_AXI_REGS_bvalid),
        .M_AXI_REGS_rdata(M_AXI_REGS_rdata),
        .M_AXI_REGS_rready(M_AXI_REGS_rready),
        .M_AXI_REGS_rresp(M_AXI_REGS_rresp),
        .M_AXI_REGS_rvalid(M_AXI_REGS_rvalid),
        .M_AXI_REGS_wdata(M_AXI_REGS_wdata),
        .M_AXI_REGS_wready(M_AXI_REGS_wready),
        .M_AXI_REGS_wstrb(M_AXI_REGS_wstrb),
        .M_AXI_REGS_wvalid(M_AXI_REGS_wvalid),
        .M_AXI_SYS_araddr(M_AXI_SYS_araddr),
        .M_AXI_SYS_arprot(M_AXI_SYS_arprot),
        .M_AXI_SYS_arready(M_AXI_SYS_arready),
        .M_AXI_SYS_arvalid(M_AXI_SYS_arvalid),
        .M_AXI_SYS_awaddr(M_AXI_SYS_awaddr),
        .M_AXI_SYS_awprot(M_AXI_SYS_awprot),
        .M_AXI_SYS_awready(M_AXI_SYS_awready),
        .M_AXI_SYS_awvalid(M_AXI_SYS_awvalid),
        .M_AXI_SYS_bready(M_AXI_SYS_bready),
        .M_AXI_SYS_bresp(M_AXI_SYS_bresp),
        .M_AXI_SYS_bvalid(M_AXI_SYS_bvalid),
        .M_AXI_SYS_rdata(M_AXI_SYS_rdata),
        .M_AXI_SYS_rready(M_AXI_SYS_rready),
        .M_AXI_SYS_rresp(M_AXI_SYS_rresp),
        .M_AXI_SYS_rvalid(M_AXI_SYS_rvalid),
        .M_AXI_SYS_wdata(M_AXI_SYS_wdata),
        .M_AXI_SYS_wready(M_AXI_SYS_wready),
        .M_AXI_SYS_wstrb(M_AXI_SYS_wstrb),
        .M_AXI_SYS_wvalid(M_AXI_SYS_wvalid),
        .adc_1_clk(adc_1_clk),
        .adc_1_data_i0(adc_1_data_i0),
        .adc_1_data_q0(adc_1_data_q0),
        .adc_1_rst(adc_1_rst),
        .adc_1_valid(adc_1_valid),
        .adc_2_clk(adc_2_clk),
        .adc_2_data_i0(adc_2_data_i0),
        .adc_2_data_q0(adc_2_data_q0),
        .adc_2_rst(adc_2_rst),
        .adc_2_valid(adc_2_valid),
        .aurora_sample_clk(aurora_sample_clk),
        .dac_1_clk(dac_1_clk),
        .dac_1_data_i0(dac_1_data_i0),
        .dac_1_data_i1(dac_1_data_i1),
        .dac_1_data_q0(dac_1_data_q0),
        .dac_1_data_q1(dac_1_data_q1),
        .dac_1_rd_en(dac_1_rd_en),
        .dac_1_rst(dac_1_rst),
        .gpio_1_tri_i(gpio_1_tri_i),
        .gpio_1_tri_o(gpio_1_tri_o),
        .gpio_i(gpio_i),
        .gpio_o(gpio_o),
        .gpio_rx1_enable_in(gpio_rx1_enable_in),
        .gpio_rx2_enable_in(gpio_rx2_enable_in),
        .gpio_t(gpio_t),
        .gpio_tx1_enable_in(gpio_tx1_enable_in),
        .gpio_tx2_enable_in(gpio_tx2_enable_in),
        .hb_tft_csn(hb_tft_csn),
        .hb_tft_sclk(hb_tft_sclk),
        .hb_tft_sdi(hb_tft_sdi),
        .hb_tft_sdo(hb_tft_sdo),
        .init_clk(init_clk),
        .initclk_rstn(initclk_rstn),
        .lb_tft_csn(lb_tft_csn),
        .lb_tft_sclk(lb_tft_sclk),
        .lb_tft_sdi(lb_tft_sdi),
        .lb_tft_sdo(lb_tft_sdo),
        .mcs_in(mcs_in),
        .mcs_out(mcs_out),
        .mssi_sync(mssi_sync),
        .ps_gpio0_o(ps_gpio0_o),
        .ps_gpio0_t(ps_gpio0_t),
        .ps_gpio1_o(ps_gpio1_o),
        .ps_gpio1_t(ps_gpio1_t),
        .ref_clk(ref_clk),
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
        .spi0_miso(spi0_miso),
        .spi0_mosi(spi0_mosi),
        .spi0_sclk(spi0_sclk),
        .spi1_csn(spi1_csn),
        .spi1_miso(spi1_miso),
        .spi1_mosi(spi1_mosi),
        .spi1_sclk(spi1_sclk),
        .t12_aux_gpio_i(t12_aux_gpio_i),
        .t12_aux_gpio_o(t12_aux_gpio_o),
        .t12_aux_gpio_t(t12_aux_gpio_t),
        .t12_gpio0_i(t12_gpio0_i),
        .t12_gpio1_i(t12_gpio1_i),
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

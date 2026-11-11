----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/07/2025 03:16:42 PM
-- Design Name: 
-- Module Name: top_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;
Library xpm;
use xpm.vcomponents.all;
entity msdr_fpga is
Port (
    -----------------------------------------------------------------------
    -- [MSDR] Chan board
    -----------------------------------------------------------------------
    -- Chan vat ly cua T12 (qua bo dem muc)
    t12_gpio0_pad       : inout std_logic_vector(23 downto 0);
    t12_gpio1_pad       : inout std_logic_vector(25 downto 0);
    rfsw_ctrl_sense     : in    std_logic_vector(3 downto 0);
    lbf_ctrl_sense      : in    std_logic_vector(4 downto 0);
    dgpio               : inout std_logic_vector(11 downto 0);
    gp_int              : inout std_logic;
    reset_trx           : inout std_logic;
    fpga_ref_clk        : in    std_logic;
    spi_clk             : out   std_logic;
    spi_dio             : out   std_logic;
    spi_do              : in    std_logic;
    spi_en              : out   std_logic;
    rx1_dclk_in_n              : in  std_logic;
    rx1_dclk_in_p              : in  std_logic;
    rx1_enable                 : out std_logic;
    rx1_idata_in_n             : in  std_logic;
    rx1_idata_in_p             : in  std_logic;
    rx1_qdata_in_n             : in  std_logic;
    rx1_qdata_in_p             : in  std_logic;
    rx1_strobe_in_n            : in  std_logic;
    rx1_strobe_in_p            : in  std_logic;
    rx2_dclk_in_n              : in  std_logic;
    rx2_dclk_in_p              : in  std_logic;
    rx2_enable                 : out std_logic;
    rx2_idata_in_n             : in  std_logic;
    rx2_idata_in_p             : in  std_logic;
    rx2_qdata_in_n             : in  std_logic;
    rx2_qdata_in_p             : in  std_logic;
    rx2_strobe_in_n            : in  std_logic;
    rx2_strobe_in_p            : in  std_logic;
    tx1_dclk_in_n              : in  std_logic;
    tx1_dclk_in_p              : in  std_logic;
    tx1_dclk_out_n             : out std_logic;
    tx1_dclk_out_p             : out std_logic;
    tx1_enable                 : out std_logic;
    tx1_idata_out_n            : out std_logic;
    tx1_idata_out_p            : out std_logic;
    tx1_qdata_out_n            : out std_logic;
    tx1_qdata_out_p            : out std_logic;
    tx1_strobe_out_n           : out std_logic;
    tx1_strobe_out_p           : out std_logic;
    tx2_dclk_in_n              : in  std_logic;
    tx2_dclk_in_p              : in  std_logic;
    tx2_dclk_out_n             : out std_logic;
    tx2_dclk_out_p             : out std_logic;
    tx2_enable                 : out std_logic;
    tx2_idata_out_n            : out std_logic;
    tx2_idata_out_p            : out std_logic;
    tx2_qdata_out_n            : out std_logic;
    tx2_qdata_out_p            : out std_logic;
    tx2_strobe_out_n           : out std_logic;
    tx2_strobe_out_p           : out std_logic;

    -----------------------------------------------------------------------
    -- Dieu khien tu PS (thay cho mb_bd_wrapper cua tvsdr).
    -- Giu dung ten bus ma mb_bd phat ra top de doi chieu duoc tung dong.
    -----------------------------------------------------------------------
    -- Bang tra cau hinh cho fsm_main (mb_bd goi la CFG_LUT)
    -- Kenh ban tin GFP. tvsdr noi thang len MicroBlaze (GFP_UB_IN/OUT),
    -- MSDR dua len PS qua axi_fifo_mm_s_0 nam ben system.bd.
    -- Tu lenh cua PS toi fsm_main (mb_bd goi la gpio_1_tri)
    -- Thanh ghi dieu khien rieng cua MSDR (tx_iq_source, mat na GPIO, ...)
    -----------------------------------------------------------------------
    -- ADRV9002 qua axi_adrv9001, thay cho rx_system_wrap va tx_sys
    --
    -- adc_1 mang kenh A = RX1 (i0/q0); kenh B = RX2 lay o adc_2 theo nhip
    -- rieng. dac_1 mang kenh A = TX1 (i0/q0), kenh B = TX2 (i1/q1).
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- Aurora toi BBU (J2). tx_ref_ins : IBUFDS_GTE4 van la bo dem refclk,
    -- chi doi chan vao tu tx_ref_0_p/n sang Aurora_refclk_p/n.
    -----------------------------------------------------------------------
    Aurora_refclk_p     : in  std_logic;
    Aurora_refclk_n     : in  std_logic;
    Aurora_Txp          : out std_logic_vector(0 downto 0);
    Aurora_Txn          : out std_logic_vector(0 downto 0);
    Aurora_Rxp          : in  std_logic_vector(0 downto 0);
    Aurora_Rxn          : in  std_logic_vector(0 downto 0);

    -----------------------------------------------------------------------
    -- Tham chieu thoi gian va kenh phu tu BBU
    -----------------------------------------------------------------------
    gpio_1              : in  std_logic;   -- 10 MHz
    uart_rxd            : in  std_logic;

    -----------------------------------------------------------------------
    -- Mat dieu khien RF cua T12 (xem khoi anh xa o cuoi kien truc)
    -----------------------------------------------------------------------

    trx_spi_sclk        : inout std_logic;
    trx_spi_mosi        : inout std_logic;
    trx_spi_miso        : inout std_logic;
    tx_dsa_si           : inout std_logic;
    tx_dsa_clk          : inout std_logic;
    tx_dsa_le           : inout std_logic;
    rx_dsa_si           : inout std_logic;
    rx_dsa_clk          : inout std_logic;
    rx_dsa_le           : inout std_logic;
    orx_dsa_si          : inout std_logic;
    orx_dsa_clk         : inout std_logic;
    orx_dsa_le          : inout std_logic;
    bbu_gpio_1          : inout std_logic;
    bbu_gpio_2          : inout std_logic;
    bbu_gpio_3          : inout std_logic;
    lb_tft_sfl          : inout std_logic;
    hb_tft_sfl          : inout std_logic;
    lb_tft_sclk         : out std_logic;
    lb_tft_sdi          : out std_logic;
    lb_tft_sdo          : in  std_logic;
    lb_tft_csn          : out std_logic_vector(1 downto 0);
    hb_tft_sclk         : out std_logic;
    hb_tft_sdi          : out std_logic;
    hb_tft_sdo          : in  std_logic;
    hb_tft_csn          : out std_logic_vector(3 downto 0);
    dcosc_spi_sclk      : out std_logic;   -- DAC VCXO cua tvsdr -> DCXO cua T12
    dcosc_spi_mosi      : out std_logic;
    dcosc_spi_miso      : in  std_logic;
    dcosc_spi_csn       : out std_logic
  );
end entity msdr_fpga;

architecture Behavior of msdr_fpga is

  -- Temporary board profile: external 1PPS is unavailable until mapped.
  constant onepps_in : std_logic := '0';

  ---------------------------------------------------------------------------
  -- [MSDR] system.bd dong dung vai tro ma mb_bd cua tvsdr tung dam nhiem:
  -- CPU, bang tra cau hinh, kenh ban tin GFP, tu lenh, va cac bus AXI.
  ---------------------------------------------------------------------------
  component system_wrapper is
    port (
      CFG_LUT_addr               : in  std_logic_vector(31 downto 0);
      CFG_LUT_clk                : in  std_logic;
      CFG_LUT_din                : in  std_logic_vector(31 downto 0);
      CFG_LUT_dout               : out std_logic_vector(31 downto 0);
      CFG_LUT_en                 : in  std_logic;
      CFG_LUT_rst                : in  std_logic;
      CFG_LUT_we                 : in  std_logic_vector(3 downto 0);
      GFP_UB_IN_tdata            : in  std_logic_vector(7 downto 0);
      GFP_UB_IN_tlast            : in  std_logic;
      GFP_UB_IN_tready           : out std_logic;
      GFP_UB_IN_tvalid           : in  std_logic;
      GFP_UB_OUT_tdata           : out std_logic_vector(7 downto 0);
      GFP_UB_OUT_tlast           : out std_logic;
      GFP_UB_OUT_tready          : in  std_logic;
      GFP_UB_OUT_tvalid          : out std_logic;
      M_AXI_SYS_araddr           : out std_logic_vector(31 downto 0);
      M_AXI_SYS_arprot           : out std_logic_vector(2 downto 0);
      M_AXI_SYS_arready          : in  std_logic_vector(0 downto 0);
      M_AXI_SYS_arvalid          : out std_logic_vector(0 downto 0);
      M_AXI_SYS_awaddr           : out std_logic_vector(31 downto 0);
      M_AXI_SYS_awprot           : out std_logic_vector(2 downto 0);
      M_AXI_SYS_awready          : in  std_logic_vector(0 downto 0);
      M_AXI_SYS_awvalid          : out std_logic_vector(0 downto 0);
      M_AXI_SYS_bready           : out std_logic_vector(0 downto 0);
      M_AXI_SYS_bresp            : in  std_logic_vector(1 downto 0);
      M_AXI_SYS_bvalid           : in  std_logic_vector(0 downto 0);
      M_AXI_SYS_rdata            : in  std_logic_vector(31 downto 0);
      M_AXI_SYS_rready           : out std_logic_vector(0 downto 0);
      M_AXI_SYS_rresp            : in  std_logic_vector(1 downto 0);
      M_AXI_SYS_rvalid           : in  std_logic_vector(0 downto 0);
      M_AXI_SYS_wdata            : out std_logic_vector(31 downto 0);
      M_AXI_SYS_wready           : in  std_logic_vector(0 downto 0);
      M_AXI_SYS_wstrb            : out std_logic_vector(3 downto 0);
      M_AXI_SYS_wvalid           : out std_logic_vector(0 downto 0);
      M_AXI_REGS_araddr          : out std_logic_vector(31 downto 0);
      M_AXI_REGS_arprot          : out std_logic_vector(2 downto 0);
      M_AXI_REGS_arready         : in  std_logic_vector(0 downto 0);
      M_AXI_REGS_arvalid         : out std_logic_vector(0 downto 0);
      M_AXI_REGS_awaddr          : out std_logic_vector(31 downto 0);
      M_AXI_REGS_awprot          : out std_logic_vector(2 downto 0);
      M_AXI_REGS_awready         : in  std_logic_vector(0 downto 0);
      M_AXI_REGS_awvalid         : out std_logic_vector(0 downto 0);
      M_AXI_REGS_bready          : out std_logic_vector(0 downto 0);
      M_AXI_REGS_bresp           : in  std_logic_vector(1 downto 0);
      M_AXI_REGS_bvalid          : in  std_logic_vector(0 downto 0);
      M_AXI_REGS_rdata           : in  std_logic_vector(31 downto 0);
      M_AXI_REGS_rready          : out std_logic_vector(0 downto 0);
      M_AXI_REGS_rresp           : in  std_logic_vector(1 downto 0);
      M_AXI_REGS_rvalid          : in  std_logic_vector(0 downto 0);
      M_AXI_REGS_wdata           : out std_logic_vector(31 downto 0);
      M_AXI_REGS_wready          : in  std_logic_vector(0 downto 0);
      M_AXI_REGS_wstrb           : out std_logic_vector(3 downto 0);
      M_AXI_REGS_wvalid          : out std_logic_vector(0 downto 0);
      adc_1_clk                  : out std_logic;
      adc_1_data_i0              : out std_logic_vector(15 downto 0);
      adc_1_data_q0              : out std_logic_vector(15 downto 0);
      adc_1_rst                  : out std_logic;
      adc_1_valid                : out std_logic;
      adc_2_clk                  : out std_logic;
      adc_2_data_i0              : out std_logic_vector(15 downto 0);
      adc_2_data_q0              : out std_logic_vector(15 downto 0);
      adc_2_rst                  : out std_logic;
      adc_2_valid                : out std_logic;
      aurora_sample_clk          : out std_logic;
      dac_1_clk                  : out std_logic;
      dac_1_data_i0              : in  std_logic_vector(15 downto 0);
      dac_1_data_i1              : in  std_logic_vector(15 downto 0);
      dac_1_data_q0              : in  std_logic_vector(15 downto 0);
      dac_1_data_q1              : in  std_logic_vector(15 downto 0);
      dac_1_rd_en                : out std_logic;
      dac_1_rst                  : out std_logic;
      gpio_1_tri_i               : in  std_logic_vector(31 downto 0);
      gpio_1_tri_o               : out std_logic_vector(31 downto 0);
      gpio_i                     : in  std_logic_vector(94 downto 0);
      gpio_o                     : out std_logic_vector(94 downto 0);
      gpio_rx1_enable_in         : in  std_logic;
      gpio_rx2_enable_in         : in  std_logic;
      gpio_t                     : out std_logic_vector(94 downto 0);
      gpio_tx1_enable_in         : in  std_logic;
      gpio_tx2_enable_in         : in  std_logic;
      init_clk                   : out std_logic;
      initclk_rstn               : out std_logic_vector(0 downto 0);
      mcs_in                     : in  std_logic;
      mcs_out                    : out std_logic;
      mssi_sync                  : in  std_logic;
      ps_gpio0_o                 : out std_logic_vector(31 downto 0);
      ps_gpio0_t                 : out std_logic_vector(31 downto 0);
      ps_gpio1_o                 : out std_logic_vector(26 downto 0);
      ps_gpio1_t                 : out std_logic_vector(26 downto 0);
      t12_aux_gpio_i             : in  std_logic_vector(16 downto 0);
      t12_aux_gpio_o             : out std_logic_vector(16 downto 0);
      t12_aux_gpio_t             : out std_logic_vector(16 downto 0);
      ref_clk                    : in  std_logic;
      rx1_dclk_in_n              : in  std_logic;
      rx1_dclk_in_p              : in  std_logic;
      rx1_enable                 : out std_logic;
      rx1_idata_in_n             : in  std_logic;
      rx1_idata_in_p             : in  std_logic;
      rx1_qdata_in_n             : in  std_logic;
      rx1_qdata_in_p             : in  std_logic;
      rx1_strobe_in_n            : in  std_logic;
      rx1_strobe_in_p            : in  std_logic;
      rx2_dclk_in_n              : in  std_logic;
      rx2_dclk_in_p              : in  std_logic;
      rx2_enable                 : out std_logic;
      rx2_idata_in_n             : in  std_logic;
      rx2_idata_in_p             : in  std_logic;
      rx2_qdata_in_n             : in  std_logic;
      rx2_qdata_in_p             : in  std_logic;
      rx2_strobe_in_n            : in  std_logic;
      rx2_strobe_in_p            : in  std_logic;
      spi0_csn                   : out std_logic_vector(2 downto 0);
      spi0_miso                  : in  std_logic;
      spi0_mosi                  : out std_logic;
      spi0_sclk                  : out std_logic;
      spi1_csn                   : out std_logic_vector(2 downto 0);
      spi1_miso                  : in  std_logic;
      spi1_mosi                  : out std_logic;
      spi1_sclk                  : out std_logic;
      lb_tft_sclk                : out std_logic;
      lb_tft_sdi                 : out std_logic;
      lb_tft_sdo                 : in  std_logic;
      lb_tft_csn                 : out std_logic_vector(1 downto 0);
      hb_tft_sclk                : out std_logic;
      hb_tft_sdi                 : out std_logic;
      hb_tft_sdo                 : in  std_logic;
      hb_tft_csn                 : out std_logic_vector(3 downto 0);
      t12_gpio0_i                : in  std_logic_vector(31 downto 0);
      t12_gpio1_i                : in  std_logic_vector(26 downto 0);
      tdd_sync                   : in  std_logic;
      tdd_sync_cntr              : out std_logic;
      tx1_dclk_in_n              : in  std_logic;
      tx1_dclk_in_p              : in  std_logic;
      tx1_dclk_out_n             : out std_logic;
      tx1_dclk_out_p             : out std_logic;
      tx1_enable                 : out std_logic;
      tx1_idata_out_n            : out std_logic;
      tx1_idata_out_p            : out std_logic;
      tx1_qdata_out_n            : out std_logic;
      tx1_qdata_out_p            : out std_logic;
      tx1_strobe_out_n           : out std_logic;
      tx1_strobe_out_p           : out std_logic;
      tx2_dclk_in_n              : in  std_logic;
      tx2_dclk_in_p              : in  std_logic;
      tx2_dclk_out_n             : out std_logic;
      tx2_dclk_out_p             : out std_logic;
      tx2_enable                 : out std_logic;
      tx2_idata_out_n            : out std_logic;
      tx2_idata_out_p            : out std_logic;
      tx2_qdata_out_n            : out std_logic;
      tx2_qdata_out_p            : out std_logic;
      tx2_strobe_out_n           : out std_logic;
      tx2_strobe_out_p           : out std_logic;
      tx_output_enable           : in  std_logic
    );
  end component system_wrapper;

  signal M_AXI_SYS_araddr : std_logic_vector(31 downto 0);
  signal M_AXI_SYS_arprot : std_logic_vector(2 downto 0);
  signal M_AXI_SYS_arready : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_arvalid : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_awaddr : std_logic_vector(31 downto 0);
  signal M_AXI_SYS_awprot : std_logic_vector(2 downto 0);
  signal M_AXI_SYS_awready : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_awvalid : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_bready : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_bresp : std_logic_vector(1 downto 0);
  signal M_AXI_SYS_bvalid : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_rdata : std_logic_vector(31 downto 0);
  signal M_AXI_SYS_rready : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_rresp : std_logic_vector(1 downto 0);
  signal M_AXI_SYS_rvalid : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_wdata : std_logic_vector(31 downto 0);
  signal M_AXI_SYS_wready : std_logic_vector(0 downto 0);
  signal M_AXI_SYS_wstrb : std_logic_vector(3 downto 0);
  signal M_AXI_SYS_wvalid : std_logic_vector(0 downto 0);
  signal CFG_LUT_addr : std_logic_vector(31 downto 0);
  signal CFG_LUT_clk : std_logic;
  signal CFG_LUT_din : std_logic_vector(31 downto 0);
  signal CFG_LUT_dout : std_logic_vector(31 downto 0);
  signal CFG_LUT_en : std_logic;
  signal CFG_LUT_rst : std_logic;
  signal CFG_LUT_we : std_logic_vector(3 downto 0);
  signal GFP_UB_IN_tdata : std_logic_vector(7 downto 0);
  signal GFP_UB_IN_tlast : std_logic;
  signal GFP_UB_IN_tready : std_logic;
  signal GFP_UB_IN_tvalid : std_logic;
  signal GFP_UB_OUT_tdata : std_logic_vector(7 downto 0);
  signal GFP_UB_OUT_tlast : std_logic;
  signal GFP_UB_OUT_tready : std_logic;
  signal GFP_UB_OUT_tvalid : std_logic;
  signal adc_1_clk : std_logic;
  signal adc_1_data_i0 : std_logic_vector(15 downto 0);
  signal adc_1_data_q0 : std_logic_vector(15 downto 0);
  signal adc_1_rst : std_logic;
  signal adc_1_valid : std_logic;
  signal adc_2_clk : std_logic;
  signal adc_2_data_i0 : std_logic_vector(15 downto 0);
  signal adc_2_data_q0 : std_logic_vector(15 downto 0);
  signal adc_2_rst : std_logic;
  signal adc_2_valid : std_logic;
  signal dac_1_clk : std_logic;
  signal dac_1_data_i0 : std_logic_vector(15 downto 0);
  signal dac_1_data_i1 : std_logic_vector(15 downto 0);
  signal dac_1_data_q0 : std_logic_vector(15 downto 0);
  signal dac_1_data_q1 : std_logic_vector(15 downto 0);
  signal dac_1_rd_en : std_logic;
  signal dac_1_rst : std_logic;
  signal init_clk : std_logic;
  signal ps_gpio0_o : std_logic_vector(31 downto 0);
  signal ps_gpio0_t : std_logic_vector(31 downto 0);
  signal ps_gpio1_o : std_logic_vector(26 downto 0);
  signal ps_gpio1_t : std_logic_vector(26 downto 0);
  signal gpio_i : std_logic_vector(94 downto 0);
  signal gpio_o : std_logic_vector(94 downto 0);
  signal gpio_t : std_logic_vector(94 downto 0);
  signal gpio_rx1_enable_in : std_logic;
  signal gpio_rx2_enable_in : std_logic;
  signal gpio_tx1_enable_in : std_logic;
  signal gpio_tx2_enable_in : std_logic;
  signal mssi_sync : std_logic;
  signal mcs_in : std_logic;
  signal tdd_sync : std_logic;
  signal tx_output_enable : std_logic;
  signal ref_clk : std_logic;
  signal spi0_sclk : std_logic;
  signal spi0_csn : std_logic_vector(2 downto 0);
  signal spi0_miso : std_logic;
  signal spi0_mosi : std_logic;
  signal spi1_sclk : std_logic;
  signal spi1_csn : std_logic_vector(2 downto 0);
  signal spi1_miso : std_logic;
  signal spi1_mosi : std_logic;
  signal t12_gpio0_i : std_logic_vector(31 downto 0);
  signal t12_gpio1_i : std_logic_vector(26 downto 0);
  signal t12_aux_gpio_i : std_logic_vector(16 downto 0);
  signal t12_aux_gpio_o : std_logic_vector(16 downto 0);
  signal t12_aux_gpio_t : std_logic_vector(16 downto 0);
  signal rf_gpio0_o : std_logic_vector(31 downto 0);
  signal rf_gpio0_t : std_logic_vector(31 downto 0);
  signal rf_gpio1_o : std_logic_vector(26 downto 0);
  signal rf_gpio1_t : std_logic_vector(26 downto 0);
  signal SYS_INTERFACE_araddr : std_logic_vector(31 downto 0);
  signal SYS_INTERFACE_arprot : std_logic_vector(2 downto 0);
  signal SYS_INTERFACE_arready : std_logic;
  signal SYS_INTERFACE_arvalid : std_logic;
  signal SYS_INTERFACE_awaddr : std_logic_vector(31 downto 0);
  signal SYS_INTERFACE_awprot : std_logic_vector(2 downto 0);
  signal SYS_INTERFACE_awready : std_logic;
  signal SYS_INTERFACE_awvalid : std_logic;
  signal SYS_INTERFACE_bready : std_logic;
  signal SYS_INTERFACE_bresp : std_logic_vector(1 downto 0);
  signal SYS_INTERFACE_bvalid : std_logic;
  signal SYS_INTERFACE_rdata : std_logic_vector(31 downto 0);
  signal SYS_INTERFACE_rready : std_logic;
  signal SYS_INTERFACE_rresp : std_logic_vector(1 downto 0);
  signal SYS_INTERFACE_rvalid : std_logic;
  signal SYS_INTERFACE_wdata : std_logic_vector(31 downto 0);
  signal SYS_INTERFACE_wready : std_logic;
  signal SYS_INTERFACE_wstrb : std_logic_vector(3 downto 0);
  signal SYS_INTERFACE_wvalid : std_logic;
  signal M_AXI_REGS_araddr : std_logic_vector(31 downto 0);
  signal M_AXI_REGS_arprot : std_logic_vector(2 downto 0);
  signal M_AXI_REGS_arready : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_arvalid : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_awaddr : std_logic_vector(31 downto 0);
  signal M_AXI_REGS_awprot : std_logic_vector(2 downto 0);
  signal M_AXI_REGS_awready : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_awvalid : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_bready : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_bresp : std_logic_vector(1 downto 0);
  signal M_AXI_REGS_bvalid : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_rdata : std_logic_vector(31 downto 0);
  signal M_AXI_REGS_rready : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_rresp : std_logic_vector(1 downto 0);
  signal M_AXI_REGS_rvalid : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_wdata : std_logic_vector(31 downto 0);
  signal M_AXI_REGS_wready : std_logic_vector(0 downto 0);
  signal M_AXI_REGS_wstrb : std_logic_vector(3 downto 0);
  signal M_AXI_REGS_wvalid : std_logic_vector(0 downto 0);
  signal dac_samp_i     : std_logic_vector(15 downto 0);
  signal dac_samp_q     : std_logic_vector(15 downto 0);
  signal tx_fifo_din_s      : std_logic_vector(31 downto 0);
  signal tx_fifo_dout_s     : std_logic_vector(31 downto 0);
  signal tx_fifo_full_s     : std_logic;
  signal tx_fifo_empty_s    : std_logic;
  signal tx_fifo_wr_en_s    : std_logic;
  signal tx_fifo_rd_en_s    : std_logic;
  signal tx_fifo_rst_s      : std_logic;
  signal tx_fifo_overflow_sticky_s  : std_logic := '0';
  signal tx_fifo_underflow_sticky_s : std_logic := '0';
  signal tx_fir_error_sticky_s      : std_logic := '0';
  signal tx_fifo_read_started_s     : std_logic := '0';
  signal tx_fifo_overflow_init_s    : std_logic;
  signal tx_fifo_underflow_init_s   : std_logic;
  signal tx_fir_error_init_s        : std_logic;
  signal tx_aurora_reset_s          : std_logic;
  signal tx_path_rst_250_s  : std_logic;
  signal tx_path_async_rst_s: std_logic;
  signal fir_input_valid_s  : std_logic := '0';
  signal fir_output_valid_s : std_logic;
  signal fir_output_i_s     : std_logic_vector(15 downto 0);
  signal fir_output_q_s     : std_logic_vector(15 downto 0);
  signal fir_core_input_valid_s : std_logic;
  signal fir_i_input_ready_s : std_logic;
  signal fir_q_input_ready_s : std_logic;
  signal fir_i_output_valid_s : std_logic;
  signal fir_q_output_valid_s : std_logic;
  signal fir_i_output_data_s : std_logic_vector(15 downto 0);
  signal fir_q_output_data_s : std_logic_vector(15 downto 0);
  signal tx_iq_source_dac_s : std_logic_vector(2 downto 0);
  signal gpio_1_tri_o : std_logic_vector(31 downto 0);
  signal gpio_1_tri_i : std_logic_vector(31 downto 0);
  signal initclk_rstn_v : std_logic_vector(0 downto 0);


  -- [MSDR] anh xa RF cua T12 va thanh ghi rieng cua MSDR
  signal fsm_gpio0       : std_logic_vector(31 downto 0);
  signal fsm_gpio1       : std_logic_vector(26 downto 0);
  signal gpio0_mask_s    : std_logic_vector(31 downto 0);
  signal gpio1_mask_s    : std_logic_vector(26 downto 0);
  signal tx_iq_source_ps : std_logic_vector(2 downto 0);

  -- [MSDR] dem vuot nhip cho RX2
  signal adc2_fifo_dout  : std_logic_vector(31 downto 0);
  signal adc2_fifo_empty : std_logic;
  signal adc2_fifo_full  : std_logic;
  signal adc2_fifo_rden  : std_logic;
  signal adc1_dovf_src_s       : std_logic;
  signal adc2_dovf_src_s       : std_logic;
  signal adc1_dovf_src_d_s     : std_logic := '0';
  signal adc2_dovf_src_d_s     : std_logic := '0';
  signal adc1_dovf_pulse_s     : std_logic := '0';
  signal adc2_dovf_pulse_s     : std_logic := '0';
  signal adc1_dovf_axi_s       : std_logic;
  signal adc2_dovf_axi_s       : std_logic;
  signal adc1_dovf_level_axi_s : std_logic;
  signal adc2_dovf_level_axi_s : std_logic;
  signal adc_dovf_axi_s        : std_logic;
  signal sync_locked_axi_s     : std_logic;

  ---------------------------------------------------------------------------
  -- [MSDR] Cac chan cua board TVSDR duoc giu nguyen TEN nhung ha xuong thanh
  -- tin hieu noi bo, de than kien truc (nhat la port map cua i_fsm_main)
  -- khong phai sua mot dong nao so voi tvsdr_fpga.vhd. Khoi anh xa o cuoi
  -- kien truc moi noi chung ra mat chan that cua T12.
  ---------------------------------------------------------------------------
  signal INIT_CLK_P : std_logic := '0';
  signal INIT_CLK_N : std_logic := '0';
  signal tx_data_0_p : std_logic := '0';
  signal tx_data_0_n : std_logic := '0';
  signal tx_data_1_p : std_logic := '0';
  signal tx_data_1_n : std_logic := '0';
  signal tx_ref_0_p : std_logic := '0';
  signal tx_ref_0_n : std_logic := '0';
  signal tx_sync_0_p : std_logic := '0';
  signal tx_sync_0_n : std_logic := '0';
  signal adc_csb : std_logic := '0';
  signal adc_sclk : std_logic := '0';
  signal adc_sdio : std_logic := '0';
  signal if_fb_sw_1 : std_logic := '0';
  signal if_fb_sw_0 : std_logic := '0';
  signal hb_tpfb_sw_2 : std_logic := '0';
  signal hb_tpfb_sw_1 : std_logic := '0';
  signal hb_tpfb_sw_0 : std_logic := '0';
  signal hb_tpfb_sw_0n : std_logic := '0';
  signal lb_rx_tbpf_sw_1 : std_logic := '0';
  signal lb_rx_tbpf_sw_2 : std_logic := '0';
  signal lb_sw_1 : std_logic := '0';
  signal lb_sw_2 : std_logic := '0';
  signal lb_tx_tbpf_sw_1 : std_logic := '0';
  signal lb_tx_tbpf_sw_2 : std_logic := '0';
  signal hb_fb_sw_1 : std_logic := '0';
  signal hb_fb_sw_0 : std_logic := '0';
  signal dac_txenable : std_logic := '0';
  signal dac_sdio : std_logic := '0';
  signal dac_sdo : std_logic := '0';
  signal dac_rstn : std_logic := '0';
  signal dac_sclk : std_logic := '0';
  signal dac_csn : std_logic := '0';
  signal dac_irqn : std_logic := '0';
  signal adc_afe_csbn_1v8 : std_logic := '0';
  signal adc_afe_csan_1v8 : std_logic := '0';
  signal pll_b_clk : std_logic := '0';
  signal pll_b_data : std_logic := '0';
  signal pll_b_le : std_logic := '0';
  signal pll_a_clk : std_logic := '0';
  signal pll_a_data : std_logic := '0';
  signal pll_a_le : std_logic := '0';
  signal PG_ADC_PLL : std_logic := '0';
  signal PG_VCVCSO : std_logic := '0';
  signal if_fb_le : std_logic := '0';
  signal if_fb_clk : std_logic := '0';
  signal if_fb_si : std_logic := '0';
  signal lut_spi_sclk : std_logic := '0';
  signal lut_spi_mosi : std_logic := '0';
  signal hb_fb_tx : std_logic := '0';
  signal tx_att_sin : std_logic := '0';
  signal tx_att_clk : std_logic := '0';
  signal tx_att_le : std_logic := '0';
  signal rtx_att_sin : std_logic := '0';
  signal rtx_att_clk : std_logic := '0';
  signal rtx_att_le : std_logic := '0';
  signal hb_tbpf_sdi : std_logic := '0';
  signal hb_tbpf_sdo : std_logic := '0';
  signal hb_tbpf_sclk : std_logic := '0';
  signal hb_1_tbpf_csn : std_logic := '0';
  signal hb_2_tbpf_csn : std_logic := '0';
  signal hb_3_tbpf_csn : std_logic := '0';
  signal hb_4_tbpf_csn : std_logic := '0';
  signal lo_ps : std_logic_vector(7 downto 0) := (others => '0');
  signal ADC_LS_CS : std_logic := '0';
  signal PLL_ADC_CE : std_logic := '0';
  signal pll_adc_917_le : std_logic := '0';
  signal pll_adc_504_le : std_logic := '0';
  signal spi_tx_csn_0 : std_logic := '0';
  signal spi_tx_csn_1 : std_logic := '0';
  signal spi_tx_csn_2 : std_logic := '0';
  signal spi_tx_csn_3 : std_logic := '0';
  signal spi_tx_csn_4 : std_logic := '0';
  signal spi_tx_csn_5 : std_logic := '0';
  signal spi_tx_sclk : std_logic := '0';
  signal spi_tx_mosi : std_logic := '0';
  signal spi_tx_miso : std_logic := '0';
  signal lut_spi_miso : std_logic := '0';
  signal lut_spi_cs_b : std_logic := '0';
  signal dac_ls_cs : std_logic := '0';
  signal GPIO_MUX_LE_0 : std_logic := '0';
  signal GPIO_MUX_LE_1 : std_logic := '0';
  signal GPIO_MUX_LE_2 : std_logic := '0';
  signal GPIO_MUX_LE_3 : std_logic := '0';
  signal gpio_mux_clk_p : std_logic := '0';
  signal gpio_mux_clk_n : std_logic := '0';
  signal hb_fb_sw_2n : std_logic := '0';
  signal hb_fb_sw_2 : std_logic := '0';
  signal lb_rx_tbpf_mosi : std_logic := '0';
  signal lb_rx_tbpf_sclk : std_logic := '0';
  signal lb_rx_tbpf1_csn : std_logic := '0';
  signal lb_rx_tbpf2_csn : std_logic := '0';
  signal lb_tx_tbpf_mosi : std_logic := '0';
  signal lb_tx_tbpf_sclk : std_logic := '0';
  signal lb_tx_tbpf2_csn : std_logic := '0';
  signal lb_tx_tbpf1_csn : std_logic := '0';
  signal dac_vcso_din : std_logic := '0';
  signal dac_vcso_sclk : std_logic := '0';
  signal dac_vcso_sync : std_logic := '0';
  signal lb_tx_tbpf_1_tune_rdy : std_logic := '0';
  signal lb_tx_tbpf_2_tune_rdy : std_logic := '0';
  signal lb_rx_tbpf_1_tune_rdy_a : std_logic := '0';
  signal lb_rx_tbpf_1_tune_rdy_b : std_logic := '0';
  signal lb_rx_tbpf_2_tune_rdy_a : std_logic := '0';
  signal lb_rx_tbpf_2_tune_rdy_b : std_logic := '0';
  signal pll_504_locked : std_logic := '0';
  signal pll_917_locked : std_logic := '0';
  signal adc_data_in_p : std_logic_vector(15 downto 0) := (others => '0');
  signal adc_data_in_n : std_logic_vector(15 downto 0) := (others => '0');
  signal adc_clk_in_p : std_logic := '0';
  signal adc_clk_in_n : std_logic := '0';
  signal adc_or_in_p : std_logic := '0';
  signal adc_or_in_n : std_logic := '0';
  signal gpio_mux : std_logic_vector(7 downto 0) := (others => '0');
  signal dac_ph_en_1v8 : std_logic := '0';
  signal dac_ph_sload_1v8 : std_logic := '0';
  signal pingpong_An_b : std_logic := '0';
  signal TX_RF_OFF_1V8 : std_logic := '0';
  signal vcxo_cp : std_logic := '0';
  signal dds_a_0_csn : std_logic := '0';
  signal dds_b_0_csn : std_logic := '0';
  signal dds_scl : std_logic := '0';
  signal dds_sdio : std_logic := '0';
  signal dds_sdo : std_logic := '0';
  signal dds_b_syncio : std_logic := '0';
  signal dds_a_syncio : std_logic := '0';
  signal dds_data : std_logic_vector(31 downto 5) := (others => '0');
  signal dds_a_sync_clk : std_logic := '0';
  signal dds_a_ioupdate : std_logic := '0';
  signal dds_b_sync_clk : std_logic := '0';
  signal dds_b_ioupdate : std_logic := '0';
  signal lo_div2_en_b : std_logic := '0';
  signal lo_div2_en_a : std_logic := '0';
  signal hb_sw : std_logic := '0';
  signal RTX_PUSH_GATE : std_logic := '0';


	component ila_1
		Port ( clk 		: in STD_LOGIC;
				probe0 	: in std_logic_vector(15 downto 0); 
				probe1 	: in std_logic_vector(15 downto 0); 
				probe2 	: in std_logic_vector(0 downto 0);
				probe3 	: in std_logic_vector(0 downto 0);
				probe4 	: in std_logic_vector(0 downto 0);
				probe5 	: in std_logic_vector(0 downto 0));
	end component;

    component vio_ts
      port (
        clk : in std_logic;
        probe_in0, probe_in1, probe_in2, probe_in3, probe_in4 : in std_logic_vector(31 downto 0);
        probe_in5 : in std_logic_vector(0 downto 0);
        probe_out0 : out std_logic_vector(2 downto 0);
        probe_out1 : out std_logic_vector(15 downto 0);
        probe_out2 : out std_logic_vector(0 downto 0)
      );
    end component;

	component vio_0
		Port (  clk 		: in  std_logic;
				probe_out0 	: out std_logic_vector(2 downto 0);
				probe_out1 	: out std_logic_vector(2 downto 0);
				probe_out2 	: out std_logic_vector(0 downto 0);
				probe_out3 	: out std_logic_vector(0 downto 0));
	end component;
	
    component clk_wiz_0 
    Port (
        clk_out1 : out std_logic;
        clk_out2 : out std_logic;
        reset : in std_logic;
        locked : out std_logic;
        clk_in1 : in std_logic
    );
    end component;
    
    component Waveform_streamer
		Port (  clk				: in  std_logic;
				rst				: in  std_logic;
				IQout_tlast     : out std_logic:= '0';
				IQout_tdata     : out std_logic_vector (31 downto 0) := (others => '0');
				IQout_tvalid    : out std_logic:= '0');  
	end component;
    
    COMPONENT dds_compiler_1
		  PORT (
			aclk : IN STD_LOGIC;
			m_axis_data_tvalid : OUT STD_LOGIC;
			m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
		  );
		END COMPONENT;
	
    component ila_0 IS
    PORT (
    clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
    end component ila_0;
	
   COMPONENT rf_params
		PORT (  clk    : IN STD_LOGIC;
				probe0 : IN STD_LOGIC_VECTOR(47 DOWNTO 0); 
				probe1 : IN STD_LOGIC_VECTOR(47 DOWNTO 0); 
				probe2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0); 
				probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
				probe4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT  ;
	
    COMPONENT ila_32
		PORT (  clk    : IN STD_LOGIC;
				probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0));
		END COMPONENT  ;

    COMPONENT ila_12
		PORT (  clk    : IN STD_LOGIC;
				probe0 : IN STD_LOGIC_VECTOR(11 DOWNTO 0));
		END COMPONENT  ;
		
	COMPONENT	FifoResetComp5
	   Port (Full : IN STD_LOGIC;
	   		 Fref : IN STD_LOGIC;
	   		 Reset : OUT STD_LOGIC);
	END COMPONENT  ;	

    --------------------AURORA SIGNALS---------------------------------
    signal system_clk_s : std_logic;
    signal aurora_clk_s : std_logic;
    signal aurora_rst_s : std_logic;  
    signal Aurora_IQin_tdata_s : std_logic_vector (63 downto 0);
    signal Aurora_IQin_tkeep_s : std_logic_vector (7 downto 0);
    signal Aurora_IQin_tvalid_s : std_logic;
    signal Aurora_IQin_tlast_s: std_logic;
    signal Aurora_IQin_tready_s: std_logic;

    signal Aurora_IQout_tlast_s : std_logic;
    signal Aurora_IQout_tdata_s : std_logic_vector (63 downto 0);
    signal Aurora_IQout_tkeep_s : std_logic_vector (7 downto 0);
    signal Aurora_IQout_tvalid_s : std_logic;

    signal init_clk_s, sample_clk_s : std_logic;
    signal Sample_rst_s : std_logic;
    signal initclk_rstn_s,initclk_rstfromaurora_s : std_logic;
    ---------------------AURORA DEFRAMER SIGNALS-------------------------
    signal Frame_Length_out                : std_logic_vector (47 downto 0);
    signal Tx_freq_out                     : std_logic_vector (47 downto 0);
    signal Rx_freq_out                     : std_logic_vector (47 downto 0);
    signal Next_Frame_Transmit_Time_out    : std_logic_vector (26 downto 0);
    signal Power_Tx_out                    : std_logic_vector (7 downto 0);
    signal Rx_bw_out                       : std_logic_vector (7 downto 0);
    signal Tx_bw_out                       : std_logic_vector (7 downto 0);
    signal Next_Frame_Receive_Time_out     : std_logic_vector (26 downto 0);
    signal Second_from_2000_out            : std_logic_vector (39 downto 0);
    signal Subsecond_out                   : std_logic_vector (26 downto 0);
    signal timestamp_valid_out             : std_logic;
    -- metadata_valid: 1-cycle pulse (aurora_clk domain) from aurora_protocol, once per frame
    -- at the first Subsecond = complete RX timestamp/metadata. Available for system use.
    signal metadata_valid_aclk_s           : std_logic;

    signal Frame_Length_out_sync                : std_logic_vector (47 downto 0);
    signal Tx_freq_out_sync                     : std_logic_vector (47 downto 0);
    signal Rx_freq_out_sync                     : std_logic_vector (47 downto 0);
    signal Next_Frame_Transmit_Time_out_sync    : std_logic_vector (26 downto 0);
    signal Power_Tx_out_sync                    : std_logic_vector (7 downto 0);
    signal Rx_bw_out_sync                       : std_logic_vector (7 downto 0);
    signal Tx_bw_out_sync                       : std_logic_vector (7 downto 0);
    signal Next_Frame_Receive_Time_out_sync     : std_logic_vector (26 downto 0);
    signal Second_from_2000_out_sync            : std_logic_vector (39 downto 0);
    signal Subsecond_out_sync                   : std_logic_vector (26 downto 0);
    signal timestamp_valid_out_sync             : std_logic;
    signal trx_config_sync                      : std_logic;    

    signal Frame_Length_in                : std_logic_vector (47 downto 0):= (others => '1');
    signal Tx_freq_in                     : std_logic_vector (47 downto 0):= x"112233445566";
    signal Rx_freq_in                     : std_logic_vector (47 downto 0):= x"112233445577";
    signal Next_Frame_Transmit_Time_in    : std_logic_vector (26 downto 0):= (others => '0');
    signal Power_Tx_in                    : std_logic_vector (7 downto 0):= (others => '0');
    signal Rx_bw_in                       : std_logic_vector (7 downto 0):=x"10";
    signal Tx_bw_in                       : std_logic_vector (7 downto 0):=x"12";
    signal Next_Frame_Receive_Time_in     : std_logic_vector (26 downto 0):= (others => '0');
    signal Second_from_2000_in            : std_logic_vector (39 downto 0):= x"0123456789";
    signal Subsecond_in                   : std_logic_vector (26 downto 0):= "000"&x"aabbcc";

    signal first_aurora_s                 : std_logic; 

    signal GFPin_data                      : std_logic_vector(7 downto 0):= (others => '1');
    signal GFPin_valid                     : std_logic:= '0';
    signal GFPin_ready                     : std_logic:= '0';
    signal GFPin_last                      : std_logic:= '0';

    signal GFPout_data                     : std_logic_vector(7 downto 0):= (others => '1');
    signal GFPout_valid                    : std_logic:= '0';
    signal GFPout_ready                    : std_logic:= '1';
    signal GFPout_last                     : std_logic:= '0';

	signal GMSK_IQout_tdata                : std_logic_vector(31 downto 0):= (others => '0');  
    signal GMSK_IQout_valid                : std_logic:= '0';
    signal sample_IQin_data                : std_logic_vector(63 downto 0):= (others => '0');  
    signal Sample_IQin_valid               : std_logic:= '0';
    signal Sample_IQin_ready               : std_logic:= '0'; 

    signal sample_IQout_data               : std_logic_vector(31 downto 0):= (others => '0');  
    signal Sample_IQout_valid              : std_logic:= '0';
    signal gfp_counter                     : std_logic_vector(15 downto 0);


    signal clk_200M : STD_LOGIC;
    signal clk_250m : STD_LOGIC;
    signal clk_375M : STD_LOGIC;
    signal tx_sysref_0,tx_sysref_0_1 : std_logic;
    signal tx_sync_0 : std_logic;
    signal tx_ref_clk: std_logic;
    signal clk_250m_aurora_s : std_logic;
    -- =================== Rx System Signals ===================
    signal delay_clk : std_logic := '0';

    signal ADC_AXI_INTERFACE_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ADC_AXI_INTERFACE_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal ADC_AXI_INTERFACE_arready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_arvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ADC_AXI_INTERFACE_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal ADC_AXI_INTERFACE_awready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_awvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_bready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal ADC_AXI_INTERFACE_bvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ADC_AXI_INTERFACE_rready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal ADC_AXI_INTERFACE_rvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ADC_AXI_INTERFACE_wready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal ADC_AXI_INTERFACE_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal ADC_AXI_INTERFACE_wvalid : STD_LOGIC_VECTOR ( 0 to 0 );

    --    signal s_axi_aclk                     : std_logic := '0';

    --    signal fir_mixer_aclken               : std_logic := '0';
    --    signal fir_ddc_aclken                 : std_logic := '0';
    --    signal fir_ddc_resetn                 : std_logic := '0';

    --    signal delay_rst_sim                  : std_logic := '0';
    --    signal s_axi_aresetn                  : std_logic := '0';

    --    signal iq_ready                       : std_logic := '0';
    signal adc_iq_valid                       : std_logic;

    signal data_a, data_b                 : std_logic_vector(31 downto 0);
    signal adc_clk_out                    : std_logic;

    signal dds_cfg_valid                  : std_logic := '0';
    signal dds_cfg_phase_inc              : std_logic_vector(31 downto 0) := (others => '0');

    -- =================== Tx System Signals ===================
    signal PHY_AXI_INTERFACE_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal PHY_AXI_INTERFACE_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal PHY_AXI_INTERFACE_arready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_arvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal PHY_AXI_INTERFACE_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal PHY_AXI_INTERFACE_awready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_awvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_bready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal PHY_AXI_INTERFACE_bvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal PHY_AXI_INTERFACE_rready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal PHY_AXI_INTERFACE_rvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal PHY_AXI_INTERFACE_wready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal PHY_AXI_INTERFACE_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal PHY_AXI_INTERFACE_wvalid : STD_LOGIC_VECTOR ( 0 to 0 );

    signal LINK_AXI_INTERFACE_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal LINK_AXI_INTERFACE_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal LINK_AXI_INTERFACE_arready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_arvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal LINK_AXI_INTERFACE_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal LINK_AXI_INTERFACE_awready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_awvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_bready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal LINK_AXI_INTERFACE_bvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal LINK_AXI_INTERFACE_rready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal LINK_AXI_INTERFACE_rvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal LINK_AXI_INTERFACE_wready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal LINK_AXI_INTERFACE_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal LINK_AXI_INTERFACE_wvalid : STD_LOGIC_VECTOR ( 0 to 0 );

    signal TRANS_AXI_INTERFACE_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TRANS_AXI_INTERFACE_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal TRANS_AXI_INTERFACE_arready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_arvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TRANS_AXI_INTERFACE_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal TRANS_AXI_INTERFACE_awready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_awvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_bready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal TRANS_AXI_INTERFACE_bvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TRANS_AXI_INTERFACE_rready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal TRANS_AXI_INTERFACE_rvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TRANS_AXI_INTERFACE_wready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TRANS_AXI_INTERFACE_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal TRANS_AXI_INTERFACE_wvalid : STD_LOGIC_VECTOR ( 0 to 0 );

    signal TS_AXI_INTERFACE_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TS_AXI_INTERFACE_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal TS_AXI_INTERFACE_arready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_arvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TS_AXI_INTERFACE_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal TS_AXI_INTERFACE_awready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_awvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_bready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal TS_AXI_INTERFACE_bvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TS_AXI_INTERFACE_rready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal TS_AXI_INTERFACE_rvalid : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal TS_AXI_INTERFACE_wready : STD_LOGIC_VECTOR ( 0 to 0 );
    signal TS_AXI_INTERFACE_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal TS_AXI_INTERFACE_wvalid : STD_LOGIC_VECTOR ( 0 to 0 );



    signal tx_core_clk : std_logic;
    signal spi_top_cs : std_logic_vector(7 downto 0);
    signal spi_top_clk : std_logic;
    signal spi_top_miso : std_logic;
    signal spi_top_mosi : std_logic;
    signal gpio_control : std_logic_vector(31 downto 0);

    signal spi_1_clk : STD_LOGIC;
    signal spi_1_csn : STD_LOGIC_VECTOR ( 7 downto 0 );
    signal spi_1_miso : STD_LOGIC;
    signal spi_1_mosi : STD_LOGIC;

    -- time_sync_top internal signals
    signal sec_loc_s         : unsigned(39 downto 0);
    signal usec_loc_s        : unsigned(26 downto 0);
    signal local_time_snapshot_s : std_logic_vector(66 downto 0) := (others => '0');
    signal local_time_cdc_s      : std_logic_vector(66 downto 0);
    signal local_time_init_s     : std_logic_vector(66 downto 0) := (others => '0');
    signal local_time_send_s     : std_logic := '0';
    signal local_time_rcv_s      : std_logic;
    signal local_time_valid_s    : std_logic;
    signal offset_us_s       : signed(31 downto 0);
    signal pps_error_us_s    : signed(31 downto 0);
    signal error_us_s        : signed(31 downto 0);
    signal inc_out_s         : unsigned(31 downto 0);
    signal tick_us_s         : std_logic;
    signal onepps_s          : std_logic;
    -- Coherent RX timestamp -> sample_clk (servo domain) atomic CDC nets.
    -- A single 67-bit handshake carries {Second_from_2000, Subsecond} together so the
    -- pair is sampled atomically in the sample_clk domain; the handshake dest_req is the
    -- aligned valid. Avoids the init_clk hop and any sec/usec skew between domains.
    signal rx_ts_concat_src_s : std_logic_vector(66 downto 0); -- aurora_clk: Second(40) & Subsecond(27)
    signal rx_ts_concat_smp_s : std_logic_vector(66 downto 0); -- sample_clk: synchronized snapshot
    signal rx_ts_valid_smp_s  : std_logic;                     -- sample_clk: handshake dest_req (aligned valid)
    signal rx_ts_sec_smp_s    : unsigned(39 downto 0);
    signal rx_ts_usec_smp_s   : unsigned(26 downto 0);
    -- new-config event detector (init_clk): decouples fsm_main from the per-rotation
    -- servo timestamp strobe. running_config_valid pulses ONLY when the announced frame
    -- config (freq / bw / next-frame times) actually changes. Pure init_clk logic on
    -- already-synced metadata, so it introduces no new clock-domain crossing.
    --   key = Tx_freq(48) & Rx_freq(48) & NFTT(27) & NFRT(27) & Tx_bw(8) & Rx_bw(8) = 166b
    signal cfg_key_s              : std_logic_vector(165 downto 0);
    signal cfg_key_committed_s    : std_logic_vector(165 downto 0) := (others => '0');
    signal running_config_valid_s : std_logic := '0';
    -- Do tre truyen CO DINH cua duong timestamp MBU->RFU, don vi chu ky sample_clk
    -- (250 MHz => 4 ns/chu ky). Do tren HW 2026-07-31: sau khi servo da khoa,
    -- (ts_off - pps_err) = +720/+730/+730/+720 ns o ca 4 cfg_mode (AUTO, PPS_ONLY,
    -- TS_ONLY, FULL_SYNC) => day la bias hang so cua duong timestamp, khong phu
    -- thuoc nguon nao dang dieu khien servo. 720 ns / 4 ns = 180 chu ky.
    -- Day la gia tri HARDCODE tam thoi (init cua vio_ts probe_out1); khi do lai
    -- chinh xac hon thi doi o DAY va o scripts_ts/build_vio_ts.tcl cho khop.
    constant TS_DELAY_CYC_MEASURED : integer := 180;
    -- vcsco_wrapper debug / monitor signals
    signal run_state_dbg_s   : std_logic_vector(2 downto 0);
    signal pps_ok_dbg_s      : std_logic;
    signal ts_ok_dbg_s       : std_logic;
    signal sync_locked_dbg_s : std_logic;
    signal holdover_dbg_s    : std_logic;
    -- VIO dieu khien che do dong bo (xem vio_timesync o duoi). Init "000" = AUTO,
    -- khop voi gia tri hardcode truoc day nen hanh vi sau reset khong doi.
    signal cfg_mode_vio_s    : std_logic_vector(2 downto 0);
    -- Bu do tre truyen timestamp, don vi CHU KY sample_clk (250 MHz -> 4 ns).
    -- ts_delay_vio_s = probe_out1 cua vio_ts (init 0x0000):
    --   bit15 = 0 -> dung hardcode TS_DELAY_CYC_MEASURED  (mac dinh sau reset)
    --   bit15 = 1 -> dung [14:0] lam so chu ky, KE CA 0 (=> tat bu de A/B)
    -- Nho co bit "override" nay, gia tri mac dinh nam trong RTL (kiem tra duoc
    -- bang mat) chu khong phu thuoc vao INIT cua IP VIO, ma van quet duoc luc chay.
    signal ts_delay_vio_s    : std_logic_vector(15 downto 0);
    -- 20/10/2026: chon che do ky luat luc chay qua VIO (probe_out2, 1 bit).
    -- '0' = NCO so (DAC dong bang), '1' = analog DAC->VCSO. IP init 0x0 =>
    -- SAU KHI NAP BITSTREAM HE O CHE DO SO cho den khi go probe_out2 = 1.
    -- (Ban generic cu build 17-19/10 chay cung '1' tu luc nap.)
    signal vcxo_en_vio_s     : std_logic_vector(0 downto 0);
    signal ts_delay_cyc_s    : unsigned(15 downto 0);
    signal ts_status_word_s  : std_logic_vector(31 downto 0);
    signal dac_code_dbg_s    : unsigned(17 downto 0);
    signal dac_update_dbg_s  : std_logic;
    signal spi_busy_dbg_s    : std_logic;
    signal vcsco_ila_probe4_s : std_logic_vector(31 downto 0);
    -- VCSCO SPI bus taps (driven to the AD5680 pins below) + ILA probe vectors.
    -- A dedicated ila_0 instance probes these via explicit port connections, which
    -- survive synthesis (unlike top-level mark_debug on these pass-through nets).
    signal dac_vcso_din_i  : std_logic;
    signal dac_vcso_sclk_i : std_logic;
    signal dac_vcso_sync_i : std_logic;
    signal vcsco_spi_p1_s  : std_logic_vector(31 downto 0); -- dac_code (zero-extended)
    signal vcsco_spi_p4_s  : std_logic_vector(31 downto 0); -- pps_error_us
    signal control_bus       : std_logic_vector(7 downto 0) := (others => '0');
    signal I_data, Q_data    : std_logic_vector(15 downto 0);
    signal I_data_out, Q_data_out : std_logic_vector(15 downto 0);
    signal aurora_data_out  : std_logic_vector(31 downto 0);
    signal aurora_data_valid_out  : std_logic;
    signal aurora_rst_out         : std_logic;
    signal aurora_status          : std_logic_vector(31 downto 0);
    signal aurora_status_core_s   : std_logic_vector(31 downto 0);
    signal adc_rst_s              : std_logic;											  
    --------ad9164 NCO Config SPI Interface
    signal ad9164_csn                 : std_logic_vector(0 downto 0);
    signal ad9164_sclk                : std_logic_vector(0 downto 0);
    signal ad9164_mosi                : std_logic_vector(0 downto 0);
    ---- pll configuration SPI Interface
    signal pll_a_ad9914_clk           : std_logic;
    signal pll_a_ad9914_data          : std_logic;
    signal pll_a_ad9914_le            : std_logic;

    signal pll_a_adf41510_clk         : std_logic;
    signal pll_a_adf41510_mosi        : std_logic;
    signal pll_a_adf41510_csn         : std_logic;

    signal pll_b_ad9914_clk           : std_logic;
    signal pll_b_ad9914_data          : std_logic;
    signal pll_b_ad9914_le            : std_logic;

    signal pll_b_adf41510_clk         : std_logic;
    signal pll_b_adf41510_mosi        : std_logic;
    signal pll_b_adf41510_csn         : std_logic;


    signal cfg_reload                  : std_logic;
    signal gpio_test_ub                   : std_logic;
    signal gpio_mask1_ub               : std_logic_vector( 31 downto 0) ;
    signal gpio_mask2_ub               : std_logic_vector( 31 downto 0) ;
    signal gpio_mask3_ub               : std_logic_vector( 31 downto 0) ;
    signal gpio_mux_clk                : std_logic;
    signal gpio_toggle                 : std_logic;
	signal hb_fb_sw_2s 				   : std_logic := '0';
	signal command1_ub                 : std_logic_vector( 31 downto 0) ;
    signal command2_ub                 : std_logic_vector( 31 downto 0) ;
    signal command3_ub                 : std_logic_vector( 31 downto 0) ;
    signal command4_ub                 : std_logic_vector( 31 downto 0) ;
    signal command5_ub                 : std_logic_vector( 31 downto 0) ;    	
    signal spi_tx_clk_s                : std_logic;
    signal spi_bite_sdio_s             : std_logic;
    signal spi_bite_miso_s             : std_logic;
    signal spi_tx_csn_s                  : std_logic_vector(9 downto 0);
    signal spi_tx_miso_s                 : std_logic;
    signal spi_tx_mosi_s                 : std_logic;
   
    signal spi_tx_cpld_csn             : std_logic;
    signal spi_tx_cpld_mosi            : std_logic;
    signal spi_tx_cpld_miso            : std_logic;
    signal spi_tx_cpld_clk             : std_logic;
    signal tx_command                  : std_logic_vector(31 downto 0);
    signal tx_card_status                : std_logic_vector(31 downto 0);
    signal IQ_fifo_almost_full,IQ_fifo_empty : std_logic;
    
    signal    run_state_out   		: std_logic_vector(2 downto 0);
    signal    enable_fsm      		: std_logic_vector(0 downto 0);
    signal    pps_ok_out      		: std_logic;
    signal    sync_locked_out 		: std_logic;
    signal    holdover_out    		: std_logic;
    signal    dac_code_out    		: std_logic_vector(31 downto 0); -- current DAC code command
    signal    gpio_out    			: std_logic_vector(64 downto 0);
    signal    aurora_pll_notlock    : std_logic_vector(0 downto 0);
    signal    gt_pll_lock    		: std_logic_vector(0 downto 0);
    signal    lane_up    			: std_logic_vector(0 downto 0);
    signal    channel_up    		: std_logic_vector(0 downto 0);
    signal    soft_err    			: std_logic_vector(0 downto 0);
    signal    hard_err    			: std_logic_vector(0 downto 0);
    signal    reset_pb    			: std_logic_vector(0 downto 0);
    signal    pmi_init    			: std_logic_vector(0 downto 0); 
    signal 	  gt_rxusrclk_s			: std_logic;
    signal    FSM_locked			: std_logic;
    signal    aurora_data_out_sample_current	: std_logic_vector(31 downto 0);
    signal    track_error_counter				: std_logic;
    signal    ADC_PDWN				: std_logic;
    signal    DDS_PWR_DWN			: std_logic;
    signal    EN_RX					: std_logic;
    signal    EN_TX					: std_logic;
    signal    EN_LO					: std_logic;
    signal    EN_RTX				: std_logic;
    signal    ADC_AFE_PM			: std_logic;
    signal    ADC_AFE_PWUP			: std_logic;
    signal    conf_NB6L295			: std_logic := '0';
    signal    spi_tx_mosi_in		: std_logic := '0';
    signal    I_error				: std_logic_vector(0 downto 0);
    signal    Q_error				: std_logic_vector(0 downto 0);
    signal    tx_IQ_source,tx_IQ_source_sync			: std_logic_vector(2 downto 0);
    signal    VCSO_ctrl_mode		: std_logic_vector(2 downto 0);
    signal    rx_dds_config_tvalid	: std_logic;
    signal    rx_dds_config_tdata	: std_logic_vector(31 downto 0);
    
    -- constant nominal increment
    --constant INC_NOMINAL_CONST : unsigned(31 downto 0) := to_unsigned(14316558, 32); --(2^32*1M)/300M
    ---constant INC_NOMINAL_CONST : unsigned(31 downto 0) := to_unsigned(42949673, 32); --(2^32*1M)/100M
    constant INC_NOMINAL_CONST : integer := 17179869; --(2^32*1M)/250M
    
begin
    aurora_status <= aurora_status_core_s(31 downto 13) &
                     tx_fir_error_init_s &
                     tx_fifo_overflow_init_s &
                     tx_fifo_underflow_init_s &
                     aurora_status_core_s(9 downto 0);

        -- DAC Control
    spi_top_miso        <= lut_spi_miso 	when (spi_top_cs(1) = '0') else dac_sdo;
    dac_rstn            <= '1';
    dac_sdio            <= spi_top_mosi 	when (spi_top_cs(0) = '0') else ad9164_mosi(0); 																					 
    dac_sclk            <= spi_top_clk 		when (spi_top_cs(0) = '0') else ad9164_sclk(0);
    dac_csn             <= '0'				when (spi_top_cs(0) = '0') else ad9164_csn(0);

    lut_spi_cs_b        <= spi_top_cs(1);
    lut_spi_sclk        <= spi_top_clk    	when (spi_top_cs(1) = '0') else '0';
    lut_spi_mosi        <= spi_top_mosi   	when (spi_top_cs(1) = '0') else 'Z';

 -- PLL B -- no needed control by uBlaze
    pll_b_clk           <= pll_b_adf41510_clk;-- when pll_b_adf41510_csn = '0' else '1';
    pll_b_data          <= pll_b_adf41510_mosi;-- when pll_b_adf41510_csn = '0' else '1';
    pll_b_le            <= pll_b_adf41510_csn;
    
    -- PLL A -- no needed control by uBlaze
    pll_a_clk           <= pll_a_adf41510_clk;-- when pll_a_adf41510_csn = '0' else '1';
    pll_a_data          <= pll_a_adf41510_mosi;-- when pll_a_adf41510_csn = '0' else '1';
    pll_a_le            <= pll_a_adf41510_csn;

--    dds_a_0_csn         <= pll_a_ad9914_le;
--    dds_b_0_csn         <= pll_b_ad9914_le;
--    dds_scl             <= pll_a_ad9914_clk when pll_a_ad9914_le = '0' else pll_b_ad9914_clk;
--    dds_scl            <= pll_a_ad9914_data when pll_a_ad9914_le = '0' else pll_b_ad9914_data;

   OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => gpio_mux_clk_p,     -- Diff_p output (connect directly to top-level port)
      OB =>gpio_mux_clk_n,     -- Diff_n output (connect directly to top-level port)
      I => init_clk_s);        -- Buffer input 
   
    dds_instan: dds_compiler_1
		Port map   (aclk => clk_250m_aurora_s,
					m_axis_data_tvalid => sample_IQout_valid,
					m_axis_data_tdata => sample_IQout_data);
    
    Waveform_streamer_inst : Waveform_streamer
		Port map   (clk				=> clk_250m_aurora_s,
					rst				=> '0',
					IQout_tlast		=> open,
					IQout_tdata		=> GMSK_IQout_tdata,
					IQout_tvalid	=> GMSK_IQout_valid);

    --      -- =================== Instantiate rx_wrap ===================

    -- [MSDR] bo khoi: rx_wrap : rx_system_wrap  -> thay bang tap IQ tu axi_adrv9001
    --
    -- rx_system_wrap cu phat A_B_data_o = I_A & Q_A & I_B & Q_B tren sample_clk_s.
    -- ADRV9002 cho dung hai kenh do: kenh A = RX1 o adc_1, kenh B = RX2 o adc_2
    -- theo nhip rieng. adc_1_clk va adc_2_clk sinh tu cung xung thiet bi nen
    -- cung tan so, lech pha khong biet truoc; RX2 vuot sang adc_1_clk bang mot
    -- FIFO khong dong bo nong.
    u_adc2_cdc : xpm_fifo_async
      generic map (
        CDC_SYNC_STAGES => 2, DOUT_RESET_VALUE => "0", ECC_MODE => "no_ecc",
        FIFO_MEMORY_TYPE => "distributed", FIFO_READ_LATENCY => 0,
        FIFO_WRITE_DEPTH => 16, FULL_RESET_VALUE => 0,
        PROG_EMPTY_THRESH => 5, PROG_FULL_THRESH => 10,
        RD_DATA_COUNT_WIDTH => 5, READ_DATA_WIDTH => 32, READ_MODE => "fwft",
        RELATED_CLOCKS => 0, USE_ADV_FEATURES => "0000", WAKEUP_TIME => 0,
        WRITE_DATA_WIDTH => 32, WR_DATA_COUNT_WIDTH => 5)
      port map (
        sleep => '0', rst => adc_2_rst,
        wr_clk => adc_2_clk, wr_en => adc_2_valid,
        din => adc_2_data_i0 & adc_2_data_q0, full => adc2_fifo_full,
        rd_clk => sample_clk_s, rd_en => adc2_fifo_rden,
        dout => adc2_fifo_dout, empty => adc2_fifo_empty,
        injectdbiterr => '0', injectsbiterr => '0', dbiterr => open, sbiterr => open,
        almost_empty => open, almost_full => open, data_valid => open,
        overflow => open, prog_empty => open, prog_full => open,
        rd_data_count => open, rd_rst_busy => open, underflow => open,
        wr_ack => open, wr_data_count => open, wr_rst_busy => open);

    adc2_fifo_rden    <= adc_1_valid and not adc2_fifo_empty;
    Sample_IQin_data  <= adc_1_data_i0 & adc_1_data_q0 &
                         adc2_fifo_dout(31 downto 16) & adc2_fifo_dout(15 downto 0)
                         when adc2_fifo_empty = '0' else
                         adc_1_data_i0 & adc_1_data_q0 & x"00000000";
    Sample_IQin_valid <= adc_1_valid;
    adc1_dovf_src_s <= adc_1_valid and not Sample_IQin_ready;
    adc2_dovf_src_s <= adc_2_valid and adc2_fifo_full;
    adc_clk_out       <= adc_1_clk;

    adc1_dovf_event : process (adc_1_clk)
    begin
      if rising_edge(adc_1_clk) then
        if adc_1_rst = '1' then
          adc1_dovf_src_d_s <= '0';
          adc1_dovf_pulse_s <= '0';
        else
          adc1_dovf_pulse_s <= adc1_dovf_src_s and not adc1_dovf_src_d_s;
          adc1_dovf_src_d_s <= adc1_dovf_src_s;
        end if;
      end if;
    end process;

    adc2_dovf_event : process (adc_2_clk)
    begin
      if rising_edge(adc_2_clk) then
        if adc_2_rst = '1' then
          adc2_dovf_src_d_s <= '0';
          adc2_dovf_pulse_s <= '0';
        else
          adc2_dovf_pulse_s <= adc2_dovf_src_s and not adc2_dovf_src_d_s;
          adc2_dovf_src_d_s <= adc2_dovf_src_s;
        end if;
      end if;
    end process;

    adc1_dovf_cdc : xpm_cdc_pulse
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 1,
        REG_OUTPUT     => 0,
        RST_USED       => 1,
        SIM_ASSERT_CHK => 0
      )
      port map (
        dest_pulse => adc1_dovf_axi_s,
        dest_clk   => init_clk_s,
        dest_rst   => not initclk_rstn_s,
        src_clk    => adc_1_clk,
        src_pulse  => adc1_dovf_pulse_s,
        src_rst    => adc_1_rst
      );

    adc2_dovf_cdc : xpm_cdc_pulse
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 1,
        REG_OUTPUT     => 0,
        RST_USED       => 1,
        SIM_ASSERT_CHK => 0
      )
      port map (
        dest_pulse => adc2_dovf_axi_s,
        dest_clk   => init_clk_s,
        dest_rst   => not initclk_rstn_s,
        src_clk    => adc_2_clk,
        src_pulse  => adc2_dovf_pulse_s,
        src_rst    => adc_2_rst
      );

    adc1_dovf_level_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 1,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => adc1_dovf_level_axi_s,
        dest_clk => init_clk_s,
        src_clk  => adc_1_clk,
        src_in   => adc1_dovf_src_s
      );

    adc2_dovf_level_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 1,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => adc2_dovf_level_axi_s,
        dest_clk => init_clk_s,
        src_clk  => adc_2_clk,
        src_in   => adc2_dovf_src_s
      );

    adc_dovf_axi_s <= adc1_dovf_axi_s or adc2_dovf_axi_s or
                      adc1_dovf_level_axi_s or adc2_dovf_level_axi_s;

    sync_locked_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 1,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => sync_locked_axi_s,
        dest_clk => init_clk_s,
        src_clk  => sample_clk_s,
        src_in   => sync_locked_dbg_s
      );

    tx_aurora_reset_s <= aurora_rst_s when tx_IQ_source_sync = "010" else '0';
    tx_path_async_rst_s <= (not initclk_rstn_s) or tx_aurora_reset_s or dac_1_rst;
    tx_fifo_rst_s <= tx_path_rst_250_s or dac_1_rst;

    tx_path_rst_cdc : xpm_cdc_async_rst
      generic map (
        DEST_SYNC_FF    => 4,
        INIT_SYNC_FF    => 1,
        RST_ACTIVE_HIGH => 1
      )
      port map (
        dest_arst => tx_path_rst_250_s,
        dest_clk  => clk_250m_aurora_s,
        src_arst  => tx_path_async_rst_s
      );

    fir_core_input_valid_s <= fir_input_valid_s and
                              fir_i_input_ready_s and
                              fir_q_input_ready_s;
    fir_output_valid_s <= fir_i_output_valid_s and fir_q_output_valid_s;
    fir_output_i_s <= fir_i_output_data_s;
    fir_output_q_s <= fir_q_output_data_s;

    i_tx_i_fir_decimator : entity work.fir_i_decimator
      port map (
        aresetn             => not tx_path_rst_250_s,
        aclk                => clk_250m_aurora_s,
        s_axis_data_tvalid  => fir_core_input_valid_s,
        s_axis_data_tready  => fir_i_input_ready_s,
        s_axis_data_tdata   => I_data,
        m_axis_data_tvalid  => fir_i_output_valid_s,
        m_axis_data_tdata   => fir_i_output_data_s
      );

    i_tx_q_fir_decimator : entity work.fir_q_decimator
      port map (
        aresetn             => not tx_path_rst_250_s,
        aclk                => clk_250m_aurora_s,
        s_axis_data_tvalid  => fir_core_input_valid_s,
        s_axis_data_tready  => fir_q_input_ready_s,
        s_axis_data_tdata   => Q_data,
        m_axis_data_tvalid  => fir_q_output_valid_s,
        m_axis_data_tdata   => fir_q_output_data_s
      );

    tx_fifo_din_s <= fir_output_i_s & fir_output_q_s;
    tx_fifo_wr_en_s <= fir_output_valid_s and not tx_fifo_full_s;
    tx_fifo_rd_en_s <= dac_1_rd_en and not tx_fifo_empty_s;

    tx_iq_rate_cdc_fifo : xpm_fifo_async
      generic map (
        CDC_SYNC_STAGES     => 2,
        DOUT_RESET_VALUE    => "0",
        ECC_MODE            => "no_ecc",
        FIFO_MEMORY_TYPE    => "block",
        FIFO_READ_LATENCY   => 0,
        FIFO_WRITE_DEPTH    => 1024,
        FULL_RESET_VALUE    => 0,
        PROG_EMPTY_THRESH   => 16,
        PROG_FULL_THRESH    => 1008,
        RD_DATA_COUNT_WIDTH => 11,
        READ_DATA_WIDTH     => 32,
        READ_MODE           => "fwft",
        RELATED_CLOCKS      => 0,
        USE_ADV_FEATURES    => "0000",
        WAKEUP_TIME         => 0,
        WRITE_DATA_WIDTH    => 32,
        WR_DATA_COUNT_WIDTH => 11
      )
      port map (
        sleep         => '0',
        rst           => tx_fifo_rst_s,
        wr_clk        => clk_250m_aurora_s,
        wr_en         => tx_fifo_wr_en_s,
        din           => tx_fifo_din_s,
        full          => tx_fifo_full_s,
        rd_clk        => dac_1_clk,
        rd_en         => tx_fifo_rd_en_s,
        dout          => tx_fifo_dout_s,
        empty         => tx_fifo_empty_s,
        injectdbiterr => '0',
        injectsbiterr => '0',
        dbiterr       => open,
        sbiterr       => open,
        almost_empty  => open,
        almost_full   => open,
        data_valid    => open,
        overflow      => open,
        prog_empty    => open,
        prog_full     => open,
        rd_data_count => open,
        rd_rst_busy   => open,
        underflow     => open,
        wr_ack        => open,
        wr_data_count => open,
        wr_rst_busy   => open
      );

    tx_fifo_overflow_monitor : process (clk_250m_aurora_s)
    begin
      if rising_edge(clk_250m_aurora_s) then
        if tx_path_rst_250_s = '1' then
          tx_fifo_overflow_sticky_s <= '0';
        elsif fir_output_valid_s = '1' and tx_fifo_full_s = '1' then
          tx_fifo_overflow_sticky_s <= '1';
        end if;
      end if;
    end process;

    tx_fifo_underflow_monitor : process (dac_1_clk)
    begin
      if rising_edge(dac_1_clk) then
        if tx_fifo_rst_s = '1' then
          tx_fifo_underflow_sticky_s <= '0';
          tx_fifo_read_started_s <= '0';
        elsif tx_iq_source_dac_s = "110" or tx_iq_source_dac_s = "111" then
          tx_fifo_read_started_s <= '0';
        elsif tx_fifo_empty_s = '0' then
          tx_fifo_read_started_s <= '1';
        elsif dac_1_rd_en = '1' and tx_fifo_read_started_s = '1' then
          tx_fifo_underflow_sticky_s <= '1';
        end if;
      end if;
    end process;

    tx_fifo_overflow_status_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => tx_fifo_overflow_init_s,
        dest_clk => init_clk_s,
        src_clk  => clk_250m_aurora_s,
        src_in   => tx_fifo_overflow_sticky_s
      );

    tx_fir_error_monitor : process (clk_250m_aurora_s)
    begin
      if rising_edge(clk_250m_aurora_s) then
        if tx_path_rst_250_s = '1' then
          tx_fir_error_sticky_s <= '0';
        elsif (fir_input_valid_s = '1' and
               (fir_i_input_ready_s = '0' or fir_q_input_ready_s = '0')) or
              (fir_i_input_ready_s /= fir_q_input_ready_s) or
              (fir_i_output_valid_s /= fir_q_output_valid_s) then
          tx_fir_error_sticky_s <= '1';
        end if;
      end if;
    end process;

    tx_fir_error_status_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => tx_fir_error_init_s,
        dest_clk => init_clk_s,
        src_clk  => clk_250m_aurora_s,
        src_in   => tx_fir_error_sticky_s
      );

    tx_fifo_underflow_status_cdc : xpm_cdc_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1
      )
      port map (
        dest_out => tx_fifo_underflow_init_s,
        dest_clk => init_clk_s,
        src_clk  => dac_1_clk,
        src_in   => tx_fifo_underflow_sticky_s
      );
    
	process(clk_250m_aurora_s)
		begin
			if rising_edge(clk_250m_aurora_s) then
        if tx_path_rst_250_s = '1' then
          I_data <= (others => '0');
          Q_data <= (others => '0');
          I_data_out <= (others => '0');
          Q_data_out <= (others => '0');
          fir_input_valid_s <= '0';
          I_error(0) <= '0';
          Q_error(0) <= '0';
        else
				case tx_IQ_source_sync is
					when "000"	=>	I_data 	<= sample_IQout_data(31) & sample_IQout_data(31) & sample_IQout_data(31 downto 18); -- for IMD3 measurements 500 kHz far eachother
									Q_data	<= sample_IQout_data(31) & sample_IQout_data(31) & sample_IQout_data(31 downto 18);
                  fir_input_valid_s <= sample_IQout_valid;
					when "001"	=>	I_data 	<= sample_IQout_data(31) & sample_IQout_data(31) & sample_IQout_data(31 downto 18); -- for one carrier shifted by 250 kHz
									Q_data	<= sample_IQout_data(15) & sample_IQout_data(15) & sample_IQout_data(15 downto 2);
                  fir_input_valid_s <= sample_IQout_valid;
					when "010"	=>	I_data	<= aurora_data_out(31)   & aurora_data_out(31)   & aurora_data_out(31 downto 18);   -- from MBU
									Q_data	<= aurora_data_out(15)   & aurora_data_out(15)   & aurora_data_out(15 downto 2);
                  fir_input_valid_s <= aurora_data_valid_out;
					when "011"	=>	I_data	<= x"3FFF";							-- CW 1/2 power
									Q_data	<= x"3FFF";
                  fir_input_valid_s <= '1';
					when "100"	=>	I_data	<= x"1FFF";							-- CW 1/8 power
									Q_data	<= x"1FFF";
                  fir_input_valid_s <= '1';
					when "101"	=>	I_data	<= GMSK_IQout_tdata(31) & GMSK_IQout_tdata(31) & GMSK_IQout_tdata(31 downto 18);	-- GMSK 2Mb/s
									Q_data	<= GMSK_IQout_tdata(15) & GMSK_IQout_tdata(15) & GMSK_IQout_tdata(15 downto 2);
                  fir_input_valid_s <= GMSK_IQout_valid;
					when "110" => I_data <= (others => '0'); Q_data <= (others => '0');
                  fir_input_valid_s <= '0';
					when others =>	I_data	<= x"0000";							--RF off
									Q_data	<= x"0000";
                  fir_input_valid_s <= '0';
				end case;
								
				I_data_out <= I_data;
				Q_data_out <= Q_data;
        if (I_data_out + 1) /= I_data then
          I_error(0) <= '1';
        else
          I_error(0) <= '0';
        end if;
        if (Q_data_out + 1) /= Q_data then
          Q_error(0) <= '1';
        else
          Q_error(0) <= '0';
        end if;
        end if;
			end if;
		end process;
	
    -- [MSDR] bo khoi: Aurora_samp_out_ila : ila_1 (bo het ILA khoi code)
            
    -- [MSDR] bo khoi: tx_wrap : tx_sys (JESD204 AD9164) -> thay bang dac_1
    --
    -- One IQ pair is one 32-bit sample: I[15:0] and Q[15:0]. The Aurora-side
    -- 250-MSPS stream is FIR-decimated by five, then crossed to the DAC clock.
    dac_unpack : process (dac_1_clk)
    begin
      if rising_edge(dac_1_clk) then
        if dac_1_rst = '1' then
          dac_samp_i     <= (others => '0');
          dac_samp_q     <= (others => '0');
        elsif dac_1_rd_en = '1' then
          if tx_iq_source_dac_s = "110" or tx_iq_source_dac_s = "111" then
            dac_samp_i <= (others => '0');
            dac_samp_q <= (others => '0');
          elsif tx_fifo_empty_s = '0' then
            dac_samp_i <= tx_fifo_dout_s(31 downto 16);
            dac_samp_q <= tx_fifo_dout_s(15 downto 0);
          else
            dac_samp_i <= (others => '0');
            dac_samp_q <= (others => '0');
          end if;
        end if;
      end if;
    end process dac_unpack;

    dac_1_data_i0 <= dac_samp_i;
    dac_1_data_q0 <= dac_samp_q;
    dac_1_data_i1 <= (others => '0');
    dac_1_data_q1 <= (others => '0');
    tx_core_clk   <= dac_1_clk;

    -- [MSDR] bo khoi: tx_sync_inst : IBUFDS (SYNC cua JESD, khong con)

--    GPIO_CLK_OUT_INST : OBUFDS
--    generic map (
--        IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
--        SLEW => "FAST")          -- Specify the output slew rate
--    port map (
--        O => gpio_mux_clk_p,     -- Diff_p output (connect directly to top-level port)
--        OB => gpio_mux_clk_n,   -- Diff_n output (connect directly to top-level port)
--        I => init_clk_s      -- Buffer input 
--    );

    --   tx_sysref_inst : IBUFDS
    --   port map (
    --      O => tx_sysref_0,   -- 1-bit output: Buffer output
    --      I => tx_sysref_0_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
    --      IB => tx_sysref_0_n  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    --   );    

    tx_ref_ins : IBUFDS_GTE4 
    port map (
        O => tx_ref_clk,         -- 1-bit output: Refer to Transceiver User Guide.
        ODIV2 => open, -- 1-bit output: Refer to Transceiver User Guide.
        CEB => '0',     -- 1-bit input: Refer to Transceiver User Guide.
        I => Aurora_refclk_p,
        IB => Aurora_refclk_n
    );

    --    gfp_gen_proc: process(init_clk_s)
    --    begin
    --            if(init_clk_s'event and init_clk_s = '1')then
    --                if(initclk_rst_s = '0')then
    --                    GFPin_valid    <= '0';
    --                    GFPin_data     <= (others => '0');  
    --                    GFPin_last     <= '0';   
    --                    gfp_counter    <= (others => '0');       
    --                else
    --                    if(GFPin_ready = '1') then
    --                        if(gfp_counter <= x"04B4") then

    --                            if(gfp_counter = x"0001" ) then 
    --                                GFPin_data <= x"4E";
    --                                GFPin_valid   <= '1';
    --                                GFPin_last <= '0';
    --                            elsif(gfp_counter = x"0002" ) then 
    --                                GFPin_data <= x"04"; 
    --                                GFPin_valid   <= '1';
    --                                GFPin_last <= '0';
    --                            elsif(gfp_counter = x"0003" ) then 
    --                                GFPin_data <= x"B0";  
    --                                GFPin_valid   <= '1';
    --                                GFPin_last <= '0'; 
    --                            elsif(gfp_counter = x"0004" ) then 
    --                                GFPin_data <= x"02";
    --                                GFPin_valid   <= '1';
    --                                GFPin_last <= '0';
    --                            elsif(gfp_counter < x"04B4" ) then 
    --                                GFPin_data <= gfp_counter(7 downto 0);
    --                                GFPin_valid   <= '1';
    --                                GFPin_last <= '0';
    --                            elsif(gfp_counter = x"04B4" ) then 
    --                                GFPin_data <= gfp_counter(7 downto 0);
    --                                GFPin_last <= '1';
    --                                GFPin_valid   <= '1';
    --                            else
    --                                GFPin_last <= '0';
    --                                GFPin_valid <= '0';                            
    --                            end if;
    --                        else
    --                            GFPin_last <= '0';
    --                            GFPin_valid <= '0';  
    --                        end if;
    --                        if(gfp_counter < x"04FF") then
    --                            gfp_counter <= gfp_counter + '1';
    --                        else
    --                            gfp_counter <= (others => '0');
    --                        end if; 
    --                    end if;
    --                end if;
    --            end if;
    --    end process;

    -- [MSDR] mb_wrapper_ins : mb_bd_wrapper -> sys_wrapper_ins : system_wrapper
    --
    -- Giu dung vi tri trong file nhu ban cu. system.bd chua PS, axi_adrv9001,
    -- DMA phat, bang tra cau hinh, FIFO ban tin GFP va tu lenh - tuc la dung
    -- nhung thu mb_bd tung cung cap.
    sys_wrapper_ins : system_wrapper
      port map (
        CFG_LUT_addr               => CFG_LUT_addr,
        CFG_LUT_clk                => CFG_LUT_clk,
        CFG_LUT_din                => CFG_LUT_din,
        CFG_LUT_dout               => CFG_LUT_dout,
        CFG_LUT_en                 => CFG_LUT_en,
        CFG_LUT_rst                => CFG_LUT_rst,
        CFG_LUT_we                 => CFG_LUT_we,
        GFP_UB_IN_tdata            => GFP_UB_IN_tdata,
        GFP_UB_IN_tlast            => GFP_UB_IN_tlast,
        GFP_UB_IN_tready           => GFP_UB_IN_tready,
        GFP_UB_IN_tvalid           => GFP_UB_IN_tvalid,
        GFP_UB_OUT_tdata           => GFP_UB_OUT_tdata,
        GFP_UB_OUT_tlast           => GFP_UB_OUT_tlast,
        GFP_UB_OUT_tready          => GFP_UB_OUT_tready,
        GFP_UB_OUT_tvalid          => GFP_UB_OUT_tvalid,
        M_AXI_SYS_araddr           => M_AXI_SYS_araddr,
        M_AXI_SYS_arprot           => M_AXI_SYS_arprot,
        M_AXI_SYS_arready          => M_AXI_SYS_arready,
        M_AXI_SYS_arvalid          => M_AXI_SYS_arvalid,
        M_AXI_SYS_awaddr           => M_AXI_SYS_awaddr,
        M_AXI_SYS_awprot           => M_AXI_SYS_awprot,
        M_AXI_SYS_awready          => M_AXI_SYS_awready,
        M_AXI_SYS_awvalid          => M_AXI_SYS_awvalid,
        M_AXI_SYS_bready           => M_AXI_SYS_bready,
        M_AXI_SYS_bresp            => M_AXI_SYS_bresp,
        M_AXI_SYS_bvalid           => M_AXI_SYS_bvalid,
        M_AXI_SYS_rdata            => M_AXI_SYS_rdata,
        M_AXI_SYS_rready           => M_AXI_SYS_rready,
        M_AXI_SYS_rresp            => M_AXI_SYS_rresp,
        M_AXI_SYS_rvalid           => M_AXI_SYS_rvalid,
        M_AXI_SYS_wdata            => M_AXI_SYS_wdata,
        M_AXI_SYS_wready           => M_AXI_SYS_wready,
        M_AXI_SYS_wstrb            => M_AXI_SYS_wstrb,
        M_AXI_SYS_wvalid           => M_AXI_SYS_wvalid,
        M_AXI_REGS_araddr          => M_AXI_REGS_araddr,
        M_AXI_REGS_arprot          => M_AXI_REGS_arprot,
        M_AXI_REGS_arready         => M_AXI_REGS_arready,
        M_AXI_REGS_arvalid         => M_AXI_REGS_arvalid,
        M_AXI_REGS_awaddr          => M_AXI_REGS_awaddr,
        M_AXI_REGS_awprot          => M_AXI_REGS_awprot,
        M_AXI_REGS_awready         => M_AXI_REGS_awready,
        M_AXI_REGS_awvalid         => M_AXI_REGS_awvalid,
        M_AXI_REGS_bready          => M_AXI_REGS_bready,
        M_AXI_REGS_bresp           => M_AXI_REGS_bresp,
        M_AXI_REGS_bvalid          => M_AXI_REGS_bvalid,
        M_AXI_REGS_rdata           => M_AXI_REGS_rdata,
        M_AXI_REGS_rready          => M_AXI_REGS_rready,
        M_AXI_REGS_rresp           => M_AXI_REGS_rresp,
        M_AXI_REGS_rvalid          => M_AXI_REGS_rvalid,
        M_AXI_REGS_wdata           => M_AXI_REGS_wdata,
        M_AXI_REGS_wready          => M_AXI_REGS_wready,
        M_AXI_REGS_wstrb           => M_AXI_REGS_wstrb,
        M_AXI_REGS_wvalid          => M_AXI_REGS_wvalid,
        adc_1_clk                  => adc_1_clk,
        adc_1_data_i0              => adc_1_data_i0,
        adc_1_data_q0              => adc_1_data_q0,
        adc_1_rst                  => adc_1_rst,
        adc_1_valid                => adc_1_valid,
        adc_2_clk                  => adc_2_clk,
        adc_2_data_i0              => adc_2_data_i0,
        adc_2_data_q0              => adc_2_data_q0,
        adc_2_rst                  => adc_2_rst,
        adc_2_valid                => adc_2_valid,
        aurora_sample_clk          => clk_250m_aurora_s,
        dac_1_clk                  => dac_1_clk,
        dac_1_data_i0              => dac_1_data_i0,
        dac_1_data_i1              => dac_1_data_i1,
        dac_1_data_q0              => dac_1_data_q0,
        dac_1_data_q1              => dac_1_data_q1,
        dac_1_rd_en                => dac_1_rd_en,
        dac_1_rst                  => dac_1_rst,
        gpio_1_tri_i               => gpio_1_tri_i,
        gpio_1_tri_o               => gpio_1_tri_o,
        gpio_i                     => gpio_i,
        gpio_o                     => gpio_o,
        gpio_rx1_enable_in         => gpio_rx1_enable_in,
        gpio_rx2_enable_in         => gpio_rx2_enable_in,
        gpio_t                     => gpio_t,
        gpio_tx1_enable_in         => gpio_tx1_enable_in,
        gpio_tx2_enable_in         => gpio_tx2_enable_in,
        init_clk                   => init_clk,
        initclk_rstn               => initclk_rstn_v,
        mcs_in                     => mcs_in,
        mcs_out                    => open,
        mssi_sync                  => mssi_sync,
        ps_gpio0_o                 => ps_gpio0_o,
        ps_gpio0_t                 => ps_gpio0_t,
        ps_gpio1_o                 => ps_gpio1_o,
        ps_gpio1_t                 => ps_gpio1_t,
        t12_aux_gpio_i             => t12_aux_gpio_i,
        t12_aux_gpio_o             => t12_aux_gpio_o,
        t12_aux_gpio_t             => t12_aux_gpio_t,
        ref_clk                    => ref_clk,
        rx1_dclk_in_n              => rx1_dclk_in_n,
        rx1_dclk_in_p              => rx1_dclk_in_p,
        rx1_enable                 => rx1_enable,
        rx1_idata_in_n             => rx1_idata_in_n,
        rx1_idata_in_p             => rx1_idata_in_p,
        rx1_qdata_in_n             => rx1_qdata_in_n,
        rx1_qdata_in_p             => rx1_qdata_in_p,
        rx1_strobe_in_n            => rx1_strobe_in_n,
        rx1_strobe_in_p            => rx1_strobe_in_p,
        rx2_dclk_in_n              => rx2_dclk_in_n,
        rx2_dclk_in_p              => rx2_dclk_in_p,
        rx2_enable                 => rx2_enable,
        rx2_idata_in_n             => rx2_idata_in_n,
        rx2_idata_in_p             => rx2_idata_in_p,
        rx2_qdata_in_n             => rx2_qdata_in_n,
        rx2_qdata_in_p             => rx2_qdata_in_p,
        rx2_strobe_in_n            => rx2_strobe_in_n,
        rx2_strobe_in_p            => rx2_strobe_in_p,
        spi0_csn                   => spi0_csn,
        spi0_miso                  => spi0_miso,
        spi0_mosi                  => spi0_mosi,
        spi0_sclk                  => spi0_sclk,
        spi1_csn                   => spi1_csn,
        spi1_miso                  => spi1_miso,
        spi1_mosi                  => spi1_mosi,
        spi1_sclk                  => spi1_sclk,
        lb_tft_sclk                => lb_tft_sclk,
        lb_tft_sdi                 => lb_tft_sdi,
        lb_tft_sdo                 => lb_tft_sdo,
        lb_tft_csn                 => lb_tft_csn,
        hb_tft_sclk                => hb_tft_sclk,
        hb_tft_sdi                 => hb_tft_sdi,
        hb_tft_sdo                 => hb_tft_sdo,
        hb_tft_csn                 => hb_tft_csn,
        t12_gpio0_i                => t12_gpio0_i,
        t12_gpio1_i                => t12_gpio1_i,
        tdd_sync                   => tdd_sync,
        tdd_sync_cntr              => open,
        tx1_dclk_in_n              => tx1_dclk_in_n,
        tx1_dclk_in_p              => tx1_dclk_in_p,
        tx1_dclk_out_n             => tx1_dclk_out_n,
        tx1_dclk_out_p             => tx1_dclk_out_p,
        tx1_enable                 => tx1_enable,
        tx1_idata_out_n            => tx1_idata_out_n,
        tx1_idata_out_p            => tx1_idata_out_p,
        tx1_qdata_out_n            => tx1_qdata_out_n,
        tx1_qdata_out_p            => tx1_qdata_out_p,
        tx1_strobe_out_n           => tx1_strobe_out_n,
        tx1_strobe_out_p           => tx1_strobe_out_p,
        tx2_dclk_in_n              => tx2_dclk_in_n,
        tx2_dclk_in_p              => tx2_dclk_in_p,
        tx2_dclk_out_n             => tx2_dclk_out_n,
        tx2_dclk_out_p             => tx2_dclk_out_p,
        tx2_enable                 => tx2_enable,
        tx2_idata_out_n            => tx2_idata_out_n,
        tx2_idata_out_p            => tx2_idata_out_p,
        tx2_qdata_out_n            => tx2_qdata_out_n,
        tx2_qdata_out_p            => tx2_qdata_out_p,
        tx2_strobe_out_n           => tx2_strobe_out_n,
        tx2_strobe_out_p           => tx2_strobe_out_p,
        tx_output_enable           => tx_output_enable
      );
    initclk_rstn_s    <= initclk_rstn_v(0);
    sample_clk_s      <= adc_1_clk;
    clk_375M          <= adc_1_clk;
    init_clk_s        <= init_clk;
    system_clk_s      <= init_clk;

    -- Kenh ban tin GFP: tvsdr noi thang len MicroBlaze (GFP_UB_IN/OUT),
    -- MSDR dua len PS qua axi_fifo_mm_s_0 nam ben system.bd.
    GFPin_data        <= GFP_UB_IN_tdata;
    GFPin_valid       <= GFP_UB_IN_tvalid;
    GFPin_last        <= GFP_UB_IN_tlast;
    GFP_UB_IN_tready  <= GFPin_ready;
    GFP_UB_OUT_tdata  <= GFPout_data;
    GFP_UB_OUT_tvalid <= GFPout_valid;
    GFP_UB_OUT_tlast  <= GFPout_last;
    GFPout_ready      <= GFP_UB_OUT_tready;
    
    
    
    spi_tx_csn_0        <= spi_tx_csn_s(0);--- ac61416 thresholds 
    spi_tx_csn_1        <= spi_tx_csn_s(1);---dac61416 gates bias
    spi_tx_csn_2        <= spi_tx_csn_s(2);----CPLD on TX card
    spi_tx_csn_3        <= spi_tx_csn_s(3);--DAC SMPS
    spi_tx_csn_4        <= spi_tx_csn_s(4);--BITE Rx
    spi_tx_csn_5        <= spi_tx_csn_s(5);-- FLASH
    adc_afe_csan_1v8    <= spi_tx_csn_s(6); --ADL5205 CSa
    adc_afe_csbn_1v8    <= spi_tx_csn_s(7);--ADL5205 CSb
    pll_adc_917_le      <= spi_tx_csn_s(8);-- ADF4355 --U25
    pll_adc_504_le      <= spi_tx_csn_s(9);-- ADF4355 --U29
    
    
    sys_infor_ins: entity work.system_info_wrapper
    port map(
        --// User Ports
        cfg_reload_out => cfg_reload,
        gpio_test_out => gpio_test_ub,
        aurora_rst_out     => aurora_rst_out,
        gpio_mask1_ub_out     => gpio_mask1_ub,
        gpio_mask2_ub_out     => gpio_mask2_ub,
        gpio_mask3_ub_out     => gpio_mask3_ub,
        
        command1_out          => command1_ub,
        command2_out          => command2_ub,
        command3_out          => command3_ub,
        command4_out          => command4_ub,
        command5_out          => command5_ub,
        
        tx_command_out        => tx_command,
        tx_card_status_in     => tx_card_status,
        aurora_status_in      => aurora_status,

        S_AXI_ACLK             => init_clk_s,
        S_AXI_ARESETN          => initclk_rstn_s,

        S_AXI_ARADDR           => SYS_INTERFACE_araddr(7 downto 0),
        S_AXI_ARPROT           => SYS_INTERFACE_arprot,
        S_AXI_ARREADY          => SYS_INTERFACE_arready,
        S_AXI_ARVALID          => SYS_INTERFACE_arvalid,
        S_AXI_AWADDR           => SYS_INTERFACE_awaddr(7 downto 0),
        S_AXI_AWPROT           => SYS_INTERFACE_awprot,
        S_AXI_AWREADY          => SYS_INTERFACE_awready,
        S_AXI_AWVALID          => SYS_INTERFACE_awvalid,
        S_AXI_BREADY           => SYS_INTERFACE_bready,
        S_AXI_BRESP            => SYS_INTERFACE_bresp,
        S_AXI_BVALID           => SYS_INTERFACE_bvalid,
        S_AXI_RDATA            => SYS_INTERFACE_rdata,
        S_AXI_RREADY           => SYS_INTERFACE_rready,
        S_AXI_RRESP            => SYS_INTERFACE_rresp,
        S_AXI_RVALID           => SYS_INTERFACE_rvalid ,
        S_AXI_WDATA            => SYS_INTERFACE_wdata,
        S_AXI_WREADY           => SYS_INTERFACE_wready,
        S_AXI_WSTRB            => SYS_INTERFACE_wstrb,
        S_AXI_WVALID           => SYS_INTERFACE_wvalid);
												   

    delay_clk    <= clk_200m;

	ADC_PDWN 		<= gpio_1_tri_o(0);
    DDS_PWR_DWN 	<= gpio_1_tri_o(1);
    
    EN_RX 			<= gpio_1_tri_o(2);
    PLL_ADC_CE		<= gpio_1_tri_o(2);
    
    EN_TX 			<= gpio_1_tri_o(3);
    EN_LO 			<= gpio_1_tri_o(4);
    EN_RTX 			<= gpio_1_tri_o(5);
    ADC_AFE_PM 		<= gpio_1_tri_o(6);
	ADC_AFE_PWUP 	<= gpio_1_tri_o(7);
	
	--tx_IQ_source	<= 	conv_integer(gpio_out(0) & gpio_out(1) & gpio_out(2) & gpio_out(3));------------------------------------conv_integer(gpio_1_tri_o(29 downto 26));
	conf_NB6L295 	<= gpio_1_tri_o(30);
	enable_fsm(0) 	<= gpio_1_tri_o(31);
    xpm_cdc_array_single_inst : xpm_cdc_array_single
       generic map (
          DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
          INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
          SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
          SRC_INPUT_REG => 1,  -- DECIMAL; 0=do not register input, 1=register input
          WIDTH =>  3          -- DECIMAL; range: 1-1024
       )
       port map (
          dest_out => tx_IQ_source_sync, -- WIDTH-bit output: src_in synchronized to the destination clock domain. This
                                         -- output is registered.
          dest_clk => clk_250m_aurora_s, -- 1-bit input: Clock signal for the destination clock domain.
          src_clk => init_clk_s,         -- 1-bit input: optional; required when SRC_INPUT_REG = 1
          src_in => tx_IQ_source         -- WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                                         -- domain. It is assumed that each bit of the array is unrelated to the others.
                                         -- This is reflected in the constraints applied to this macro. To transfer a binary
                                         -- value losslessly across the two clock domains, use the XPM_CDC_GRAY macro
                                         -- instead.
    
       );

    tx_iq_source_dac_cdc : xpm_cdc_array_single
      generic map (
        DEST_SYNC_FF   => 4,
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_INPUT_REG  => 1,
        WIDTH          => 3
      )
      port map (
        dest_out => tx_iq_source_dac_s,
        dest_clk => dac_1_clk,
        src_clk  => init_clk_s,
        src_in   => tx_IQ_source
      );
	
	vio_0_inst : vio_0
		port map (  clk 		=> init_clk_s,
					probe_out0 	=> VCSO_ctrl_mode,
					probe_out1 	=> tx_IQ_source,
					probe_out2 	=> open,
					probe_out3 	=> open);

    -- [MSDR] bo khoi: IBUFDS_inst : IBUFDS tren INIT_CLK_P/N.
    -- T12 khong co cap xung nhip dieu khien rieng; system_clk_s lay tu
    -- pl_clk0 cua PS (xem phan thay mb_bd_wrapper o tren).

    initclk_rst_cdc_ins : xpm_cdc_async_rst
		generic map (
			DEST_SYNC_FF => 10,    -- DECIMAL; range: 2-10
			INIT_SYNC_FF => 1,    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
			RST_ACTIVE_HIGH => 0  -- DECIMAL; 0=active low reset, 1=active high reset
		)
		port map (
			dest_arst => initclk_rstfromaurora_s,
			dest_clk => init_clk_s,   -- 1-bit input: Destination clock.
			src_arst => not aurora_rst_s    -- 1-bit input: Source asynchronous reset signal.
		);

    sampleclk_rst_cdc_ins : xpm_cdc_single
		generic map (
			DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
			INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
			SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
			SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
		)
		port map (
			dest_out => Sample_rst_s,
			dest_clk => sample_clk_s, -- 1-bit input: Clock signal for the destination clock domain.
			src_clk => aurora_clk_s,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
			src_in => aurora_rst_s      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
		);

    adc_rst_cdc_ins : xpm_cdc_single
		generic map (
			DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
			INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
			SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
			SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
		)
		port map (
			dest_out => adc_rst_s,
			dest_clk => clk_375M, -- 1-bit input: Clock signal for the destination clock domain.
			src_clk => aurora_clk_s,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
			src_in => aurora_rst_s);      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
			
    xpm_cdc_pulse_inst : xpm_cdc_pulse
		generic map (
			DEST_SYNC_FF => 2,   -- DECIMAL; range: 2-10
			INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
			REG_OUTPUT => 0,     -- DECIMAL; 0=disable registered output, 1=enable registered output
			RST_USED => 0,       -- DECIMAL; 0=no reset, 1=implement reset
			SIM_ASSERT_CHK => 0  -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		)
		port map (
			dest_pulse => timestamp_valid_out_sync, -- 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
									-- transfer is correctly initiated on src_pulse input. This output is
									-- combinatorial unless REG_OUTPUT is set to 1.

			dest_clk => init_clk_s,     -- 1-bit input: Destination clock.
			dest_rst => '0',     -- 1-bit input: optional; required when RST_USED = 1
			src_clk => aurora_clk_s,       -- 1-bit input: Source clock.
			src_pulse => timestamp_valid_out,   -- 1-bit input: Rising edge of this signal initiates a pulse transfer
			src_rst => '0'        -- 1-bit input: optional; required when RST_USED = 1
		);

    Frame_Length_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 48
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Frame_Length_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Frame_Length_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Tx_freq_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 48
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Tx_freq_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Tx_freq_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0');             -- Input ignored, tie to 0
			
    Rx_freq_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 48
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Rx_freq_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Rx_freq_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Next_Frame_Transmit_Time_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 27
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Next_Frame_Transmit_Time_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Next_Frame_Transmit_Time_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Power_Tx_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 8
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Power_Tx_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Power_Tx_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Rx_bw_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 8
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Rx_bw_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Rx_bw_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Tx_bw_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 8
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Tx_bw_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Tx_bw_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);

    Next_Frame_Receive_Time_out_sync_cdc : xpm_cdc_handshake
		generic map (
			DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
			DEST_SYNC_FF   => 2,        -- standard safety
			INIT_SYNC_FF   => 0,
			SIM_ASSERT_CHK => 0,
			SRC_SYNC_FF  => 2,
			WIDTH          => 27
		)
		port map (
			-- Source Clock Domain
			src_clk  => aurora_clk_s,
			src_in   => Next_Frame_Receive_Time_out,
			src_send => timestamp_valid_out,
			src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

			-- Destination Clock Domain
			dest_clk => init_clk_s,
			dest_out => Next_Frame_Receive_Time_out_sync,
			dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
			dest_ack => '0'             -- Input ignored, tie to 0
		);										  
Second_from_2000_out_sync_cdc : xpm_cdc_handshake
    generic map (
        DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
        DEST_SYNC_FF   => 2,        -- standard safety
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_SYNC_FF  => 2,
        WIDTH          => 40
    )
    port map (
        -- Source Clock Domain
        src_clk  => aurora_clk_s,
        src_in   => Second_from_2000_out,
        src_send => timestamp_valid_out,
        src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

        -- Destination Clock Domain
        dest_clk => init_clk_s,
        dest_out => Second_from_2000_out_sync,
        dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
        dest_ack => '0'             -- Input ignored, tie to 0
    );

    Subsecond_out_sync_cdc : xpm_cdc_handshake
    generic map (
        DEST_EXT_HSK   => 0,        -- 0 = Internal/Auto acknowledge (No backpressure)
        DEST_SYNC_FF   => 2,        -- standard safety
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_SYNC_FF  => 2,
        WIDTH          => 27
    )
    port map (
        -- Source Clock Domain
        src_clk  => aurora_clk_s,
        src_in   => Subsecond_out,
        src_send => timestamp_valid_out,
        src_rcv  => open,       -- Still needed! Source must wait for this before sending next.

        -- Destination Clock Domain
        dest_clk => init_clk_s,
        dest_out => Subsecond_out_sync,
        dest_req => open,     -- Use this as a "Write Enable" or "Valid" strobe
        dest_ack => '0'             -- Input ignored, tie to 0
    );

    ---------------------------------------------------------------------------
    -- Coherent RX timestamp -> sample_clk (time-sync servo) atomic CDC.
    --
    -- The servo (vcsco_wrapper / time_sync_top) runs on sample_clk_s (250 MHz),
    -- NOT init_clk. The timestamp is produced by aurora_protocol in aurora_clk_s.
    -- We cross aurora_clk_s -> sample_clk_s directly in ONE hop (no init_clk detour)
    -- using a single 67-bit handshake carrying {Second_from_2000, Subsecond} as one
    -- atomic word, so sec/usec land coherently with zero inter-bus skew. The handshake
    -- dest_req is used as rx_ts_valid -- it is asserted in sample_clk exactly when the
    -- synchronized data is valid, so ts_offset_calc samples a consistent timestamp.
    --
    -- src_in is the HELD snapshot from aurora_protocol (stable until the next
    -- timestamp_valid_out pulse, i.e. one full metadata rotation), which far exceeds
    -- the handshake transfer time -> the source never changes mid-transfer.
    ---------------------------------------------------------------------------
    rx_ts_concat_src_s <= Second_from_2000_out & Subsecond_out;

    rx_ts_servo_cdc : xpm_cdc_handshake
    generic map (
        DEST_EXT_HSK   => 0,        -- internal auto-ack (no backpressure)
        DEST_SYNC_FF   => 2,
        INIT_SYNC_FF   => 0,
        SIM_ASSERT_CHK => 0,
        SRC_SYNC_FF    => 2,
        WIDTH          => 67
    )
    port map (
        -- Source: aurora_clk domain
        src_clk  => aurora_clk_s,
        src_in   => rx_ts_concat_src_s,
        src_send => timestamp_valid_out,    -- one well-spaced pulse per metadata rotation
        src_rcv  => open,

        -- Destination: sample_clk domain (servo)
        dest_clk => sample_clk_s,
        dest_out => rx_ts_concat_smp_s,
        dest_req => rx_ts_valid_smp_s,      -- aligned valid in sample_clk domain
        dest_ack => '0'
    );
    rx_ts_sec_smp_s  <= unsigned(rx_ts_concat_smp_s(66 downto 27));
    rx_ts_usec_smp_s <= unsigned(rx_ts_concat_smp_s(26 downto 0));

    -- Hold the complete local time until the FSM-domain transfer is acknowledged.
    local_time_capture : process(sample_clk_s)
    begin
      if rising_edge(sample_clk_s) then
        if sample_rst_s = '1' then
          local_time_send_s <= '0';
          local_time_snapshot_s <= (others => '0');
        elsif local_time_send_s = '0' then
          if local_time_rcv_s = '0' then
            local_time_snapshot_s <= std_logic_vector(sec_loc_s) & std_logic_vector(usec_loc_s);
            local_time_send_s <= '1';
          end if;
        elsif local_time_rcv_s = '1' then
          local_time_send_s <= '0';
        end if;
      end if;
    end process;

    local_time_fsm_cdc : xpm_cdc_handshake
      generic map (
        DEST_EXT_HSK => 0, DEST_SYNC_FF => 2, INIT_SYNC_FF => 1,
        SIM_ASSERT_CHK => 1, SRC_SYNC_FF => 2, WIDTH => 67
      )
      port map (
        src_clk => sample_clk_s, src_in => local_time_snapshot_s,
        src_send => local_time_send_s, src_rcv => local_time_rcv_s,
        dest_clk => init_clk_s, dest_out => local_time_cdc_s,
        dest_req => local_time_valid_s, dest_ack => '0'
      );

    local_time_commit : process(init_clk_s)
    begin
      if rising_edge(init_clk_s) then
        if initclk_rstn_s = '0' then
          local_time_init_s <= (others => '0');
        elsif local_time_valid_s = '1' then
          local_time_init_s <= local_time_cdc_s;
        end if;
      end if;
    end process;

    i_aurora_protocol : entity work.aurora_protocol
    generic map(
        RFU_MODE => "YES"
    )
    port map(
        aurora_clk_in                => aurora_clk_s,
        aurora_rst_in                => aurora_rst_s,

        Aurora_IQin_tdata            => Aurora_IQout_tdata_s,
        Aurora_IQin_tkeep            => Aurora_IQout_tkeep_s,
        Aurora_IQin_tvalid           => Aurora_IQout_tvalid_s,
        Aurora_IQin_tlast            => Aurora_IQout_tlast_s,
        Aurora_IQin_tready           => open,

        Aurora_IQout_tlast           => Aurora_IQin_tlast_s,
        Aurora_IQout_tdata           => Aurora_IQin_tdata_s,
        Aurora_IQout_tkeep           => Aurora_IQin_tkeep_s,
        Aurora_IQout_tvalid          => Aurora_IQin_tvalid_s,
        Aurora_IQout_tready          => Aurora_IQin_tready_s,

        sample_IQin_data             => Sample_IQin_data,
        Sample_IQin_valid            => Sample_IQin_valid,
        Sample_IQin_ready            => Sample_IQin_ready,
        Sample_IQin_clk_375M		 => clk_375M,
        
        sample_IQout_data            => aurora_data_out,
        Sample_IQout_valid           => aurora_data_valid_out,
    --    sample_IQout_data            => open,
    --    Sample_IQout_valid           => open,
		
        sample_clk_in                => sample_clk_s,
		Sample_clk_deframer_in       => clk_250m_aurora_s,
        Sample_rst_in                => Sample_rst_s,

        GFPin_data                   => GFPin_data,
        GFPin_valid                  => GFPin_valid,
        GFPin_ready                  => GFPin_ready,
        GFPin_last                   => GFPin_last,

        GFPout_data                  => GFPout_data,
        GFPout_valid                 => GFPout_valid,
        GFPout_ready                 => GFPout_ready,
        GFPout_last                  => GFPout_last,

        GFP_clk_in                   => init_clk_s,
        GFP_rstn_in                  => initclk_rstfromaurora_s,

        Frame_Length_in              => Frame_Length_in,
        Tx_freq_in                   => Tx_freq_in,
        Rx_freq_in                   => Rx_freq_in,
        Next_Frame_Transmit_Time_in  => Next_Frame_Transmit_Time_in,
        Power_Tx_in                  => Power_Tx_in,
        Rx_bw_in                     => Rx_bw_in,
        Tx_bw_in                     => Tx_bw_in,
        Next_Frame_Receive_Time_in   => Next_Frame_Receive_Time_in,
        Second_from_2000_in          => Second_from_2000_in,
        Subsecond_in                 => Subsecond_in,

        Frame_Length_out             => Frame_Length_out,
        Tx_freq_out                  => Tx_freq_out,
        Rx_freq_out                  => Rx_freq_out,
        Next_Frame_Transmit_Time_out => Next_Frame_Transmit_Time_out,
        Power_Tx_out                 => Power_Tx_out,
        Rx_bw_out                    => Rx_bw_out,
        Tx_bw_out                    => Tx_bw_out,
        Next_Frame_Receive_Time_out  => Next_Frame_Receive_Time_out,
        Second_from_2000_out         => Second_from_2000_out,
        Subsecond_out                => Subsecond_out,
        timestamp_valid_out          => timestamp_valid_out,   
        -- SAin_data                    => SAin_data,
        -- SAin_valid                   => SAin_valid,
        -- SAin_ready                   => SAin_ready,
        -- SAin_last                    => SAin_last,

        -- SAout_data                   => SAout_data,
        -- SAout_valid                  => SAout_valid,
        -- SAout_ready                  => SAout_ready,

        SA_clk_in                    => init_clk_s,
        SA_rstn_in                   => initclk_rstn_s,
                
       -- metadata_valid: 1-cycle pulse (aurora_clk domain), once per frame at the first
        -- Subsecond = a complete RX timestamp/metadata set is valid. Available to the system.
        metadata_valid_out           => metadata_valid_aclk_s

        --almost_empty                => IQ_fifo_empty,
        --almost_full                 => IQ_fifo_almost_full
    );

    trx_config_sync <= '1' when Tx_freq_out_sync /=x"000000000000"  else '0';

---------------------------------------------------------------------------
    -- new-config event for fsm_main (separate from the servo timestamp strobe).
    -- The Aurora timestamp pulse now fires once per metadata rotation (good for the
    -- time-sync servo), which is far too fast to retrigger fsm_main's RF reconfiguration.
    -- Here we sample the synced config key at each synced timestamp pulse and emit a
    -- single running_config_valid pulse ONLY when it changes. The metadata fields are
    -- static between Aurora (re)syncs, so this fires once per genuine new config /
    -- frequency hop. A settling double-pulse is harmless: fsm_main consumes
    -- running_config_valid only while in IDLE.
    ---------------------------------------------------------------------------
    cfg_key_s <= Tx_freq_out_sync & Rx_freq_out_sync &
                 Next_Frame_Transmit_Time_out_sync & Next_Frame_Receive_Time_out_sync &
                 Tx_bw_out_sync & Rx_bw_out_sync;

    new_config_detect : process(init_clk_s)
    begin
      if rising_edge(init_clk_s) then
        if (initclk_rstn_s = '0') then
          cfg_key_committed_s    <= (others => '0');
          running_config_valid_s <= '0';
        else
          running_config_valid_s <= '0';          -- 1-cycle strobe; default low
          if (timestamp_valid_out_sync = '1') then
            if (cfg_key_s /= cfg_key_committed_s) then
              running_config_valid_s <= '1';
              cfg_key_committed_s    <= cfg_key_s;
            end if;
          end if;
        end if;
      end if;
    end process;
	
    i_fsm_main : entity work.fsm_main
    generic map(
        N_GPIO => 65
    )
    port map(
        fsm_clk_in                  => init_clk_s,
        adc_clk_in					=> adc_clk_out,
        fsm_rstn_in                 => initclk_rstn_s,
		enable_fsm					=> enable_fsm(0),
        
        gpio_outs					=> gpio_out,	 
        CFG_LUT_addr                => CFG_LUT_addr,
        CFG_LUT_clk                 => CFG_LUT_clk,
        CFG_LUT_din                 => CFG_LUT_dout,
        CFG_LUT_en                  => CFG_LUT_en,
        CFG_LUT_rst                 => CFG_LUT_rst,
        CFG_LUT_we                  => CFG_LUT_we,

        command1_in                 => command1_ub,
        command2_in                 => command2_ub,
        command3_in                 => command3_ub,
        command4_in                 => command4_ub,
        command5_in                 => command5_ub,
        
         -- ADDED: tx_ctrl command/status interface
        tx_command_in               => tx_command,
        tx_card_status_out          => tx_card_status,
        SPI_CPLD_MISO_in            => spi_tx_cpld_miso,
        SPI_CPLD_MOSI_out           => spi_tx_cpld_mosi,
        SPI_CPLD_SCLK_out           => spi_tx_cpld_clk,
        SPI_CPLD_CSN_out            => spi_tx_cpld_csn,
        

        cfg_reload_in               => cfg_reload,
        gpio_test_in                => gpio_test_ub,
        gpio_mask_ub_in             => gpio_mask1_ub& gpio_mask2_ub & gpio_mask3_ub(31),
        Frame_Length_in             => Frame_Length_out_sync,
        Tx_freq_in                  => Tx_freq_out_sync,
        Rx_freq_in                  => Rx_freq_out_sync,
        Next_Frame_Transmit_Time_in => Next_Frame_Transmit_Time_out_sync,
        Power_Tx_in                 => Power_Tx_out_sync,
        Rx_bw_in                    => Rx_bw_out_sync,
        Tx_bw_in                    => Tx_bw_out_sync,
        Next_Frame_Receive_Time_in  => Next_Frame_Receive_Time_out_sync,
        Second_from_2000_in         => Second_from_2000_out_sync,
        Subsecond_in                => Subsecond_out_sync,
        trx_config_in               => trx_config_sync,
        Current_second_from_2000_in => local_time_init_s(66 downto 27),
        Current_Subsecond_in        => local_time_init_s(26 downto 0),
        running_config_valid_in     => running_config_valid_s,
        ad9164_csn                  => ad9164_csn(0),
        ad9164_sclk                 => ad9164_sclk(0),
        ad9164_mosi                 => ad9164_mosi(0),
--        pll_a_ad9914_clk            => pll_a_ad9914_clk,
--        pll_a_ad9914_data           => pll_a_ad9914_data,
--        pll_a_ad9914_le             => pll_a_ad9914_le,
        pll_a_adf41510_clk          => pll_a_adf41510_clk,
        pll_a_adf41510_mosi         => pll_a_adf41510_mosi,
        pll_a_adf41510_csn          => pll_a_adf41510_csn,
--        pll_b_ad9914_clk            => pll_b_ad9914_clk,
--        pll_b_ad9914_data           => pll_b_ad9914_data,
--        pll_b_ad9914_le             => pll_b_ad9914_le,
        pll_b_adf41510_clk          => pll_b_adf41510_clk,
        pll_b_adf41510_mosi         => pll_b_adf41510_mosi,
        pll_b_adf41510_csn          => pll_b_adf41510_csn,
        if_fb_le          			=> if_fb_le,
    	if_fb_clk           		=> if_fb_clk,
    	if_fb_si          			=> if_fb_si,
    	rtx_att_sin           		=> rtx_att_sin,
    	rtx_att_clk           		=> rtx_att_clk,
    	rtx_att_le           		=> rtx_att_le,
        if_fb_sw_1                  => if_fb_sw_1,
        if_fb_sw_0                  => if_fb_sw_0,
        hb_tpfb_sw_2                => hb_tpfb_sw_2,
        hb_tpfb_sw_1                => hb_tpfb_sw_1,
        hb_tpfb_sw_0                => hb_tpfb_sw_0,
        hb_tpfb_sw_0n               => hb_tpfb_sw_0n,
        lb_rx_tbpf_sw_1             => lb_rx_tbpf_sw_1,
        lb_rx_tbpf_sw_2             => lb_rx_tbpf_sw_2,
        lb_sw_1                     => lb_sw_1,
        lb_sw_2                     => lb_sw_2,
        lb_tx_tbpf_sw_1             => lb_tx_tbpf_sw_1,
        lb_tx_tbpf_sw_2             => lb_tx_tbpf_sw_2,
        hb_fb_sw_1                  => hb_fb_sw_1,
        hb_fb_sw_0                  => hb_fb_sw_0,
        dac_txenable                => dac_txenable,
        PG_ADC_PLL                  => PG_ADC_PLL,
        PG_VCVCSO                   => PG_VCVCSO,
        hb_fb_tx                    => hb_fb_tx,
        lo_ps                       => lo_ps,
        hb_fb_sw_2n                 => hb_fb_sw_2n,
        hb_fb_sw_2                  => hb_fb_sw_2,
        lb_tx_tbpf_1_tune_rdy       => lb_tx_tbpf_1_tune_rdy,
        lb_tx_tbpf_2_tune_rdy       => lb_tx_tbpf_2_tune_rdy,
        lb_rx_tbpf_1_tune_rdy_a     => lb_rx_tbpf_1_tune_rdy_a,
        lb_rx_tbpf_1_tune_rdy_b     => lb_rx_tbpf_1_tune_rdy_b,
        lb_rx_tbpf_2_tune_rdy_a     => lb_rx_tbpf_2_tune_rdy_a,
        lb_rx_tbpf_2_tune_rdy_b     => lb_rx_tbpf_2_tune_rdy_b,
        
		lb_rx_tbpf_mosi             => lb_rx_tbpf_mosi,
		lb_rx_tbpf_sclk             => lb_rx_tbpf_sclk,
		lb_rx_tbpf2_csn             => lb_rx_tbpf2_csn,
		lb_rx_tbpf1_csn             => lb_rx_tbpf1_csn,
		
		lb_tx_tbpf_mosi             => lb_tx_tbpf_mosi,
		lb_tx_tbpf_sclk             => lb_tx_tbpf_sclk,
		lb_tx_tbpf2_csn             => lb_tx_tbpf2_csn,
		lb_tx_tbpf1_csn             => lb_tx_tbpf1_csn,
    
        hb_tbpf_sdi     			=> hb_tbpf_sdi,
		hb_tbpf_sdo     			=> hb_tbpf_sdo,
		hb_tbpf_sclk     			=> hb_tbpf_sclk,
		hb_1_tbpf_csn     			=> hb_1_tbpf_csn,
		hb_2_tbpf_csn     			=> hb_2_tbpf_csn,
		hb_3_tbpf_csn     			=> hb_3_tbpf_csn,
		hb_4_tbpf_csn     			=> hb_4_tbpf_csn,								  
        pll_504_locked              => pll_504_locked,
        pll_917_locked              => pll_917_locked,
        --gpio_mux                    => gpio_mux,
        pingpong_An_b               => pingpong_An_b,
        TX_RF_OFF_1V8               => TX_RF_OFF_1V8,
        vcxo_cp                     => open,--vcxo_cp,
        lo_div2_en_b                => lo_div2_en_b,
        lo_div2_en_a                => lo_div2_en_a,
        hb_sw                       => hb_sw,
        RTX_PUSH_GATE               => RTX_PUSH_GATE,
        GPIO_MUXED                  => gpio_mux,
        GPIO_MUX_LE_0               => GPIO_MUX_LE_0,
        GPIO_MUX_LE_1               => GPIO_MUX_LE_1,
        GPIO_MUX_LE_2               => GPIO_MUX_LE_2,
        GPIO_MUX_LE_3               => GPIO_MUX_LE_3,
        dds_a_sync_clk              => dds_a_sync_clk,
		dds_b_sync_clk              => dds_b_sync_clk,
		--fsm_clk           					: in  STD_LOGIC;
		dds_data               		=> dds_data,
		dds_a_syncio               	=> dds_a_syncio,
		dds_b_syncio               	=> dds_b_syncio,
		dds_sdo               		=> dds_sdo,
		dds_sdio               		=> dds_sdio,
		dds_scl               		=> dds_scl,
		dds_a_0_csn               	=> dds_a_0_csn,
		dds_b_0_csn               	=> dds_b_0_csn,
		tx_att_sin               	=> tx_att_sin,
    	tx_att_clk               	=> tx_att_clk,
    	tx_att_le               	=> tx_att_le,
		--dds_a_in          					: in  STD_LOGIC_VECTOR(31 downto 0);
		--dds_b_in          					: in  STD_LOGIC_VECTOR(31 downto 0);
		--reset             					: in  STD_LOGIC;
		dds_a_ioupdate            	=> dds_a_ioupdate,
		dds_b_ioupdate            	=> dds_b_ioupdate,
		ADC_PDWN             		=> ADC_PDWN,
		DDS_PWR_DWN            		=> DDS_PWR_DWN,
		EN_RX             			=> EN_RX,
		EN_TX             			=> EN_TX,
		EN_LO             			=> EN_LO,
		EN_RTX             			=> EN_RTX,
		ADC_AFE_PM             		=> ADC_AFE_PM,
		ADC_AFE_PWUP             	=> ADC_AFE_PWUP,
		
		rx_dds_config_tvalid		=> rx_dds_config_tvalid,
		rx_dds_config_tdata			=> rx_dds_config_tdata);
		
--          if_fb_sw_1  		<= '1';--, claudio  
          
--        hb_fb_sw_1 		<= '1';--, claudio bypass
--        hb_fb_sw_0 		<= '1';
--        hb_fb_tx 		<= '0';
--        hb_fb_sw_2n 	<= '0';
--        hb_fb_sw_2 		<= '1';
        
--        hb_fb_sw_1 		<= '0';--, claudio f261 1960-2620
--        hb_fb_sw_0 		<= '0';
--        hb_fb_tx 		<= '0';
--        hb_fb_sw_2n 	<= '0';
--        hb_fb_sw_2 		<= '1';


--    sample_ila: ila_0  -- claudio
--    port map(
--        clk => sample_clk_s,

--        probe0(0) => aurora_data_valid_out,
--        probe1 => aurora_data_out,
--        probe2(0) => Sample_IQin_ready,
--        probe3 (0) => FSM_locked,
--        probe4 => sample_IQout_data,
--        probe5(0) => aurora_status(4), --Sample_rst_s,
--        probe6(0) => IQ_fifo_empty,
--        probe7(0) => aurora_status(5) --IQ_fifo_almost_full
--    );    
    
    
    
    
--   ILA_TX_SPI: entity work.ila_5
--    PORT MAP (
--        clk => init_clk_s,
--        probe0(0) => spi_tx_csn_0,
--        probe1(0) => spi_tx_csn_1,
--        probe2(0) => spi_tx_csn_2,
--        probe3(0) => spi_tx_csn_3,
--        probe4(0) => spi_tx_csn_4,
--        probe5(0) => spi_tx_csn_5,
--        probe6(0) => spi_tx_sclk,
--        probe7(0) => spi_tx_mosi,
--        probe8(0) => spi_tx_miso_s
        
--    );

--    sample125_ila: entity work.ila_1
--    port map(
--        clk => tx_core_clk,

--        probe0(0) => dac_data_valid,
--        probe1 => dac_data_data
--    );  


    Aurora_ins : entity work.aurora_wrapper
    Port map ( 
        rstn_i  => initclk_rstn_s,
        
        -- System Interface
        init_clk_i => init_clk_s,
        -- GTX Reference Clock Interface
    --        gthq0_p => Aurora_refclk_p,
    --        gthq0_n => Aurora_refclk_n,
        gt_refclk1 => tx_ref_clk,
        -- GTX Serial I/O
        rxp => Aurora_Rxp(0),
        rxn => Aurora_Rxn(0),
        txp => Aurora_Txp(0),
        txn => Aurora_Txn(0),
        -----  control outports----------------
        aurora_clk_o => aurora_clk_s,
        aurora_rst_o => aurora_rst_s,
        --gt_refclk_o  => tx_ref_clk,
        aurora_status_o => aurora_status_core_s,
        gt_rxusrclk_o => gt_rxusrclk_s,
        -- AXI-STREAM interface-------
        s_IQ_tdata_i => Aurora_IQin_tdata_s,
        s_IQ_tvalid_i => Aurora_IQin_tvalid_s,
        s_IQ_tready_o => Aurora_IQin_tready_s,
        s_IQ_tlast_i => Aurora_IQin_tlast_s,
        s_IQ_tkeep_i => Aurora_IQin_tkeep_s,
        
        m_IQ_tdata_o => Aurora_IQout_tdata_s,
        m_IQ_tvalid_o => Aurora_IQout_tvalid_s,
        m_IQ_tlast_o => Aurora_IQout_tlast_s,
        m_IQ_tkeep_o => Aurora_IQout_tkeep_s);

    ---------------------------------------------------------------------------
    -- Core time_sync_top
    ---------------------------------------------------------------------------

--    u_time_sync_top : entity work.time_sync_top
--    port map (
--        clk              => init_clk_s,
--        rst              => not initclk_rstn_s,
--        pps_in           => onepps_in,
--        cfg_mode         => "000",
--        rx_ts_valid      => timestamp_valid_out_sync,
--        rx_sec           => unsigned(Second_from_2000_out_sync),
--        rx_usec          => unsigned(Subsecond_out_sync),
--        inc_nominal      => INC_NOMINAL_CONST,
--        sec_loc          => sec_loc_s,
--        usec_loc         => usec_loc_s,
--        offset_us_out    => offset_us_s,
--        pps_error_us_out => pps_error_us_s,
--        error_us_out     => error_us_s,
--        inc_out          => inc_out_s,
--        tick_us          => tick_us_s
--    );


    -- Timestamp + 1PPS VCSO disciplining: time_sync_top (AUTO/FULL_SYNC, VCXO mode) + AD5680 SPI
    u_vcsco_wrapper : entity work.vcsco_wrapper
    generic map (
        CLK_HZ             => 250_000_000,
        -- PROTOCOL UNIT 2026-07-30: the Aurora Subsecond field is 10 ns per LSB
        -- (MBU side: aurora_mbu.vhd -> pps_generator SUBSEC_TICK_HZ => 100_000_000).
        -- These three MUST move together with it:
        --   USEC_PER_SEC = ticks/second on rx_usec and in the local time counter.
        --   NCO_PHASE_W  = 32 so the auto inc_nominal = 2^32*1e8/250e6
        --                  = 1_717_986_918 still fits INC_WIDTH=32; 2^36 would need
        --                  35 bits and overflow. Rate trim = 1/inc = 0.58 ns/s,
        --                  finer than the 3.64 ns/s of the old 1 us / 36-bit combo.
        --   FRAC_BITS    = 1 keeps the sub-tick error LSB at 10ns/2 = 5 ns (close to
        --                  the old 1us/256 = 3.9 ns) so KP_SHIFT/KI_SHIFT below stay
        --                  valid, and keeps STEP_THRESH_SUB = 1e8*2 = 2e8 inside a
        --                  32-bit signed (FRAC_BITS=8 would be 2.56e10 -> overflow).
        USEC_PER_SEC       => 100_000_000,
        NCO_PHASE_W        => 32,
        FRAC_BITS          => 1,
        DAC_BITS           => 18,
        DAC_DEFAULT_CODE   => 16#20000#,     -- TODO: set to measured VCSO-914 center code
        SPI_CLK_DIV        => 5,             -- SCLK = 250MHz/(2*5) = 25 MHz
        DAC_GAIN_SHIFT     => 2,             -- max mapper gain (analog mode only)
        -- CHINH LAI GAIN 2026-10-14 (PA2). Hai dieu chinh lai so voi ghi chu 30/7:
        --
        -- 1) Cong thuc zeta ~ Kp/(2*sqrt(Ki)) o ghi chu cu THIEU he so don vi.
        --    Do loi vong that la 2^-KP_SHIFT * g voi
        --        g = (LSB cua inc, ns/s) * T / (LSB cua error, ns)
        --    Truoc 30/7 (tick 1 us, FRAC_BITS=8, NCO 36 bit): g = 3.638/3.906 = 0.931.
        --    Sau 30/7  (tick 10 ns, FRAC_BITS=1, NCO 32 bit): g = 0.582/5    = 0.1164.
        --    => lan doi don vi chia do loi vong cho dung 8.00 lan ma khong ai bu lai.
        --    zeta that = sqrt(g) * 2^-KP_SHIFT / (2 * 2^(-KI_SHIFT/2)), nen bo
        --    (KP=1, KI=7) cho zeta = 0.97 chu KHONG phai 2.83, va Kp = 0.058/s
        --    thay vi 0.466/s -> bang thong vong chi con 0.005 Hz, khong bam kip
        --    troi tan cua dao dong 250 MHz. Do la nguon cua ripple ~110 s / +-0.5 us
        --    do duoc ngay 1/8, chu khong phai thieu giam chan.
        --
        -- 2) Tran cua Kp khi KP_SHIFT >= 0 chi la 0.116/s. Vi vay time_servo_pi
        --    duoc mo rong de nhan KP_SHIFT AM (= dich trai). KP_SHIFT = -2 khoi
        --    phuc dung Kp = 0.466/s nhu truoc lan doi don vi.
        --
        -- Bang do (mo phong bit-accurate, cung mo hinh nhieu hieu chinh de tai tao
        -- p-p 1300 ns cua bo so hien hanh), cua so 600 s, trung binh 5 seed:
        --   bo so                 zeta  max|z|  p-p(nhieu)  bat nguoi tu 20 us
        --   KP= 1 KI=7 I_FRAC=0   0.97  0.9678   1282 ns     > 400 s (chua xong)
        --   KP= 0 KI=4 I_FRAC=0   0.68  0.9375    412 ns
        --   KP=-2 KI=1 I_FRAC=8   0.97  0.9173    102 ns        52 s
        --   KP=-2 KI=2 I_FRAC=8   1.36  0.9280    123 ns       113 s   <-- chon
        --   KP=-2 KI=3 I_FRAC=8   1.93  0.9665    153 ns       236 s
        --   KP=-3 KI=1 I_FRAC=8   max|z| = 1.0017 -> MAT ON DINH (tre cua FILT_SHIFT=1)
        -- Chon KI_SHIFT=2: bien on dinh tot nhat (max|z| nho nhat), bat nguoi nhanh
        -- gap 2 lan KI=3, ma van giu zeta = 1.36. KI=1 cho nhieu tot hon 20 ns nhung
        -- zeta tut ve 0.97 -- dung muc giam chan da gay dao dong +-400 ns tren HW
        -- voi bo so goc, nen khong lay.
        -- Do bang tb_servo_loop.vhd (vong kin RTL that) va mo hinh bit-accurate.
        KP_SHIFT           => -2,            -- Kp = 0.466/s (= gia tri truoc 30/7)
        KI_SHIFT           => 1,             -- Ki = 2.91e-2/s^2 -> zeta = 1.36
        -- I_FRAC xoa VUNG CHET cua nhanh I. Voi I_FRAC=0, i_delta =
        -- shift_right(error, KI_SHIFT) = 0 voi moi |error| < 2^KI_SHIFT LSB; o bo
        -- so cu (KI_SHIFT=7, LSB 5 ns) vung chet la 640 ns, va vi shift_right lam
        -- tron XUONG nen trong vung do integrator chi chay duoc mot chieu -> bias
        -- tinh. Mo phong cho +118 ns, do tren HW 1/8 cho mean +132 ns (PPS_ONLY)
        -- va +215 ns (FULL_SYNC). I_FRAC=8 >= KI_SHIFT=3 => vung chet = 0.
        I_FRAC             => 8,
        -- Kep trim +-300 ppm (lech dao dong that do duoc la -109 ppm). Day la
        -- anti-windup DUY NHAT con hieu luc: cong i_freeze trong time_sync_top
        -- bi dieu kien vcxo_ctrl_en='1' chan, ma che do dang chay la '0'.
        --   0.000300 * 1_717_986_918 = 515_396 LSB
        INC_TRIM_MAX       => 515396,
        DAC_SLEW_MAX_STEP  => 0,          -- allow up to 1024 LSB/update (analog mode only)
        PPS_TIMEOUT_CYCLES => 625000000,     -- 2.5 s @250MHz (PPS source-alive window)
        TS_TIMEOUT_CYCLES  => 625000000      -- 2.5 s @250MHz (timestamp source-alive window)
    )
    port map (
        clk              => sample_clk_s,
        rst              => sample_rst_s,
        pps_in           => onepps_in,
        -- Chon che do luc CHAY qua VIO (vio_ts, probe_out0) thay vi hardcode "000",
        -- de kiem chung rieng tung nguon dong bo tren HW:
        --   000 AUTO  001 FORCE_FREE_RUN  010 FORCE_PPS_ONLY
        --   011 FORCE_TS_ONLY  100 FORCE_FULL_SYNC  101 FORCE_HOLDOVER
        cfg_mode         => cfg_mode_vio_s,
        -- doi che do luc chay: nen ve FORCE_FREE_RUN (cfg=001) truoc khi lat
        -- bit nay roi tra lai mode do, de servo bat lai tu trang thai sach.
        vcxo_ctrl_en     => vcxo_en_vio_s(0),

        -- RX timestamp from Aurora, synchronized aurora_clk -> sample_clk above.
        -- Coherent {sec, usec} pair + aligned valid (handshake dest_req).
        rx_ts_valid      => rx_ts_valid_smp_s,
        rx_sec           => rx_ts_sec_smp_s,
        rx_usec          => rx_ts_usec_smp_s,

        -- Bu do tre truyen cua chinh duong tren (xem TS_DELAY_CYC_MEASURED).
        -- Dat luc chay qua vio_ts probe_out1 => co the A/B 0 vs 180 khong build lai.
        ts_delay_cyc     => ts_delay_cyc_s,

        -- AD5680 SPI (write-only) -- tapped via *_i for the dedicated SPI debug ILA
        dac_vcso_din     => dac_vcso_din_i,
        dac_vcso_sclk    => dac_vcso_sclk_i,
        dac_vcso_sync    => dac_vcso_sync_i,

        -- monitors for AXI-RO
        sec_loc          => sec_loc_s,
        usec_loc         => usec_loc_s,
        offset_us_out    => offset_us_s,
        pps_error_us_out => pps_error_us_s,
        error_us_out     => error_us_s,
        inc_out          => inc_out_s,
        tick_us          => tick_us_s,

        -- debug / status
        run_state_out    => run_state_dbg_s,
        pps_ok_out       => pps_ok_dbg_s,
        ts_ok_out        => ts_ok_dbg_s,
        sync_locked_out  => sync_locked_dbg_s,
        holdover_out     => holdover_dbg_s,
        dac_code_out     => dac_code_dbg_s,
        dac_update_o     => dac_update_dbg_s,
        spi_busy         => spi_busy_dbg_s
    );
    -- 1PPS noi bo tai hien tu dong ho da disciplined: '1' trong nua giay dau.
    -- SUA 2026-07-30: nguong phai la NUA GIAY tinh theo TICK, tuoc do cung 500000
    -- (dung khi 1 tick = 1 us) nen voi tick 10 ns no chi con 5 ms -> duty 0.5%.
    onepps_s <= '1' when usec_loc_s <= to_unsigned(50_000_000, usec_loc_s'length) else '0';

    ---------------------------------------------------------------------------
    -- VIO dieu khien + quan sat khoi dong bo thoi gian.
    --   probe_out0 (3 bit)  -> cfg_mode
    --   probe_out1 (16 bit) -> bu do tre timestamp (don vi chu ky sample_clk = 4 ns).
    --   probe_out2 (1 bit)  -> vcxo_ctrl_en: 0 = NCO so, 1 = analog DAC->VCSO
    --                          (init 0x0: sau nap bitstream la che do SO).
    --                          IP init 0x0000 => bit15=0 => dung hardcode 180 cyc.
    --                          0x8000 = TAT bu; 0x8000|n = bu n chu ky.
    --   probe_in0  (32 bit) = tu trang thai: [2:0] run_state, [3] pps_ok, [4] ts_ok,
    --                         [5] sync_locked, [6] holdover, [7] pps_in da sync,
    --                         [23:8] doc lai ts_delay_cyc dang ap dung
    --   probe_in1  (32 bit) = pps_error_us (sub-tick, LSB = tick/2^FRAC_BITS)
    --   probe_in2  (32 bit) = offset_us    (tick, DA bu do tre truyen)
    --   probe_in3  (32 bit) = inc_out      (so sanh voi nominal 0x66666666)
    -- Nho vay doc duoc chat luong dong bo bang VIO (tuc thoi) thay vi phai arm ILA.
    ---------------------------------------------------------------------------
    -- Gia tri bu THUC SU dang ap dung: hardcode, tru khi VIO bat bit override.
    ts_delay_cyc_s <= resize(unsigned(ts_delay_vio_s(14 downto 0)), ts_delay_cyc_s'length)
                      when ts_delay_vio_s(15) = '1'
                      else to_unsigned(TS_DELAY_CYC_MEASURED, ts_delay_cyc_s'length);

    ts_status_word_s <= x"00"                             -- [31:24] khong dung
                      & std_logic_vector(ts_delay_cyc_s)  -- [23:8] bu dang ap dung
                      & onepps_in          -- [7]
                      & holdover_dbg_s     -- [6]
                      & sync_locked_dbg_s  -- [5]
                      & ts_ok_dbg_s        -- [4]
                      & pps_ok_dbg_s       -- [3]
                      & run_state_dbg_s;   -- [2:0]

    vio_timesync : vio_ts
    port map (
        clk        => sample_clk_s,
        probe_in0  => ts_status_word_s,
        probe_in1  => std_logic_vector(pps_error_us_s),
        probe_in2  => std_logic_vector(offset_us_s),
        probe_in3  => std_logic_vector(inc_out_s),
        probe_in4  => vcsco_spi_p1_s,
        probe_in5(0)  => onepps_in,
        probe_out0 => cfg_mode_vio_s,
        probe_out1 => ts_delay_vio_s,
        probe_out2 => vcxo_en_vio_s      -- vcxo_ctrl_en: 0=NCO so, 1=analog DAC
    );

    -- drive the AD5680 SPI pins from the tapped internal signals
    dac_vcso_din  <= dac_vcso_din_i;
    dac_vcso_sclk <= dac_vcso_sclk_i;
    dac_vcso_sync <= dac_vcso_sync_i;

    ---------------------------------------------------------------------------
    -- Dedicated ILA: AD5680 SPI bus + DAC code/update + servo error/lock.
    -- (aurora_framer ILA was freed to make room.) Trigger on dac_vcso_sync
    -- falling to capture each 24-bit write to the AD5680.
    ---------------------------------------------------------------------------
    vcsco_spi_p1_s <= std_logic_vector(resize(dac_code_dbg_s, 32));
    vcsco_spi_p4_s <= std_logic_vector(pps_error_us_s);

    -- [MSDR] bo khoi: vcsco_spi_ila : ila_0 (bo het ILA khoi code)

    vcxo_cp <= init_clk_s;

check_counter_process : process(sample_clk_s)
	begin 
	  if (sample_clk_s'event and sample_clk_s ='1') then
	  	if (aurora_data_valid_out = '1') then
			aurora_data_out_sample_current <= aurora_data_out;
			if (aurora_data_out /= (aurora_data_out_sample_current + x"00000001")) then
				track_error_counter <= '1';
			else
				track_error_counter <= '0';
			end if;
		else
			track_error_counter <= '0';
		end if;
	end if;
end process;

--checker_counter :ila_0
--	port map(
--	  clk => sample_clk_s, 
--	  probe0(0) => aurora_data_valid_out, 
--	  probe1 => aurora_data_out, 
--	  probe2(0) => track_error_counter, 
--	  probe3(0) => '0', 
--	  probe4 => aurora_data_out_sample_current,
--	  probe5(0) => '0',   
--	  probe6(0) => '0', 
--	  probe7(0) => '0'
--	  );
 
    -- [MSDR] bo khoi: ila_Aurora_link_inst : ila_12 (bo het ILA khoi code)
 
-- rf_params_aurora : rf_params
--port map(
--  clk => aurora_clk_s, 
--  probe0 => Tx_freq_out, 
--  probe1 => Rx_freq_out, 
--  probe2(0) => timestamp_valid_out,
--  probe2(26 downto 1) => Next_Frame_Transmit_Time_out(25 downto 0),
--  probe3 => Power_Tx_out, 
--  probe4 => Tx_bw_out
--  );
  
--rf_params_rf : rf_params
--port map(
--  clk => init_clk_s, 
--  probe0 => Tx_freq_out_sync, 
--  probe1 => Rx_freq_out_sync, 
--  probe2 => Subsecond_out_sync,--Next_Frame_Transmit_Time_out_sync,
--  probe3 => Power_Tx_out_sync, 
--  probe4 => Tx_bw_out_sync
--  );
    ---------------------------------------------------------------------------
    -- [MSDR] Dem hai chieu cho chan GPIO cua T12 va cua ADRV9002.
    --
    -- tvsdr_fpga lai thang cac chan dieu khien RF vi chung la mot chieu. Tren
    -- T12 chung di qua bo dem muc (SN74LVC8T245) va duoc doc nguoc, nen phai
    -- dung IOBUF. Phan nay truoc day nam o msdr_top.v cua ADI; gio dua len top
    -- vi khong con file do nua.
    ---------------------------------------------------------------------------
    t12_gpio0_i(31 downto 24) <= lbf_ctrl_sense(3 downto 0) & rfsw_ctrl_sense;
    t12_gpio1_i(26)           <= lbf_ctrl_sense(4);

    gpio0_iobuf : for i in 0 to 23 generate
      IOBUF_inst : IOBUF
        port map (O => t12_gpio0_i(i), IO => t12_gpio0_pad(i),
                  I => rf_gpio0_o(i),  T => rf_gpio0_t(i));
    end generate;
    gpio1_iobuf : for i in 0 to 25 generate
      IOBUF_inst : IOBUF
        port map (O => t12_gpio1_i(i), IO => t12_gpio1_pad(i),
                  I => rf_gpio1_o(i),  T => rf_gpio1_t(i));
    end generate;

    -- GPIO channel 3 controls the auxiliary T12 signals; reset leaves them
    -- high-impedance until PS software configures each direction.
    tx_dsa_si_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(0), IO => tx_dsa_si,
                I => t12_aux_gpio_o(0), T => t12_aux_gpio_t(0));
    tx_dsa_clk_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(1), IO => tx_dsa_clk,
                I => t12_aux_gpio_o(1), T => t12_aux_gpio_t(1));
    tx_dsa_le_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(2), IO => tx_dsa_le,
                I => t12_aux_gpio_o(2), T => t12_aux_gpio_t(2));
    rx_dsa_si_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(3), IO => rx_dsa_si,
                I => t12_aux_gpio_o(3), T => t12_aux_gpio_t(3));
    rx_dsa_clk_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(4), IO => rx_dsa_clk,
                I => t12_aux_gpio_o(4), T => t12_aux_gpio_t(4));
    rx_dsa_le_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(5), IO => rx_dsa_le,
                I => t12_aux_gpio_o(5), T => t12_aux_gpio_t(5));
    orx_dsa_si_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(6), IO => orx_dsa_si,
                I => t12_aux_gpio_o(6), T => t12_aux_gpio_t(6));
    orx_dsa_clk_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(7), IO => orx_dsa_clk,
                I => t12_aux_gpio_o(7), T => t12_aux_gpio_t(7));
    orx_dsa_le_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(8), IO => orx_dsa_le,
                I => t12_aux_gpio_o(8), T => t12_aux_gpio_t(8));
    bbu_gpio_1_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(9), IO => bbu_gpio_1,
                I => t12_aux_gpio_o(9), T => t12_aux_gpio_t(9));
    bbu_gpio_2_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(10), IO => bbu_gpio_2,
                I => t12_aux_gpio_o(10), T => t12_aux_gpio_t(10));
    bbu_gpio_3_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(11), IO => bbu_gpio_3,
                I => t12_aux_gpio_o(11), T => t12_aux_gpio_t(11));
    trx_spi_sclk_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(12), IO => trx_spi_sclk,
                I => t12_aux_gpio_o(12), T => t12_aux_gpio_t(12));
    trx_spi_mosi_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(13), IO => trx_spi_mosi,
                I => t12_aux_gpio_o(13), T => t12_aux_gpio_t(13));
    trx_spi_miso_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(14), IO => trx_spi_miso,
                I => t12_aux_gpio_o(14), T => t12_aux_gpio_t(14));
    lb_tft_sfl_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(15), IO => lb_tft_sfl,
                I => t12_aux_gpio_o(15), T => t12_aux_gpio_t(15));
    hb_tft_sfl_iobuf : IOBUF
      port map (O => t12_aux_gpio_i(16), IO => hb_tft_sfl,
                I => t12_aux_gpio_o(16), T => t12_aux_gpio_t(16));

    -- dgpio/gp_int/reset_trx cua ADRV9002 di qua EMIO GPIO cua PS.
    dgpio_iobuf : for i in 0 to 11 generate
      IOBUF_inst : IOBUF
        port map (O => gpio_i(32+i), IO => dgpio(i),
                  I => gpio_o(32+i), T => gpio_t(32+i));
    end generate;
    gp_int_iobuf : IOBUF
      port map (O => gpio_i(44), IO => gp_int, I => gpio_o(44), T => gpio_t(44));
    reset_trx_iobuf : IOBUF
      port map (O => gpio_i(46), IO => reset_trx, I => gpio_o(46), T => gpio_t(46));

    -- Cac bit EMIO khong noi chan: doc nguoc chinh gia tri ghi ra, giong
    -- msdr_top.v cua ADI de phan mem ADI thay dung trang thai.
    gpio_i( 7 downto  0) <= gpio_o( 7 downto  0);
    gpio_i(20 downto  8) <= (others => '0');
    gpio_i(31 downto 21) <= gpio_o(31 downto 21);
    gpio_i(45)           <= gpio_i(43);
    gpio_i(47)           <= '0';
    gpio_i(54 downto 48) <= gpio_o(54 downto 48);
    gpio_i(55)           <= '0';
    gpio_i(94 downto 56) <= gpio_o(94 downto 56);
    mssi_sync            <= gpio_o(54);
    gpio_rx1_enable_in   <= gpio_o(48);
    gpio_rx2_enable_in   <= gpio_o(49);
    gpio_tx1_enable_in   <= gpio_o(50);
    gpio_tx2_enable_in   <= gpio_o(51);
    tx_output_enable     <= '1';
    mcs_in               <= '0';
    tdd_sync             <= '0';
    spi0_miso            <= spi_do;
    spi_clk              <= spi0_sclk;
    spi_dio              <= spi0_mosi;
    spi_en               <= spi0_csn(0);
    spi1_miso            <= dcosc_spi_miso;
    dcosc_spi_sclk       <= spi1_sclk;
    dcosc_spi_mosi       <= spi1_mosi;
    dcosc_spi_csn        <= spi1_csn(0);
    ref_clk              <= fpga_ref_clk;

    -- [MSDR] system_info_wrapper van dung ten SYS_INTERFACE nhu ban cu;
    -- day chi la bi danh cua cong M_AXI_SYS do system.bd phat ra.
    SYS_INTERFACE_araddr  <= M_AXI_SYS_araddr;
    SYS_INTERFACE_arprot  <= M_AXI_SYS_arprot;
    M_AXI_SYS_arready(0)  <= SYS_INTERFACE_arready;
    SYS_INTERFACE_arvalid <= M_AXI_SYS_arvalid(0);
    SYS_INTERFACE_awaddr  <= M_AXI_SYS_awaddr;
    SYS_INTERFACE_awprot  <= M_AXI_SYS_awprot;
    M_AXI_SYS_awready(0)  <= SYS_INTERFACE_awready;
    SYS_INTERFACE_awvalid <= M_AXI_SYS_awvalid(0);
    SYS_INTERFACE_bready  <= M_AXI_SYS_bready(0);
    M_AXI_SYS_bresp       <= SYS_INTERFACE_bresp;
    M_AXI_SYS_bvalid(0)   <= SYS_INTERFACE_bvalid;
    M_AXI_SYS_rdata       <= SYS_INTERFACE_rdata;
    SYS_INTERFACE_rready  <= M_AXI_SYS_rready(0);
    M_AXI_SYS_rresp       <= SYS_INTERFACE_rresp;
    M_AXI_SYS_rvalid(0)   <= SYS_INTERFACE_rvalid;
    SYS_INTERFACE_wdata   <= M_AXI_SYS_wdata;
    M_AXI_SYS_wready(0)   <= SYS_INTERFACE_wready;
    SYS_INTERFACE_wstrb   <= M_AXI_SYS_wstrb;
    SYS_INTERFACE_wvalid  <= M_AXI_SYS_wvalid(0);

    ---------------------------------------------------------------------------
    -- [MSDR] Anh xa sang mat chan that cua T12
    --
    -- Toan bo than kien truc ben tren giu nguyen ten tin hieu cua tvsdr_fpga.
    -- Khoi nay la cho duy nhat biet den phan cung T12, nen muon doi chieu voi
    -- ban cu chi can bo qua tu day den cuoi file.
    ---------------------------------------------------------------------------

    -- PS SPI1 drives the T12 DCXO; the legacy VCXO driver is no longer routed
    -- to the board pins.

    -- The PS auxiliary GPIO owns the RFE and digital-attenuator pins.
    spi_tx_cpld_miso  <= t12_aux_gpio_i(14);

    -- The PS AXI Quad SPI controllers own the low- and high-band filter buses.
    hb_tbpf_sdo   <= hb_tft_sdo;

    -- Hai tu dieu khien GPIO cua T12. Thu tu bit theo msdr_top.v:
    --   gpio0[3:0] rfsw_ctrl   [8:4] lbf_ctrl   [9] hb_lna_byp  [10] lb_lna_byp
    --   gpio0[11] hb_trx_ctrl  [12] lb_trx_ctrl [23:13] byp/gb/led/bbu
    --   gpio0[31:24] va gpio1[26] la duong doc nguoc, FSM khong lai.
    -- Bang tra gpio_out (gpio_BRAM/gpio.coe) van la cua board TVSDR; 13 bit dau
    -- duoc lay theo dung thu tu chuc nang tuong duong, phan con lai de PS giu.
    fsm_gpio0 <= x"00" & gpio_out(23 downto 0);
    fsm_gpio1 <= (others => '0');   -- khoi TFT/SW do fsm_main lai qua SPI

    gpio0_arb : for i in rf_gpio0_o'range generate
      rf_gpio0_o(i) <= ps_gpio0_o(i) when gpio0_mask_s(i) = '1' else fsm_gpio0(i);
      rf_gpio0_t(i) <= ps_gpio0_t(i) when gpio0_mask_s(i) = '1' else '0';
    end generate;
    gpio1_arb : for i in rf_gpio1_o'range generate
      rf_gpio1_o(i) <= ps_gpio1_o(i) when gpio1_mask_s(i) = '1' else fsm_gpio1(i);
      rf_gpio1_t(i) <= ps_gpio1_t(i) when gpio1_mask_s(i) = '1' else '0';
    end generate;

    -- Bang tra cau hinh: fsm_main chi doc, khong bao gio ghi.
    CFG_LUT_din <= (others => '0');

    ---------------------------------------------------------------------------
    -- [MSDR] Thanh ghi dieu khien rieng cua MSDR
    --
    -- mb_bd cu dua lenh xuong fsm_main qua gpio_1_tri, va chon tx_IQ_source
    -- bang vio_0. Hai duong do van con. Khoi nay chi them nhung thu TVSDR
    -- khong co: mat na trong tai GPIO giua PS va fsm_main, va ban sao
    -- tx_iq_source doc duoc tu phan mem.
    ---------------------------------------------------------------------------
    u_msdr_trx_regs : entity work.msdr_trx_regs
      generic map (C_S_AXI_ADDR_WIDTH => 7)
      port map (
        s_axi_aclk    => init_clk_s,
        s_axi_aresetn => initclk_rstn_s,
        s_axi_awaddr  => M_AXI_REGS_awaddr(6 downto 0),
        s_axi_awprot  => M_AXI_REGS_awprot,
        s_axi_awvalid => M_AXI_REGS_awvalid(0),
        s_axi_awready => M_AXI_REGS_awready(0),
        s_axi_wdata   => M_AXI_REGS_wdata,
        s_axi_wstrb   => M_AXI_REGS_wstrb,
        s_axi_wvalid  => M_AXI_REGS_wvalid(0),
        s_axi_wready  => M_AXI_REGS_wready(0),
        s_axi_bresp   => M_AXI_REGS_bresp,
        s_axi_bvalid  => M_AXI_REGS_bvalid(0),
        s_axi_bready  => M_AXI_REGS_bready(0),
        s_axi_araddr  => M_AXI_REGS_araddr(6 downto 0),
        s_axi_arprot  => M_AXI_REGS_arprot,
        s_axi_arvalid => M_AXI_REGS_arvalid(0),
        s_axi_arready => M_AXI_REGS_arready(0),
        s_axi_rdata   => M_AXI_REGS_rdata,
        s_axi_rresp   => M_AXI_REGS_rresp,
        s_axi_rvalid  => M_AXI_REGS_rvalid(0),
        s_axi_rready  => M_AXI_REGS_rready(0),
        enable_fsm    => open,
        cfg_reload    => open,
        trx_config    => open,
        dummy_frame   => open,
        gpio_test     => open,
        ts_cfg_mode   => open,
        ts_delay_cyc  => open,
        tx_iq_source  => tx_iq_source_ps,
        gpio0_mask    => gpio0_mask_s,
        gpio1_mask    => gpio1_mask_s,
        command1      => open,
        command2      => open,
        command3      => open,
        command4      => open,
        command5      => open,
        tx_command    => open,
        aurora_status  => aurora_status,
        tx_card_status => (others => '0'),
        sec_loc        => local_time_init_s(66 downto 27),
        usec_loc       => local_time_init_s(26 downto 0),
        sync_locked    => sync_locked_axi_s,
        adc_ovf        => adc_dovf_axi_s,
        dac_unf        => '0',
        metadata_valid => timestamp_valid_out_sync
      );


end Behavior;

----------------------------------------------------------------------------------
-- msdr_rf_ctrl
--
-- Lop thich ung dieu khien RF cua MSDR (T12) cho fsm_main chuyen tu TVSDR RFU.
--
-- fsm_main la may trang thai dinh thoi khung TDD: no nhan metadata khung
-- (Frame_Length, Next_Frame_Transmit_Time, Next_Frame_Receive_Time, Tx/Rx_freq)
-- cung thoi gian noi bo, roi phat ra chuoi dieu khien bang tan va cac giao dich
-- SPI dung thoi diem. Phan dinh thoi do khong phu thuoc board nen giu nguyen.
--
-- Phan phu thuoc board thi khac han: board TVSDR RFU co AD9914 DDS, ADF41510 PLL,
-- NB6L295, MAAD-011045, bo loc LB/HB TBPF NetCom, AD9164 DAC va mot IC mux GPIO
-- ngoai (fsm_main day 48 bit dieu khien qua 8 chan bang GPIO_Mux). T12 khong co
-- bat ky thu nao trong so do. Mat dieu khien cua T12, theo U_8/U_10/13.1 cua
-- docs/T12_DSP_Hardware_Architecture.md, chi gom:
--
--   RFE J6 : RFSW_CTRL1..4, LBF_CTRL1..5, HB/LB_LNA_BYP, HB/LB_TRX_CTRL,
--            TRX_SPI 3 day (SCLK/MOSI/MISO)
--   TFT    : LB_TFT_SPI -> ADMV8052, HB_TFT_SPI -> ADMV8513/8526
--            (tft_ctrl_a/b, sw_ctrl_a/b, hb/lb_tft_reset)
--   DSA    : 3 x RFSA3713 (TX/RX/ORX) giao tiep SI/CLK/LE
--
-- Nen o day: cac ngo ra cua fsm_main thuoc IC khong ton tai tren T12 duoc de
-- "open", con lai anh xa thang vao hai tu dieu khien gpio0/gpio1 cua T12.
-- GPIO_Mux_wrapper van duoc giu vi fsm_main instantiate no ben trong, nhung
-- tren T12 khong co IC mux ngoai nen ngo ra cua no khong di dau ca.
--
-- Trong tai PS: moi bit cua hai tu dieu khien duoc chon nguon bang mat na
-- ps_gpio*_mask ('1' = PS giu quyen, '0' = FSM giu quyen). Day dung co che ma
-- tvsdr dung giua MicroBlaze va fsm_main (gpio_mask_ub_in), chi doi chu CPU.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity msdr_rf_ctrl is
  generic (
    N_GPIO : integer := 65
  );
  port (
    ---------------------------------------------------------------------------
    -- Dong ho / reset (mien init_clk = pl_clk0 100 MHz)
    ---------------------------------------------------------------------------
    fsm_clk       : in  std_logic;
    fsm_rstn      : in  std_logic;
    enable_fsm    : in  std_logic;

    ---------------------------------------------------------------------------
    -- Metadata khung tu msdr_trx_core (da dong bo sang init_clk)
    ---------------------------------------------------------------------------
    Frame_Length_in             : in  std_logic_vector(47 downto 0);
    Tx_freq_in                  : in  std_logic_vector(47 downto 0);
    Rx_freq_in                  : in  std_logic_vector(47 downto 0);
    Next_Frame_Transmit_Time_in : in  std_logic_vector(26 downto 0);
    Power_Tx_in                 : in  std_logic_vector(7 downto 0);
    Rx_bw_in                    : in  std_logic_vector(7 downto 0);
    Tx_bw_in                    : in  std_logic_vector(7 downto 0);
    Next_Frame_Receive_Time_in  : in  std_logic_vector(26 downto 0);
    Second_from_2000_in         : in  std_logic_vector(39 downto 0);
    Subsecond_in                : in  std_logic_vector(26 downto 0);
    trx_config_in               : in  std_logic := '0';

    -- Thoi gian noi bo tu time_sync
    Current_second_from_2000_in : in  std_logic_vector(39 downto 0);
    Current_Subsecond_in        : in  std_logic_vector(26 downto 0);
    running_config_valid_in     : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- Lenh / trang thai qua AXI GPIO cua PS
    ---------------------------------------------------------------------------
    command1_in        : in  std_logic_vector(31 downto 0) := (others => '0');
    command2_in        : in  std_logic_vector(31 downto 0) := (others => '0');
    command3_in        : in  std_logic_vector(31 downto 0) := (others => '0');
    command4_in        : in  std_logic_vector(31 downto 0) := (others => '0');
    command5_in        : in  std_logic_vector(31 downto 0) := (others => '0');
    tx_command_in      : in  std_logic_vector(31 downto 0) := (others => '0');
    tx_card_status_out : out std_logic_vector(31 downto 0);
    cfg_reload_in      : in  std_logic := '0';
    gpio_test_in       : in  std_logic := '0';
    gpio_mask_in       : in  std_logic_vector(N_GPIO-1 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- BRAM cau hinh (fsm_main doc bang LUT tan so).
    --
    -- Giao dien BRAM duoc khai bao TUONG MINH bang X_INTERFACE_INFO o phan
    -- khai bao kien truc ben duoi. Khong the de IP Integrator tu suy dien:
    -- analog.com:interface:fifo_rd co moi cong deu optional nen no khop voi
    -- gan nhu mot cong 'en' bat ky va thang suy dien, lam connect_bd_intf_net
    -- bao BD 41-177 (fifo_rd khong noi duoc vao blk_mem_gen).
    -- Luu y huong: BRAM_PORTB_dout la du lieu DOC VE tu BRAM, tuong ung voi
    -- cong CFG_LUT_din cua fsm_main; BRAM_PORTB_din la du lieu GHI RA va khong
    -- duoc dung (fsm_main chi doc).
    ---------------------------------------------------------------------------
    BRAM_PORTB_clk  : out std_logic;
    BRAM_PORTB_rst  : out std_logic;
    BRAM_PORTB_en   : out std_logic;
    BRAM_PORTB_we   : out std_logic_vector(3 downto 0);
    BRAM_PORTB_addr : out std_logic_vector(31 downto 0);
    BRAM_PORTB_din  : out std_logic_vector(31 downto 0);
    BRAM_PORTB_dout : in  std_logic_vector(31 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Hai tu dieu khien T12. Thu tu bit giong het msdr_top.v:
    --
    --  gpio0[ 3: 0] rfsw_ctrl        gpio0[16]    rx_test_en
    --  gpio0[ 8: 4] lbf_ctrl         gpio0[17]    rx_gb_ctrl
    --  gpio0[ 9]    hb_lna_byp       gpio0[20:18] tx_gb_ctrl
    --  gpio0[10]    lb_lna_byp       gpio0[22:21] led_id
    --  gpio0[11]    hb_trx_ctrl      gpio0[23]    bbu_gpio_0
    --  gpio0[12]    lb_trx_ctrl
    --  gpio0[13]    gb_lb_byp_ctrl   gpio1[15: 0] tft_ctrl_b/a dan xen
    --  gpio0[14]    gb1_hb_byp_ctrl  gpio1[23:16] sw_ctrl_b/a dan xen
    --  gpio0[15]    gb2_hb_byp_ctrl  gpio1[24]    hb_tft_reset
    --                                gpio1[25]    lb_tft_reset
    ---------------------------------------------------------------------------
    -- Do rong phai dung het cua axi_t12_gpio: kenh 1 la 32 bit
    -- (C_GPIO_WIDTH), kenh 2 la 27 bit (C_GPIO2_WIDTH). Chi 24 bit thap cua
    -- kenh 1 va 26 bit thap cua kenh 2 thuc su lai chan; phan con lai la cac
    -- bit doc nguoc (sense) nen gia tri o/t khong co y nghia, cu cho PS giu.
    ps_gpio0_o     : in  std_logic_vector(31 downto 0);
    ps_gpio0_t     : in  std_logic_vector(31 downto 0);
    ps_gpio0_mask  : in  std_logic_vector(31 downto 0) := (others => '1');
    ps_gpio1_o     : in  std_logic_vector(26 downto 0);
    ps_gpio1_t     : in  std_logic_vector(26 downto 0);
    ps_gpio1_mask  : in  std_logic_vector(26 downto 0) := (others => '1');

    rf_gpio0_o     : out std_logic_vector(31 downto 0);
    rf_gpio0_t     : out std_logic_vector(31 downto 0);
    rf_gpio1_o     : out std_logic_vector(26 downto 0);
    rf_gpio1_t     : out std_logic_vector(26 downto 0);

    ---------------------------------------------------------------------------
    -- TRX_SPI 3 day toi RFE (J6)
    ---------------------------------------------------------------------------
    trx_spi_sclk   : out std_logic;
    trx_spi_mosi   : out std_logic;
    trx_spi_miso   : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- 3 bo suy hao so RFSA3713 (SI / CLK / LE)
    ---------------------------------------------------------------------------
    tx_dsa_si      : out std_logic;
    tx_dsa_clk     : out std_logic;
    tx_dsa_le      : out std_logic;
    rx_dsa_si      : out std_logic;
    rx_dsa_clk     : out std_logic;
    rx_dsa_le      : out std_logic;
    orx_dsa_si     : out std_logic;
    orx_dsa_clk    : out std_logic;
    orx_dsa_le     : out std_logic;

    ---------------------------------------------------------------------------
    -- SPI toi cac bo loc dieu chinh ADMV (LB_TFT_SPI / HB_TFT_SPI)
    ---------------------------------------------------------------------------
    lb_tft_sclk    : out std_logic;
    lb_tft_sdi     : out std_logic;
    lb_tft_sdo     : in  std_logic := '0';
    lb_tft_csn     : out std_logic_vector(1 downto 0);
    hb_tft_sclk    : out std_logic;
    hb_tft_sdi     : out std_logic;
    hb_tft_sdo     : in  std_logic := '0';
    hb_tft_csn     : out std_logic_vector(3 downto 0)
  );
end entity msdr_rf_ctrl;

architecture rtl of msdr_rf_ctrl is

  ---------------------------------------------------------------------------
  -- Khai bao giao dien BRAM cho IP Integrator
  ---------------------------------------------------------------------------
  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;

  attribute X_INTERFACE_INFO of BRAM_PORTB_clk  : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK";
  attribute X_INTERFACE_INFO of BRAM_PORTB_rst  : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB RST";
  attribute X_INTERFACE_INFO of BRAM_PORTB_en   : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB EN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_we   : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB WE";
  attribute X_INTERFACE_INFO of BRAM_PORTB_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR";
  attribute X_INTERFACE_INFO of BRAM_PORTB_din  : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT";
  attribute X_INTERFACE_PARAMETER of BRAM_PORTB_clk : signal is
    "MASTER_TYPE BRAM_CTRL, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, READ_WRITE_MODE READ_ONLY";

  -- Cac chan *_clk cua bo suy hao so va cua SPI khong phai xung nhip he thong
  -- ma la xung dich do FSM phat ra theo nhip bit. Khong khai bao thi IP
  -- Integrator coi chung la clock interface va doi FREQ_HZ (IP_Flow 19-4751).
  attribute X_INTERFACE_INFO of tx_dsa_clk   : signal is "xilinx.com:signal:data:1.0 tx_dsa_clk DATA";
  attribute X_INTERFACE_INFO of rx_dsa_clk   : signal is "xilinx.com:signal:data:1.0 rx_dsa_clk DATA";
  attribute X_INTERFACE_INFO of orx_dsa_clk  : signal is "xilinx.com:signal:data:1.0 orx_dsa_clk DATA";
  attribute X_INTERFACE_INFO of trx_spi_sclk : signal is "xilinx.com:signal:data:1.0 trx_spi_sclk DATA";
  attribute X_INTERFACE_INFO of lb_tft_sclk  : signal is "xilinx.com:signal:data:1.0 lb_tft_sclk DATA";
  attribute X_INTERFACE_INFO of hb_tft_sclk  : signal is "xilinx.com:signal:data:1.0 hb_tft_sclk DATA";


  -- Bus dieu khien 65 bit cua fsm_main.
  signal gpio_outs_s : std_logic_vector(64 downto 0);

  -- Cac ngo ra roi le cua fsm_main duoc T12 su dung.
  signal rfsw_ctrl_s      : std_logic_vector(3 downto 0);
  signal lbf_ctrl_s       : std_logic_vector(4 downto 0);
  signal hb_lna_byp_s     : std_logic;
  signal lb_lna_byp_s     : std_logic;
  signal hb_trx_ctrl_s    : std_logic;
  signal lb_trx_ctrl_s    : std_logic;

  signal fsm_gpio0_s      : std_logic_vector(31 downto 0);
  signal fsm_gpio1_s      : std_logic_vector(26 downto 0);

  -- Chuoi dich cua bo suy hao RX: fsm_main lai, ca RX va ORX cung dung.
  -- Phai di qua tin hieu trung gian vi VHDL khong cho doc nguoc cong 'out'.
  signal rx_dsa_si_s      : std_logic;
  signal rx_dsa_clk_s     : std_logic;
  signal rx_dsa_le_s      : std_logic;

  -- SPI bo loc dieu chinh: fsm_main dung giao dien kieu inout.
  signal hb_tbpf_sdi_s    : std_logic;
  signal hb_tbpf_sclk_s   : std_logic;
  signal hb_tbpf_csn_s    : std_logic_vector(3 downto 0);
  signal lb_rx_tbpf_mosi_s : std_logic;
  signal lb_rx_tbpf_sclk_s : std_logic;
  signal lb_rx_tbpf1_csn_s : std_logic;
  signal lb_rx_tbpf2_csn_s : std_logic;
  signal lb_tx_tbpf_mosi_s : std_logic;
  signal lb_tx_tbpf_sclk_s : std_logic;
  signal lb_tx_tbpf1_csn_s : std_logic;
  signal lb_tx_tbpf2_csn_s : std_logic;

begin

  -- fsm_main chi doc LUT, khong bao gio ghi.
  BRAM_PORTB_din <= (others => '0');

  ---------------------------------------------------------------------------
  -- fsm_main: cac ngo ra thuoc IC khong co tren T12 de open.
  -- Bo qua: ad9164_* (AD9164 DAC), pll_a/b_adf41510_* (ADF41510), dds_*
  -- (AD9914), if_fb_* (bo loc IF cua TVSDR), lo_ps (bo dich pha), hb/lb/if
  -- switch matrix cua TVSDR, dac_ph_*, pingpong_An_b, vcxo_cp, GPIO_MUX_*.
  ---------------------------------------------------------------------------
  u_fsm_main : entity work.fsm_main
    generic map (
      N_GPIO => N_GPIO
    )
    port map (
      fsm_clk_in      => fsm_clk,
      adc_clk_in      => fsm_clk,
      fsm_rstn_in     => fsm_rstn,
      enable_fsm      => enable_fsm,
      gpio_outs       => gpio_outs_s,

      CFG_LUT_addr    => BRAM_PORTB_addr,
      CFG_LUT_clk     => BRAM_PORTB_clk,
      CFG_LUT_din     => BRAM_PORTB_dout,
      CFG_LUT_en      => BRAM_PORTB_en,
      CFG_LUT_rst     => BRAM_PORTB_rst,
      CFG_LUT_we      => BRAM_PORTB_we,

      cfg_reload_in   => cfg_reload_in,
      gpio_test_in    => gpio_test_in,
      gpio_mask_ub_in => gpio_mask_in,

      command1_in     => command1_in,
      command2_in     => command2_in,
      command3_in     => command3_in,
      command4_in     => command4_in,
      command5_in     => command5_in,

      -- SPI bo loc dieu chinh dai thap -> LB_TFT_SPI (ADMV8052)
      lb_rx_tbpf_mosi => lb_rx_tbpf_mosi_s,
      lb_rx_tbpf_sclk => lb_rx_tbpf_sclk_s,
      lb_rx_tbpf1_csn => lb_rx_tbpf1_csn_s,
      lb_rx_tbpf2_csn => lb_rx_tbpf2_csn_s,
      lb_tx_tbpf_mosi => lb_tx_tbpf_mosi_s,
      lb_tx_tbpf_sclk => lb_tx_tbpf_sclk_s,
      lb_tx_tbpf1_csn => lb_tx_tbpf1_csn_s,
      lb_tx_tbpf2_csn => lb_tx_tbpf2_csn_s,

      Frame_Length_in             => Frame_Length_in,
      Tx_freq_in                  => Tx_freq_in,
      Rx_freq_in                  => Rx_freq_in,
      Next_Frame_Transmit_Time_in => Next_Frame_Transmit_Time_in,
      Power_Tx_in                 => Power_Tx_in,
      Rx_bw_in                    => Rx_bw_in,
      Tx_bw_in                    => Tx_bw_in,
      Next_Frame_Receive_Time_in  => Next_Frame_Receive_Time_in,
      Second_from_2000_in         => Second_from_2000_in,
      Subsecond_in                => Subsecond_in,
      trx_config_in               => trx_config_in,

      Current_second_from_2000_in => Current_second_from_2000_in,
      Current_Subsecond_in        => Current_Subsecond_in,
      running_config_valid_in     => running_config_valid_in,

      -- TRX_SPI 3 day cua RFE
      tx_command_in       => tx_command_in,
      tx_card_status_out  => tx_card_status_out,
      SPI_CPLD_MISO_in    => trx_spi_miso,
      SPI_CPLD_MOSI_out   => trx_spi_mosi,
      SPI_CPLD_SCLK_out   => trx_spi_sclk,
      SPI_CPLD_CSN_out    => open,

      -- AD9164 khong co tren T12
      ad9164_csn  => open,
      ad9164_sclk => open,
      ad9164_mosi => open,

      -- ADF41510 khong co tren T12 (ADRV9002 tu tao LO)
      pll_a_adf41510_clk  => open,
      pll_a_adf41510_mosi => open,
      pll_a_adf41510_csn  => open,
      pll_b_adf41510_clk  => open,
      pll_b_adf41510_mosi => open,
      pll_b_adf41510_csn  => open,

      -- Ma tran chuyen mach cua TVSDR: khong co tren T12
      if_fb_sw_1      => open,
      if_fb_sw_0      => open,
      hb_tpfb_sw_2    => open,
      hb_tpfb_sw_1    => open,
      hb_tpfb_sw_0    => open,
      hb_tpfb_sw_0n   => open,
      lb_rx_tbpf_sw_1 => open,
      lb_rx_tbpf_sw_2 => open,
      lb_sw_1         => open,
      lb_sw_2         => open,
      lb_tx_tbpf_sw_1 => open,
      lb_tx_tbpf_sw_2 => open,
      hb_fb_sw_1      => open,
      hb_fb_sw_0      => open,
      hb_fb_sw_2n     => open,
      hb_fb_sw_2      => open,
      hb_fb_tx        => open,
      hb_sw           => open,
      lo_ps           => open,
      lo_div2_en_a    => open,
      lo_div2_en_b    => open,
      RTX_PUSH_GATE   => open,

      dac_txenable    => open,
      dac_ph_en_1v8   => open,
      dac_ph_sload_1v8=> open,
      pingpong_An_b   => open,
      TX_RF_OFF_1V8   => open,
      vcxo_cp         => open,

      -- SPI bo loc dieu chinh dai cao -> HB_TFT_SPI (ADMV8513/8526)
      hb_tbpf_sdi   => hb_tbpf_sdi_s,
      hb_tbpf_sdo   => hb_tft_sdo,
      hb_tbpf_sclk  => hb_tbpf_sclk_s,
      hb_1_tbpf_csn => hb_tbpf_csn_s(0),
      hb_2_tbpf_csn => hb_tbpf_csn_s(1),
      hb_3_tbpf_csn => hb_tbpf_csn_s(2),
      hb_4_tbpf_csn => hb_tbpf_csn_s(3),

      -- AD9914 DDS khong co tren T12
      dds_data       => open,
      dds_a_syncio   => open,
      dds_b_syncio   => open,
      dds_sdo        => open,
      dds_sdio       => open,
      dds_scl        => open,
      dds_a_0_csn    => open,
      dds_b_0_csn    => open,
      dds_a_ioupdate => open,
      dds_b_ioupdate => open,

      -- Bo suy hao so: TVSDR co 2, T12 co 3 (TX / RX / ORX).
      -- ORX dung chung chuoi dich voi RX cho den khi fsm_main co kenh thu ba.
      tx_att_sin   => tx_dsa_si,
      tx_att_clk   => tx_dsa_clk,
      tx_att_le    => tx_dsa_le,
      rtx_att_sin  => rx_dsa_si_s,
      rtx_att_clk  => rx_dsa_clk_s,
      rtx_att_le   => rx_dsa_le_s,

      -- Bo loc IF cua TVSDR: khong co tren T12
      if_fb_si  => open,
      if_fb_clk => open,
      if_fb_le  => open,

      -- IC mux GPIO ngoai: T12 khong co IC nay. GPIO_Mux_wrapper van nam ben
      -- trong fsm_main nen cac chan sense cua no phai duoc noi, nhung ca chuoi
      -- dich lan cac chan sense deu khong di ra ngoai tren T12.
      GPIO_MUXED    => open,
      GPIO_MUX_LE_0 => open,
      GPIO_MUX_LE_1 => '1',
      GPIO_MUX_LE_2 => '1',
      GPIO_MUX_LE_3 => '1',
      ADC_AFE_PWUP  => '0',
      ADC_AFE_PM    => '0',
      ADC_PDWN      => '0',
      DDS_PWR_DWN   => '0',
      EN_RX         => '0',
      EN_TX         => '0',
      EN_LO         => '0',
      EN_RTX        => '0',

      rx_dds_config_tvalid => open,
      rx_dds_config_tdata  => open
    );

  -- ORX dung chung chuoi dich voi RX (mot RFSA3713 nua tren T12).
  rx_dsa_si   <= rx_dsa_si_s;
  rx_dsa_clk  <= rx_dsa_clk_s;
  rx_dsa_le   <= rx_dsa_le_s;
  orx_dsa_si  <= rx_dsa_si_s;
  orx_dsa_clk <= rx_dsa_clk_s;
  orx_dsa_le  <= rx_dsa_le_s;

  ---------------------------------------------------------------------------
  -- LB_TFT_SPI: ADMV8052 co hai duong (RX va TX) tren TVSDR, T12 chi co mot
  -- bus chung nen hai chip select duoc dua ra rieng, SCLK/SDI dung chung.
  ---------------------------------------------------------------------------
  lb_tft_sclk <= lb_rx_tbpf_sclk_s when lb_rx_tbpf1_csn_s = '0' or lb_rx_tbpf2_csn_s = '0'
                 else lb_tx_tbpf_sclk_s;
  lb_tft_sdi  <= lb_rx_tbpf_mosi_s when lb_rx_tbpf1_csn_s = '0' or lb_rx_tbpf2_csn_s = '0'
                 else lb_tx_tbpf_mosi_s;
  lb_tft_csn(0) <= lb_rx_tbpf1_csn_s and lb_tx_tbpf1_csn_s;
  lb_tft_csn(1) <= lb_rx_tbpf2_csn_s and lb_tx_tbpf2_csn_s;

  hb_tft_sclk <= hb_tbpf_sclk_s;
  hb_tft_sdi  <= hb_tbpf_sdi_s;
  hb_tft_csn  <= hb_tbpf_csn_s;

  ---------------------------------------------------------------------------
  -- Anh xa bus 65 bit cua fsm_main sang mat dieu khien cua T12.
  --
  -- gpio_outs cua fsm_main duoc gpio_band_decoder nap tu gpio_BRAM (gpio.coe),
  -- bang tra do duoc soan cho board TVSDR. Bang cho T12 phai soan lai theo
  -- chuoi RF cua U_10; cho den luc do, 13 bit dau duoc lay theo dung thu tu
  -- chuc nang tuong duong, phan con lai de PS giu.
  ---------------------------------------------------------------------------
  rfsw_ctrl_s   <= gpio_outs_s(3 downto 0);
  lbf_ctrl_s    <= gpio_outs_s(8 downto 4);
  hb_lna_byp_s  <= gpio_outs_s(9);
  lb_lna_byp_s  <= gpio_outs_s(10);
  hb_trx_ctrl_s <= gpio_outs_s(11);
  lb_trx_ctrl_s <= gpio_outs_s(12);

  -- Bit 31..24 cua kenh 1 la cac duong sense doc nguoc, FSM khong lai.
  fsm_gpio0_s <= "00000000"
               & gpio_outs_s(23 downto 13)   -- bbu_gpio_0, led_id, tx/rx_gb, byp
               & lb_trx_ctrl_s & hb_trx_ctrl_s
               & lb_lna_byp_s & hb_lna_byp_s
               & lbf_ctrl_s & rfsw_ctrl_s;

  -- Khoi TFT/SW do fsm_main dieu khien qua SPI, khong qua bus song song.
  fsm_gpio1_s <= (others => '0');

  ---------------------------------------------------------------------------
  -- Trong tai PS theo tung bit: mask='1' thi PS giu quyen.
  ---------------------------------------------------------------------------
  gpio0_arb : for i in rf_gpio0_o'range generate
    rf_gpio0_o(i) <= ps_gpio0_o(i) when ps_gpio0_mask(i) = '1' else fsm_gpio0_s(i);
    rf_gpio0_t(i) <= ps_gpio0_t(i) when ps_gpio0_mask(i) = '1' else '0';
  end generate;

  gpio1_arb : for i in rf_gpio1_o'range generate
    rf_gpio1_o(i) <= ps_gpio1_o(i) when ps_gpio1_mask(i) = '1' else fsm_gpio1_s(i);
    rf_gpio1_t(i) <= ps_gpio1_t(i) when ps_gpio1_mask(i) = '1' else '0';
  end generate;

end architecture rtl;

----------------------------------------------------------------------------------
-- msdr_trx_core
--
-- Khoi tich hop TRX cua MSDR (T12 / XCZU15EG + ADRV9002).
--
-- Day la ban chuyen doi cua src/hdl/top/tvsdr_rfu_trx.vhd tu board TVSDR RFU
-- (XCAU15P + AD9652 ADC + AD9164 DAC qua JESD204) sang MSDR. Nhung gi giu lai:
--
--   * aurora_wrapper   - link GTH 1 lane 10.3125 Gbps toi BBU (J2)
--   * aurora_protocol  - framer/deframer + GFP + metadata khung
--   * time_sync_top    - dong bo thoi gian 1PPS + timestamp tu Aurora
--   * time_sync_axi_ro - thanh ghi chi doc cho PS doc trang thai dong bo
--   * bo chon nguon IQ phat cua tvsdr_fpga.vhd: DDS hai tong, GMSK 2 Mb/s,
--     CW, IQ tu Aurora, DMA cua PS - cung phep lui 6 dB nhu tvsdr
--
-- Nhung gi bo di so voi tvsdr_rfu_trx:
--
--   * rx_system_wrap (AD9652 LVDS + DDC)  -> thay bang tap IQ tu axi_adrv9001 adc_1
--   * tx_sys (JESD204 AD9164)             -> thay bang dac_1 cua axi_adrv9001
--   * mb_bd_wrapper (MicroBlaze)          -> thay bang PS ARM cua Zynq UltraScale+
--   * clk_wiz_0 / IBUFDS INIT_CLK         -> init_clk lay tu pl_clk0 (100 MHz)
--
-- Mien xung nhip:
--   init_clk  100 MHz  - pl_clk0: AXI-Lite, GFP, SA, time_sync, DRP cua Aurora
--   aurora_clk         - user_clk cua aurora_64b66b_0 (do aurora_wrapper phat ra)
--   adc_clk            - adc_1_clk cua axi_adrv9001: nhip mau framer (huong thu)
--   dac_clk            - dac_1_clk cua axi_adrv9001: nhip mau deframer (huong phat)
--
-- Luu y giu nguyen tu tvsdr: cac bus metadata huong di (*_in) duoc noi thang vao
-- framer khong qua CDC, giong het ban RFU. Framer chi chot chung mot lan moi khung
-- nen thuc te on dinh, nhung day van la duong CDC khong co bat tay - xem README.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library xpm;
use xpm.vcomponents.all;

entity msdr_trx_core is
  generic (
    -- "YES" = phia RFU (MSDR), "NO" = phia MBU. Giu nguyen nhu tvsdr_rfu_trx.
    RFU_MODE        : string  := "YES";
    -- Tan so init_clk (Hz) - pl_clk0 cua PS.
    INIT_CLK_HZ     : integer := 100000000;
    -- So tick thoi gian noi bo trong mot giay (= don vi cua usec_loc va rx_usec).
    --
    -- CAN KIEM TRA LAI VOI MBU: ghi chu trong time_sync_v2/time_sync_top.vhd noi
    -- don vi Subsecond cua giao thuc Rev M/N la 10 ns, tuc 100_000_000 tick/giay,
    -- va hai ben PHAI khop nhau. Nhung NCO khong dat duoc nhip do: local_time_nco
    -- sinh tick khi bo tich luy PHASE_WIDTH=36 bit tran, con inc bi gioi han
    -- INC_WIDTH=32 bit, nen nhip tick toi da chi bang clk/16. Voi 10 ns/tick se
    -- can clk >= 1,6 GHz. Vi vay o day dung mac dinh 1 us/tick cua time_sync_v2.
    -- Neu MBU that su gui Subsecond theo don vi 10 ns thi phai quy doi o duong
    -- rx_usec (hoac noi rong inc) truoc khi dua vao servo.
    USEC_PER_SEC    : integer := 1000000;
    -- Buoc NCO danh dinh = round(2^36 * USEC_PER_SEC / INIT_CLK_HZ).
    -- 2^36 * 1e6 / 1e8 = 687194767,36
    INC_NOMINAL     : natural := 687194767
  );
  port (
    ---------------------------------------------------------------------------
    -- Mien dieu khien (pl_clk0, 100 MHz)
    ---------------------------------------------------------------------------
    init_clk            : in  std_logic;
    init_rstn           : in  std_logic;

    ---------------------------------------------------------------------------
    -- Tham chieu thoi gian
    ---------------------------------------------------------------------------
    pps_in              : in  std_logic;                     -- 1PPS tu BBU (J2)
    ref_10m_in          : in  std_logic := '0';              -- 10 MHz tu BBU (J2 GPIO_1)
    ts_cfg_mode         : in  std_logic_vector(2 downto 0) := "000";  -- 000 = AUTO
    ts_delay_cyc        : in  std_logic_vector(15 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Aurora GTH (1 lane, Quad X1Y1, 10.3125 Gbps, refclk 156.25 MHz)
    ---------------------------------------------------------------------------
    gt_refclk           : in  std_logic;                     -- da qua IBUFDS_GTE4
    aurora_rxp          : in  std_logic;
    aurora_rxn          : in  std_logic;
    aurora_txp          : out std_logic;
    aurora_txn          : out std_logic;
    aurora_status_o     : out std_logic_vector(31 downto 0);

    ---------------------------------------------------------------------------
    -- Tap IQ thu tu axi_adrv9001 kenh adc_1 (RX1) - mien adc_1_clk
    -- adc_1 cua ADRV9002 o che do LVDS cho 2 mau IQ moi nhip (i0/q0 + i1/q1),
    -- dung bang 64 bit ma framer cua tvsdr mong doi tu ADC 2 lane.
    ---------------------------------------------------------------------------
    adc_clk             : in  std_logic;
    adc_rst             : in  std_logic;
    adc_valid           : in  std_logic;
    adc_data_i0         : in  std_logic_vector(15 downto 0);  -- RX1 I
    adc_data_q0         : in  std_logic_vector(15 downto 0);  -- RX1 Q
    adc_ovf             : out std_logic;                      -- FIFO framer day

    ---------------------------------------------------------------------------
    -- Tap IQ thu kenh 2: axi_adrv9001 adc_2 (RX2) - mien adc_2_clk
    --
    -- GIA DINH: T12 noi day ca hai giao dien LVDS thu (msdr_top.v co rieng hai
    -- nhom chan rx1_* va rx2_*), nen ADRV9002 chay che do moi kenh mot giao
    -- dien. Khi do RX2 ra o adc_2 theo nhip adc_2_clk rieng.
    --
    -- Neu profile cua ADRV9002 lai dung che do mot giao dien ghep kenh thi RX2
    -- se ra o adc_1_data_i1/q1 ngay tren adc_1_clk (xem i_rx1 trong
    -- axi_adrv9001_core.v: adc_data_i_B <= rx2_data_i). Luc do bo FIFO ben
    -- duoi va lay thang i1/q1 - doi mot dong, nhung phai doi.
    ---------------------------------------------------------------------------
    adc2_clk            : in  std_logic;
    adc2_rst            : in  std_logic;
    adc2_valid          : in  std_logic;
    adc2_data_i0        : in  std_logic_vector(15 downto 0);  -- RX2 I
    adc2_data_q0        : in  std_logic_vector(15 downto 0);  -- RX2 Q

    ---------------------------------------------------------------------------
    -- Duong IQ phat ra axi_adrv9001 kenh dac_1 - mien dac_1_clk
    --
    -- dac_1 mang HAI KENH chu khong phai hai mau lien tiep:
    --   i0/q0 = TX1 (kenh A), i1/q1 = TX2 (kenh B)
    -- Chi TX1 duoc lai o day theo yeu cau; TX2 di duong DMA rieng qua dac_2.
    ---------------------------------------------------------------------------
    dac_clk             : in  std_logic;
    dac_rst             : in  std_logic;
    dac_rd_en           : in  std_logic;                     -- dac_1_valid_i0
    dac_data_i0         : out std_logic_vector(15 downto 0); -- TX1 I
    dac_data_q0         : out std_logic_vector(15 downto 0); -- TX1 Q
    dac_data_i1         : out std_logic_vector(15 downto 0); -- TX2 I (khong dung)
    dac_data_q1         : out std_logic_vector(15 downto 0); -- TX2 Q (khong dung)
    dac_unf             : out std_logic;                     -- dem deframer rong
    tx_i_err            : out std_logic;   -- mau I khong tang deu 1 (probe)
    tx_q_err            : out std_logic;   -- mau Q khong tang deu 1 (probe)
    tx_track_err        : out std_logic;   -- dau ra deframer khong tang deu 1

    ---------------------------------------------------------------------------
    -- Chon nguon IQ phat. Chuyen nguyen tu tvsdr_fpga.vhd (tx_IQ_source):
    --   000  hai tong DDS                 - do IMD3, hai song cach nhau 500 kHz
    --   001  mot song DDS dich 250 kHz
    --   010  IQ tu Aurora (BBU)           - duong khai thac binh thuong
    --   011  CW muc 1/2 cong suat
    --   100  CW muc 1/8 cong suat
    --   101  GMSK 2 Mb/s tu Waveform_streamer
    --   110  DMA cua PS (util_dac_1_upack) - bo sung them cho MSDR
    --   khac RF off (IQ = 0)
    ---------------------------------------------------------------------------
    tx_iq_source        : in  std_logic_vector(2 downto 0) := "010";
    dac_dma_data_i0     : in  std_logic_vector(15 downto 0) := (others => '0');
    dac_dma_data_q0     : in  std_logic_vector(15 downto 0) := (others => '0');
    dac_dma_rd_en       : out std_logic;                     -- toi upack/fifo_rd_en

    ---------------------------------------------------------------------------
    -- Metadata khung gui len BBU (mien init_clk, chuan tinh)
    ---------------------------------------------------------------------------
    Frame_Length_in             : in  std_logic_vector(47 downto 0) := (others => '0');
    Tx_freq_in                  : in  std_logic_vector(47 downto 0) := (others => '0');
    Rx_freq_in                  : in  std_logic_vector(47 downto 0) := (others => '0');
    Next_Frame_Transmit_Time_in : in  std_logic_vector(26 downto 0) := (others => '0');
    Power_Tx_in                 : in  std_logic_vector(7 downto 0)  := (others => '0');
    Rx_bw_in                    : in  std_logic_vector(7 downto 0)  := (others => '0');
    Tx_bw_in                    : in  std_logic_vector(7 downto 0)  := (others => '0');
    Next_Frame_Receive_Time_in  : in  std_logic_vector(26 downto 0) := (others => '0');
    Second_from_2000_in         : in  std_logic_vector(39 downto 0) := (others => '0');
    Subsecond_in                : in  std_logic_vector(26 downto 0) := (others => '0');
    dummy_frame_in              : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- Metadata khung nhan tu BBU (da dong bo sang init_clk)
    ---------------------------------------------------------------------------
    Frame_Length_out             : out std_logic_vector(47 downto 0);
    Tx_freq_out                  : out std_logic_vector(47 downto 0);
    Rx_freq_out                  : out std_logic_vector(47 downto 0);
    Next_Frame_Transmit_Time_out : out std_logic_vector(26 downto 0);
    Power_Tx_out                 : out std_logic_vector(7 downto 0);
    Rx_bw_out                    : out std_logic_vector(7 downto 0);
    Tx_bw_out                    : out std_logic_vector(7 downto 0);
    Next_Frame_Receive_Time_out  : out std_logic_vector(26 downto 0);
    Second_from_2000_out         : out std_logic_vector(39 downto 0);
    Subsecond_out                : out std_logic_vector(26 downto 0);
    metadata_valid_out           : out std_logic;

    ---------------------------------------------------------------------------
    -- Thoi gian noi bo (mien init_clk) cho FSM dieu khien RF
    ---------------------------------------------------------------------------
    sec_loc_out         : out std_logic_vector(39 downto 0);
    usec_loc_out        : out std_logic_vector(26 downto 0);
    sync_locked_out     : out std_logic;
    tick_us_out         : out std_logic;

    ---------------------------------------------------------------------------
    -- GFP (kenh ban tin trong khung Aurora) - mien init_clk
    ---------------------------------------------------------------------------
    GFPin_data          : in  std_logic_vector(7 downto 0) := (others => '1');
    GFPin_valid         : in  std_logic := '0';
    GFPin_ready         : out std_logic;
    GFPin_last          : in  std_logic := '0';
    GFPout_data         : out std_logic_vector(7 downto 0);
    GFPout_valid        : out std_logic;
    GFPout_ready        : in  std_logic := '0';
    GFPout_last         : out std_logic;

    ---------------------------------------------------------------------------
    -- AXI4-Lite: thanh ghi chi doc cua time_sync
    ---------------------------------------------------------------------------
    s_axi_aclk          : in  std_logic;
    s_axi_aresetn       : in  std_logic;
    s_axi_awaddr        : in  std_logic_vector(5 downto 0);
    s_axi_awprot        : in  std_logic_vector(2 downto 0);
    s_axi_awvalid       : in  std_logic;
    s_axi_awready       : out std_logic;
    s_axi_wdata         : in  std_logic_vector(31 downto 0);
    s_axi_wstrb         : in  std_logic_vector(3 downto 0);
    s_axi_wvalid        : in  std_logic;
    s_axi_wready        : out std_logic;
    s_axi_bresp         : out std_logic_vector(1 downto 0);
    s_axi_bvalid        : out std_logic;
    s_axi_bready        : in  std_logic;
    s_axi_araddr        : in  std_logic_vector(5 downto 0);
    s_axi_arprot        : in  std_logic_vector(2 downto 0);
    s_axi_arvalid       : in  std_logic;
    s_axi_arready       : out std_logic;
    s_axi_rdata         : out std_logic_vector(31 downto 0);
    s_axi_rresp         : out std_logic_vector(1 downto 0);
    s_axi_rvalid        : out std_logic;
    s_axi_rready        : in  std_logic
  );
end entity msdr_trx_core;

architecture rtl of msdr_trx_core is

  ---------------------------------------------------------------------------
  -- IP dung lai nguyen tu tvsdr (da retarget sang xczu15eg)
  ---------------------------------------------------------------------------
  component dds_compiler_1 is
    port (
      aclk               : in  std_logic;
      m_axis_data_tvalid : out std_logic;
      m_axis_data_tdata  : out std_logic_vector(31 downto 0)
    );
  end component dds_compiler_1;

  component ila_1 is
    port (
      clk    : in std_logic;
      probe0 : in std_logic_vector(15 downto 0);
      probe1 : in std_logic_vector(15 downto 0);
      probe2 : in std_logic_vector(0 downto 0);
      probe3 : in std_logic_vector(0 downto 0);
      probe4 : in std_logic_vector(0 downto 0);
      probe5 : in std_logic_vector(0 downto 0)
    );
  end component ila_1;

  component Waveform_streamer is
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      IQout_tlast  : out std_logic;
      IQout_tdata  : out std_logic_vector(31 downto 0);
      IQout_tvalid : out std_logic
    );
  end component Waveform_streamer;

  ---------------------------------------------------------------------------
  -- Tin hieu Aurora
  ---------------------------------------------------------------------------
  signal aurora_clk_s         : std_logic;
  signal aurora_rst_s         : std_logic;

  signal Aurora_IQin_tdata_s  : std_logic_vector(63 downto 0);
  signal Aurora_IQin_tkeep_s  : std_logic_vector(7 downto 0);
  signal Aurora_IQin_tvalid_s : std_logic;
  signal Aurora_IQin_tlast_s  : std_logic;
  signal Aurora_IQin_tready_s : std_logic;

  signal Aurora_IQout_tdata_s  : std_logic_vector(63 downto 0);
  signal Aurora_IQout_tkeep_s  : std_logic_vector(7 downto 0);
  signal Aurora_IQout_tvalid_s : std_logic;
  signal Aurora_IQout_tlast_s  : std_logic;

  ---------------------------------------------------------------------------
  -- Reset dong bo sang cac mien
  ---------------------------------------------------------------------------
  signal init_rstn_s          : std_logic;
  signal initclk_rstfromaurora_s : std_logic;
  signal adc_rst_sync_s       : std_logic;

  ---------------------------------------------------------------------------
  -- Duong mau
  ---------------------------------------------------------------------------
  signal Sample_IQin_data_s   : std_logic_vector(63 downto 0);
  signal Sample_IQin_valid_s  : std_logic;
  signal Sample_IQin_ready_s  : std_logic;

  -- RX2 vuot sang mien adc_clk. Hai nhip adc_1_clk/adc_2_clk sinh tu cung mot
  -- xung thiet bi cua ADRV9002 nen cung tan so, lech pha khong biet truoc
  -- (mesochronous) - mot FIFO khong dong bo nong la dung bai.
  signal adc2_fifo_din        : std_logic_vector(31 downto 0);
  signal adc2_fifo_dout       : std_logic_vector(31 downto 0);
  signal adc2_fifo_empty      : std_logic;
  signal adc2_fifo_full       : std_logic;
  signal adc2_fifo_rden       : std_logic;
  signal adc2_i_s             : std_logic_vector(15 downto 0);
  signal adc2_q_s             : std_logic_vector(15 downto 0);

  -- Deframer -> dem dan hoi -> bo chon nguon -> dac_1
  signal sample_IQout_data_s  : std_logic_vector(31 downto 0);
  signal Sample_IQout_valid_s : std_logic;
  signal txfifo_dout          : std_logic_vector(31 downto 0);
  signal txfifo_empty         : std_logic;
  signal txfifo_full          : std_logic;
  signal txfifo_rden          : std_logic;
  signal aurora_iq_s          : std_logic_vector(31 downto 0);

  -- Cac nguon thu nghiem
  signal dds_tdata_s          : std_logic_vector(31 downto 0);
  signal gmsk_tdata_s         : std_logic_vector(31 downto 0);

  signal tx_i_s, tx_q_s       : std_logic_vector(15 downto 0);
  -- Ban sao tre mot chu ky, dung ten theo tvsdr: I_data_out / Q_data_out
  signal tx_i_d1, tx_q_d1     : std_logic_vector(15 downto 0);
  signal i_err_s, q_err_s     : std_logic;

  -- tx_iq_source di tu mien init_clk (khoi thanh ghi) sang dac_clk, va
  -- dummy_frame sang aurora_clk: deu phai qua dong bo nhu tvsdr lam o
  -- tvsdr_fpga.vhd dong 1452.
  signal tx_src_sync          : std_logic_vector(2 downto 0);
  signal dummy_frame_sync     : std_logic;

  -- Kiem tra lien tuc mau o dau ra deframer (check_counter_process cua tvsdr)
  signal aurora_prev_s        : std_logic_vector(31 downto 0);
  signal track_error_s        : std_logic;

  ---------------------------------------------------------------------------
  -- Metadata o mien aurora_clk truoc khi CDC
  ---------------------------------------------------------------------------
  signal Frame_Length_aur             : std_logic_vector(47 downto 0);
  signal Tx_freq_aur                  : std_logic_vector(47 downto 0);
  signal Rx_freq_aur                  : std_logic_vector(47 downto 0);
  signal Next_Frame_Transmit_Time_aur : std_logic_vector(26 downto 0);
  signal Power_Tx_aur                 : std_logic_vector(7 downto 0);
  signal Rx_bw_aur                    : std_logic_vector(7 downto 0);
  signal Tx_bw_aur                    : std_logic_vector(7 downto 0);
  signal Next_Frame_Receive_Time_aur  : std_logic_vector(26 downto 0);
  signal Second_from_2000_aur         : std_logic_vector(39 downto 0);
  signal Subsecond_aur                : std_logic_vector(26 downto 0);
  signal timestamp_valid_aur          : std_logic;

  signal Second_from_2000_sync        : std_logic_vector(39 downto 0);
  signal Subsecond_sync               : std_logic_vector(26 downto 0);
  signal timestamp_valid_sync         : std_logic;

  ---------------------------------------------------------------------------
  -- time_sync
  ---------------------------------------------------------------------------
  signal sec_loc_s        : unsigned(39 downto 0);
  signal usec_loc_s       : unsigned(26 downto 0);
  signal offset_us_s      : signed(31 downto 0);
  signal pps_error_us_s   : signed(31 downto 0);
  signal error_us_s       : signed(31 downto 0);
  signal inc_out_s        : unsigned(31 downto 0);
  signal tick_us_s        : std_logic;

  constant INC_NOMINAL_C  : unsigned(31 downto 0) := to_unsigned(INC_NOMINAL, 32);

begin

  ---------------------------------------------------------------------------
  -- Reset
  ---------------------------------------------------------------------------
  init_rstn_s <= init_rstn;

  -- Reset cua Aurora dong bo nguoc ve init_clk, dung cho GFP/SA (nhu tvsdr).
  initclk_rst_cdc_ins : xpm_cdc_async_rst
    generic map (
      DEST_SYNC_FF    => 10,
      INIT_SYNC_FF    => 1,
      RST_ACTIVE_HIGH => 0
    )
    port map (
      dest_arst => initclk_rstfromaurora_s,
      dest_clk  => init_clk,
      src_arst  => not aurora_rst_s
    );

  -- Reset Aurora dong bo sang mien mau thu (framer).
  sampleclk_rst_cdc_ins : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 4,
      INIT_SYNC_FF   => 0,
      SIM_ASSERT_CHK => 0,
      SRC_INPUT_REG  => 1
    )
    port map (
      dest_out => adc_rst_sync_s,
      dest_clk => adc_clk,
      src_clk  => aurora_clk_s,
      src_in   => aurora_rst_s
    );

  ---------------------------------------------------------------------------
  -- Dong bo cac bit dieu khien sang mien tieu thu
  ---------------------------------------------------------------------------
  tx_src_cdc : xpm_cdc_array_single
    generic map (DEST_SYNC_FF => 4, INIT_SYNC_FF => 0, SIM_ASSERT_CHK => 0,
                 SRC_INPUT_REG => 1, WIDTH => 3)
    port map (dest_out => tx_src_sync, dest_clk => dac_clk,
              src_clk => init_clk, src_in => tx_iq_source);

  dummy_frame_cdc : xpm_cdc_single
    generic map (DEST_SYNC_FF => 4, INIT_SYNC_FF => 0, SIM_ASSERT_CHK => 0,
                 SRC_INPUT_REG => 1)
    port map (dest_out => dummy_frame_sync, dest_clk => aurora_clk_s,
              src_clk => init_clk, src_in => dummy_frame_in);

  ---------------------------------------------------------------------------
  -- Aurora: GTH + AXI-Stream 64 bit
  ---------------------------------------------------------------------------
  Aurora_ins : entity work.aurora_wrapper
    port map (
      rstn_i          => init_rstn_s,
      init_clk_i      => init_clk,
      gt_refclk1      => gt_refclk,
      rxp             => aurora_rxp,
      rxn             => aurora_rxn,
      txp             => aurora_txp,
      txn             => aurora_txn,
      aurora_clk_o    => aurora_clk_s,
      aurora_rst_o    => aurora_rst_s,
      aurora_status_o => aurora_status_o,
      gt_rxusrclk_o   => open,
      s_IQ_tdata_i    => Aurora_IQin_tdata_s,
      s_IQ_tkeep_i    => Aurora_IQin_tkeep_s,
      s_IQ_tvalid_i   => Aurora_IQin_tvalid_s,
      s_IQ_tlast_i    => Aurora_IQin_tlast_s,
      s_IQ_tready_o   => Aurora_IQin_tready_s,
      m_IQ_tdata_o    => Aurora_IQout_tdata_s,
      m_IQ_tkeep_o    => Aurora_IQout_tkeep_s,
      m_IQ_tvalid_o   => Aurora_IQout_tvalid_s,
      m_IQ_tlast_o    => Aurora_IQout_tlast_s
    );

  ---------------------------------------------------------------------------
  -- Ghep mau thu thanh tu 64 bit cua framer.
  --
  -- Giu dung quy uoc cua tvsdr (rx_system_wrap.vhd:395):
  --     A_B_data_o <= fir_ddc_ia_o & fir_ddc_qa_o & fir_ddc_ib_o & fir_ddc_qb_o
  -- tuc I_A & Q_A & I_B & Q_B, I nam o nua cao cua moi kenh.
  -- Tren MSDR: kenh A = RX1, kenh B = RX2, giong het hai kenh cua AD9652.
  ---------------------------------------------------------------------------
  adc2_fifo_din <= adc2_data_i0 & adc2_data_q0;

  -- Dem vuot nhip cho RX2. Doc moi khi RX1 co mau moi, nen hai ben luon can
  -- bang; neu RX2 tat thi FIFO rong va kenh B ra 0.
  u_adc2_cdc : xpm_fifo_async
    generic map (
      CDC_SYNC_STAGES     => 2,
      DOUT_RESET_VALUE    => "0",
      ECC_MODE            => "no_ecc",
      FIFO_MEMORY_TYPE    => "distributed",
      FIFO_READ_LATENCY   => 0,
      FIFO_WRITE_DEPTH    => 16,
      FULL_RESET_VALUE    => 0,
      PROG_EMPTY_THRESH   => 5,
      PROG_FULL_THRESH    => 10,
      RD_DATA_COUNT_WIDTH => 5,
      READ_DATA_WIDTH     => 32,
      READ_MODE           => "fwft",
      RELATED_CLOCKS      => 0,
      USE_ADV_FEATURES    => "0000",
      WAKEUP_TIME         => 0,
      WRITE_DATA_WIDTH    => 32,
      WR_DATA_COUNT_WIDTH => 5
    )
    port map (
      sleep         => '0',
      rst           => adc2_rst,
      wr_clk        => adc2_clk,
      wr_en         => adc2_valid,
      din           => adc2_fifo_din,
      full          => adc2_fifo_full,
      rd_clk        => adc_clk,
      rd_en         => adc2_fifo_rden,
      dout          => adc2_fifo_dout,
      empty         => adc2_fifo_empty,
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

  adc2_fifo_rden <= adc_valid and not adc2_fifo_empty;
  adc2_i_s <= adc2_fifo_dout(31 downto 16) when adc2_fifo_empty = '0' else (others => '0');
  adc2_q_s <= adc2_fifo_dout(15 downto  0) when adc2_fifo_empty = '0' else (others => '0');

  Sample_IQin_data_s  <= adc_data_i0 & adc_data_q0 & adc2_i_s & adc2_q_s;
  Sample_IQin_valid_s <= adc_valid;

  -- Tran o huong thu: framer khong kip nhan, hoac dem RX2 bi day.
  adc_ovf <= (adc_valid and not Sample_IQin_ready_s) or (adc2_valid and adc2_fifo_full);

  ---------------------------------------------------------------------------
  -- Framer / deframer / GFP / metadata
  ---------------------------------------------------------------------------
  i_aurora_protocol : entity work.aurora_protocol
    generic map (
      RFU_MODE => RFU_MODE
    )
    port map (
      aurora_clk_in       => aurora_clk_s,
      aurora_rst_in       => aurora_rst_s,

      Aurora_IQin_tdata   => Aurora_IQout_tdata_s,
      Aurora_IQin_tkeep   => Aurora_IQout_tkeep_s,
      Aurora_IQin_tvalid  => Aurora_IQout_tvalid_s,
      Aurora_IQin_tlast   => Aurora_IQout_tlast_s,
      Aurora_IQin_tready  => open,

      Aurora_IQout_tlast  => Aurora_IQin_tlast_s,
      Aurora_IQout_tdata  => Aurora_IQin_tdata_s,
      Aurora_IQout_tkeep  => Aurora_IQin_tkeep_s,
      Aurora_IQout_tvalid => Aurora_IQin_tvalid_s,
      Aurora_IQout_tready => Aurora_IQin_tready_s,

      -- Huong thu: ADRV9002 adc_1 -> Aurora
      sample_IQin_data      => Sample_IQin_data_s,
      Sample_IQin_valid     => Sample_IQin_valid_s,
      Sample_IQin_ready     => Sample_IQin_ready_s,
      Sample_IQin_clk_375M  => adc_clk,

      -- Huong phat: Aurora -> ADRV9002 dac_1
      sample_IQout_data     => sample_IQout_data_s,
      Sample_IQout_valid    => Sample_IQout_valid_s,

      sample_clk_in          => adc_clk,          -- nhip mau framer
      Sample_rst_in          => adc_rst_sync_s,
      Sample_clk_deframer_in => dac_clk,          -- nhip mau deframer

      GFPin_data   => GFPin_data,
      GFPin_valid  => GFPin_valid,
      GFPin_ready  => GFPin_ready,
      GFPin_last   => GFPin_last,
      GFPout_data  => GFPout_data,
      GFPout_valid => GFPout_valid,
      GFPout_ready => GFPout_ready,
      GFPout_last  => GFPout_last,
      GFP_clk_in   => init_clk,
      GFP_rstn_in  => initclk_rstfromaurora_s,

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

      Frame_Length_out             => Frame_Length_aur,
      Tx_freq_out                  => Tx_freq_aur,
      Rx_freq_out                  => Rx_freq_aur,
      Next_Frame_Transmit_Time_out => Next_Frame_Transmit_Time_aur,
      Power_Tx_out                 => Power_Tx_aur,
      Rx_bw_out                    => Rx_bw_aur,
      Tx_bw_out                    => Tx_bw_aur,
      Next_Frame_Receive_Time_out  => Next_Frame_Receive_Time_aur,
      Second_from_2000_out         => Second_from_2000_aur,
      Subsecond_out                => Subsecond_aur,
      timestamp_valid_out          => timestamp_valid_aur,

      -- Kenh SA khong dung tren MSDR (giong tvsdr_rfu_trx).
      SA_clk_in  => init_clk,
      SA_rstn_in => init_rstn_s,

      dummy_frame_in     => dummy_frame_sync,
      metadata_valid_out => open
    );

  ---------------------------------------------------------------------------
  -- Duong IQ phat
  --
  -- Deframer da chay ngay tren dac_clk nen khong con phai vuot nhip nhu tvsdr
  -- (ben do deframer o sample_clk con DAC o tx_core_clk, phai qua
  -- axis_32_to64 + IQ_stream_FIFO). O day chi can mot dem dan hoi, vi deframer
  -- do ra theo cum moi khung con dac_1 thi rut deu dan.
  ---------------------------------------------------------------------------
  u_tx_fifo : xpm_fifo_sync
    generic map (
      DOUT_RESET_VALUE    => "0",
      ECC_MODE            => "no_ecc",
      FIFO_MEMORY_TYPE    => "block",
      FIFO_READ_LATENCY   => 0,
      FIFO_WRITE_DEPTH    => 2048,
      FULL_RESET_VALUE    => 0,
      PROG_EMPTY_THRESH   => 10,
      PROG_FULL_THRESH    => 2038,
      RD_DATA_COUNT_WIDTH => 12,
      READ_DATA_WIDTH     => 32,
      READ_MODE           => "fwft",
      USE_ADV_FEATURES    => "0000",
      WAKEUP_TIME         => 0,
      WRITE_DATA_WIDTH    => 32,
      WR_DATA_COUNT_WIDTH => 12
    )
    port map (
      sleep         => '0',
      rst           => dac_rst,
      wr_clk        => dac_clk,
      wr_en         => Sample_IQout_valid_s,
      din           => sample_IQout_data_s,
      full          => txfifo_full,
      rd_en         => txfifo_rden,
      dout          => txfifo_dout,
      empty         => txfifo_empty,
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
      underflow     => open,
      wr_ack        => open,
      wr_data_count => open,
      wr_rst_busy   => open,
      rd_rst_busy   => open
    );

  -- Chi rut dem khi dang thuc su phat tu Aurora.
  txfifo_rden <= dac_rd_en and not txfifo_empty when tx_src_sync = "010" else '0';
  aurora_iq_s <= txfifo_dout when txfifo_empty = '0' else (others => '0');
  dac_unf     <= dac_rd_en and txfifo_empty when tx_src_sync = "010" else '0';

  -- Chi rut DMA khi dang chon no, de duong kia khong bi xa oan.
  dac_dma_rd_en <= dac_rd_en when tx_src_sync = "110" else '0';

  ---------------------------------------------------------------------------
  -- Nguon thu nghiem: DDS hai tong va song GMSK 2 Mb/s
  ---------------------------------------------------------------------------
  u_dds : dds_compiler_1
    port map (
      aclk               => dac_clk,
      m_axis_data_tvalid => open,
      m_axis_data_tdata  => dds_tdata_s
    );

  u_gmsk : Waveform_streamer
    port map (
      clk          => dac_clk,
      rst          => dac_rst,
      IQout_tlast  => open,
      IQout_tdata  => gmsk_tdata_s,
      IQout_tvalid => open
    );

  ---------------------------------------------------------------------------
  -- Bo chon nguon IQ phat - chuyen nguyen tu tvsdr_fpga.vhd (khoi case o
  -- dong 947). Moi nguon deu qua cung mot phep lui 6 dB: lay bit dau mo rong
  -- hai lan roi cat 14 bit cao, tuc chia 4. Giu dung nhu tvsdr de muc CW,
  -- GMSK va DDS so sanh duoc truc tiep voi so lieu do tren board cu.
  ---------------------------------------------------------------------------
  tx_mux : process (dac_clk)
  begin
    if rising_edge(dac_clk) then
      if dac_rst = '1' then
        tx_i_s  <= (others => '0');
        tx_q_s  <= (others => '0');
        tx_i_d1 <= (others => '0');
        tx_q_d1 <= (others => '0');
        i_err_s <= '0';
        q_err_s <= '0';
      else
        case tx_src_sync is
          -- Hai tong DDS, cach nhau 500 kHz: do IMD3
          when "000" =>
            tx_i_s <= dds_tdata_s(31) & dds_tdata_s(31) & dds_tdata_s(31 downto 18);
            tx_q_s <= dds_tdata_s(31) & dds_tdata_s(31) & dds_tdata_s(31 downto 18);
          -- Mot song DDS dich 250 kHz
          when "001" =>
            tx_i_s <= dds_tdata_s(31) & dds_tdata_s(31) & dds_tdata_s(31 downto 18);
            tx_q_s <= dds_tdata_s(15) & dds_tdata_s(15) & dds_tdata_s(15 downto  2);
          -- IQ tu BBU qua Aurora
          when "010" =>
            tx_i_s <= aurora_iq_s(31) & aurora_iq_s(31) & aurora_iq_s(31 downto 18);
            tx_q_s <= aurora_iq_s(15) & aurora_iq_s(15) & aurora_iq_s(15 downto  2);
          -- CW 1/2 cong suat
          when "011" =>
            tx_i_s <= x"3FFF";
            tx_q_s <= x"3FFF";
          -- CW 1/8 cong suat
          when "100" =>
            tx_i_s <= x"1FFF";
            tx_q_s <= x"1FFF";
          -- GMSK 2 Mb/s
          when "101" =>
            tx_i_s <= gmsk_tdata_s(31) & gmsk_tdata_s(31) & gmsk_tdata_s(31 downto 18);
            tx_q_s <= gmsk_tdata_s(15) & gmsk_tdata_s(15) & gmsk_tdata_s(15 downto  2);
          -- DMA cua PS (bo sung cho MSDR, tvsdr khong co)
          when "110" =>
            tx_i_s <= dac_dma_data_i0;
            tx_q_s <= dac_dma_data_q0;
          -- RF off
          when others =>
            tx_i_s <= (others => '0');
            tx_q_s <= (others => '0');
        end case;

        -- I_data_out / Q_data_out cua tvsdr: ban sao tre mot chu ky.
        tx_i_d1 <= tx_i_s;
        tx_q_d1 <= tx_q_s;

        -- Kiem tra lien tuc mau ramp. Chi co nghia khi nguon dang phat mau
        -- dem tang dan (duong Aurora hoac DMA voi mau thu); voi CW/DDS/GMSK
        -- thi co dinh '1' - dung nhu tvsdr, day chi la probe go roi.
        if (unsigned(tx_i_d1) + 1) /= unsigned(tx_i_s) then
          i_err_s <= '1';
        else
          i_err_s <= '0';
        end if;
        if (unsigned(tx_q_d1) + 1) /= unsigned(tx_q_s) then
          q_err_s <= '1';
        else
          q_err_s <= '0';
        end if;
      end if;
    end if;
  end process tx_mux;

  ---------------------------------------------------------------------------
  -- check_counter_process cua tvsdr: kiem tra dau ra deframer co tang deu 1
  ---------------------------------------------------------------------------
  check_counter_process : process (dac_clk)
  begin
    if rising_edge(dac_clk) then
      if Sample_IQout_valid_s = '1' then
        aurora_prev_s <= sample_IQout_data_s;
        if unsigned(sample_IQout_data_s) /= (unsigned(aurora_prev_s) + 1) then
          track_error_s <= '1';
        else
          track_error_s <= '0';
        end if;
      else
        track_error_s <= '0';
      end if;
    end if;
  end process check_counter_process;

  ---------------------------------------------------------------------------
  -- Probe go roi, dung dung bo probe cua ila_1 trong tvsdr_fpga.vhd
  ---------------------------------------------------------------------------
  tx_samp_ila : ila_1
    port map (
      clk       => dac_clk,
      probe0    => tx_i_d1,
      probe1    => tx_q_d1,
      probe2(0) => i_err_s,
      probe3(0) => q_err_s,
      probe4(0) => txfifo_full,
      probe5(0) => txfifo_empty
    );

  tx_i_err     <= i_err_s;
  tx_q_err     <= q_err_s;
  tx_track_err <= track_error_s;

  -- Kenh A cua dac_1 = TX1.
  dac_data_i0 <= tx_i_s;
  dac_data_q0 <= tx_q_s;
  -- Kenh B cua dac_1 = TX2, khong lai o day (TX2 di duong DMA qua dac_2).
  dac_data_i1 <= (others => '0');
  dac_data_q1 <= (others => '0');

  ---------------------------------------------------------------------------
  -- CDC metadata nhan duoc: aurora_clk -> init_clk
  -- Giong het tvsdr_rfu_trx: mot xpm_cdc_handshake cho moi truong, cung chung
  -- src_send = timestamp_valid va dest_req lam strobe hop le.
  ---------------------------------------------------------------------------
  timestamp_valid_cdc : xpm_cdc_pulse
    generic map (
      DEST_SYNC_FF   => 4,
      INIT_SYNC_FF   => 0,
      REG_OUTPUT     => 0,
      RST_USED       => 0,
      SIM_ASSERT_CHK => 0
    )
    port map (
      dest_pulse => timestamp_valid_sync,
      dest_clk   => init_clk,
      dest_rst   => '0',
      src_clk    => aurora_clk_s,
      src_pulse  => timestamp_valid_aur,
      src_rst    => '0'
    );

  Frame_Length_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 48)
    port map (src_clk => aurora_clk_s, src_in => Frame_Length_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Frame_Length_out,
              dest_req => open, dest_ack => '0');

  Tx_freq_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 48)
    port map (src_clk => aurora_clk_s, src_in => Tx_freq_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Tx_freq_out,
              dest_req => open, dest_ack => '0');

  Rx_freq_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 48)
    port map (src_clk => aurora_clk_s, src_in => Rx_freq_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Rx_freq_out,
              dest_req => open, dest_ack => '0');

  Next_Tx_Time_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 27)
    port map (src_clk => aurora_clk_s, src_in => Next_Frame_Transmit_Time_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Next_Frame_Transmit_Time_out,
              dest_req => open, dest_ack => '0');

  Power_Tx_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 8)
    port map (src_clk => aurora_clk_s, src_in => Power_Tx_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Power_Tx_out,
              dest_req => open, dest_ack => '0');

  Rx_bw_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 8)
    port map (src_clk => aurora_clk_s, src_in => Rx_bw_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Rx_bw_out,
              dest_req => open, dest_ack => '0');

  Tx_bw_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 8)
    port map (src_clk => aurora_clk_s, src_in => Tx_bw_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Tx_bw_out,
              dest_req => open, dest_ack => '0');

  Next_Rx_Time_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 27)
    port map (src_clk => aurora_clk_s, src_in => Next_Frame_Receive_Time_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Next_Frame_Receive_Time_out,
              dest_req => open, dest_ack => '0');

  Second_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 40)
    port map (src_clk => aurora_clk_s, src_in => Second_from_2000_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Second_from_2000_sync,
              dest_req => open, dest_ack => '0');

  Subsecond_cdc : xpm_cdc_handshake
    generic map (DEST_EXT_HSK => 0, DEST_SYNC_FF => 4, INIT_SYNC_FF => 0,
                 SIM_ASSERT_CHK => 0, SRC_SYNC_FF => 4, WIDTH => 27)
    port map (src_clk => aurora_clk_s, src_in => Subsecond_aur,
              src_send => timestamp_valid_aur, src_rcv => open,
              dest_clk => init_clk, dest_out => Subsecond_sync,
              dest_req => open, dest_ack => '0');

  Second_from_2000_out <= Second_from_2000_sync;
  Subsecond_out        <= Subsecond_sync;
  metadata_valid_out   <= timestamp_valid_sync;

  ---------------------------------------------------------------------------
  -- Dong bo thoi gian: 1PPS tu BBU + timestamp tu khung Aurora
  ---------------------------------------------------------------------------
  u_time_sync_top : entity work.time_sync_top
    generic map (
      CLK_HZ       => INIT_CLK_HZ,
      USEC_PER_SEC => USEC_PER_SEC
    )
    port map (
      clk          => init_clk,
      rst          => not init_rstn_s,
      cfg_mode     => ts_cfg_mode,
      pps_in       => pps_in,
      rx_ts_valid  => timestamp_valid_sync,
      rx_sec       => unsigned(Second_from_2000_sync),
      rx_usec      => unsigned(Subsecond_sync),
      ts_delay_cyc => unsigned(ts_delay_cyc),
      inc_nominal  => INC_NOMINAL_C,
      vcxo_ctrl_en => '0',          -- T12 chua dung vong dieu khien DCXO
      vcxo_ref_10m => ref_10m_in,
      dac_fb_code  => (others => '0'),
      dac_fb_valid => '0',
      sec_loc      => sec_loc_s,
      usec_loc     => usec_loc_s,
      run_state_out   => open,
      pps_ok_out      => open,
      ts_ok_out       => open,
      sync_locked_out => sync_locked_out,
      holdover_out    => open,
      offset_us_out    => offset_us_s,
      pps_error_us_out => pps_error_us_s,
      error_us_out     => error_us_s,
      inc_out          => inc_out_s,
      tick_us          => tick_us_s,
      dac_code_out     => open,
      dac_update_pulse => open
    );

  sec_loc_out  <= std_logic_vector(sec_loc_s);
  usec_loc_out <= std_logic_vector(usec_loc_s);
  tick_us_out  <= tick_us_s;

  ---------------------------------------------------------------------------
  -- Thanh ghi chi doc cho PS
  ---------------------------------------------------------------------------
  u_time_sync_axi_ro : entity work.time_sync_axi_ro
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awprot  => s_axi_awprot,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,
      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,
      s_axi_araddr  => s_axi_araddr,
      s_axi_arprot  => s_axi_arprot,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,
      sec_loc_i      => sec_loc_s,
      usec_loc_i     => usec_loc_s,
      offset_us_i    => offset_us_s,
      pps_error_us_i => pps_error_us_s,
      error_us_i     => error_us_s,
      inc_i          => inc_out_s,
      tick_us_i      => tick_us_s
    );

end architecture rtl;

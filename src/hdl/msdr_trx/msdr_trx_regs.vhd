----------------------------------------------------------------------------------
-- msdr_trx_regs
--
-- Mot cua so AXI4-Lite 4 kB de PS dieu khien phan TRX chuyen tu tvsdr_rfu_trx.
--
-- Tren TVSDR RFU cac gia tri nay do MicroBlaze ghi qua axi_gpio / BRAM trong
-- mb_bd_trx. MSDR khong co MicroBlaze nua, va dung sau sau IP axi_gpio cho tung
-- tu mot thi vua ton dia chi vua kho doc, nen gom het vao mot khoi thanh ghi.
--
-- Ban do thanh ghi (offset byte, tat ca 32 bit, little endian):
--
--   0x00  R   ID            = 0x4D534452 ("MSDR")
--   0x04  RW  CTRL          reset = 0x0000_0700 (tx_iq_source = RF off)
--                           [0]    enable_fsm
--                           [1]    cfg_reload
--                           [2]    trx_config
--                           [6:4]  ts_cfg_mode   000 AUTO .. 101 HOLDOVER
--                           [10:8] tx_iq_source  chon nguon IQ phat:
--                                    000 DDS hai tong   001 DDS mot song
--                                    010 Aurora (BBU)   011 CW 1/2
--                                    100 CW 1/8         101 GMSK 2 Mb/s
--                                    110 DMA cua PS     khac RF off
--                           [3]    dummy_frame   framer phat IQ = 0
--                           [7]    gpio_test
--   0x08  RW  TS_DELAY      [15:0] tre duong timestamp, don vi chu ky init_clk
--   0x0C  RW  GPIO0_MASK    [23:0] 1 = PS giu quyen bit do, 0 = FSM giu quyen
--   0x10  RW  GPIO1_MASK    [25:0] nhu tren cho tu dieu khien thu hai
--   0x14  RW  COMMAND1
--   0x18  RW  COMMAND2
--   0x1C  RW  COMMAND3
--   0x20  RW  COMMAND4
--   0x24  RW  COMMAND5
--   0x28  RW  TX_COMMAND
--   0x2C  R   AURORA_STATUS
--   0x30  R   TX_CARD_STATUS
--   0x34  R   SEC_LOC_LO    [31:0]  giay tu nam 2000, 32 bit thap
--   0x38  R   SEC_LOC_HI    [7:0]   giay, 8 bit cao
--                           [16]    sync_locked
--   0x3C  R   USEC_LOC      [26:0]
--   0x40  RC  EVENTS        [0] adc_ovf  [1] dac_unf  [2] metadata_valid
--                           [3] tx_i_err  [4] tx_q_err  [5] tx_track_err
--                           Bit dinh, ghi 1 de xoa. Ba bit kiem tra ramp chi
--                           co nghia khi nguon phat la mau dem tang dan.
--
-- Doc SEC_LOC_LO se chot ca bo ba SEC/USEC vao thanh ghi bong, nen doc theo thu
-- tu SEC_LOC_LO -> SEC_LOC_HI -> USEC_LOC luon duoc mot moc thoi gian nhat quan.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity msdr_trx_regs is
  generic (
    C_S_AXI_ADDR_WIDTH : integer := 12;
    C_S_AXI_DATA_WIDTH : integer := 32
  );
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    -- Dieu khien di ra
    enable_fsm    : out std_logic;
    cfg_reload    : out std_logic;
    trx_config    : out std_logic;
    tx_iq_source  : out std_logic_vector(2 downto 0);
    dummy_frame   : out std_logic;
    gpio_test     : out std_logic;
    ts_cfg_mode   : out std_logic_vector(2 downto 0);
    ts_delay_cyc  : out std_logic_vector(15 downto 0);
    gpio0_mask    : out std_logic_vector(31 downto 0);
    gpio1_mask    : out std_logic_vector(26 downto 0);
    command1      : out std_logic_vector(31 downto 0);
    command2      : out std_logic_vector(31 downto 0);
    command3      : out std_logic_vector(31 downto 0);
    command4      : out std_logic_vector(31 downto 0);
    command5      : out std_logic_vector(31 downto 0);
    tx_command    : out std_logic_vector(31 downto 0);

    -- Trang thai di vao
    aurora_status   : in  std_logic_vector(31 downto 0) := (others => '0');
    tx_card_status  : in  std_logic_vector(31 downto 0) := (others => '0');
    sec_loc         : in  std_logic_vector(39 downto 0) := (others => '0');
    usec_loc        : in  std_logic_vector(26 downto 0) := (others => '0');
    sync_locked     : in  std_logic := '0';
    adc_ovf         : in  std_logic := '0';
    dac_unf         : in  std_logic := '0';
    metadata_valid  : in  std_logic := '0';
    tx_i_err        : in  std_logic := '0';
    tx_q_err        : in  std_logic := '0';
    tx_track_err    : in  std_logic := '0'
  );
end entity msdr_trx_regs;

architecture rtl of msdr_trx_regs is

  constant ID_VALUE : std_logic_vector(31 downto 0) := x"4D534452";

  -- Chi 7 bit dia chi tu (offset 0x00..0x40 => 17 tu) duoc giai ma.
  subtype word_addr_t is natural range 0 to 31;

  -- Reset dua tx_iq_source ve 111 = RF off. Neu de 0 thi vua cap nguon la
  -- phat ngay tong DDS (ma 000) truoc khi phan mem kip noi gi.
  constant CTRL_RESET : std_logic_vector(31 downto 0) := x"00000700";

  signal ctrl_r      : std_logic_vector(31 downto 0) := CTRL_RESET;
  signal ts_delay_r  : std_logic_vector(31 downto 0) := (others => '0');
  signal gpio0_msk_r : std_logic_vector(31 downto 0) := (others => '1');
  signal gpio1_msk_r : std_logic_vector(31 downto 0) := (others => '1');
  signal cmd1_r      : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd2_r      : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd3_r      : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd4_r      : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd5_r      : std_logic_vector(31 downto 0) := (others => '0');
  signal txcmd_r     : std_logic_vector(31 downto 0) := (others => '0');
  signal events_r    : std_logic_vector(5 downto 0)  := (others => '0');

  -- Chot thoi gian: doc SEC_LOC_LO chot ca ba truong.
  signal sec_shadow  : std_logic_vector(39 downto 0) := (others => '0');
  signal usec_shadow : std_logic_vector(26 downto 0) := (others => '0');
  signal lock_shadow : std_logic := '0';

  -- Kenh ghi
  signal awready_r : std_logic := '0';
  signal wready_r  : std_logic := '0';
  signal bvalid_r  : std_logic := '0';
  signal awaddr_r  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal aw_held   : std_logic := '0';
  signal w_held    : std_logic := '0';
  signal wdata_r   : std_logic_vector(31 downto 0) := (others => '0');
  signal wstrb_r   : std_logic_vector(3 downto 0)  := (others => '0');

  -- Kenh doc
  signal arready_r : std_logic := '0';
  signal rvalid_r  : std_logic := '0';
  signal rdata_r   : std_logic_vector(31 downto 0) := (others => '0');

  function word_of (addr : std_logic_vector) return word_addr_t is
  begin
    -- Lay het bit dia chi co san tru hai bit thap (dia chi byte trong tu).
    -- Viet theo addr'high de khong phu thuoc C_S_AXI_ADDR_WIDTH.
    return to_integer(unsigned(addr(addr'high downto 2)));
  end function;

  function apply_strb (old_v, new_v : std_logic_vector(31 downto 0);
                       strb : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable r : std_logic_vector(31 downto 0);
  begin
    r := old_v;
    for b in 0 to 3 loop
      if strb(b) = '1' then
        r(b*8+7 downto b*8) := new_v(b*8+7 downto b*8);
      end if;
    end loop;
    return r;
  end function;

begin

  s_axi_awready <= awready_r;
  s_axi_wready  <= wready_r;
  s_axi_bvalid  <= bvalid_r;
  s_axi_bresp   <= "00";
  s_axi_arready <= arready_r;
  s_axi_rvalid  <= rvalid_r;
  s_axi_rdata   <= rdata_r;
  s_axi_rresp   <= "00";

  enable_fsm   <= ctrl_r(0);
  cfg_reload   <= ctrl_r(1);
  trx_config   <= ctrl_r(2);
  dummy_frame  <= ctrl_r(3);
  ts_cfg_mode  <= ctrl_r(6 downto 4);
  gpio_test    <= ctrl_r(7);
  tx_iq_source <= ctrl_r(10 downto 8);
  ts_delay_cyc <= ts_delay_r(15 downto 0);
  gpio0_mask   <= gpio0_msk_r(31 downto 0);
  gpio1_mask   <= gpio1_msk_r(26 downto 0);
  command1     <= cmd1_r;
  command2     <= cmd2_r;
  command3     <= cmd3_r;
  command4     <= cmd4_r;
  command5     <= cmd5_r;
  tx_command   <= txcmd_r;

  ---------------------------------------------------------------------------
  -- Kenh ghi
  ---------------------------------------------------------------------------
  write_proc : process (s_axi_aclk)
    variable do_write : boolean;
    variable w        : word_addr_t;
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        awready_r   <= '0';
        wready_r    <= '0';
        bvalid_r    <= '0';
        aw_held     <= '0';
        w_held      <= '0';
        ctrl_r      <= CTRL_RESET;
        ts_delay_r  <= (others => '0');
        gpio0_msk_r <= (others => '1');
        gpio1_msk_r <= (others => '1');
        cmd1_r      <= (others => '0');
        cmd2_r      <= (others => '0');
        cmd3_r      <= (others => '0');
        cmd4_r      <= (others => '0');
        cmd5_r      <= (others => '0');
        txcmd_r     <= (others => '0');
        events_r    <= (others => '0');
      else
        -- Bit su kien dinh lai cho den khi phan mem xoa.
        if adc_ovf = '1' then
          events_r(0) <= '1';
        end if;
        if dac_unf = '1' then
          events_r(1) <= '1';
        end if;
        if metadata_valid = '1' then
          events_r(2) <= '1';
        end if;
        if tx_i_err = '1' then
          events_r(3) <= '1';
        end if;
        if tx_q_err = '1' then
          events_r(4) <= '1';
        end if;
        if tx_track_err = '1' then
          events_r(5) <= '1';
        end if;

        awready_r <= '0';
        wready_r  <= '0';

        if bvalid_r = '1' and s_axi_bready = '1' then
          bvalid_r <= '0';
        end if;

        if aw_held = '0' and s_axi_awvalid = '1' and awready_r = '0' and bvalid_r = '0' then
          awaddr_r  <= s_axi_awaddr;
          aw_held   <= '1';
          awready_r <= '1';
        end if;

        if w_held = '0' and s_axi_wvalid = '1' and wready_r = '0' and bvalid_r = '0' then
          wdata_r  <= s_axi_wdata;
          wstrb_r  <= s_axi_wstrb;
          w_held   <= '1';
          wready_r <= '1';
        end if;

        do_write := (aw_held = '1' and w_held = '1' and bvalid_r = '0');
        if do_write then
          w := word_of(awaddr_r);
          case w is
            when 1  => ctrl_r      <= apply_strb(ctrl_r,      wdata_r, wstrb_r);
            when 2  => ts_delay_r  <= apply_strb(ts_delay_r,  wdata_r, wstrb_r);
            when 3  => gpio0_msk_r <= apply_strb(gpio0_msk_r, wdata_r, wstrb_r);
            when 4  => gpio1_msk_r <= apply_strb(gpio1_msk_r, wdata_r, wstrb_r);
            when 5  => cmd1_r      <= apply_strb(cmd1_r,      wdata_r, wstrb_r);
            when 6  => cmd2_r      <= apply_strb(cmd2_r,      wdata_r, wstrb_r);
            when 7  => cmd3_r      <= apply_strb(cmd3_r,      wdata_r, wstrb_r);
            when 8  => cmd4_r      <= apply_strb(cmd4_r,      wdata_r, wstrb_r);
            when 9  => cmd5_r      <= apply_strb(cmd5_r,      wdata_r, wstrb_r);
            when 10 => txcmd_r     <= apply_strb(txcmd_r,     wdata_r, wstrb_r);
            when 16 =>
              -- Ghi 1 de xoa, nhung su kien moi trong cung chu ky van thang.
              for b in events_r'range loop
                if wdata_r(b) = '1' then
                  events_r(b) <= '0';
                end if;
              end loop;
              if adc_ovf = '1' then
                events_r(0) <= '1';
              end if;
              if dac_unf = '1' then
                events_r(1) <= '1';
              end if;
              if metadata_valid = '1' then
                events_r(2) <= '1';
              end if;
              if tx_i_err = '1' then
                events_r(3) <= '1';
              end if;
              if tx_q_err = '1' then
                events_r(4) <= '1';
              end if;
              if tx_track_err = '1' then
                events_r(5) <= '1';
              end if;
            when others => null;
          end case;
          aw_held  <= '0';
          w_held   <= '0';
          bvalid_r <= '1';
        end if;
      end if;
    end if;
  end process write_proc;

  ---------------------------------------------------------------------------
  -- Kenh doc
  ---------------------------------------------------------------------------
  read_proc : process (s_axi_aclk)
    variable w : word_addr_t;
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        arready_r   <= '0';
        rvalid_r    <= '0';
        rdata_r     <= (others => '0');
        sec_shadow  <= (others => '0');
        usec_shadow <= (others => '0');
        lock_shadow <= '0';
      else
        arready_r <= '0';

        if rvalid_r = '1' and s_axi_rready = '1' then
          rvalid_r <= '0';
        end if;

        if s_axi_arvalid = '1' and arready_r = '0' and rvalid_r = '0' then
          arready_r <= '1';
          rvalid_r  <= '1';
          w := word_of(s_axi_araddr);
          case w is
            when 0  => rdata_r <= ID_VALUE;
            when 1  => rdata_r <= ctrl_r;
            when 2  => rdata_r <= ts_delay_r;
            when 3  => rdata_r <= gpio0_msk_r;
            when 4  => rdata_r <= gpio1_msk_r;
            when 5  => rdata_r <= cmd1_r;
            when 6  => rdata_r <= cmd2_r;
            when 7  => rdata_r <= cmd3_r;
            when 8  => rdata_r <= cmd4_r;
            when 9  => rdata_r <= cmd5_r;
            when 10 => rdata_r <= txcmd_r;
            when 11 => rdata_r <= aurora_status;
            when 12 => rdata_r <= tx_card_status;
            when 13 =>
              -- Chot bo ba thoi gian ngay tai day.
              sec_shadow  <= sec_loc;
              usec_shadow <= usec_loc;
              lock_shadow <= sync_locked;
              rdata_r     <= sec_loc(31 downto 0);
            when 14 =>
              rdata_r              <= (others => '0');
              rdata_r(7 downto 0)  <= sec_shadow(39 downto 32);
              rdata_r(16)          <= lock_shadow;
            when 15 =>
              rdata_r              <= (others => '0');
              rdata_r(26 downto 0) <= usec_shadow;
            when 16 =>
              rdata_r             <= (others => '0');
              rdata_r(5 downto 0) <= events_r;
            when others => rdata_r <= (others => '0');
          end case;
        end if;
      end if;
    end if;
  end process read_proc;

end architecture rtl;

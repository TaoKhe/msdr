----------------------------------------------------------------------------------
-- Module Name : vcsco_wrapper - rtl
-- Description : Timestamp + 1PPS VCSO disciplining wrapper.
--
--   Ties together:
--     * work.time_sync_top  (timestamp+PPS servo, VCXO/DAC control mode)
--     * work.spi_master     (SPI to the external AD5680 18-bit DAC)
--
--   The AD5680 drives the CVCSO-914-1000 control voltage. This wrapper:
--     1. Synchronizes the external 1PPS and runs time_sync_top; vcxo_ctrl_en
--        (runtime signal, from VIO at top) chooses digital-NCO ('0') or
--        analog DAC->VCSO ('1') discipline.
--        AUTO uses FULL_SYNC (timestamp + 1PPS) when both sources are alive and
--        degrades gracefully (PPS-only / TS-only / holdover / free-run) otherwise.
--        The Aurora RX timestamp arrives via rx_ts_valid/rx_sec/rx_usec, already
--        synchronized into this clk domain at the top level (no CDC here). The
--        10 MHz reference input remains disabled (vcxo_ref_10m = '0').
--     2. "Reads" the VCSO default voltage: the AD5680 is write-only and the board
--        has no MISO, so at boot the wrapper writes a known default code
--        (DAC_DEFAULT_CODE) and echoes that same code once into time_sync_top via
--        dac_fb_code/dac_fb_valid, aligning the servo's internal DAC register.
--     3. On every dac_update_pulse, writes dac_code_out to the AD5680 over SPI.
--
--   AD5680 24-bit frame (MSB-first, SYNC active-low): "0000" & code(17:0) & "00".
--   See ad5680_frame() below to adjust bit alignment if needed.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity vcsco_wrapper is
  generic (
    CLK_HZ             : integer := 100_000_000; -- clk frequency
    INC_NOMINAL        : integer := 0;           -- 0 = auto: round(2^NCO_PHASE_W * 1e6 / CLK_HZ)
    NCO_PHASE_W        : integer := 36;          -- NCO accumulator width (inc LSB ~3.6 ns/s @250MHz)
    FRAC_BITS          : integer := 8;           -- sub-us servo error resolution (1/2^8 us ~ 3.9 ns)
    USEC_PER_SEC       : integer := 1_000_000;   -- scale-down for fast simulation only (HW: 1e6)
    PPS_LATENCY_CYCLES : integer := 10;          -- pps pipeline delay compensated in pps_cap
                                                 -- (2 FF here + 2 FF sync + 5-tap debounce + edge reg)
    DAC_BITS           : integer := 18;          -- AD5680 resolution
    DAC_DEFAULT_CODE   : integer := 16#20000#;   -- VCSO center code (USER TO SET before bring-up)
    SPI_CLK_DIV        : integer := 5;           -- SCLK = CLK_HZ / (2*SPI_CLK_DIV)
    -- servo loop gains (passthrough to time_sync_top) -- exposed for HW tuning.
    -- Defaults retuned for the sub-us error domain (error in 1/2^8 us units,
    -- inc LSB ~3.6 ns/s): Kp_eff ~0.47/s, Ki_eff ~0.06/s^2 at 1 Hz PPS updates.
    KP_SHIFT           : integer := 1;           -- PI proportional: Kp = 2^-KP_SHIFT (AM = dich trai)
    KI_SHIFT           : integer := 4;           -- PI integral:    Ki = 2^-KI_SHIFT
    I_FRAC             : integer := 0;           -- bit le integrator PI: 0 = nhu cu, >= KI_SHIFT = het vung chet
    INC_TRIM_MAX       : integer := 0;           -- kep |i_term| theo LSB cua inc (anti-windup); 0 = tat
    FILT_SHIFT         : integer := 1;           -- combiner IIR: 1/2 smoothing (PPS is clean; deep
                                                 -- filtering would add loop lag at 1 Hz updates)
    DAC_GAIN_SHIFT     : integer := 10;          -- inc_delta -> code: delta/2^DAC_GAIN_SHIFT
    DAC_SLEW_MAX_STEP  : integer := 64;          -- max DAC code step per accepted update
    PPS_TIMEOUT_CYCLES : integer := 250000000;   -- pps_ok drop threshold (clk cycles)
    TS_TIMEOUT_CYCLES  : integer := 33333333     -- ts_ok drop threshold (clk cycles)
    );
  port (
    clk : in std_logic;                              -- 100 MHz init clock
    rst : in std_logic;                              -- active-high synchronous reset

    pps_in   : in std_logic;                         -- external 1PPS (async, synced internally)
    cfg_mode : in std_logic_vector(2 downto 0) := "000"; -- default AUTO (FULL_SYNC when PPS+TS alive)

    -- 20/10/2026: VCXO_CTRL_EN doi tu generic thanh tin hieu de doi che do luc
    -- chay qua VIO (khong phai build lai). Cung mien clk voi khoi nay (top noi
    -- tu vio_timesync/probe_out2, VIO chay sample_clk) nen khong can CDC.
    -- '0' = ky luat NCO so (DAC dong bang o ma cuoi; chay duoc ca khi duong
    --       DAC->VCSO hong). '1' = ky luat analog: NCO o nominal, servo lai
    --       AD5680 -> VCSO. Doi gia tri luc chay la hop le; nen doi khi
    --       cfg_mode = FORCE_FREE_RUN roi tra lai mode do de vong bat lai sach.
    vcxo_ctrl_en : in std_logic := '0';

    -- RX timestamp from the Aurora link (timestamp + 1PPS disciplining).
    -- These are ALREADY synchronized into this clk domain by the top-level
    -- xpm_cdc_handshake: {rx_sec, rx_usec} are a coherent atomic sample and
    -- rx_ts_valid is that handshake's dest_req, aligned to the data. Therefore
    -- NO further CDC is done here -- they are passed straight to time_sync_top.
    rx_ts_valid : in std_logic := '0';
    rx_sec      : in unsigned(39 downto 0) := (others => '0');
    rx_usec     : in unsigned(26 downto 0) := (others => '0');

    -- Bu do tre truyen CO DINH cua duong timestamp (framer -> GT TX -> soi ->
    -- GT RX -> deframer -> CDC), don vi CHU KY clk. Do duoc tren HW 2026-07-31:
    -- ts_off - pps_err = +720 ns khong doi o ca 4 cfg_mode => 180 chu ky @250 MHz.
    -- Quasi-static: dat luc chay qua VIO/thanh ghi. 0 = khong bu.
    ts_delay_cyc : in unsigned(15 downto 0) := (others => '0');

    -- AD5680 SPI (write-only)
    dac_vcso_din  : out std_logic;
    dac_vcso_sclk : out std_logic;
    dac_vcso_sync : out std_logic;                   -- active-low frame (ss_n)

    -- monitors
    sec_loc         : out unsigned(39 downto 0);
    usec_loc        : out unsigned(26 downto 0);
    run_state_out   : out std_logic_vector(2 downto 0);
    pps_ok_out      : out std_logic;
    -- ts_ok: nguon timestamp Aurora con song hay khong. THEM 2026-07-30: truoc day
    -- wrapper KHONG phoi ra tin hieu nay, nen khi AUTO khong vao FULL_SYNC (dieu kien
    -- la pps_ok AND ts_ok) thi khong the biet ben nao thieu.
    ts_ok_out       : out std_logic;
    sync_locked_out : out std_logic;
    holdover_out    : out std_logic;
    offset_us_out    : out signed(31 downto 0);
    pps_error_us_out : out signed(31 downto 0);
    error_us_out     : out signed(31 downto 0);
    inc_out          : out unsigned(31 downto 0);      -- effective NCO increment (for AXI-RO)
    tick_us          : out std_logic;                  -- 1-cycle local microsecond tick (for AXI-RO)
    dac_code_out    : out unsigned(DAC_BITS-1 downto 0); -- current DAC code command
    dac_update_o    : out std_logic;                   -- 1-cycle servo DAC-update pulse (debug)
    spi_busy        : out std_logic
    );
end entity;

architecture rtl of vcsco_wrapper is

  constant INC_WIDTH_C  : integer := 32;  -- matches time_sync_top INC_WIDTH default
  constant SPI_WORD_C   : integer := 24;  -- AD5680 frame length

  -- Nominal NCO increment: one local TICK per 2^NCO_PHASE_W/inc clk cycles ->
  -- inc_nominal = 2^NCO_PHASE_W * USEC_PER_SEC / CLK_HZ. Auto-computed from
  -- CLK_HZ unless the INC_NOMINAL generic overrides it (INC_NOMINAL /= 0).
  --   1 us  tick @250 MHz / 36-bit ->     274_877_907   (rate trim 1/inc = 3.64 ns/s)
  --   10 ns tick @250 MHz / 36-bit -> 27_487_790_694   <-- does NOT fit 32 bit!
  --   10 ns tick @250 MHz / 32-bit ->   1_717_986_918   (rate trim 1/inc = 0.58 ns/s)
  -- Rate-trim resolution is 1/inc, so the fix for a finer tick is to LOWER
  -- NCO_PHASE_W (keeping inc near 2^31), not to raise it.
  -- BUG FIX 2026-07-30: this used the literal 1.0e6 instead of USEC_PER_SEC, so
  -- changing the tick unit left the NCO running at the old rate (local time 100x
  -- too slow) with no compile error. time_sync_top zero-extends inc into the
  -- NCO_PHASE_W accumulator (inc_nco_s <= resize(inc_s, NCO_PHASE_WIDTH)), it does
  -- NOT shift, so this value must be scaled for the FULL accumulator width.
  function calc_inc_nominal return integer is
    variable inc_r : real;
  begin
    if INC_NOMINAL /= 0 then
      return INC_NOMINAL;
    end if;
    inc_r := (2.0 ** NCO_PHASE_W) * real(USEC_PER_SEC) / real(CLK_HZ);
    assert inc_r <= 2.0**31 - 1.0
      report "vcsco_wrapper: inc_nominal = " & real'image(inc_r) &
             " overflows INC_WIDTH_C=32. Lower NCO_PHASE_W (e.g. 36 -> 32 for a " &
             "10 ns tick at 250 MHz) or raise CLK_HZ."
      severity failure;
    return integer(round(inc_r));
  end function;

  -- refresh period for the periodic AD5680 re-write (~4 ms @ 250 MHz): keeps
  -- the DAC in a known state even if an update pulse is ever lost.
  constant DAC_REFRESH_CYCLES : integer := 2**20;

  -- build the 24-bit AD5680 write frame from an 18-bit code
  function ad5680_frame(code : unsigned(DAC_BITS-1 downto 0))
    return std_logic_vector is
  begin
    -- 4 leading bits, 18 data bits (MSB-first), 2 trailing bits
    return "0000" & std_logic_vector(code(17 downto 0)) & "00";
  end function;

  -- 1PPS synchronizer
  signal pps_meta_s : std_logic := '0';
  signal pps_sync_s : std_logic := '0';

  -- time_sync_top interface
  signal dac_code_s   : unsigned(DAC_BITS-1 downto 0);
  signal dac_upd_s    : std_logic;
  signal dac_fb_code_s  : unsigned(DAC_BITS-1 downto 0) := (others => '0');
  signal dac_fb_valid_s : std_logic := '0';
  signal sec_loc_s      : unsigned(39 downto 0);
  signal usec_loc_s     : unsigned(26 downto 0);

  constant INC_NOMINAL_C : unsigned(INC_WIDTH_C-1 downto 0) :=
    to_unsigned(calc_inc_nominal, INC_WIDTH_C);

  -- spi_master interface
  signal spi_en_s   : std_logic := '0';
  signal spi_tx_s   : std_logic_vector(SPI_WORD_C-1 downto 0) := (others => '0');
  signal spi_busy_s : std_logic;

  -- control FSM
  type state_t is (ST_BOOT, ST_LAUNCH, ST_WAIT_BUSY, ST_WAIT_DONE, ST_ECHO, ST_RUN);
  signal state_s   : state_t := ST_BOOT;
  signal code_lat_s : unsigned(DAC_BITS-1 downto 0) := to_unsigned(DAC_DEFAULT_CODE, DAC_BITS);
  signal req_s     : std_logic := '0';
  signal is_boot_s : std_logic := '1';

  signal refresh_cnt_s   : unsigned(20 downto 0) := (others => '0');
  signal dac_vcso_sclk_n : std_logic := '0';
  signal rst_n_s         : std_logic := '0';



  -- HW debug: observe the 1PPS input + the DAC/SPI actuator path so an ILA build can
  -- confirm (a) the onepps_in pin toggles and (b) the AD5680 is actually being written.
  attribute mark_debug : string;
  attribute mark_debug of pps_meta_s : signal is "true";
  attribute mark_debug of pps_sync_s : signal is "true";
  attribute mark_debug of dac_code_s : signal is "true";  -- code sent to AD5680
  attribute mark_debug of code_lat_s : signal is "true";  -- latched servo code
  attribute mark_debug of dac_upd_s  : signal is "true";  -- servo DAC-update pulse
  attribute mark_debug of spi_en_s   : signal is "true";  -- SPI transfer start
  attribute mark_debug of spi_busy_s : signal is "true";  -- SPI transfer active

begin

  assert DAC_BITS = 18
    report "vcsco_wrapper: ad5680_frame assumes DAC_BITS = 18"
    severity warning;

  ---------------------------------------------------------------------------
  -- 1PPS metastability synchronizer
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      pps_meta_s <= pps_in;
      pps_sync_s <= pps_meta_s;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- monitor outputs
  ---------------------------------------------------------------------------
  sec_loc      <= sec_loc_s;
  usec_loc     <= usec_loc_s;
  dac_code_out <= dac_code_s;
  dac_update_o <= dac_upd_s;
  spi_busy     <= spi_busy_s;

  ---------------------------------------------------------------------------
  -- core servo (PPS-only, VCXO/DAC control mode)
  ---------------------------------------------------------------------------
  u_time_sync_top : entity work.time_sync_top
    generic map (
      CLK_HZ             => CLK_HZ,
      USEC_PER_SEC       => USEC_PER_SEC,
      NCO_PHASE_WIDTH    => NCO_PHASE_W,
      FRAC_BITS          => FRAC_BITS,
      PPS_LATENCY_CYCLES => PPS_LATENCY_CYCLES,
      FILT_SHIFT         => FILT_SHIFT,
      DAC_BITS           => DAC_BITS,
      KP_SHIFT           => KP_SHIFT,
      KI_SHIFT           => KI_SHIFT,
      I_FRAC             => I_FRAC,
      INC_TRIM_MAX       => INC_TRIM_MAX,
      DAC_GAIN_SHIFT     => DAC_GAIN_SHIFT,
      DAC_SLEW_MAX_STEP  => DAC_SLEW_MAX_STEP,
      PPS_TIMEOUT_CYCLES => PPS_TIMEOUT_CYCLES,
      TS_TIMEOUT_CYCLES  => TS_TIMEOUT_CYCLES
      )
    port map (
      clk          => clk,
      rst          => rst,
      cfg_mode     => cfg_mode,
      pps_in       => pps_sync_s,

      -- timestamp path (timestamp + 1PPS sync): coherent RX timestamp from Aurora,
      -- already in this clk domain (synchronized at top level). AUTO mode combines it
      -- with the 1PPS reference and degrades gracefully if either source drops.
      rx_ts_valid  => rx_ts_valid,
      rx_sec       => rx_sec,
      rx_usec      => rx_usec,
      ts_delay_cyc => ts_delay_cyc,

      inc_nominal  => INC_NOMINAL_C,
      vcxo_ctrl_en => vcxo_ctrl_en,
      vcxo_ref_10m => '0',
      dac_fb_code  => dac_fb_code_s,
      dac_fb_valid => dac_fb_valid_s,

      sec_loc          => sec_loc_s,
      usec_loc         => usec_loc_s,
      run_state_out    => run_state_out,
      pps_ok_out       => pps_ok_out,
      ts_ok_out        => ts_ok_out,
      sync_locked_out  => sync_locked_out,
      holdover_out     => holdover_out,
      offset_us_out    => offset_us_out,
      pps_error_us_out => pps_error_us_out,
      error_us_out     => error_us_out,
      inc_out          => inc_out,
      tick_us          => tick_us,
      dac_code_out     => dac_code_s,
      dac_update_pulse => dac_upd_s
      );

  ---------------------------------------------------------------------------
  -- SPI master to AD5680 (event-driven via the control FSM below; a periodic
  -- refresh in the FSM re-writes the latest code every ~DAC_REFRESH_CYCLES so
  -- the DAC always converges to the servo state even if a pulse is missed)
  ---------------------------------------------------------------------------
  rst_n_s <= not rst;

  u_spi : entity work.spi_master
    generic map (
      DATA_WIDTH => SPI_WORD_C,
      CLK_DIV    => SPI_CLK_DIV
      )
    port map (
      clk      => clk,
      reset_n  => rst_n_s,
      enable   => spi_en_s,
      tx_data  => spi_tx_s,
      rx_data  => open,
      busy     => spi_busy_s,
      rx_valid => open,
      sclk     => dac_vcso_sclk_n,
      mosi     => dac_vcso_din,
      miso     => '0',
      ss_n     => dac_vcso_sync
      );

  -- forward SPI clock to the AD5680 pin (inverted: the DAC clocks data on its
  -- falling edge, which aligns with spi_master's rising edge where MOSI is stable)
  dac_vcso_sclk <= not dac_vcso_sclk_n;

  ---------------------------------------------------------------------------
  -- control FSM: boot-default write + echo, then per-update writes
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state_s        <= ST_BOOT;
        spi_en_s       <= '0';
        req_s          <= '0';
        is_boot_s      <= '1';
        dac_fb_valid_s <= '0';
        code_lat_s     <= to_unsigned(DAC_DEFAULT_CODE, DAC_BITS);
        refresh_cnt_s  <= (others => '0');
      else
        -- one-cycle defaults
        spi_en_s       <= '0';
        dac_fb_valid_s <= '0';

        -- periodic refresh: re-send the latest latched code so the AD5680
        -- always ends up at the servo state even if an update pulse is lost
        if refresh_cnt_s = to_unsigned(DAC_REFRESH_CYCLES-1, refresh_cnt_s'length) then
          refresh_cnt_s <= (others => '0');
          req_s         <= '1';
        else
          refresh_cnt_s <= refresh_cnt_s + 1;
        end if;

        case state_s is
          when ST_BOOT =>
            -- write the configured default code at startup
            spi_tx_s  <= ad5680_frame(to_unsigned(DAC_DEFAULT_CODE, DAC_BITS));
            is_boot_s <= '1';
            state_s   <= ST_LAUNCH;

          when ST_LAUNCH =>
            spi_en_s <= '1';            -- single-cycle start pulse
            state_s  <= ST_WAIT_BUSY;

          when ST_WAIT_BUSY =>
            if spi_busy_s = '1' then
              state_s <= ST_WAIT_DONE;
            end if;

          when ST_WAIT_DONE =>
            if spi_busy_s = '0' then
              if is_boot_s = '1' then
                state_s <= ST_ECHO;
              else
                state_s <= ST_RUN;
              end if;
            end if;

          when ST_ECHO =>
            -- one-shot echo of the written default into the servo
            dac_fb_code_s  <= to_unsigned(DAC_DEFAULT_CODE, DAC_BITS);
            dac_fb_valid_s <= '1';
            is_boot_s      <= '0';
            state_s        <= ST_RUN;

          when ST_RUN =>
            if req_s = '1' then
              spi_tx_s <= ad5680_frame(code_lat_s);
              req_s    <= '0';
              state_s  <= ST_LAUNCH;
            end if;

        end case;

        -- latch the newest servo update at all times; assigned last so a pulse
        -- coincident with the serving cycle is preserved (not dropped)
        if dac_upd_s = '1' then
          code_lat_s <= dac_code_s;
          req_s      <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;

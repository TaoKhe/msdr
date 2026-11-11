library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_sync_top is
  generic (
    SECOND_WIDTH            : integer := 40;       -- local time seconds counter width
    USEC_WIDTH              : integer := 27;       -- local time microseconds counter width
    ERR_WIDTH               : integer := 32;       -- signed error width for offset/pps/freq paths
    INC_WIDTH               : integer := 32;       -- control increment width (NCO/PI/trim/mapping domain)
    CLK_HZ                  : integer := 250000000;-- clk frequency (PPS latency compensation)
    -- Local-time TICKS per second = the unit of rx_usec / usec_loc / offsets.
    -- Protocol Rev M/N Subsecond unit is 10 ns => 100_000_000 (see the MBU's
    -- pps_generator SUBSEC_TICK_HZ; the two MUST match). 1_000_000 = the old 1 us.
    USEC_PER_SEC            : integer := 1000000;
    NCO_PHASE_WIDTH         : integer := 36;       -- NCO accumulator width (36 @250MHz -> ~3.6 ns/s per inc LSB)
    FRAC_BITS               : integer := 8;        -- sub-tick error resolution: 1/2^FRAC_BITS tick
    PPS_LATENCY_CYCLES      : integer := 8;        -- pps_in -> capture pipeline delay compensated in pps_cap
    FILT_SHIFT              : integer := 3;        -- combiner LPF strength (larger => smoother, slower)
    KP_SHIFT                : integer := 10;       -- PI proportional gain: Kp = 2^-KP_SHIFT (AM = dich trai)
    KI_SHIFT                : integer := 18;       -- PI integral gain: Ki = 2^-KI_SHIFT
    I_FRAC                  : integer := 0;        -- bit le cua integrator PI (xoa vung chet nhanh I)
    INC_TRIM_MAX            : integer := 0;        -- kep |i_term| theo LSB cua inc (anti-windup); 0 = tat
    -- hard-step threshold in TICKS (scaled to sub-tick internally). Default =
    -- USEC_PER_SEC = 1 second, so it stays 1 s whatever the tick unit is; it used
    -- to be the literal 1000000, which silently means 10 ms once a tick is 10 ns.
    STEP_THRESH             : integer := USEC_PER_SEC;

    -- source timeout thresholds in clk cycles
    PPS_TIMEOUT_CYCLES      : integer := 250000000; -- pps_ok drops after this many cycles without PPS sample
    TS_TIMEOUT_CYCLES       : integer :=  33333333; -- ts_ok drops after this many cycles without TS sample
    HOLDOVER_TIMEOUT_CYCLES : integer := 500000000; -- max holdover duration before forcing FREE_RUN

    -- VCXO / DAC actuator mapping
    DAC_BITS                : integer := 18;       -- DAC code width
    DAC_CODE_INIT           : integer := 131072;   -- reset/free-run fallback code
    DAC_CODE_CENTER         : integer := 131072;   -- zero-delta operating point code
    DAC_CODE_MIN            : integer := 0;        -- lower clamp limit for DAC code
    DAC_CODE_MAX            : integer := 262143;   -- upper clamp limit for DAC code
    DAC_GAIN_SHIFT          : integer := 10;       -- inc_delta to code scale: delta / 2^DAC_GAIN_SHIFT
    DAC_SLEW_MAX_STEP       : integer := 64;       -- max DAC code step per accepted update
    AD_UPDATE_MIN_CYCLES    : integer := 100000;   -- minimum gap between DAC updates in clk cycles

    -- VCXO frequency feedback from external reference (default: 10 MHz)
    VCXO_OUT_HZ                  : integer := 1000000000; -- actual VCXO output frequency before divider
    FREQ_FB_CLK_HZ               : integer := 250000000;  -- feedback clock frequency seen at clk input
    REF_CLK_HZ                   : integer := 10000000;   -- external reference clock frequency
    -- if 0, auto derive expected cycles/ref as FREQ_FB_CLK_HZ / REF_CLK_HZ
    FREQ_FB_EXPECTED_CLK_PER_REF : integer := 0;          -- override expected feedback cycles per ref period
    -- if 0, auto derive divider ratio as VCXO_OUT_HZ / FREQ_FB_CLK_HZ
    FREQ_FB_DIV_RATIO            : integer := 0;          -- override VCXO-to-feedback divider ratio
    FREQ_FB_WINDOW_REFS          : integer := 100000;     -- number of ref periods per freq-error sample
    FREQ_FB_TIMEOUT_CYCLES       : integer := 1000;       -- ref_ok drop threshold in clk cycles
    FREQ_ERR_INC_SHIFT           : integer := 10;         -- frequency-trim gain shift (left shift on error step)
    FREQ_TRIM_INC_MAX_ABS        : integer := 4194304     -- clamp limit for accumulated frequency trim
    );
  port (
    clk : in  std_logic; -- feedback clock domain (typically VCXO divided clock, e.g. 250 MHz)
    rst : in  std_logic; -- active-high synchronous reset

    -- config mode
    -- 000 : AUTO
    -- 001 : FORCE_FREE_RUN
    -- 010 : FORCE_PPS_ONLY
    -- 011 : FORCE_TS_ONLY
    -- 100 : FORCE_FULL_SYNC
    -- 101 : FORCE_HOLDOVER
    cfg_mode : in  std_logic_vector(2 downto 0); -- runtime mode select for state machine

    -- 1PPS input
    pps_in : in  std_logic; -- external 1PPS timing reference

    -- Timestamp from Aurora
    rx_ts_valid : in  std_logic;                          -- 1-clock strobe: incoming timestamp sample is valid
    rx_sec      : in  unsigned(SECOND_WIDTH-1 downto 0); -- timestamp seconds from link/aurora
    rx_usec     : in  unsigned(USEC_WIDTH-1 downto 0); -- timestamp microseconds from link/aurora

    -- Fixed transport delay of the timestamp path (framer -> GT -> deframer ->
    -- CDC) in CLK CYCLES; subtracted from the TS offset in ts_offset_calc.
    -- Quasi-static, runtime-settable. 0 = no compensation.
    ts_delay_cyc : in  unsigned(15 downto 0) := (others => '0');

    -- Nominal NCO increment
    inc_nominal  : in  unsigned(INC_WIDTH-1 downto 0); -- nominal local NCO increment baseline
    vcxo_ctrl_en : in  std_logic;                      -- '1': VCXO control mode, '0': pure NCO control mode
    vcxo_ref_10m : in  std_logic;                      -- external 10 MHz frequency reference for VCXO loop
    dac_fb_code  : in  unsigned(DAC_BITS-1 downto 0);   -- DAC code read back from external DAC register
    dac_fb_valid : in  std_logic;                        -- 1-clock strobe: dac_fb_code is valid

    -- Local time output
    sec_loc  : out unsigned(SECOND_WIDTH-1 downto 0); -- local time seconds
    usec_loc : out unsigned(USEC_WIDTH-1 downto 0);   -- local time microseconds

    -- State / monitor
    run_state_out   : out std_logic_vector(2 downto 0); -- current runtime state encoding
    pps_ok_out      : out std_logic;                    -- PPS source alive flag from timeout monitor
    ts_ok_out       : out std_logic;                    -- timestamp source alive flag from timeout monitor
    sync_locked_out : out std_logic;                    -- high in sync states (PPS_ONLY/TS_ONLY/FULL_SYNC)
    holdover_out    : out std_logic;                    -- high when state is HOLDOVER

    -- Debug/monitor
    offset_us_out    : out signed(ERR_WIDTH-1 downto 0);   -- raw TS offset error in MICROSECONDS
    pps_error_us_out : out signed(ERR_WIDTH-1 downto 0);   -- raw PPS error in SUB-US units (1/2^FRAC_BITS us)
    error_us_out     : out signed(ERR_WIDTH-1 downto 0);   -- combined/filtered servo error, SUB-US units
    inc_out          : out unsigned(INC_WIDTH-1 downto 0); -- effective increment applied to local NCO
    tick_us          : out std_logic;                      -- 1-clock pulse per generated local microsecond

    -- VCXO DAC command to external SPI/DAC block
    dac_code_out     : out unsigned(DAC_BITS-1 downto 0); -- DAC code command for external SPI/DAC block
    dac_update_pulse : out std_logic                       -- 1-clock valid pulse for dac_code_out
    );
end entity;

architecture rtl of time_sync_top is

  ---------------------------------------------------------------------------
  -- mode encoding
  ---------------------------------------------------------------------------
  constant CFG_AUTO           : std_logic_vector(2 downto 0) := "000";
  constant CFG_FORCE_FREE_RUN : std_logic_vector(2 downto 0) := "001";
  constant CFG_FORCE_PPS_ONLY : std_logic_vector(2 downto 0) := "010";
  constant CFG_FORCE_TS_ONLY  : std_logic_vector(2 downto 0) := "011";
  constant CFG_FORCE_FULLSYNC : std_logic_vector(2 downto 0) := "100";
  constant CFG_FORCE_HOLDOVER : std_logic_vector(2 downto 0) := "101";

  ---------------------------------------------------------------------------
  -- runtime state encoding
  ---------------------------------------------------------------------------
  constant ST_FREE_RUN  : std_logic_vector(2 downto 0) := "000";
  constant ST_PPS_ONLY  : std_logic_vector(2 downto 0) := "001";
  constant ST_TS_ONLY   : std_logic_vector(2 downto 0) := "010";
  constant ST_FULL_SYNC : std_logic_vector(2 downto 0) := "011";
  constant ST_HOLDOVER  : std_logic_vector(2 downto 0) := "100";

  constant CNT_WIDTH : integer := 32;
  function pick_expected_clk_per_ref(
    expected_override : integer;
    fb_clk_hz_i       : integer;
    ref_clk_hz_i      : integer
    ) return integer is
  begin
    if expected_override > 0 then
      return expected_override;
    elsif ref_clk_hz_i > 0 then
      return fb_clk_hz_i / ref_clk_hz_i;
    else
      return 1;
    end if;
  end function;

  function pick_fb_div_ratio(
    div_override  : integer;
    vcxo_out_hz_i : integer;
    fb_clk_hz_i   : integer
    ) return integer is
  begin
    if div_override > 0 then
      return div_override;
    elsif fb_clk_hz_i > 0 then
      if vcxo_out_hz_i / fb_clk_hz_i > 0 then
        return vcxo_out_hz_i / fb_clk_hz_i;
      else
        return 1;
      end if;
    else
      return 1;
    end if;
  end function;

  constant FREQ_FB_EXPECTED_CLK_PER_REF_C : integer :=
    pick_expected_clk_per_ref(
      FREQ_FB_EXPECTED_CLK_PER_REF,
      FREQ_FB_CLK_HZ,
      REF_CLK_HZ);
  constant FREQ_FB_DIV_RATIO_C : integer :=
    pick_fb_div_ratio(
      FREQ_FB_DIV_RATIO,
      VCXO_OUT_HZ,
      FREQ_FB_CLK_HZ);

  constant TRIM_MAX_S : signed(INC_WIDTH-1 downto 0) :=
    to_signed(FREQ_TRIM_INC_MAX_ABS, INC_WIDTH);
  constant TRIM_MIN_S : signed(INC_WIDTH-1 downto 0) :=
    to_signed(-FREQ_TRIM_INC_MAX_ABS, INC_WIDTH);

  ---------------------------------------------------------------------------
  -- Sub-tick error domain.
  -- All servo errors are expressed in units of 1/2^FRAC_BITS of one tick. The PPS
  -- path measures natively at this resolution (NCO fractional phase); the TS offset
  -- path (integer ticks) is scaled up by 2^FRAC_BITS before entering the combiner.
  -- This removes the one-tick quantization floor of the discipline loop.
  --   1 us tick,  FRAC_BITS=8 -> 3.906 ns/LSB, STEP_THRESH_SUB = 1e6*256  = 2.56e8
  --   10 ns tick, FRAC_BITS=1 -> 5.000 ns/LSB, STEP_THRESH_SUB = 1e8*2    = 2.00e8
  -- The PI gains (KP_SHIFT/KI_SHIFT) are tuned for a given ns/LSB, so pick
  -- FRAC_BITS to keep ns/LSB roughly unchanged when the tick unit changes -- and
  -- keep STEP_THRESH_SUB inside a 32-bit signed (FRAC_BITS <= 4 at a 10 ns tick).
  ---------------------------------------------------------------------------
  -- NOTE: an overflow here is caught by the tool at elaboration (static expression
  -- outside INTEGER'range), not at run time -- no assert can help.
  constant STEP_THRESH_SUB : integer := STEP_THRESH * (2**FRAC_BITS);

  ---------------------------------------------------------------------------
  -- local time
  ---------------------------------------------------------------------------
  signal sec_loc_s  : unsigned(SECOND_WIDTH-1 downto 0);
  signal usec_loc_s : unsigned(USEC_WIDTH-1 downto 0);
  signal frac_us_s  : unsigned(FRAC_BITS-1 downto 0);   -- sub-us NCO phase

  -- one-time absolute NCO load (coarse phase alignment to the RX timestamp)
  signal ts_loaded   : std_logic := '0';
  signal load_req_s  : std_logic := '0';
  signal load_sec_s  : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal load_usec_s : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');

  -- absolute-seconds mismatch guard: if the TS offset stays beyond +/-0.5 s for
  -- several consecutive samples while the TS source is alive, the local seconds
  -- counter no longer matches the link time (e.g. missed initial load or a long
  -- holdover). Re-arm the one-time load so the next TS sample re-aligns.
  signal sec_mism_cnt_s : unsigned(3 downto 0) := (others => '0');

  -- PPS gross-error jam guard (fix 19/10/2026). Doi xung voi guard TS o tren
  -- nhung cho duong 1PPS: khi |pps_error| >= OUTLIER_THRESH_SUB tren 16 canh
  -- PPS lien tiep, phat mot lenh hard-step NCO bang dung sai so do duoc.
  -- Vi sao can: voi nguon PPS doc lap (GPS), pha giay cuc bo (da nap tu
  -- timestamp MBU) lech canh GPS mot gia tri tuy y trong +-0.5 s. Roi vao
  -- 0.2..0.5 s thi cong loc outlier chan moi mau, hard-step cua servo can
  -- > STEP_THRESH (1 s) khong bao gio toi, va guard TS khong kich vi
  -- offset_us van nho -> he nam im vinh vien du pps_ok=1 (do tren HW
  -- 19/10/2026: GPS -417 ms, dac_code dung yen o 0x20000 suot 357 s).
  -- Jam di vao bo dem NCO (khong dung DAC) nen hoat dong giong nhau o ca
  -- che do so lan analog; 16 canh lien tiep giu triet ly chong mau rach.
  signal pps_mism_cnt_s : unsigned(3 downto 0) := (others => '0');
  signal pps_jam_req_s  : std_logic := '0';
  signal pps_jam_off_s  : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  -- step vao NCO = step cua servo (qua mux che do) OR jam cua guard PPS
  signal step_req_nco_s : std_logic;
  signal step_off_nco_s : signed(ERR_WIDTH-1 downto 0);

  ---------------------------------------------------------------------------
  -- ts offset block
  ---------------------------------------------------------------------------
  signal offset_valid_s : std_logic;
  signal offset_us_s    : signed(ERR_WIDTH-1 downto 0);

  ---------------------------------------------------------------------------
  -- pps cap block
  ---------------------------------------------------------------------------
  signal pps_valid_s    : std_logic;
  signal pps_error_us_s : signed(ERR_WIDTH-1 downto 0);

  -- Outlier rejection for the servo error sources. The MBU samples its {Second, Subsecond}
  -- timestamp RAW across a sample_clk -> aurora_clk CDC, so it can TEAR at a second boundary
  -- and emit one wildly wrong frame timestamp. Decoded faithfully by the RFU, that becomes a
  -- huge offset spike which the combiner's IIR then smears across ~8 samples, corrupting the
  -- servo error and stalling the discipline. Drop any source sample whose magnitude exceeds
  -- OUTLIER_THRESH_US (locked-mode offset/pps error is normally << ms, garbage spikes are seconds).
  -- Derived from USEC_PER_SEC so it stays 0.2 s in ANY tick unit; it used to be the
  -- literal 200_000, which is 0.2 s only while a tick was 1 us (2 ms at a 10 ns tick,
  -- i.e. the rejector would have thrown away every legitimate sample after startup).
  constant OUTLIER_THRESH_US  : integer := USEC_PER_SEC / 5;  -- 0.2 s, TS offset path (ticks)
  constant OUTLIER_THRESH_SUB : integer := (USEC_PER_SEC / 5) * (2**FRAC_BITS); -- PPS path, sub-ticks
  signal offset_valid_clean  : std_logic;
  signal offset_sub_s        : signed(ERR_WIDTH-1 downto 0); -- TS offset scaled to sub-us units
  signal pps_valid_clean     : std_logic;
  signal sec_at_pps_s   : unsigned(SECOND_WIDTH-1 downto 0);
  signal usec_at_pps_s  : unsigned(USEC_WIDTH-1 downto 0);

  ---------------------------------------------------------------------------
  -- combiner/filter
  ---------------------------------------------------------------------------
  signal error_valid_raw_s : std_logic;
  signal error_us_raw_s    : signed(ERR_WIDTH-1 downto 0);
  signal clear_filter_s    : std_logic;

  ---------------------------------------------------------------------------
  -- servo
  ---------------------------------------------------------------------------
  signal inc_cmd_s         : unsigned(INC_WIDTH-1 downto 0) := (others => '0');
  signal step_req_raw_s    : std_logic := '0';
  signal step_offset_raw_s : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal clear_servo_s     : std_logic;
  signal hold_servo_s      : std_logic;
  signal i_freeze_s        : std_logic;

  ---------------------------------------------------------------------------
  -- applied to NCO
  ---------------------------------------------------------------------------
  signal inc_s            : unsigned(INC_WIDTH-1 downto 0) := (others => '0');
  signal inc_nco_s        : unsigned(NCO_PHASE_WIDTH-1 downto 0) := (others => '0');
  signal step_req_s       : std_logic := '0';
  signal step_offset_us_s : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal inc_hold_s       : unsigned(INC_WIDTH-1 downto 0) := (others => '0');

  signal tick_us_s : std_logic;

  ---------------------------------------------------------------------------
  -- VCXO/DAC control
  ---------------------------------------------------------------------------
  signal dac_code_s           : unsigned(DAC_BITS-1 downto 0);
  signal dac_sat_hi_s         : std_logic;
  signal dac_sat_lo_s         : std_logic;
  signal dac_force_init_s     : std_logic;
  signal dac_hold_code_s      : std_logic;
  signal dac_enable_update_s  : std_logic;
  signal dac_update_cnt_s     : unsigned(CNT_WIDTH-1 downto 0) :=
    to_unsigned(AD_UPDATE_MIN_CYCLES, CNT_WIDTH);
  signal dac_update_event_s   : std_logic;
  signal ad_wr_req_s          : std_logic;
  signal dac_map_ready_s      : std_logic;
  signal dac_map_done_s       : std_logic;

  signal freq_err_valid_s     : std_logic;
  signal freq_err_cycles_s    : signed(ERR_WIDTH-1 downto 0);
  signal freq_ref_ok_s        : std_logic;
  signal freq_fb_active_s     : std_logic;
  signal freq_trim_inc_s      : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal freq_step_valid_s    : std_logic := '0';
  signal freq_step_s          : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal inc_cmd_dac_s        : unsigned(INC_WIDTH-1 downto 0);

  ---------------------------------------------------------------------------
  -- source presence
  ---------------------------------------------------------------------------
  signal pps_seen_cnt_s : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
  signal ts_seen_cnt_s  : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');

  signal pps_ok_s : std_logic;
  signal ts_ok_s  : std_logic;

  ---------------------------------------------------------------------------
  -- holdover
  ---------------------------------------------------------------------------
  signal holdover_cnt_s       : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
  signal holdover_expired_s   : std_logic;

  ---------------------------------------------------------------------------
  -- state
  ---------------------------------------------------------------------------
  signal desired_state_s : std_logic_vector(2 downto 0) := ST_FREE_RUN;
  signal run_state_s     : std_logic_vector(2 downto 0) := ST_FREE_RUN;
  signal ever_locked_s   : std_logic := '0';

  ---------------------------------------------------------------------------
  -- control
  ---------------------------------------------------------------------------
  signal use_offset_s   : std_logic;
  signal use_pps_s      : std_logic;
  signal servo_enable_s : std_logic;
  signal allow_step_s   : std_logic;
  signal holdover_s     : std_logic;
  signal sync_active_s  : std_logic;

  ---------------------------------------------------------------------------
  -- HW debug: mark the before/after signals of error_combiner_filter and
  -- time_servo_pi so Vivado's "Set Up Debug" auto-inserts an ILA on them.
  --   * combiner inputs  : offset_us_s/offset_valid_s, pps_error_us_s/pps_valid_s
  --   * combiner output  : error_us_raw_s/error_valid_raw_s  (= servo input)
  --   * servo outputs    : inc_cmd_s, step_req_raw_s, step_offset_raw_s
  -- plus the gating controls that explain why a sample was/was not taken.
  ---------------------------------------------------------------------------
  attribute mark_debug : string;
  attribute mark_debug of offset_us_s       : signal is "true";
  attribute mark_debug of offset_valid_s    : signal is "true";
  attribute mark_debug of pps_error_us_s    : signal is "true";
  attribute mark_debug of pps_valid_s       : signal is "true";
  attribute mark_debug of use_offset_s      : signal is "true";
  attribute mark_debug of use_pps_s         : signal is "true";
  attribute mark_debug of error_us_raw_s    : signal is "true";
  attribute mark_debug of error_valid_raw_s : signal is "true";
  attribute mark_debug of servo_enable_s    : signal is "true";
  attribute mark_debug of allow_step_s      : signal is "true";
  attribute mark_debug of i_freeze_s        : signal is "true";
  attribute mark_debug of inc_cmd_s         : signal is "true";
  attribute mark_debug of step_req_raw_s    : signal is "true";
  attribute mark_debug of step_offset_raw_s : signal is "true";
  -- local NCO (local_time_nco) tuning verification: the increment actually applied
  -- to the NCO and its time outputs/tick. These are functional nets (real loads) so
  -- the probes survive synthesis reliably.
  attribute mark_debug of inc_s             : signal is "true";  -- increment applied to NCO
  attribute mark_debug of sec_loc_s         : signal is "true";  -- local seconds
  attribute mark_debug of usec_loc_s        : signal is "true";  -- local microseconds
  attribute mark_debug of tick_us_s         : signal is "true";  -- 1-cycle per local microsecond

begin

  assert REF_CLK_HZ > 0
    report "REF_CLK_HZ must be > 0"
    severity failure;
  assert FREQ_FB_EXPECTED_CLK_PER_REF_C > 0
    report "Expected clk-per-ref must be > 0"
    severity failure;
  assert FREQ_FB_DIV_RATIO_C > 0
    report "Feedback divider ratio must be > 0"
    severity failure;

  ---------------------------------------------------------------------------
  -- outputs
  ---------------------------------------------------------------------------
  sec_loc          <= sec_loc_s;
  usec_loc         <= usec_loc_s;

  run_state_out    <= run_state_s;
  pps_ok_out       <= pps_ok_s;
  ts_ok_out        <= ts_ok_s;
  sync_locked_out  <= sync_active_s;
  holdover_out     <= holdover_s;

  offset_us_out    <= offset_us_s;
  pps_error_us_out <= pps_error_us_s;
  error_us_out     <= error_us_raw_s;
  inc_out          <= inc_s;
  tick_us          <= tick_us_s;
  dac_code_out     <= dac_code_s;
  dac_update_pulse <= dac_map_done_s;

  ---------------------------------------------------------------------------
  -- source presence counters
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pps_seen_cnt_s <= (others => '1');
        ts_seen_cnt_s  <= (others => '1');
      else
        if pps_valid_s = '1' then
          pps_seen_cnt_s <= (others => '0');
        elsif pps_seen_cnt_s < to_unsigned(PPS_TIMEOUT_CYCLES, CNT_WIDTH) then
          pps_seen_cnt_s <= pps_seen_cnt_s + 1;
        end if;

        if offset_valid_s = '1' then
          ts_seen_cnt_s <= (others => '0');
        elsif ts_seen_cnt_s < to_unsigned(TS_TIMEOUT_CYCLES, CNT_WIDTH) then
          ts_seen_cnt_s <= ts_seen_cnt_s + 1;
        end if;
      end if;
    end if;
  end process;

  pps_ok_s <= '1' when pps_seen_cnt_s < to_unsigned(PPS_TIMEOUT_CYCLES, CNT_WIDTH) else '0';
  ts_ok_s  <= '1' when ts_seen_cnt_s  < to_unsigned(TS_TIMEOUT_CYCLES,  CNT_WIDTH) else '0';

  ---------------------------------------------------------------------------
  -- desired state decode
  ---------------------------------------------------------------------------
  process(cfg_mode, pps_ok_s, ts_ok_s, ever_locked_s, holdover_expired_s)
  begin
    desired_state_s <= ST_FREE_RUN;

    case cfg_mode is
      when CFG_AUTO =>
        if    (pps_ok_s = '1') and (ts_ok_s = '1') then
          desired_state_s <= ST_FULL_SYNC;
        elsif (pps_ok_s = '1') then
          desired_state_s <= ST_PPS_ONLY;
        elsif (ts_ok_s = '1') then
          desired_state_s <= ST_TS_ONLY;
        else
          if (ever_locked_s = '1') and (holdover_expired_s = '0') then
            desired_state_s <= ST_HOLDOVER;
          else
            desired_state_s <= ST_FREE_RUN;
          end if;
        end if;

      when CFG_FORCE_FREE_RUN =>
        desired_state_s <= ST_FREE_RUN;

      when CFG_FORCE_PPS_ONLY =>
        if (pps_ok_s = '1') then
          desired_state_s <= ST_PPS_ONLY;
        else
          if (ever_locked_s = '1') and (holdover_expired_s = '0') then
            desired_state_s <= ST_HOLDOVER;
          else
            desired_state_s <= ST_FREE_RUN;
          end if;
        end if;

      when CFG_FORCE_TS_ONLY =>
        if (ts_ok_s = '1') then
          desired_state_s <= ST_TS_ONLY;
        else
          if (ever_locked_s = '1') and (holdover_expired_s = '0') then
            desired_state_s <= ST_HOLDOVER;
          else
            desired_state_s <= ST_FREE_RUN;
          end if;
        end if;

      when CFG_FORCE_FULLSYNC =>
        if (pps_ok_s = '1') and (ts_ok_s = '1') then
          desired_state_s <= ST_FULL_SYNC;
        else
          if (ever_locked_s = '1') and (holdover_expired_s = '0') then
            desired_state_s <= ST_HOLDOVER;
          else
            desired_state_s <= ST_FREE_RUN;
          end if;
        end if;

      when CFG_FORCE_HOLDOVER =>
        if (holdover_expired_s = '0') and (ever_locked_s = '1') then
          desired_state_s <= ST_HOLDOVER;
        else
          desired_state_s <= ST_FREE_RUN;
        end if;

      when others =>
        desired_state_s <= ST_FREE_RUN;
    end case;
  end process;

  ---------------------------------------------------------------------------
  -- runtime state reg
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        run_state_s <= ST_FREE_RUN;
      else
        run_state_s <= desired_state_s;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- sync / ever_locked
  ---------------------------------------------------------------------------
  sync_active_s <= '1' when
                   (run_state_s = ST_PPS_ONLY) or
                   (run_state_s = ST_TS_ONLY)  or
                   (run_state_s = ST_FULL_SYNC)
                   else '0';

  holdover_s <= '1' when run_state_s = ST_HOLDOVER else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ever_locked_s <= '0';
      else
        if sync_active_s = '1' then
          ever_locked_s <= '1';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- holdover timeout
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        holdover_cnt_s <= (others => '0');
      else
        if run_state_s = ST_HOLDOVER then
          if holdover_cnt_s < to_unsigned(HOLDOVER_TIMEOUT_CYCLES, CNT_WIDTH) then
            holdover_cnt_s <= holdover_cnt_s + 1;
          end if;
        else
          holdover_cnt_s <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  holdover_expired_s <= '1' when holdover_cnt_s >= to_unsigned(HOLDOVER_TIMEOUT_CYCLES, CNT_WIDTH) else '0';

  ---------------------------------------------------------------------------
  -- control from state
  --
  -- FULL_SYNC uses the PPS error ONLY for the fine servo: the TS offset carries
  -- the Aurora link latency (~ms-scale bias), so blending it into the loop
  -- would wreck sub-100ns phase accuracy. The timestamp path still provides
  -- absolute seconds (one-time load + mismatch guard) and the TS_ONLY fallback.
  ---------------------------------------------------------------------------
  use_offset_s <= '1' when
                  (run_state_s = ST_TS_ONLY)
                  else '0';

  use_pps_s <= '1' when
               (run_state_s = ST_PPS_ONLY) or
               (run_state_s = ST_FULL_SYNC)
               else '0';

  servo_enable_s <= '1' when
                    (run_state_s = ST_PPS_ONLY) or
                    (run_state_s = ST_TS_ONLY)  or
                    (run_state_s = ST_FULL_SYNC)
                    else '0';

  allow_step_s <= '1' when
                  (run_state_s = ST_PPS_ONLY) or
                  (run_state_s = ST_TS_ONLY)  or
                  (run_state_s = ST_FULL_SYNC)
                  else '0';

  ---------------------------------------------------------------------------
  -- VCXO/DAC control policy
  ---------------------------------------------------------------------------
  freq_fb_active_s <= '1' when
                      (vcxo_ctrl_en = '1') and
                      (freq_ref_ok_s = '1')
                      else '0';

  dac_force_init_s <= '1' when
                      (vcxo_ctrl_en = '1') and
                      (run_state_s = ST_FREE_RUN) and
                      (freq_fb_active_s = '0')
                      else '0';

  dac_hold_code_s <= '1' when
                     (vcxo_ctrl_en = '0') or
                     ((sync_active_s = '0') and (freq_fb_active_s = '0'))
                     else '0';

  dac_update_event_s <= '1' when
                        ((sync_active_s = '1') and (error_valid_raw_s = '1')) or
                        ((freq_fb_active_s = '1') and (freq_err_valid_s = '1'))
                        else '0';

  ad_wr_req_s <= '1' when
                 (vcxo_ctrl_en = '1') and
                 (dac_update_event_s = '1') and
                 (dac_map_ready_s = '1') and
                 (dac_update_cnt_s >= to_unsigned(AD_UPDATE_MIN_CYCLES, CNT_WIDTH))
                 else '0';

  dac_enable_update_s <= ad_wr_req_s;

  i_freeze_s <= '1' when
                (vcxo_ctrl_en = '1') and
                (
                ((dac_sat_hi_s = '1') and (error_us_raw_s < to_signed(0, ERR_WIDTH))) or
                ((dac_sat_lo_s = '1') and (error_us_raw_s > to_signed(0, ERR_WIDTH)))
                )
                else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dac_update_cnt_s <= to_unsigned(AD_UPDATE_MIN_CYCLES, CNT_WIDTH);
      else
        if (vcxo_ctrl_en = '0') or
          ((sync_active_s = '0') and (freq_fb_active_s = '0')) then
          dac_update_cnt_s <= to_unsigned(AD_UPDATE_MIN_CYCLES, CNT_WIDTH);
        elsif ad_wr_req_s = '1' then
          dac_update_cnt_s <= (others => '0');
        elsif dac_update_cnt_s < to_unsigned(AD_UPDATE_MIN_CYCLES, CNT_WIDTH) then
          dac_update_cnt_s <= dac_update_cnt_s + 1;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- frequency trim from 10 MHz reference feedback (pipelined for timing)
  -- stage-1: scale/clamp freq_err -> freq_step
  -- stage-2: accumulate freq_trim -= freq_step
  ---------------------------------------------------------------------------
  process(clk)
    variable step_v : signed(INC_WIDTH-1 downto 0);
    variable step_ext_v : signed(INC_WIDTH+16-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        freq_step_valid_s <= '0';
        freq_step_s       <= (others => '0');
      else
        freq_step_valid_s <= '0';

        if (vcxo_ctrl_en = '0') or (freq_fb_active_s = '0') then
          freq_step_valid_s <= '0';
          freq_step_s       <= (others => '0');
        elsif freq_err_valid_s = '1' then
          -- Scale frequency error back to VCXO domain when feedback is divided.
          -- Example: VCXO=1G, feedback clk=250M -> ratio=4.
          step_ext_v := resize(freq_err_cycles_s, INC_WIDTH+16);
          if FREQ_FB_DIV_RATIO_C > 1 then
            step_ext_v := resize(
              step_ext_v * to_signed(FREQ_FB_DIV_RATIO_C, INC_WIDTH+16),
              INC_WIDTH+16);
          end if;

          if FREQ_ERR_INC_SHIFT > 0 then
            step_ext_v := shift_left(step_ext_v, FREQ_ERR_INC_SHIFT);
          end if;

          if step_ext_v > resize(TRIM_MAX_S, INC_WIDTH+16) then
            step_v := TRIM_MAX_S;
          elsif step_ext_v < resize(TRIM_MIN_S, INC_WIDTH+16) then
            step_v := TRIM_MIN_S;
          else
            step_v := resize(step_ext_v, INC_WIDTH);
          end if;

          freq_step_valid_s <= '1';
          freq_step_s       <= step_v;
        end if;
      end if;
    end if;
  end process;

  process(clk)
    variable next_v : signed(INC_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        freq_trim_inc_s <= (others => '0');
      else
        if (vcxo_ctrl_en = '0') or (freq_fb_active_s = '0') then
          freq_trim_inc_s <= (others => '0');
        elsif freq_step_valid_s = '1' then
          -- positive error means measured VCXO clk is high -> reduce command
          next_v := freq_trim_inc_s - freq_step_s;

          if next_v > TRIM_MAX_S then
            freq_trim_inc_s <= TRIM_MAX_S;
          elsif next_v < TRIM_MIN_S then
            freq_trim_inc_s <= TRIM_MIN_S;
          else
            freq_trim_inc_s <= next_v;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(inc_cmd_s, freq_trim_inc_s, vcxo_ctrl_en)
    variable sum_v : signed(INC_WIDTH+1 downto 0);
  begin
    if vcxo_ctrl_en = '1' then
      sum_v := resize(signed('0' & inc_cmd_s), INC_WIDTH+2) +
        resize(freq_trim_inc_s, INC_WIDTH+2);
    else
      sum_v := resize(signed('0' & inc_cmd_s), INC_WIDTH+2);
    end if;

    if sum_v(sum_v'high) = '1' then
      inc_cmd_dac_s <= (others => '0');
    elsif sum_v(INC_WIDTH) = '1' then
      inc_cmd_dac_s <= (others => '1');
    else
      inc_cmd_dac_s <= unsigned(sum_v(INC_WIDTH-1 downto 0));
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- hold last good increment
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        inc_hold_s <= inc_nominal;
      else
        if sync_active_s = '1' then
          inc_hold_s <= inc_cmd_s;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- final control to NCO
  ---------------------------------------------------------------------------
  process(run_state_s, vcxo_ctrl_en, inc_nominal, inc_cmd_s, inc_hold_s, step_req_raw_s, step_offset_raw_s, allow_step_s)
  begin
    inc_s            <= inc_nominal;
    step_req_s       <= '0';
    step_offset_us_s <= (others => '0');

    case run_state_s is
      when ST_FREE_RUN =>
        inc_s            <= inc_nominal;
        step_req_s       <= '0';
        step_offset_us_s <= (others => '0');

      when ST_PPS_ONLY =>
        if vcxo_ctrl_en = '1' then
          inc_s            <= inc_nominal;
          step_req_s       <= '0';
          step_offset_us_s <= (others => '0');
        else
          inc_s            <= inc_cmd_s;
          step_req_s       <= step_req_raw_s and allow_step_s;
          -- servo error is in sub-us units; the NCO hard-step takes whole us
          step_offset_us_s <= shift_right(step_offset_raw_s, FRAC_BITS);
        end if;

      when ST_TS_ONLY =>
        if vcxo_ctrl_en = '1' then
          inc_s            <= inc_nominal;
          step_req_s       <= '0';
          step_offset_us_s <= (others => '0');
        else
          inc_s            <= inc_cmd_s;
          step_req_s       <= step_req_raw_s and allow_step_s;
          -- servo error is in sub-us units; the NCO hard-step takes whole us
          step_offset_us_s <= shift_right(step_offset_raw_s, FRAC_BITS);
        end if;

      when ST_FULL_SYNC =>
        if vcxo_ctrl_en = '1' then
          inc_s            <= inc_nominal;
          step_req_s       <= '0';
          step_offset_us_s <= (others => '0');
        else
          inc_s            <= inc_cmd_s;
          step_req_s       <= step_req_raw_s and allow_step_s;
          -- servo error is in sub-us units; the NCO hard-step takes whole us
          step_offset_us_s <= shift_right(step_offset_raw_s, FRAC_BITS);
        end if;

      when ST_HOLDOVER =>
        if vcxo_ctrl_en = '1' then
          inc_s            <= inc_nominal;
          step_req_s       <= '0';
          step_offset_us_s <= (others => '0');
        else
          inc_s            <= inc_hold_s;
          step_req_s       <= '0';
          step_offset_us_s <= (others => '0');
        end if;

      when others =>
        inc_s            <= inc_nominal;
        step_req_s       <= '0';
        step_offset_us_s <= (others => '0');
    end case;
  end process;

  ---------------------------------------------------------------------------
  -- 1) Timestamp offset calculator
  ---------------------------------------------------------------------------
  u_ts_offset_calc : entity work.ts_offset_calc
    generic map (
      SECOND_WIDTH => SECOND_WIDTH,
      USEC_WIDTH   => USEC_WIDTH,
      ERR_WIDTH    => ERR_WIDTH,
      USEC_PER_SEC => USEC_PER_SEC,
      CLK_HZ       => CLK_HZ            -- to convert ts_delay_cyc into ticks
      )
    port map (
      clk          => clk,
      rst          => rst,
      sec_loc      => sec_loc_s,
      usec_loc     => usec_loc_s,
      rx_ts_valid  => rx_ts_valid,
      rx_sec       => rx_sec,
      rx_usec      => rx_usec,
      ts_delay_cyc => ts_delay_cyc,
      offset_valid => offset_valid_s,
      -- NOTE: already delay-compensated, so the outlier gate, the step detect
      -- and the combiner below all see the corrected offset.
      offset_us    => offset_us_s
      );

  ---------------------------------------------------------------------------
  -- 2) 1PPS capture
  ---------------------------------------------------------------------------
  u_pps_cap : entity work.pps_cap
    generic map (
      SECOND_WIDTH       => SECOND_WIDTH,
      USEC_WIDTH         => USEC_WIDTH,
      ERR_WIDTH          => ERR_WIDTH,
      FRAC_BITS          => FRAC_BITS,
      CLK_HZ             => CLK_HZ,
      USEC_PER_SEC       => USEC_PER_SEC,
      PPS_LATENCY_CYCLES => PPS_LATENCY_CYCLES
      )
    port map (
      clk          => clk,
      rst          => rst,
      pps_in       => pps_in,
      sec_loc      => sec_loc_s,
      usec_loc     => usec_loc_s,
      frac_us      => frac_us_s,
      pps_valid    => pps_valid_s,
      sec_at_pps   => sec_at_pps_s,
      usec_at_pps  => usec_at_pps_s,
      pps_error_us => pps_error_us_s   -- SUB-US units (1/2^FRAC_BITS us)
      );

  ---------------------------------------------------------------------------
  -- 3) Error combiner/filter
  ---------------------------------------------------------------------------
  clear_filter_s <= '1' when run_state_s = ST_FREE_RUN else '0';
  -- Reject torn-timestamp outliers before the servo error combiner.
  -- TS offset is in us; PPS error is in sub-us units -> separate thresholds.
  offset_valid_clean <= offset_valid_s when
                        (offset_us_s < to_signed(OUTLIER_THRESH_US, ERR_WIDTH)) and
                        (offset_us_s > to_signed(-OUTLIER_THRESH_US, ERR_WIDTH))
                        else '0';
  pps_valid_clean <= pps_valid_s when
                     (pps_error_us_s < to_signed(OUTLIER_THRESH_SUB, ERR_WIDTH)) and
                     (pps_error_us_s > to_signed(-OUTLIER_THRESH_SUB, ERR_WIDTH))
                     else '0';

  -- Bring the TS offset into the sub-us error domain. Safe against overflow:
  -- the combiner only samples it when offset_valid_clean='1', i.e. |offset| <
  -- 0.2 s -> scaled |value| < 5.2e7, well inside 32-bit signed.
  offset_sub_s <= shift_left(offset_us_s, FRAC_BITS);

  u_err_comb : entity work.error_combiner_filter
    generic map (
      ERR_WIDTH  => ERR_WIDTH,
      FILT_SHIFT => FILT_SHIFT
      )
    port map (
      clk          => clk,
      rst          => rst,

      use_offset   => use_offset_s,
      use_pps      => use_pps_s,
      hold_filter  => holdover_s,
      clear_filter => clear_filter_s,

      offset_valid => offset_valid_clean,
      offset_us    => offset_sub_s,     -- sub-us units

      pps_valid    => pps_valid_clean,
      pps_error_us => pps_error_us_s,   -- sub-us units

      error_valid  => error_valid_raw_s,
      error_us     => error_us_raw_s
      );

  ---------------------------------------------------------------------------
  -- 4) PI servo
  ---------------------------------------------------------------------------
  clear_servo_s <= '1' when run_state_s = ST_FREE_RUN else '0';
  hold_servo_s  <= '1' when run_state_s = ST_HOLDOVER else '0';
  u_servo : entity work.time_servo_pi
    generic map (
      ERR_WIDTH   => ERR_WIDTH,
      INC_WIDTH   => INC_WIDTH,
      KP_SHIFT    => KP_SHIFT,
      KI_SHIFT    => KI_SHIFT,
      I_FRAC      => I_FRAC,
      INC_TRIM_MAX=> INC_TRIM_MAX,
      STEP_THRESH => STEP_THRESH_SUB   -- servo error domain is sub-us
      )
    port map (
      clk            => clk,
      rst            => rst,

      servo_enable   => servo_enable_s,
      hold_servo     => hold_servo_s,
      clear_servo    => clear_servo_s,
      allow_step     => allow_step_s,
      i_freeze       => i_freeze_s,

      error_valid    => error_valid_raw_s,
      error_us       => error_us_raw_s,
      inc_nominal    => inc_nominal,
      inc            => inc_cmd_s,
      step_req       => step_req_raw_s,
      step_offset_us => step_offset_raw_s
      );

  ---------------------------------------------------------------------------
  -- 5) VCXO frequency error detector (10 MHz reference)
  ---------------------------------------------------------------------------
  u_freq_err : entity work.vcxo_freq_error
    generic map (
      ERR_WIDTH            => ERR_WIDTH,
      EXPECTED_CLK_PER_REF => FREQ_FB_EXPECTED_CLK_PER_REF_C,
      MEAS_WINDOW_REFS     => FREQ_FB_WINDOW_REFS,
      REF_TIMEOUT_CYCLES   => FREQ_FB_TIMEOUT_CYCLES
      )
    port map (
      clk             => clk,
      rst             => rst,
      ref_clk_10m     => vcxo_ref_10m,
      freq_err_valid  => freq_err_valid_s,
      freq_err_cycles => freq_err_cycles_s,
      ref_ok          => freq_ref_ok_s
      );

  ---------------------------------------------------------------------------
  -- 6) VCXO DAC mapper
  ---------------------------------------------------------------------------
  u_dac_map : entity work.vcxo_dac_mapper
    generic map (
      INC_WIDTH         => INC_WIDTH,
      DAC_BITS          => DAC_BITS,
      DAC_CODE_INIT     => DAC_CODE_INIT,
      DAC_CODE_CENTER   => DAC_CODE_CENTER,
      DAC_CODE_MIN      => DAC_CODE_MIN,
      DAC_CODE_MAX      => DAC_CODE_MAX,
      DAC_GAIN_SHIFT    => DAC_GAIN_SHIFT,
      DAC_SLEW_MAX_STEP => DAC_SLEW_MAX_STEP
      )
    port map (
      clk           => clk,
      rst           => rst,
      force_init    => dac_force_init_s,
      hold_code     => dac_hold_code_s,
      enable_update => dac_enable_update_s,
      fb_valid      => dac_fb_valid,
      fb_code       => dac_fb_code,
      ready         => dac_map_ready_s,
      dac_code_valid => dac_map_done_s,
      inc_cmd       => inc_cmd_dac_s,
      inc_nominal   => inc_nominal,
      dac_code      => dac_code_s,
      sat_hi        => dac_sat_hi_s,
      sat_lo        => dac_sat_lo_s
      );

  ---------------------------------------------------------------------------
  -- One-time absolute NCO load: on the FIRST valid RX timestamp after the source is
  -- alive (ts_ok), jump local time to {rx_sec, rx_usec} for coarse absolute alignment
  -- (offset -> ~link latency instead of the free-run gap). Afterwards the VCXO rate
  -- discipline maintains alignment. One-shot: re-armed only by reset (ts_loaded latches).
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ts_loaded      <= '0';
        load_req_s     <= '0';
        sec_mism_cnt_s <= (others => '0');
      else
        load_req_s <= '0';                  -- 1-cycle pulse
        if (rx_ts_valid = '1') and (ts_loaded = '0') and (ts_ok_s = '1') then
          load_req_s  <= '1';
          load_sec_s  <= rx_sec;
          load_usec_s <= rx_usec;
          ts_loaded   <= '1';
        end if;

        -- Gross-error guard (ISSUE 1 FIX): re-arm the one-time absolute load
        -- when |offset| >= OUTLIER_THRESH_US (0.2 s) on 16 consecutive TS
        -- samples while the source is alive.
        --
        -- Nguong cu la USEC_PER_SEC/2 (0.5 s) va tao VUNG CHET 0.2..0.5 s:
        --   * cong loc outlier chan moi mau |err| >= OUTLIER (0.2 s) truoc
        --     combiner -> servo khong nhan duoc mau nao;
        --   * hard-step cua time_servo_pi can |err| > STEP_THRESH (1 s) ma
        --     pps_cap da gap sai so ve [-0.5 s, +0.5 s) -> khong bao gio toi;
        --   * guard nay (loi thoat cuoi cung) lai doi >= 0.5 s.
        -- Sai pha roi vao 0.2..0.5 s thi he thong nam im vinh vien (do tren
        -- HW 18/10/2026: PPS_ONLY, inc ghim nominal 120/120 mau).
        -- Ha nguong xuong dung OUTLIER_THRESH_US dong kin vung chet: moi sai
        -- so hoac qua duoc cong loc (servo keo), hoac kich guard nay (nap lai
        -- tuyet doi). Bo dem 16 mau lien tiep giu nguyen kha nang loai mau
        -- timestamp rach le (torn): mot mau nhieu don le bi reset ve 0.
        --
        -- use_offset_s (19/10/2026): guard chi duoc chay khi duong TS dang la
        -- nguon dieu khien (TS_ONLY/FULL_SYNC). Khong co dieu kien nay thi o
        -- PPS_ONLY voi GPS, moi lan guard PPS jam local ve GPS xong, |offset|
        -- so voi MBU thanh ~0.47 s >= 0.2 s va guard nay nap lai thoi gian MBU
        -- sau dung 16 mau TS (~16 ms o nhip kHz) -- do tren HW 19/10/2026:
        -- pps_err rang cua -470 ms <-> ~0 chu ky 17 s, hai guard giat day nhau.
        if (offset_valid_s = '1') and (ts_ok_s = '1') and (use_offset_s = '1') then
          if (offset_us_s >= to_signed(OUTLIER_THRESH_US, ERR_WIDTH)) or
             (offset_us_s <= to_signed(-OUTLIER_THRESH_US, ERR_WIDTH)) then
            if sec_mism_cnt_s = "1111" then
              ts_loaded      <= '0';
              sec_mism_cnt_s <= (others => '0');
            else
              sec_mism_cnt_s <= sec_mism_cnt_s + 1;
            end if;
          else
            sec_mism_cnt_s <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- PPS gross-error jam (xem khai bao pps_mism_cnt_s). Dem tren pps_valid_s
  -- THO (truoc cong loc outlier) de thay duoc chinh cac mau bi cong loc chan.
  -- use_pps_s chi cho jam khi duong PPS dang duoc dung (PPS_ONLY/FULL_SYNC).
  -- Gia tri jam = pps_error_us_s >> FRAC_BITS (sub-tick -> tick), cung quy uoc
  -- voi duong step cua servo; local_time_nco tru sai so va tu xu ly muon/nho
  -- sang giay, bao hoa o +-(1 s - 1 tick).
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pps_mism_cnt_s <= (others => '0');
        pps_jam_req_s  <= '0';
        pps_jam_off_s  <= (others => '0');
      else
        pps_jam_req_s <= '0';
        if (pps_valid_s = '1') and (use_pps_s = '1') then
          if (pps_error_us_s >= to_signed(OUTLIER_THRESH_SUB, ERR_WIDTH)) or
             (pps_error_us_s <= to_signed(-OUTLIER_THRESH_SUB, ERR_WIDTH)) then
            if pps_mism_cnt_s = "1111" then
              pps_jam_req_s  <= '1';
              pps_jam_off_s  <= shift_right(pps_error_us_s, FRAC_BITS);
              pps_mism_cnt_s <= (others => '0');
            else
              pps_mism_cnt_s <= pps_mism_cnt_s + 1;
            end if;
          else
            pps_mism_cnt_s <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Jam bo qua mux che do (mux ep step_req_s='0' khi vcxo_ctrl_en='1', nhung
  -- jam chinh dang phai chay duoc o che do analog: no sua BO DEM thoi gian,
  -- khong dinh den DAC).
  step_req_nco_s <= step_req_s or pps_jam_req_s;
  step_off_nco_s <= pps_jam_off_s when pps_jam_req_s = '1' else step_offset_us_s;


  ---------------------------------------------------------------------------
  -- 7) Local NCO
  ---------------------------------------------------------------------------
  -- inc is a 32-bit control value; the NCO accumulator is NCO_PHASE_WIDTH bits
  -- (zero-extended). At 250 MHz / 36-bit, one inc LSB trims the local rate by
  -- ~3.6 ns/s, fine enough for sub-100ns steady-state phase.
  inc_nco_s <= resize(inc_s, NCO_PHASE_WIDTH);

  u_local_nco : entity work.local_time_nco
    generic map (
      SECOND_WIDTH => SECOND_WIDTH,
      USEC_WIDTH   => USEC_WIDTH,
      PHASE_WIDTH  => NCO_PHASE_WIDTH,
      ERR_WIDTH    => ERR_WIDTH,
      FRAC_BITS    => FRAC_BITS,
      USEC_PER_SEC => USEC_PER_SEC
      )
    port map (
      clk            => clk,
      rst            => rst,
      inc            => inc_nco_s,
      step_req       => step_req_nco_s,
      step_offset_us => step_off_nco_s,
      load_req       => load_req_s,
      load_sec       => load_sec_s,
      load_usec      => load_usec_s,
      sec_loc        => sec_loc_s,
      usec_loc       => usec_loc_s,
      frac_us        => frac_us_s,
      tick_us        => tick_us_s
      );

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_time_sync_top_vcxo_smoke is
end entity;

architecture sim of tb_time_sync_top_vcxo_smoke is
  constant SECOND_WIDTH_C : integer := 40;
  constant USEC_WIDTH_C   : integer := 27;
  constant ERR_WIDTH_C    : integer := 32;
  constant INC_WIDTH_C    : integer := 32;

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  signal cfg_mode     : std_logic_vector(2 downto 0) := "000";
  signal pps_in       : std_logic := '0';
  signal rx_ts_valid  : std_logic := '0';
  signal rx_sec       : unsigned(SECOND_WIDTH_C-1 downto 0) := (others => '0');
  signal rx_usec      : unsigned(USEC_WIDTH_C-1 downto 0) := (others => '0');
  signal inc_nominal  : unsigned(INC_WIDTH_C-1 downto 0) := to_unsigned(1000000, INC_WIDTH_C);
  signal vcxo_ctrl_en : std_logic := '1';
  signal vcxo_ref_10m : std_logic := '0';

  signal sec_loc          : unsigned(SECOND_WIDTH_C-1 downto 0);
  signal usec_loc         : unsigned(USEC_WIDTH_C-1 downto 0);
  signal run_state_out    : std_logic_vector(2 downto 0);
  signal pps_ok_out       : std_logic;
  signal ts_ok_out        : std_logic;
  signal sync_locked_out  : std_logic;
  signal holdover_out     : std_logic;
  signal offset_us_out    : signed(ERR_WIDTH_C-1 downto 0);
  signal pps_error_us_out : signed(ERR_WIDTH_C-1 downto 0);
  signal error_us_out     : signed(ERR_WIDTH_C-1 downto 0);
  signal inc_out          : unsigned(INC_WIDTH_C-1 downto 0);
  signal tick_us          : std_logic;
  signal dac_fb_code      : unsigned(17 downto 0) := (others => '0');
  signal dac_fb_valid     : std_logic := '0';
  signal fb_read_done     : std_logic := '0';
  signal fb_pulse_count   : integer := 0;
  signal dac_pulse_count  : integer := 0;
  signal dac_code_out     : unsigned(17 downto 0);
  signal dac_update_pulse : std_logic;

  constant ST_FREE_RUN : std_logic_vector(2 downto 0) := "000";
  constant ST_PPS_ONLY : std_logic_vector(2 downto 0) := "001";
  constant ST_TS_ONLY  : std_logic_vector(2 downto 0) := "010";
  constant ST_FULL_SYNC : std_logic_vector(2 downto 0) := "011";
  constant ST_HOLDOVER : std_logic_vector(2 downto 0) := "100";
  constant TS_SAMPLE_GAP_CYCLES_C : integer := 16;
  constant PPS_PULSE_HIGH_CYCLES_C : integer := 2;
  constant PPS_PULSE_GAP_CYCLES_C  : integer := 18;
begin

  clk <= not clk after 2 ns;
  vcxo_ref_10m <= not vcxo_ref_10m after 50 ns;

  uut : entity work.time_sync_top
    generic map (
      SECOND_WIDTH            => SECOND_WIDTH_C,
      USEC_WIDTH              => USEC_WIDTH_C,
      ERR_WIDTH               => ERR_WIDTH_C,
      INC_WIDTH               => INC_WIDTH_C,
      PPS_TIMEOUT_CYCLES      => 32,
      TS_TIMEOUT_CYCLES       => 32,
      HOLDOVER_TIMEOUT_CYCLES => 24,
      DAC_BITS                => 18,
      DAC_CODE_INIT           => 16#20000#,
      DAC_CODE_CENTER         => 16#20000#,
      DAC_CODE_MIN            => 0,
      DAC_CODE_MAX            => 16#3FFFF#,
      DAC_GAIN_SHIFT          => 10,
      DAC_SLEW_MAX_STEP       => 64,
      AD_UPDATE_MIN_CYCLES    => 3,
      FREQ_FB_EXPECTED_CLK_PER_REF => 25,
      FREQ_FB_WINDOW_REFS          => 4,
      FREQ_FB_TIMEOUT_CYCLES       => 64,
      FREQ_ERR_INC_SHIFT           => 10,
      FREQ_TRIM_INC_MAX_ABS        => 1024
      )
    port map (
      clk              => clk,
      rst              => rst,
      cfg_mode         => cfg_mode,
      pps_in           => pps_in,
      rx_ts_valid      => rx_ts_valid,
      rx_sec           => rx_sec,
      rx_usec          => rx_usec,
      inc_nominal      => inc_nominal,
      vcxo_ctrl_en     => vcxo_ctrl_en,
      vcxo_ref_10m     => vcxo_ref_10m,
      dac_fb_code      => dac_fb_code,
      dac_fb_valid     => dac_fb_valid,
      sec_loc          => sec_loc,
      usec_loc         => usec_loc,
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
      dac_code_out     => dac_code_out,
      dac_update_pulse => dac_update_pulse
      );

  -- emulate external SPI + DAC readback:
  -- read back only once, right after the first DAC update pulse
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dac_fb_valid <= '0';
        fb_read_done <= '0';
      else
        dac_fb_valid <= '0';
        if (dac_update_pulse = '1') and (fb_read_done = '0') then
          dac_fb_code  <= dac_code_out;
          dac_fb_valid <= '1';
          fb_read_done <= '1';
        end if;
      end if;
    end if;
  end process;

  -- count DAC feedback valid pulses cycle-by-cycle (no sampling miss)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        fb_pulse_count <= 0;
      elsif dac_fb_valid = '1' then
        fb_pulse_count <= fb_pulse_count + 1;
      end if;
    end if;
  end process;

  -- count DAC update pulses cycle-by-cycle (no sampling miss)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dac_pulse_count <= 0;
      elsif dac_update_pulse = '1' then
        dac_pulse_count <= dac_pulse_count + 1;
      end if;
    end if;
  end process;

  stim_proc : process
    variable seen_ts_only  : boolean := false;
    variable seen_pps_only : boolean := false;
    variable seen_full_sync : boolean := false;
    variable seen_holdover : boolean := false;
    variable seen_free_run : boolean := false;
    variable seen_inc_non_nominal : boolean := false;
    variable dac_pulses_before_vcxo_off : integer := 0;
    variable dac_pulses_after_vcxo_on : integer := 0;
    procedure wait_clk(
      constant n : in integer
      ) is
    begin
      for k in 1 to n loop
        wait until rising_edge(clk);
      end loop;
    end procedure;
    procedure pulse_ts(
      constant rx_sec_v : in integer;
      constant rx_usec_v : in integer;
      constant gap_cycles : in integer
      ) is
    begin
      rx_ts_valid <= '1';
      rx_sec      <= to_unsigned(rx_sec_v, SECOND_WIDTH_C);
      rx_usec     <= to_unsigned(rx_usec_v, USEC_WIDTH_C);
      wait until rising_edge(clk);
      rx_ts_valid <= '0';
      wait_clk(gap_cycles);
    end procedure;
    procedure pulse_pps(
      constant high_cycles : in integer;
      constant low_cycles  : in integer
      ) is
    begin
      pps_in <= '1';
      wait_clk(high_cycles);
      pps_in <= '0';
      wait_clk(low_cycles);
    end procedure;
  begin
    -- release reset aligned to rising edge for synchronous TB control
    for i in 0 to 10 loop
      wait until rising_edge(clk);
    end loop;
    rst <= '0';

    -- CASE 1: TS_ONLY
    -- feed only timestamp pulses (no PPS)
    for i in 0 to 20 loop
      pulse_ts(0, i * 10, TS_SAMPLE_GAP_CYCLES_C);

      if run_state_out = ST_TS_ONLY then
        seen_ts_only := true;
      end if;
    end loop;

    assert seen_ts_only
      report "did not reach TS_ONLY" severity error;

    -- CASE 2: PPS_ONLY
    -- stop TS and drive spaced PPS pulses (not continuous)
    rx_ts_valid <= '0';
    for i in 0 to 20 loop
      pulse_pps(PPS_PULSE_HIGH_CYCLES_C, PPS_PULSE_GAP_CYCLES_C);

      if run_state_out = ST_PPS_ONLY then
        seen_pps_only := true;
      end if;
    end loop;

    assert seen_pps_only
      report "did not reach PPS_ONLY" severity error;

    -- CASE 3: FULL_SYNC
    -- drive TS + spaced PPS together so both sources are alive
    for i in 0 to 20 loop
      pulse_ts(0, 1000 + i * 10, 8);
      pulse_pps(PPS_PULSE_HIGH_CYCLES_C, PPS_PULSE_GAP_CYCLES_C);

      if run_state_out = ST_FULL_SYNC then
        seen_full_sync := true;
      end if;
    end loop;

    assert seen_full_sync
      report "did not reach FULL_SYNC" severity error;

    -- in VCXO mode, inc_out must stay inc_nominal even in sync state
    assert inc_out = inc_nominal
      report "inc_out is not fixed to inc_nominal in VCXO mode" severity error;

    -- CASE 4: runtime mode switch vcxo_ctrl_en 1 -> 0 -> 1
    -- 4a) turn VCXO branch OFF and keep sync stimuli active
    dac_pulses_before_vcxo_off := dac_pulse_count;
    vcxo_ctrl_en <= '0';
    wait_clk(4);

    for i in 0 to 30 loop
      -- inject large TS error so PI in NCO mode moves inc_out away from inc_nominal
      pulse_ts(1, 0, 8);
      pulse_pps(PPS_PULSE_HIGH_CYCLES_C, PPS_PULSE_GAP_CYCLES_C);

      if inc_out /= inc_nominal then
        seen_inc_non_nominal := true;
      end if;
    end loop;

    assert seen_inc_non_nominal
      report "inc_out did not move from inc_nominal in NCO mode (vcxo_ctrl_en=0)" severity error;
    assert dac_pulse_count = dac_pulses_before_vcxo_off
      report "unexpected DAC update while vcxo_ctrl_en=0" severity error;

    -- 4b) turn VCXO branch back ON and expect DAC updates to resume
    vcxo_ctrl_en <= '1';
    wait_clk(4);
    for i in 0 to 20 loop
      pulse_ts(0, 2000 + i * 10, 8);
      pulse_pps(PPS_PULSE_HIGH_CYCLES_C, PPS_PULSE_GAP_CYCLES_C);

    end loop;
    dac_pulses_after_vcxo_on := dac_pulse_count;

    assert dac_pulses_after_vcxo_on > dac_pulses_before_vcxo_off
      report "DAC update did not resume after vcxo_ctrl_en returned to 1" severity error;

    -- stop timestamps to let TS timeout and enter HOLDOVER then FREE_RUN
    rx_ts_valid <= '0';
    pps_in      <= '0';
    for i in 0 to 80 loop
      wait until rising_edge(clk);

      if run_state_out = ST_HOLDOVER then
        seen_holdover := true;
      end if;

      if run_state_out = ST_FREE_RUN then
        seen_free_run := true;
      end if;

    end loop;

    assert seen_holdover
      report "did not reach HOLDOVER" severity error;
    assert seen_free_run
      report "did not return to FREE_RUN" severity error;

    assert dac_pulse_count > 0
      report "no DAC update pulse seen in VCXO smoke test" severity error;
    assert fb_pulse_count = 1
      report "DAC feedback must be one-shot after first DAC update" severity error;

    report "tb_time_sync_top_vcxo_smoke PASS" severity note;
    wait;
  end process;

end architecture;

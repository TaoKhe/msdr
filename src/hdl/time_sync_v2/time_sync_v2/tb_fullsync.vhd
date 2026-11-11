-- Focused self-checking testbench for the timestamp + 1PPS sync path.
-- Drives time_sync_top in AUTO mode (cfg_mode="000") with BOTH a 1PPS reference and
-- periodic RX timestamps, and checks it reaches FULL_SYNC (run_state="011", sync_locked='1').
-- Timeouts are shrunk via generics so locking happens within a few thousand cycles.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fullsync is
end entity;

architecture sim of tb_fullsync is
  constant CLK_PERIOD : time := 4 ns;        -- 250 MHz
  constant PPS_PERIOD : integer := 2000;     -- clk cycles between 1PPS pulses
  constant TS_PERIOD  : integer := 400;      -- clk cycles between RX timestamp samples

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  signal pps_in      : std_logic := '0';
  signal rx_ts_valid : std_logic := '0';
  signal rx_sec      : unsigned(39 downto 0) := (others => '0');
  signal rx_usec     : unsigned(26 downto 0) := (others => '0');

  signal sec_loc  : unsigned(39 downto 0);
  signal usec_loc : unsigned(26 downto 0);

  signal run_state    : std_logic_vector(2 downto 0);
  signal pps_ok       : std_logic;
  signal ts_ok        : std_logic;
  signal sync_locked  : std_logic;
  signal holdover     : std_logic;
  signal dac_code     : unsigned(17 downto 0);
  signal dac_update   : std_logic;

  signal sim_done : boolean := false;

  constant ST_FULL_SYNC : std_logic_vector(2 downto 0) := "011";
begin

  -- clock
  clk_proc : process
  begin
    while not sim_done loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  -- DUT: AUTO mode, VCXO/DAC control, 10 MHz ref disabled, shrunk timeouts
  dut : entity work.time_sync_top
    generic map (
      PPS_TIMEOUT_CYCLES      => 4000,
      TS_TIMEOUT_CYCLES       => 4000,
      HOLDOVER_TIMEOUT_CYCLES => 100000,
      AD_UPDATE_MIN_CYCLES    => 50
      )
    port map (
      clk          => clk,
      rst          => rst,
      cfg_mode     => "000",              -- AUTO
      pps_in       => pps_in,
      rx_ts_valid  => rx_ts_valid,
      rx_sec       => rx_sec,
      rx_usec      => rx_usec,
      inc_nominal  => to_unsigned(17179869, 32),
      vcxo_ctrl_en => '1',
      vcxo_ref_10m => '0',
      dac_fb_code  => to_unsigned(131072, 18),
      dac_fb_valid => '0',
      sec_loc          => sec_loc,
      usec_loc         => usec_loc,
      run_state_out    => run_state,
      pps_ok_out       => pps_ok,
      ts_ok_out        => ts_ok,
      sync_locked_out  => sync_locked,
      holdover_out     => holdover,
      offset_us_out    => open,
      pps_error_us_out => open,
      error_us_out     => open,
      inc_out          => open,
      tick_us          => open,
      dac_code_out     => dac_code,
      dac_update_pulse => dac_update
      );

  -- 1PPS generator: high for 10 cycles every PPS_PERIOD cycles
  pps_proc : process(clk)
    variable cnt : integer := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt := 0; pps_in <= '0';
      else
        cnt := cnt + 1;
        if cnt >= PPS_PERIOD then
          cnt := 0;
          pps_in <= '1';
        elsif cnt = 10 then
          pps_in <= '0';
        end if;
      end if;
    end if;
  end process;

  -- RX timestamp generator: 1-cycle valid every TS_PERIOD, rx time == local time
  -- (near-zero offset) so the servo stays happy and ts_ok holds.
  ts_proc : process(clk)
    variable cnt : integer := 0;
  begin
    if rising_edge(clk) then
      rx_ts_valid <= '0';
      if rst = '1' then
        cnt := 0;
      else
        cnt := cnt + 1;
        if cnt >= TS_PERIOD then
          cnt := 0;
          rx_ts_valid <= '1';
          rx_sec      <= sec_loc;
          rx_usec     <= usec_loc;
        end if;
      end if;
    end if;
  end process;

  -- stimulus + checker
  stim : process
    variable ok : boolean := true;
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    -- wait long enough for both sources to register and AUTO -> FULL_SYNC
    wait for 60 us;   -- ~15000 cycles @ 250 MHz

    report "pps_ok="      & std_logic'image(pps_ok) &
           " ts_ok="      & std_logic'image(ts_ok) &
           " sync_locked="& std_logic'image(sync_locked) &
           " run_state="  & integer'image(to_integer(unsigned(run_state)));

    if pps_ok /= '1' then
      report "FAIL: pps_ok not asserted" severity error; ok := false;
    end if;
    if ts_ok /= '1' then
      report "FAIL: ts_ok not asserted" severity error; ok := false;
    end if;
    if run_state /= ST_FULL_SYNC then
      report "FAIL: run_state did not reach FULL_SYNC (011)" severity error; ok := false;
    end if;
    if sync_locked /= '1' then
      report "FAIL: sync_locked not asserted" severity error; ok := false;
    end if;

    if ok then
      report "SIM_RESULT: PASS (AUTO reached FULL_SYNC with timestamp + 1PPS)" severity note;
    else
      report "SIM_RESULT: FAIL" severity error;
    end if;

    sim_done <= true;
    wait for 1 us;
    std.env.stop;
    wait;
  end process;

end architecture;

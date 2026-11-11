----------------------------------------------------------------------------------
-- Testbench : tb_vcsco_wrapper
-- Purpose   : Smoke test for vcsco_wrapper (1PPS-only VCSO disciplining).
--   Checks:
--     1. Boot SPI frame: 24 bits, MSB-first, == "0000" & DAC_DEFAULT_CODE & "00".
--     2. run_state_out reaches PPS_ONLY ("001") after driving 1PPS.
--     3. At least one further (servo-driven) SPI write occurs after lock.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_vcsco_wrapper is
end entity;

architecture sim of tb_vcsco_wrapper is

  constant DAC_BITS_C         : integer := 18;
  constant DAC_DEFAULT_CODE_C : integer := 16#2ABCD#;  -- recognizable test value
  constant SPI_CLK_DIV_C      : integer := 2;          -- faster SCLK for sim

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  signal pps_in : std_logic := '0';

  signal dac_vcso_din   : std_logic;
  signal dac_vcso_sclk  : std_logic;
  signal dac_vcso_sync  : std_logic;

  signal sec_loc          : unsigned(39 downto 0);
  signal usec_loc         : unsigned(26 downto 0);
  signal run_state_out    : std_logic_vector(2 downto 0);
  signal pps_ok_out       : std_logic;
  signal sync_locked_out  : std_logic;
  signal holdover_out     : std_logic;
  signal offset_us_out    : signed(31 downto 0);
  signal pps_error_us_out : signed(31 downto 0);
  signal error_us_out     : signed(31 downto 0);
  signal dac_code_out     : unsigned(DAC_BITS_C-1 downto 0);
  signal spi_busy         : std_logic;

  signal captured_word : std_logic_vector(23 downto 0) := (others => '0');
  signal frame_count   : integer := 0;

  constant ST_PPS_ONLY : std_logic_vector(2 downto 0) := "001";

begin

  clk <= not clk after 5 ns;  -- 100 MHz

  uut : entity work.vcsco_wrapper
    generic map (
      CLK_HZ           => 100_000_000,
      -- INC_NOMINAL left at 0 -> auto: 2^36*1e6/100e6 = 687_194_767
      DAC_BITS         => DAC_BITS_C,
      DAC_DEFAULT_CODE => DAC_DEFAULT_CODE_C,
      SPI_CLK_DIV      => SPI_CLK_DIV_C
      )
    port map (
      clk              => clk,
      rst              => rst,
      pps_in           => pps_in,
      cfg_mode         => "010",
      dac_vcso_din     => dac_vcso_din,
      dac_vcso_sclk    => dac_vcso_sclk,
      dac_vcso_sync    => dac_vcso_sync,
      sec_loc          => sec_loc,
      usec_loc         => usec_loc,
      run_state_out    => run_state_out,
      pps_ok_out       => pps_ok_out,
      sync_locked_out  => sync_locked_out,
      holdover_out     => holdover_out,
      offset_us_out    => offset_us_out,
      pps_error_us_out => pps_error_us_out,
      error_us_out     => error_us_out,
      dac_code_out     => dac_code_out,
      spi_busy         => spi_busy
      );

  ---------------------------------------------------------------------------
  -- SPI frame monitor: capture one 24-bit word per SYNC-low frame
  -- (sample MOSI on SCLK rising edge, MSB first)
  ---------------------------------------------------------------------------
  spi_mon : process
    variable w : std_logic_vector(23 downto 0);
  begin
    wait until dac_vcso_sync = '0';
    for i in 23 downto 0 loop
      wait until rising_edge(dac_vcso_sclk);
      w(i) := dac_vcso_din;
    end loop;
    captured_word <= w;
    frame_count   <= frame_count + 1;
    wait until dac_vcso_sync = '1';
  end process;

  ---------------------------------------------------------------------------
  -- Stimulus + checks
  ---------------------------------------------------------------------------
  stim : process
    variable expected_boot : std_logic_vector(23 downto 0);
    variable seen_pps_only : boolean := false;
    procedure wait_clk(constant n : in integer) is
    begin
      for k in 1 to n loop
        wait until rising_edge(clk);
      end loop;
    end procedure;
  begin
    -- reset
    rst <= '1';
    wait_clk(20);
    rst <= '0';

    -- 1) boot SPI write must appear
    wait until frame_count >= 1 for 50 us;
    assert frame_count >= 1
      report "no boot SPI frame observed" severity failure;

    expected_boot := "0000" &
                     std_logic_vector(to_unsigned(DAC_DEFAULT_CODE_C, 18)) &
                     "00";
    assert captured_word = expected_boot
      report "boot frame mismatch: got " & to_hstring(captured_word) &
             " expected " & to_hstring(expected_boot)
      severity failure;
    report "boot frame OK: " & to_hstring(captured_word) severity note;

    -- 2) drive 1PPS to reach PPS_ONLY and trigger a servo update
    for kk in 0 to 19 loop
      pps_in <= '1';
      wait_clk(20);
      pps_in <= '0';
      wait_clk(180);
      if run_state_out = ST_PPS_ONLY then
        seen_pps_only := true;
      end if;
    end loop;

    assert seen_pps_only
      report "did not reach PPS_ONLY" severity failure;
    report "reached PPS_ONLY, sync_locked=" & std_logic'image(sync_locked_out)
      severity note;

    -- 3) at least one servo-driven DAC write after the boot write
    assert frame_count >= 2
      report "no servo-driven SPI write after lock (frames=" &
             integer'image(frame_count) & ")"
      severity failure;

    report "tb_vcsco_wrapper PASS  frames=" & integer'image(frame_count) &
           "  last_code=" & to_hstring(captured_word)
      severity note;
    finish;
  end process;

end architecture;

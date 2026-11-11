library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- 1PPS capture with sub-microsecond resolution.
--
-- Captures {sec_loc, usec_loc, frac_us} at the (synchronized, debounced) rising
-- edge of pps_in and outputs the local phase deviation from the ideal second
-- boundary in SUB-MICROSECOND units of 1/2^FRAC_BITS us (~3.9 ns at FRAC_BITS=8).
-- This is the key change that lifts the old 1-us quantization floor: the error
-- fed to the servo now resolves single NCO phase steps instead of whole
-- microseconds, enabling < 100 ns disciplining against the 1PPS reference.
--
-- The input synchronizer + 5-tap debounce delays edge detection by a fixed,
-- deterministic number of clk cycles; PPS_LATENCY_CYCLES compensates that bias
-- (plus any known upstream sync stages) out of the reported error.
entity pps_cap is
  generic (
    SECOND_WIDTH       : integer := 40;
    USEC_WIDTH         : integer := 27;
    ERR_WIDTH          : integer := 32;
    FRAC_BITS          : integer := 8;         -- sub-us resolution: 1/2^FRAC_BITS us
    CLK_HZ             : integer := 250000000; -- clk frequency (for latency compensation)
    USEC_PER_SEC       : integer := 1000000;   -- scale-down for fast simulation only (HW: 1e6)
    PPS_LATENCY_CYCLES : integer := 8          -- known pps_in -> capture pipeline delay in clk cycles
    );
  port (
    clk : in  std_logic; -- logic clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- external PPS input
    pps_in : in  std_logic; -- asynchronous 1PPS signal

    -- local time input from counter/NCO
    sec_loc  : in  unsigned(SECOND_WIDTH-1 downto 0); -- local time seconds at sampling instant
    usec_loc : in  unsigned(USEC_WIDTH-1 downto 0);   -- local time microseconds at sampling instant
    frac_us  : in  unsigned(FRAC_BITS-1 downto 0) := (others => '0'); -- sub-us NCO phase

    -- captured time at PPS edge
    pps_valid   : out std_logic;                          -- 1-cycle pulse when PPS edge is captured
    sec_at_pps  : out unsigned(SECOND_WIDTH-1 downto 0);  -- captured seconds
    usec_at_pps : out unsigned(USEC_WIDTH-1 downto 0);    -- captured microseconds

    -- deviation from ideal second boundary, in 1/2^FRAC_BITS us units
    pps_error_us : out signed(ERR_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of pps_cap is

  ---------------------------------------------------------------------------
  -- Constants (sub-us domain)
  ---------------------------------------------------------------------------
  constant SUB_WIDTH     : integer := USEC_WIDTH + FRAC_BITS;
  constant SUB_EXT_WIDTH : integer := SUB_WIDTH + 1;

  -- full second / half second expressed in sub-us units
  constant FULL_SUB : signed(SUB_EXT_WIDTH-1 downto 0) :=
    shift_left(to_signed(USEC_PER_SEC, SUB_EXT_WIDTH), FRAC_BITS);
  constant HALF_SUB : signed(SUB_EXT_WIDTH-1 downto 0) :=
    shift_left(to_signed(USEC_PER_SEC/2, SUB_EXT_WIDTH), FRAC_BITS);

  -- fixed detection-pipeline bias, converted from clk cycles to sub-tick units.
  -- BUG FIX 2026-07-30: was the literal 1.0e6 instead of USEC_PER_SEC, so with a
  -- 10 ns tick the latency compensation came out 100x too small (0 sub-ticks) and
  -- the measured PPS phase kept a fixed bias of PPS_LATENCY_CYCLES clocks.
  constant LAT_COMP_SUB : integer :=
    integer(round(real(PPS_LATENCY_CYCLES) * real(2**FRAC_BITS)
                  * real(USEC_PER_SEC) / real(CLK_HZ)));

  ---------------------------------------------------------------------------
  -- PPS synchronizer + debounce (5-tap with hysteresis)
  ---------------------------------------------------------------------------
  signal pps_meta    : std_logic := '0';
  signal pps_sync    : std_logic := '0';
  signal pps_taps    : std_logic_vector(4 downto 0) := (others => '0');
  signal pps_clean   : std_logic := '0';
  signal pps_clean_d : std_logic := '0';
  signal pps_tick    : std_logic := '0';

  ---------------------------------------------------------------------------
  -- Capture pipeline
  ---------------------------------------------------------------------------
  signal cap_valid_s1 : std_logic := '0';
  signal sub_cap_s1   : unsigned(SUB_WIDTH-1 downto 0) := (others => '0');

  signal sec_at_pps_reg  : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal usec_at_pps_reg : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');
  signal pps_valid_reg   : std_logic := '0';
  signal pps_error_reg   : signed(ERR_WIDTH-1 downto 0)      := (others => '0');

begin

  sec_at_pps   <= sec_at_pps_reg;
  usec_at_pps  <= usec_at_pps_reg;
  pps_valid    <= pps_valid_reg;
  pps_error_us <= pps_error_reg;

  ---------------------------------------------------------------------------
  -- Synchronize, debounce and detect rising edge.
  -- pps_clean only changes state after 5 consistent samples -> immune to
  -- glitches/ringing on the PPS cable; delay is deterministic and included
  -- in PPS_LATENCY_CYCLES.
  ---------------------------------------------------------------------------
  sync_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pps_meta    <= '0';
        pps_sync    <= '0';
        pps_taps    <= (others => '0');
        pps_clean   <= '0';
        pps_clean_d <= '0';
        pps_tick    <= '0';
      else
        pps_meta <= pps_in;
        pps_sync <= pps_meta;
        pps_taps <= pps_taps(3 downto 0) & pps_sync;

        if pps_taps = "11111" then
          pps_clean <= '1';
        elsif pps_taps = "00000" then
          pps_clean <= '0';
        end if;

        pps_clean_d <= pps_clean;
        pps_tick    <= pps_clean and (not pps_clean_d);
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Stage 1: capture local time (integer us + sub-us NCO phase) at PPS edge.
  -- usec_loc and frac_us come from the same clocked process in local_time_nco,
  -- so the concatenated sample is coherent.
  ---------------------------------------------------------------------------
  cap_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cap_valid_s1    <= '0';
        sub_cap_s1      <= (others => '0');
        sec_at_pps_reg  <= (others => '0');
        usec_at_pps_reg <= (others => '0');
      else
        cap_valid_s1 <= '0';
        if pps_tick = '1' then
          sec_at_pps_reg  <= sec_loc;
          usec_at_pps_reg <= usec_loc;
          sub_cap_s1      <= usec_loc & frac_us;  -- usec*2^FRAC_BITS + frac
          cap_valid_s1    <= '1';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Stage 2: map into [-half_second .. +half_second) and remove the fixed
  -- detection latency. Positive error = local clock AHEAD of the reference.
  ---------------------------------------------------------------------------
  err_proc : process(clk)
    variable sub_ext_v : signed(SUB_EXT_WIDTH-1 downto 0);
    variable err_v     : signed(SUB_EXT_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pps_valid_reg <= '0';
        pps_error_reg <= (others => '0');
      else
        pps_valid_reg <= '0';

        if cap_valid_s1 = '1' then
          sub_ext_v := signed('0' & sub_cap_s1);

          if sub_ext_v > HALF_SUB then
            err_v := sub_ext_v - FULL_SUB;
          else
            err_v := sub_ext_v;
          end if;

          err_v := err_v - to_signed(LAT_COMP_SUB, SUB_EXT_WIDTH);

          pps_error_reg <= resize(err_v, ERR_WIDTH);
          pps_valid_reg <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;

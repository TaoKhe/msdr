library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Timestamp parser & offset calculator
-- offset_us = (time_local - time_rx) - transport_delay, in local TICKS.
entity ts_offset_calc is
  generic (
    SECOND_WIDTH : integer := 40;
    USEC_WIDTH   : integer := 27;
    ERR_WIDTH    : integer := 32;
    USEC_PER_SEC : integer := 1000000; -- scale-down for fast simulation only (HW: 1e6)
    -- Frequency of clk. Only used to convert ts_delay_cyc (clock cycles) into ticks.
    CLK_HZ       : integer := 250000000
    );
  port (
    clk : in  std_logic; -- logic clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- local time input
    sec_loc  : in  unsigned(SECOND_WIDTH-1 downto 0); -- local time seconds
    usec_loc : in  unsigned(USEC_WIDTH-1 downto 0);   -- local time microseconds

    -- received timestamp input
    rx_ts_valid : in  std_logic;                      -- 1-cycle pulse: rx timestamp sample valid
    rx_sec      : in  unsigned(SECOND_WIDTH-1 downto 0); -- received timestamp seconds
    rx_usec     : in  unsigned(USEC_WIDTH-1 downto 0);   -- received timestamp microseconds

    -- Fixed transport delay of the timestamp path, in CLK CYCLES (quasi-static;
    -- driven from a VIO / config register). See DLY_* below for why the unit is
    -- clock cycles and not ticks. 0 = no compensation (raw behaviour).
    ts_delay_cyc : in  unsigned(15 downto 0) := (others => '0');

    -- output offset in ticks: (time_local - time_rx) - ts_delay
    offset_valid : out std_logic;                     -- 1-cycle pulse when offset_us is updated
    offset_us    : out signed(ERR_WIDTH-1 downto 0)  -- signed offset in ticks
    );
end entity;

architecture rtl of ts_offset_calc is

  constant USEC_PER_SEC_BITS : integer :=
    integer(ceil(log2(real(USEC_PER_SEC)))) + 1;

  constant DIFF_SEC_WIDTH  : integer := SECOND_WIDTH + 1;
  constant DIFF_USEC_WIDTH : integer := USEC_WIDTH + 1;
  constant PROD_WIDTH      : integer := DIFF_SEC_WIDTH + USEC_PER_SEC_BITS;
  constant WIDE_WIDTH      : integer := PROD_WIDTH + 1;

  ---------------------------------------------------------------------------
  -- Transport-delay compensation (added 2026-07-31)
  --
  -- A timestamp is stamped at the MBU framer but only reaches this block after
  -- framer -> GT TX -> fibre -> GT RX -> deframer -> CDC. During that time the
  -- local clock keeps running, so (time_local - time_rx) contains that delay as
  -- a CONSTANT positive bias -- measured on HW at +720 ns: ts_off - pps_err was
  -- +720/+730/+730/+720 ns in all four cfg_mode settings, i.e. independent of
  -- which reference the servo was actually steering on.
  --
  -- The delay is a PIPELINE length, so its natural unit is clk cycles, and that
  -- unit does not change when the Subsecond tick unit changes. The offset
  -- arithmetic here is in ticks, so convert with a Q16 multiply (no divider):
  --     ticks = (cycles * DLY_SCALE_Q16) >> 16,
  --     DLY_SCALE_Q16 = round(2^16 * USEC_PER_SEC / CLK_HZ)
  --   10 ns tick @250 MHz -> 26214 : 180 cyc = 72 ticks = 720 ns   (exact)
  --    1 us  tick @250 MHz ->   262 : 180 cyc =  0 ticks (720 ns < 1 LSB, so
  --                                  this compensation is only meaningful once
  --                                  the tick is 10 ns -- another reason the
  --                                  unit change had to come first)
  -- Resolution is one tick = 2.5 clk cycles at 10 ns/250 MHz; the residue is
  -- below the 5 ns servo LSB, so no rounding term is needed.
  constant DLY_SCALE_W   : integer := 18;   -- holds 2^16 (USEC_PER_SEC = CLK_HZ)
  constant DLY_SCALE_Q16 : integer :=
    integer(round(65536.0 * real(USEC_PER_SEC) / real(CLK_HZ)));
  constant DLY_PROD_W    : integer := 16 + DLY_SCALE_W;

  -- >= 0 always; kept one bit narrower than ERR_WIDTH so signed('0' & x) is safe
  signal dly_ticks_reg : unsigned(ERR_WIDTH-2 downto 0) := (others => '0');

  -- Stage 0: sampled inputs
  signal sec_loc_samp  : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal usec_loc_samp : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');
  signal rx_sec_samp   : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal rx_usec_samp  : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');
  signal valid_s0      : std_logic := '0';

  -- Stage 1: diff + multiply
  signal diff_sec_reg   : signed(DIFF_SEC_WIDTH-1 downto 0)  := (others => '0');
  signal diff_usec_reg  : signed(DIFF_USEC_WIDTH-1 downto 0) := (others => '0');
  signal prod_sec_reg   : signed(PROD_WIDTH-1 downto 0)      := (others => '0');
  signal valid_s1       : std_logic := '0';

  -- Stage 2: final sum + output
  signal offset_us_reg  : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal offset_valid_r : std_logic := '0';

begin

  offset_us    <= offset_us_reg;
  offset_valid <= offset_valid_r;

  ---------------------------------------------------------------------------
  -- cycles -> ticks conversion of the configured transport delay.
  -- ts_delay_cyc is quasi-static (VIO/config register), so this is registered
  -- unconditionally every clock and needs no pipeline alignment; it is simply
  -- always ready by the time stage 2 uses it.
  ---------------------------------------------------------------------------
  process(clk)
    variable prod_v : unsigned(DLY_PROD_W-1 downto 0);
  begin
    if rising_edge(clk) then
      prod_v := ts_delay_cyc * to_unsigned(DLY_SCALE_Q16, DLY_SCALE_W);
      dly_ticks_reg <= resize(shift_right(prod_v, 16), ERR_WIDTH-1);
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Stage 0: sample input timestamps
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sec_loc_samp  <= (others => '0');
        usec_loc_samp <= (others => '0');
        rx_sec_samp   <= (others => '0');
        rx_usec_samp  <= (others => '0');
        valid_s0      <= '0';

      else
        valid_s0 <= '0';

        if rx_ts_valid = '1' then
          sec_loc_samp  <= sec_loc;
          usec_loc_samp <= usec_loc;
          rx_sec_samp   <= rx_sec;
          rx_usec_samp  <= rx_usec;
          valid_s0      <= '1';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Stage 1: compute diff_sec, diff_usec, prod_sec
  ---------------------------------------------------------------------------
  process(clk)
    variable diff_sec_v  : signed(DIFF_SEC_WIDTH-1 downto 0);
    variable diff_usec_v : signed(DIFF_USEC_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        diff_sec_reg  <= (others => '0');
        diff_usec_reg <= (others => '0');
        prod_sec_reg  <= (others => '0');
        valid_s1      <= '0';

      else
        valid_s1 <= '0';

        if valid_s0 = '1' then
          diff_sec_v  := signed('0' & sec_loc_samp)  - signed('0' & rx_sec_samp);
          diff_usec_v := signed('0' & usec_loc_samp) - signed('0' & rx_usec_samp);

          diff_sec_reg  <= diff_sec_v;
          diff_usec_reg <= diff_usec_v;
          prod_sec_reg  <= diff_sec_v * to_signed(USEC_PER_SEC, USEC_PER_SEC_BITS);
          valid_s1      <= '1';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Stage 2: final add
  ---------------------------------------------------------------------------
  process(clk)
    variable wide_error_v : signed(WIDE_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        offset_us_reg  <= (others => '0');
        offset_valid_r <= '0';

      else
        offset_valid_r <= '0';

        if valid_s1 = '1' then
          -- (local - rx) - transport_delay : the delay is a positive bias on
          -- (local - rx), so it is SUBTRACTED here.
          wide_error_v :=
            resize(prod_sec_reg, WIDE_WIDTH) +
            resize(diff_usec_reg, WIDE_WIDTH) -
            resize(signed('0' & dly_ticks_reg), WIDE_WIDTH);

          offset_us_reg  <= resize(wide_error_v, ERR_WIDTH);
          offset_valid_r <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;

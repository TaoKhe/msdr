library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vcxo_freq_error is
  generic (
    ERR_WIDTH            : integer := 32;     -- output error width (signed)
    EXPECTED_CLK_PER_REF : integer := 25;     -- expected fb-clk cycles per 10 MHz period
    MEAS_WINDOW_REFS     : integer := 100000; -- number of 10 MHz periods per error sample
    REF_TIMEOUT_CYCLES   : integer := 1000    -- max fb-clk cycles without ref edge before ref_ok drops
    );
  port (
    clk : in  std_logic; -- feedback clock to be measured (e.g. 250 MHz from VCXO divider)
    rst : in  std_logic; -- active-high synchronous reset

    -- external 10 MHz reference clock (asynchronous to clk, internally synchronized)
    ref_clk_10m : in  std_logic;

    -- 1-clock pulse when a new frequency-error sample is available
    freq_err_valid  : out std_logic;
    -- signed error in fb-clk cycles over one measurement window:
    --   measured_sum_cycles - (EXPECTED_CLK_PER_REF * MEAS_WINDOW_REFS)
    -- positive => measured fb clock is faster than expected
    -- negative => measured fb clock is slower than expected
    freq_err_cycles : out signed(ERR_WIDTH-1 downto 0);

    -- reference present/healthy flag: high after priming and while ref edges keep arriving
    ref_ok : out std_logic
    );
end entity;

architecture rtl of vcxo_freq_error is

  ---------------------------------------------------------------------------
  -- Return the larger of two integer constants.
  --
  -- Used at elaboration time to choose the worst-case period counter range
  -- from the nominal ref period and the timeout limit.
  ---------------------------------------------------------------------------
  function max_int(
    constant a : integer;
    constant b : integer
    ) return integer is
  begin
    if a > b then
      return a;
    else
      return b;
    end if;
  end function;

  ---------------------------------------------------------------------------
  -- Return the minimum unsigned vector width needed to represent max_v.
  --
  -- Example: max_v = 7 needs 3 bits, max_v = 8 needs 4 bits.
  -- The loop walks through 1, 2, 4, 8, ... and counts how many thresholds are
  -- needed to pass max_v. This is elaboration-time constant math only; it
  -- should not create runtime adders or loops in FPGA logic.
  ---------------------------------------------------------------------------
  function unsigned_width(
    constant max_v : integer
    ) return integer is
    variable limit_v : integer := 1;
    variable w : integer := 0;
  begin
    if max_v <= 0 then
      return 1;
    end if;

    while limit_v <= max_v loop
      w := w + 1;

      -- Avoid integer overflow before doubling the next threshold.
      if limit_v > integer'high - limit_v then
        return w;
      end if;

      limit_v := limit_v + limit_v;
    end loop;

    return w;
  end function;

  -- Keep the counters/adders sized to the configured measurement range.
  -- This avoids routing 32/56-bit datapaths when the VCXO reference window
  -- only needs a few dozen bits.
  constant PERIOD_MAX_C  : integer := max_int(EXPECTED_CLK_PER_REF, REF_TIMEOUT_CYCLES);
  constant PERIOD_CNT_W  : integer := unsigned_width(PERIOD_MAX_C);
  constant REF_CNT_W     : integer := unsigned_width(MEAS_WINDOW_REFS-1);
  -- Elaboration-time integer multiply used only to size err_acc_reg.
  -- It should not infer a runtime FPGA multiplier.
  -- Keep PERIOD_MAX_C * MEAS_WINDOW_REFS <= 2_147_483_647 for tools with
  -- 32-bit integer limits. With the default PERIOD_MAX_C = 1000, this means
  -- MEAS_WINDOW_REFS should be <= 2_147_483; the default 100_000 is safe.
  constant ERR_ACC_MAX_C : integer := PERIOD_MAX_C * MEAS_WINDOW_REFS;
  constant PERIOD_ERR_W  : integer := PERIOD_CNT_W + 1;
  constant ERR_ACC_W     : integer := unsigned_width(ERR_ACC_MAX_C) + 1;

  constant PERIOD_MAX_U : unsigned(PERIOD_CNT_W-1 downto 0) :=
    to_unsigned(PERIOD_MAX_C, PERIOD_CNT_W);

  constant REF_TIMEOUT_U : unsigned(PERIOD_CNT_W-1 downto 0) :=
    to_unsigned(REF_TIMEOUT_CYCLES, PERIOD_CNT_W);

  constant REF_LAST_U : unsigned(REF_CNT_W-1 downto 0) :=
    to_unsigned(MEAS_WINDOW_REFS-1, REF_CNT_W);

  constant EXPECTED_PERIOD_S : signed(PERIOD_ERR_W-1 downto 0) :=
    to_signed(EXPECTED_CLK_PER_REF, PERIOD_ERR_W);

  signal ref_meta   : std_logic := '0';
  signal ref_sync   : std_logic := '0';
  signal ref_sync_d : std_logic := '0';
  signal ref_rise_reg : std_logic := '0';

  signal primed_reg : std_logic := '0';

  signal cyc_cnt_reg : unsigned(PERIOD_CNT_W-1 downto 0) := (others => '0');
  signal ref_cnt_reg : unsigned(REF_CNT_W-1 downto 0) := (others => '0');

  signal timeout_cnt_reg : unsigned(PERIOD_CNT_W-1 downto 0) := (others => '0');

  signal freq_err_valid_reg : std_logic := '0';
  signal freq_err_reg       : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal ref_ok_reg         : std_logic := '0';
  signal period_pending_reg : std_logic := '0';
  signal period_last_reg    : std_logic := '0';
  signal period_capture_reg : unsigned(PERIOD_CNT_W-1 downto 0) := (others => '0');

  signal period_ext_pending_reg : std_logic := '0';
  signal period_ext_last_reg    : std_logic := '0';
  signal period_ext_reg         : signed(PERIOD_ERR_W-1 downto 0) := (others => '0');

  signal period_err_pending_reg : std_logic := '0';
  signal period_err_last_reg    : std_logic := '0';
  signal period_err_reg         : signed(PERIOD_ERR_W-1 downto 0) := (others => '0');

  signal err_acc_reg         : signed(ERR_ACC_W-1 downto 0) := (others => '0');
  signal acc_next_pending_reg : std_logic := '0';
  signal acc_next_last_reg    : std_logic := '0';
  signal acc_next_reg         : signed(ERR_ACC_W-1 downto 0) := (others => '0');
  signal err_out_pending_reg : std_logic := '0';
  signal err_out_reg         : signed(ERR_ACC_W-1 downto 0) := (others => '0');

begin

  assert EXPECTED_CLK_PER_REF > 0
    report "EXPECTED_CLK_PER_REF must be > 0"
    severity failure;

  assert MEAS_WINDOW_REFS > 0
    report "MEAS_WINDOW_REFS must be > 0"
    severity failure;

  assert REF_TIMEOUT_CYCLES > 0
    report "REF_TIMEOUT_CYCLES must be > 0"
    severity failure;

  freq_err_valid  <= freq_err_valid_reg;
  freq_err_cycles <= freq_err_reg;
  ref_ok          <= ref_ok_reg;

  ---------------------------------------------------------------------------
  -- Main synchronous measurement pipeline
  --
  -- All state updates happen on rising_edge(clk):
  --   1) synchronize/detect the async reference rising edge
  --   2) capture one feedback-clock period between reference edges
  --   3) convert that period into signed period error
  --   4) accumulate period errors over MEAS_WINDOW_REFS reference periods
  --   5) publish one signed frequency-error sample
  ---------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ref_meta   <= '0';
        ref_sync   <= '0';
        ref_sync_d <= '0';
        ref_rise_reg <= '0';

        primed_reg <= '0';

        cyc_cnt_reg <= (others => '0');
        ref_cnt_reg <= (others => '0');

        timeout_cnt_reg <= (others => '0');

        freq_err_valid_reg <= '0';
        freq_err_reg       <= (others => '0');
        ref_ok_reg         <= '0';
        period_pending_reg <= '0';
        period_last_reg    <= '0';
        period_capture_reg <= (others => '0');
        period_ext_pending_reg <= '0';
        period_ext_last_reg    <= '0';
        period_ext_reg         <= (others => '0');
        period_err_pending_reg <= '0';
        period_err_last_reg    <= '0';
        period_err_reg         <= (others => '0');
        err_acc_reg         <= (others => '0');
        acc_next_pending_reg <= '0';
        acc_next_last_reg    <= '0';
        acc_next_reg         <= (others => '0');
        err_out_pending_reg <= '0';
        err_out_reg         <= (others => '0');

      else
        -- 2FF synchronizer for async reference clock
        ref_meta   <= ref_clk_10m;
        ref_sync   <= ref_meta;
        ref_sync_d <= ref_sync;
        ref_rise_reg <= ref_sync and (not ref_sync_d);

        freq_err_valid_reg <= '0';

        -- Stage-3: publish the completed accumulated error.
        if err_out_pending_reg = '1' then
          freq_err_reg       <= resize(err_out_reg, ERR_WIDTH);
          freq_err_valid_reg <= '1';
          err_out_pending_reg <= '0';
        end if;

        -- Stage-2b: commit the registered accumulator result.
        if acc_next_pending_reg = '1' then
          if acc_next_last_reg = '1' then
            err_out_reg         <= acc_next_reg;
            err_out_pending_reg <= '1';
            err_acc_reg         <= (others => '0');
          else
            err_acc_reg <= acc_next_reg;
          end if;

          acc_next_pending_reg <= '0';
        end if;

        -- Stage-2a: accumulate one registered period error.
        if period_err_pending_reg = '1' then
          acc_next_reg <=
            err_acc_reg + resize(period_err_reg, ERR_ACC_W);
          acc_next_last_reg <= period_err_last_reg;
          acc_next_pending_reg <= '1';

          period_err_pending_reg <= '0';
        end if;

        -- Stage-1b: subtract nominal period from the registered extension.
        if period_ext_pending_reg = '1' then
          period_err_reg <= period_ext_reg - EXPECTED_PERIOD_S;
          period_err_last_reg <= period_ext_last_reg;
          period_err_pending_reg <= '1';
          period_ext_pending_reg <= '0';
        end if;

        -- Stage-1a: extend captured period count into signed math domain.
        if period_pending_reg = '1' then
          period_ext_reg <= resize(signed('0' & period_capture_reg), PERIOD_ERR_W);
          period_ext_last_reg <= period_last_reg;
          period_ext_pending_reg <= '1';
          period_pending_reg <= '0';
        end if;

        if timeout_cnt_reg < REF_TIMEOUT_U then
          timeout_cnt_reg <= timeout_cnt_reg + 1;
        end if;

        if cyc_cnt_reg < PERIOD_MAX_U then
          cyc_cnt_reg <= cyc_cnt_reg + 1;
        end if;

        if ref_rise_reg = '1' then
          timeout_cnt_reg <= (others => '0');

          if primed_reg = '0' then
            primed_reg   <= '1';
            cyc_cnt_reg  <= (others => '0');
            ref_cnt_reg  <= (others => '0');
            err_acc_reg  <= (others => '0');
            period_pending_reg <= '0';
            period_ext_pending_reg <= '0';
            period_err_pending_reg <= '0';
            acc_next_pending_reg <= '0';
            err_out_pending_reg <= '0';

          else
            period_capture_reg <= cyc_cnt_reg;
            cyc_cnt_reg <= (others => '0');

            if ref_cnt_reg = REF_LAST_U then
              period_last_reg    <= '1';
              period_pending_reg <= '1';

              ref_cnt_reg <= (others => '0');

            else
              period_last_reg    <= '0';
              period_pending_reg <= '1';

              ref_cnt_reg <= ref_cnt_reg + 1;
            end if;
          end if;
        end if;

        if (primed_reg = '1') and
          (timeout_cnt_reg < REF_TIMEOUT_U) then
          ref_ok_reg <= '1';
        else
          ref_ok_reg <= '0';
        end if;
      end if;
    end if;
  end process;

end architecture;

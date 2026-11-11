library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity error_combiner_filter is
  generic (
    ERR_WIDTH  : integer := 32;
    FILT_SHIFT : integer := 3; -- IIR factor: 1/2^FILT_SHIFT
    COMB_SHIFT : integer := 4  -- FULL_SYNC weight in combiner:
    -- comb = TS - (TS - PPS)/2^COMB_SHIFT
    );
  port (
    clk : in  std_logic; -- logic clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- control from top
    use_offset   : in  std_logic; -- enable timestamp-offset source
    use_pps      : in  std_logic; -- enable PPS-error source
    hold_filter  : in  std_logic; -- hold filtered output (HOLDOVER)
    clear_filter : in  std_logic; -- clear filter state (FREE_RUN)

    -- input from ts_offset_calc
    offset_valid : in  std_logic;                    -- 1-cycle valid pulse for offset_us
    offset_us    : in  signed(ERR_WIDTH-1 downto 0); -- timestamp offset error (microseconds)

    -- input from pps_cap
    pps_valid    : in  std_logic;                    -- 1-cycle valid pulse for pps_error_us
    pps_error_us : in  signed(ERR_WIDTH-1 downto 0); -- PPS phase error (microseconds)

    -- output to PI servo
    error_valid  : out std_logic;                    -- 1-cycle valid pulse for error_us
    error_us     : out signed(ERR_WIDTH-1 downto 0) -- combined/filtered control error
    );
end entity;

architecture rtl of error_combiner_filter is

  constant TEMP_WIDTH : integer := ERR_WIDTH + 4;

  ---------------------------------------------------------------------------
  -- Latest latched source values
  ---------------------------------------------------------------------------
  signal ts_err_reg  : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal pps_err_reg : signed(ERR_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- Stage 0 -> Stage 1 registers
  -- comb_mode_reg:
  --   "00" : no sample
  --   "01" : TS only
  --   "10" : PPS only
  --   "11" : FULL_SYNC (TS + PPS)
  ---------------------------------------------------------------------------
  signal comb_req_reg  : std_logic := '0';
  signal comb_mode_reg : std_logic_vector(1 downto 0) := "00";
  signal ts_sel_reg    : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal pps_sel_reg   : signed(ERR_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- Stage 1 -> Stage 2 registers
  ---------------------------------------------------------------------------
  signal comb_reg       : signed(TEMP_WIDTH-1 downto 0) := (others => '0');
  signal comb_valid_reg : std_logic := '0';

  ---------------------------------------------------------------------------
  -- Stage 2 output registers
  ---------------------------------------------------------------------------
  signal err_filt_reg    : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal error_valid_reg : std_logic := '0';

begin

  error_us    <= err_filt_reg;
  error_valid <= error_valid_reg;

  ---------------------------------------------------------------------------
  -- STAGE 0: latch latest TS/PPS and prepare selected values for combiner
  --
  -- Timing-friendly:
  --   only register/mux here, no wide arithmetic
  ---------------------------------------------------------------------------
  stage0_proc : process(clk)
    variable ts_next     : signed(ERR_WIDTH-1 downto 0);
    variable pps_next    : signed(ERR_WIDTH-1 downto 0);
    variable ts_fire     : std_logic;
    variable pps_fire    : std_logic;
    variable comb_mode_v : std_logic_vector(1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ts_err_reg     <= (others => '0');
        pps_err_reg    <= (others => '0');
        comb_req_reg   <= '0';
        comb_mode_reg  <= "00";
        ts_sel_reg     <= (others => '0');
        pps_sel_reg    <= (others => '0');

      else
        comb_req_reg  <= '0';
        comb_mode_reg <= "00";

        if clear_filter = '1' then
          ts_err_reg  <= (others => '0');
          pps_err_reg <= (others => '0');

        elsif hold_filter = '0' then
          ts_fire  := offset_valid and use_offset;
          pps_fire := pps_valid and use_pps;

          -- update latest source registers
          if ts_fire = '1' then
            ts_err_reg <= offset_us;
          end if;

          if pps_fire = '1' then
            pps_err_reg <= pps_error_us;
          end if;

          -- choose latest values (new if available, otherwise previous latched)
          ts_next  := ts_err_reg;
          if ts_fire = '1' then
            ts_next := offset_us;
          end if;

          pps_next := pps_err_reg;
          if pps_fire = '1' then
            pps_next := pps_error_us;
          end if;

          -- decide combination mode
          if (use_offset = '1') and (use_pps = '1') then
            if (ts_fire = '1') or (pps_fire = '1') then
              comb_mode_v := "11"; -- FULL_SYNC using latest latched values
              comb_req_reg <= '1';
            else
              comb_mode_v := "00";
            end if;

          elsif (use_offset = '1') then
            if ts_fire = '1' then
              comb_mode_v := "01"; -- TS only
              comb_req_reg <= '1';
            else
              comb_mode_v := "00";
            end if;

          elsif (use_pps = '1') then
            if pps_fire = '1' then
              comb_mode_v := "10"; -- PPS only
              comb_req_reg <= '1';
            else
              comb_mode_v := "00";
            end if;

          else
            comb_mode_v := "00";
          end if;

          comb_mode_reg <= comb_mode_v;
          ts_sel_reg    <= ts_next;
          pps_sel_reg   <= pps_next;
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- STAGE 1: compute comb
  --
  -- FULL_SYNC:
  --   comb = TS - (TS - PPS)/2^COMB_SHIFT
  --
  -- TS_ONLY:
  --   comb = TS
  --
  -- PPS_ONLY:
  --   comb = PPS
  ---------------------------------------------------------------------------
  stage1_proc : process(clk)
    variable ts_ext      : signed(TEMP_WIDTH-1 downto 0);
    variable pps_ext     : signed(TEMP_WIDTH-1 downto 0);
    variable diff_ext    : signed(TEMP_WIDTH-1 downto 0);
    variable scaled_ext  : signed(TEMP_WIDTH-1 downto 0);
    variable comb_next_v : signed(TEMP_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        comb_reg       <= (others => '0');
        comb_valid_reg <= '0';

      else
        comb_valid_reg <= '0';

        if clear_filter = '1' then
          comb_reg       <= (others => '0');
          comb_valid_reg <= '0';

        elsif (hold_filter = '0') and (comb_req_reg = '1') then
          ts_ext  := resize(ts_sel_reg, TEMP_WIDTH);
          pps_ext := resize(pps_sel_reg, TEMP_WIDTH);

          case comb_mode_reg is
            when "01" =>   -- TS only
              comb_next_v := ts_ext;

            when "10" =>   -- PPS only
              comb_next_v := pps_ext;

            when "11" =>   -- FULL_SYNC
              diff_ext := ts_ext - pps_ext;
              if COMB_SHIFT > 0 then
                scaled_ext := shift_right(diff_ext, COMB_SHIFT);
              else
                scaled_ext := diff_ext;
              end if;
              comb_next_v := ts_ext - scaled_ext;

            when others =>
              comb_next_v := (others => '0');
          end case;

          comb_reg       <= comb_next_v;
          comb_valid_reg <= '1';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- STAGE 2: IIR filter
  --   y(k+1) = y(k) + (comb - y(k))/2^FILT_SHIFT
  --
  -- HOLDOVER:
  --   giữ nguyên err_filt_reg, không phát error_valid
  ---------------------------------------------------------------------------
  stage2_proc : process(clk)
    variable filt_ext  : signed(TEMP_WIDTH-1 downto 0);
    variable delta_ext : signed(TEMP_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        err_filt_reg    <= (others => '0');
        error_valid_reg <= '0';

      else
        error_valid_reg <= '0';

        if clear_filter = '1' then
          err_filt_reg    <= (others => '0');
          error_valid_reg <= '0';

        elsif hold_filter = '1' then
          -- hold state, no update
          err_filt_reg    <= err_filt_reg;
          error_valid_reg <= '0';

        elsif comb_valid_reg = '1' then
          filt_ext  := resize(err_filt_reg, TEMP_WIDTH);
          delta_ext := comb_reg - filt_ext;

          if FILT_SHIFT > 0 then
            delta_ext := shift_right(delta_ext, FILT_SHIFT);
          end if;

          filt_ext       := filt_ext + delta_ext;
          err_filt_reg   <= resize(filt_ext, ERR_WIDTH);
          error_valid_reg <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vcxo_dac_mapper is
  generic (
    INC_WIDTH         : integer := 32;     -- width of servo increment domain
    DAC_BITS          : integer := 18;     -- DAC code width
    DAC_CODE_INIT     : integer := 131072; -- code used on reset/force_init
    DAC_CODE_CENTER   : integer := 131072; -- center code for zero inc_delta
    DAC_CODE_MIN      : integer := 0;      -- minimum allowed DAC code
    DAC_CODE_MAX      : integer := 262143; -- maximum allowed DAC code
    DAC_GAIN_SHIFT    : integer := 10;     -- scale: inc_delta / 2^DAC_GAIN_SHIFT
    DAC_SLEW_MAX_STEP : integer := 64      -- max code step per applied update
    );
  port (
    clk : in  std_logic; -- mapper clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- control
    force_init    : in  std_logic;                      -- high: force output back to DAC_CODE_INIT
    hold_code     : in  std_logic;                      -- high: freeze current DAC code
    enable_update : in  std_logic;                      -- 1-cycle request to compute/apply one update
    fb_valid      : in  std_logic;                      -- 1-cycle strobe: fb_code is valid readback
    fb_code       : in  unsigned(DAC_BITS-1 downto 0); -- DAC readback code from external DAC

    -- PI command
    inc_cmd     : in  unsigned(INC_WIDTH-1 downto 0); -- servo command increment
    inc_nominal : in  unsigned(INC_WIDTH-1 downto 0); -- nominal increment baseline

    -- DAC command output (grouped for external SPI wrapper)
    dac_code       : out unsigned(DAC_BITS-1 downto 0); -- DAC code command
    dac_code_valid : out std_logic;                      -- 1-cycle pulse when DAC code is applied

    -- status/monitor
    ready  : out std_logic; -- high: mapper can accept new enable_update
    sat_hi : out std_logic; -- saturation flag toward upper limit (anti-windup hint)
    sat_lo : out std_logic  -- saturation flag toward lower limit (anti-windup hint)
    );
end entity;

architecture rtl of vcxo_dac_mapper is

  constant WORK_W : integer := INC_WIDTH + 4;
  constant CODE_W : integer := DAC_BITS + 2;

  constant CODE_INIT_S : signed(CODE_W-1 downto 0) :=
    to_signed(DAC_CODE_INIT, CODE_W);
  constant CODE_MIN_S : signed(CODE_W-1 downto 0) :=
    to_signed(DAC_CODE_MIN, CODE_W);
  constant CODE_MAX_S : signed(CODE_W-1 downto 0) :=
    to_signed(DAC_CODE_MAX, CODE_W);

  constant CODE_CENTER_W_S : signed(WORK_W-1 downto 0) :=
    to_signed(DAC_CODE_CENTER, WORK_W);
  constant CODE_MIN_W_S : signed(WORK_W-1 downto 0) :=
    to_signed(DAC_CODE_MIN, WORK_W);
  constant CODE_MAX_W_S : signed(WORK_W-1 downto 0) :=
    to_signed(DAC_CODE_MAX, WORK_W);

  constant SLEW_MAX_S : signed(CODE_W-1 downto 0) :=
    to_signed(DAC_SLEW_MAX_STEP, CODE_W);

  constant SLEW_TO_TARGET : std_logic_vector(1 downto 0) := "00";
  constant SLEW_UP        : std_logic_vector(1 downto 0) := "01";
  constant SLEW_DOWN      : std_logic_vector(1 downto 0) := "10";

  signal code_reg   : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal sat_hi_reg : std_logic := '0';
  signal sat_lo_reg : std_logic := '0';
  signal ready_reg  : std_logic := '1';
  signal done_reg   : std_logic := '0';

  signal delta_pending_reg : std_logic := '0';
  signal raw_pending_reg   : std_logic := '0';
  signal pending_reg       : std_logic := '0';
  signal slew_pending_reg  : std_logic := '0';
  signal fb_clamp_pending_reg : std_logic := '0';
  signal code_load_stage_pending_reg : std_logic := '0';
  signal code_load_from_fb_reg : std_logic := '0';
  signal code_load_pending_reg : std_logic := '0';
  signal code_load_emit_reg    : std_logic := '0';
  signal delta_reg         : signed(WORK_W-1 downto 0) := (others => '0');
  signal raw_reg           : signed(WORK_W-1 downto 0) := (others => '0');
  signal fb_code_reg       : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal fb_clamped_reg    : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal fb_emit_reg       : std_logic := '0';
  signal target_reg        : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal slew_value_reg    : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal code_load_reg     : signed(CODE_W-1 downto 0) := CODE_INIT_S;
  signal slew_mode_reg     : std_logic_vector(1 downto 0) := SLEW_TO_TARGET;
  signal sat_hi_stage_reg : std_logic := '0';
  signal sat_lo_stage_reg : std_logic := '0';
  signal sat_hi_load_reg  : std_logic := '0';
  signal sat_lo_load_reg  : std_logic := '0';

  ---------------------------------------------------------------------------
  -- Clamp a wide raw DAC target into the configured legal code range.
  --
  -- raw_reg is still in WORK_W because it comes from center + scaled delta.
  -- The output is reduced to CODE_W only after the high/low comparisons, so
  -- negative or over-range values cannot wrap when assigned to target_reg.
  --
  -- sat_hi_v/sat_lo_v are inout so the caller can clear them before the call
  -- and this procedure only asserts the side that actually saturated.
  ---------------------------------------------------------------------------
  procedure clamp_raw(
    constant in_v : in signed(WORK_W-1 downto 0);
    variable out_v : out signed(CODE_W-1 downto 0);
    variable sat_hi_v : inout std_logic;
    variable sat_lo_v : inout std_logic
    ) is
    variable clamped_v : signed(WORK_W-1 downto 0);
  begin
    -- Default: pass through unchanged unless a limit is crossed.
    clamped_v := in_v;

    if in_v > CODE_MAX_W_S then
      clamped_v := CODE_MAX_W_S;
      sat_hi_v  := '1';
    end if;

    if in_v < CODE_MIN_W_S then
      clamped_v := CODE_MIN_W_S;
      sat_lo_v  := '1';
    end if;

    -- Now that the value is legal, it is safe to shrink to the DAC-code width.
    out_v := resize(clamped_v, CODE_W);
  end procedure;

begin

  dac_code <= unsigned(code_reg(DAC_BITS-1 downto 0));
  sat_hi   <= sat_hi_reg;
  sat_lo   <= sat_lo_reg;
  ready    <= ready_reg;
  dac_code_valid <= done_reg;

  ---------------------------------------------------------------------------
  -- Main synchronous DAC mapping pipeline
  --
  -- All state updates happen on rising_edge(clk). The pipeline keeps the
  -- expensive math away from code_reg/code_load_reg endpoints:
  --   1) capture inc_cmd - inc_nominal as delta_reg
  --   2) scale delta and add DAC center into raw_reg
  --   3) clamp raw DAC target into target_reg
  --   4) decide slew direction, then compute one slew-limited value
  --   5) hand off through code_load_reg and finally update code_reg
  --
  -- force_init and DAC feedback readback have priority over normal updates.
  ---------------------------------------------------------------------------
  process(clk)
    -- Clock-local temporary values. Each one is assigned before it is read in
    -- its branch, so these do not infer state by themselves.
    variable inc_delta_v : signed(WORK_W-1 downto 0);
    variable scaled_v    : signed(WORK_W-1 downto 0);
    variable target_v    : signed(CODE_W-1 downto 0);
    variable step_v      : signed(CODE_W-1 downto 0);
    variable sat_hi_v    : std_logic;
    variable sat_lo_v    : std_logic;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        code_reg   <= CODE_INIT_S;
        sat_hi_reg <= '0';
        sat_lo_reg <= '0';
        ready_reg  <= '1';
        done_reg   <= '0';
        delta_pending_reg <= '0';
        raw_pending_reg <= '0';
        pending_reg <= '0';
        slew_pending_reg <= '0';
        fb_clamp_pending_reg <= '0';
        code_load_stage_pending_reg <= '0';
        code_load_from_fb_reg <= '0';
        code_load_pending_reg <= '0';
        code_load_emit_reg <= '0';
        delta_reg <= (others => '0');
        raw_reg <= (others => '0');
        fb_code_reg <= CODE_INIT_S;
        fb_clamped_reg <= CODE_INIT_S;
        fb_emit_reg <= '0';
        target_reg <= CODE_INIT_S;
        slew_value_reg <= CODE_INIT_S;
        code_load_reg <= CODE_INIT_S;
        slew_mode_reg <= SLEW_TO_TARGET;
        sat_hi_stage_reg <= '0';
        sat_lo_stage_reg <= '0';
        sat_hi_load_reg <= '0';
        sat_lo_load_reg <= '0';

      else
        done_reg <= '0';
        ready_reg <= '0';
        sat_hi_reg <= '0';
        sat_lo_reg <= '0';

        -- Highest priority: force the mapper back to its known init code.
        if force_init = '1' then
          code_reg <= CODE_INIT_S;
          delta_pending_reg <= '0';
          raw_pending_reg <= '0';
          pending_reg <= '0';
          slew_pending_reg <= '0';
          fb_clamp_pending_reg <= '0';
          code_load_stage_pending_reg <= '0';
          code_load_from_fb_reg <= '0';
          code_load_pending_reg <= '0';
          code_load_emit_reg <= '0';
          fb_emit_reg <= '0';
          sat_hi_stage_reg <= '0';
          sat_lo_stage_reg <= '0';
          sat_hi_load_reg <= '0';
          sat_lo_load_reg <= '0';
          ready_reg <= '1';
          if code_reg /= CODE_INIT_S then
            done_reg <= '1';
          end if;

        -- Capture external DAC readback before clamping/loading it.
        elsif fb_valid = '1' then
          fb_code_reg <= resize(signed('0' & fb_code), CODE_W);
          fb_clamp_pending_reg <= '1';

          delta_pending_reg <= '0';
          raw_pending_reg <= '0';
          pending_reg <= '0';
          slew_pending_reg <= '0';
          code_load_stage_pending_reg <= '0';
          code_load_pending_reg <= '0';
          code_load_emit_reg <= '0';
          sat_hi_stage_reg <= '0';
          sat_lo_stage_reg <= '0';
          ready_reg <= '0';

        -- Clamp DAC readback to the configured legal code range.
        elsif fb_clamp_pending_reg = '1' then
          if fb_code_reg > CODE_MAX_S then
            target_v := CODE_MAX_S;
          elsif fb_code_reg < CODE_MIN_S then
            target_v := CODE_MIN_S;
          else
            target_v := fb_code_reg;
          end if;

          fb_clamped_reg <= target_v;
          if target_v /= code_reg then
            fb_emit_reg <= '1';
          else
            fb_emit_reg <= '0';
          end if;

          code_load_from_fb_reg <= '1';
          code_load_stage_pending_reg <= '1';
          fb_clamp_pending_reg <= '0';
          ready_reg <= '0';

        -- Select the prepared load value from either feedback or slew path.
        elsif code_load_stage_pending_reg = '1' then
          if code_load_from_fb_reg = '1' then
            code_load_reg <= fb_clamped_reg;
            code_load_emit_reg <= fb_emit_reg;
            sat_hi_load_reg <= '0';
            sat_lo_load_reg <= '0';
          else
            code_load_reg <= slew_value_reg;
            code_load_emit_reg <= '1';
            sat_hi_load_reg <= sat_hi_stage_reg;
            sat_lo_load_reg <= sat_lo_stage_reg;
          end if;

          code_load_stage_pending_reg <= '0';
          code_load_pending_reg <= '1';
          ready_reg <= '0';

        -- Final handoff into the externally visible DAC command register.
        elsif code_load_pending_reg = '1' then
          code_reg <= code_load_reg;
          sat_hi_reg <= sat_hi_load_reg;
          sat_lo_reg <= sat_lo_load_reg;
          done_reg <= code_load_emit_reg;

          code_load_pending_reg <= '0';
          code_load_emit_reg <= '0';
          ready_reg <= '1';

        elsif hold_code = '1' then
          null;

        -- Compute one slew-limited next value from the previously chosen mode.
        elsif slew_pending_reg = '1' then
          case slew_mode_reg is
            when SLEW_UP =>
              slew_value_reg <= code_reg + SLEW_MAX_S;

            when SLEW_DOWN =>
              slew_value_reg <= code_reg - SLEW_MAX_S;

            when others =>
              slew_value_reg <= target_reg;
          end case;

          code_load_from_fb_reg <= '0';
          code_load_stage_pending_reg <= '1';

          slew_pending_reg <= '0';
          ready_reg <= '0';

        -- Decide whether the next step goes to target, up by slew, or down.
        elsif pending_reg = '1' then
          slew_mode_reg <= SLEW_TO_TARGET;
          if DAC_SLEW_MAX_STEP > 0 then
            step_v := target_reg - code_reg;

            if step_v > SLEW_MAX_S then
              slew_mode_reg <= SLEW_UP;
            elsif step_v < -SLEW_MAX_S then
              slew_mode_reg <= SLEW_DOWN;
            end if;
          end if;

          pending_reg <= '0';
          slew_pending_reg <= '1';
          ready_reg <= '0';

        -- Clamp the raw center+scaled-delta value into the DAC target range.
        elsif raw_pending_reg = '1' then
          sat_hi_v := '0';
          sat_lo_v := '0';
          clamp_raw(raw_reg, target_v, sat_hi_v, sat_lo_v);
          target_reg <= target_v;
          sat_hi_stage_reg <= sat_hi_v;
          sat_lo_stage_reg <= sat_lo_v;

          raw_pending_reg <= '0';
          pending_reg <= '1';
          ready_reg <= '0';

        -- Apply gain shift and add DAC center. This feeds the clamp stage.
        elsif delta_pending_reg = '1' then
          scaled_v := delta_reg;
          if DAC_GAIN_SHIFT > 0 then
            scaled_v := shift_right(delta_reg, DAC_GAIN_SHIFT);
          end if;

          raw_reg <= CODE_CENTER_W_S + scaled_v;

          delta_pending_reg <= '0';
          raw_pending_reg <= '1';
          ready_reg <= '0';

        -- Accept a new mapper request only when the pipeline is idle.
        elsif enable_update = '1' then
          inc_delta_v :=
            resize(signed('0' & inc_cmd), WORK_W) -
            resize(signed('0' & inc_nominal), WORK_W);

          delta_reg <= inc_delta_v;
          delta_pending_reg <= '1';
          ready_reg <= '0';
        else
          ready_reg <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;

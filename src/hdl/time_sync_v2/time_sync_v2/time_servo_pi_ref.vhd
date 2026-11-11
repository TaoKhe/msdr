-- VANG (GOLDEN) CHI DUNG CHO MO PHONG: ban sao nguyen trang cua time_servo_pi
-- truoc khi them KP_SHIFT am / I_FRAC / INC_TRIM_MAX (PA2). tb_time_servo_pi so
-- tung chu ky ban moi (dat generic cu) voi file nay de chung minh khong hoi quy.
-- KHONG dua vao file_list.tcl -> khong anh huong tong hop.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_servo_pi_ref is
  generic (
    ERR_WIDTH   : integer := 32;
    INC_WIDTH   : integer := 32;
    KP_SHIFT    : integer := 10;        -- Kp = 1 / 2^KP_SHIFT
    KI_SHIFT    : integer := 18;        -- Ki = 1 / 2^KI_SHIFT
    STEP_THRESH : integer := 1000000    -- step threshold in µs
    );
  port (
    clk : in  std_logic; -- logic clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- control from top
    servo_enable    : in  std_logic; -- enable PI update on valid error samples
    hold_servo      : in  std_logic; -- freeze servo state (holdover mode)
    clear_servo     : in  std_logic; -- clear PI state and return to nominal increment
    allow_step      : in  std_logic; -- allow hard-step path on large errors
    i_freeze        : in  std_logic; -- freeze I integrator when actuator saturates

    -- filtered error input (microseconds)
    error_valid : in  std_logic;                    -- 1-cycle pulse for error_us
    error_us    : in  signed(ERR_WIDTH-1 downto 0); -- control error in microseconds

    -- nominal NCO increment
    inc_nominal : in  unsigned(INC_WIDTH-1 downto 0); -- nominal increment baseline

    -- outputs to NCO
    inc            : out unsigned(INC_WIDTH-1 downto 0); -- PI output increment command
    step_req       : out std_logic;                    -- 1-cycle hard-step request pulse
    step_offset_us : out signed(ERR_WIDTH-1 downto 0) -- hard-step offset in microseconds
    );
end entity;

architecture rtl of time_servo_pi_ref is

  ---------------------------------------------------------------------------
  -- Internal constants
  ---------------------------------------------------------------------------
  constant STEP_THR_POS : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(STEP_THRESH, ERR_WIDTH);

  constant STEP_THR_NEG : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(-STEP_THRESH, ERR_WIDTH);

  ---------------------------------------------------------------------------
  -- PI state
  ---------------------------------------------------------------------------
  signal inc_reg            : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal p_term_reg         : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal i_term_reg         : signed(INC_WIDTH-1 downto 0) := (others => '0');

  signal step_req_reg       : std_logic := '0';
  signal step_offset_us_reg : signed(ERR_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- Pipeline stage 1
  ---------------------------------------------------------------------------
  signal sample_valid_reg   : std_logic := '0';
  signal step_pending_reg   : std_logic := '0';
  signal step_offset_reg    : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal p_scaled_reg       : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal i_scaled_reg       : signed(INC_WIDTH-1 downto 0) := (others => '0');

begin

  inc            <= unsigned(inc_reg);
  step_req       <= step_req_reg;
  step_offset_us <= step_offset_us_reg;

  ----------------------------------------------------------------------------
  -- STAGE 1:
  --   - receive error sample
  --   - detect large-step condition
  --   - compute scaled P / I contributions
  --
  -- Timing:
  --   one compare + shift only, no adder chain here
  ----------------------------------------------------------------------------
  stage1_proc : process(clk)
    variable err_ext : signed(INC_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sample_valid_reg <= '0';
        step_pending_reg <= '0';
        step_offset_reg  <= (others => '0');
        p_scaled_reg     <= (others => '0');
        i_scaled_reg     <= (others => '0');

      else
        sample_valid_reg <= '0';
        step_pending_reg <= '0';

        if clear_servo = '1' then
          sample_valid_reg <= '0';
          step_pending_reg <= '0';
          step_offset_reg  <= (others => '0');
          p_scaled_reg     <= (others => '0');
          i_scaled_reg     <= (others => '0');

        elsif hold_servo = '1' then
          sample_valid_reg <= '0';
          step_pending_reg <= '0';

        elsif (servo_enable = '1') and (error_valid = '1') then
          sample_valid_reg <= '1';

          err_ext := resize(error_us, INC_WIDTH);

          -- hard step detection
          if ((error_us > STEP_THR_POS) or (error_us < STEP_THR_NEG)) and
            (allow_step = '1') then
            step_pending_reg <= '1';
            step_offset_reg  <= error_us;
            p_scaled_reg     <= (others => '0');
            i_scaled_reg     <= (others => '0');

          else
            step_pending_reg <= '0';
            step_offset_reg  <= (others => '0');

            -- P term: p = -error / 2^KP_SHIFT
            if KP_SHIFT > 0 then
              p_scaled_reg <= -shift_right(err_ext, KP_SHIFT);
            else
              p_scaled_reg <= -err_ext;
            end if;

            -- I delta: i_delta = error / 2^KI_SHIFT
            if KI_SHIFT > 0 then
              i_scaled_reg <= shift_right(err_ext, KI_SHIFT);
            else
              i_scaled_reg <= err_ext;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- STAGE 2:
  --   - if step_pending: request step, clear PI state, inc <- nominal
  --   - else normal PI update:
  --         i_next   = i_old - i_scaled
  --         inc_next = inc_nominal + p_scaled + i_next
  --         (with anti-windup: i_next = i_old when i_freeze = '1')
  --
  -- HOLD / CLEAR are handled here again for robustness.
  ----------------------------------------------------------------------------
  stage2_proc : process(clk)
    variable inc_nom_s : signed(INC_WIDTH-1 downto 0);
    variable i_next    : signed(INC_WIDTH-1 downto 0);
    variable inc_next  : signed(INC_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        inc_reg             <= signed(inc_nominal);
        p_term_reg          <= (others => '0');
        i_term_reg          <= (others => '0');
        step_req_reg        <= '0';
        step_offset_us_reg  <= (others => '0');

      else
        step_req_reg <= '0';

        if clear_servo = '1' then
          inc_reg            <= signed(inc_nominal);
          p_term_reg         <= (others => '0');
          i_term_reg         <= (others => '0');
          step_req_reg       <= '0';
          step_offset_us_reg <= (others => '0');

        elsif hold_servo = '1' then
          inc_reg            <= inc_reg;
          p_term_reg         <= p_term_reg;
          i_term_reg         <= i_term_reg;
          step_req_reg       <= '0';
          step_offset_us_reg <= (others => '0');

        elsif sample_valid_reg = '1' then
          inc_nom_s := signed(inc_nominal);

          if step_pending_reg = '1' then
            step_req_reg       <= '1';
            step_offset_us_reg <= step_offset_reg;

            p_term_reg <= (others => '0');
            i_term_reg <= (others => '0');
            inc_reg    <= inc_nom_s;

          else
            if i_freeze = '1' then
              i_next := i_term_reg;
            else
              i_next := i_term_reg - i_scaled_reg;
            end if;

            inc_next := inc_nom_s + p_scaled_reg + i_next;

            p_term_reg <= p_scaled_reg;
            i_term_reg <= i_next;
            inc_reg    <= inc_next;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;

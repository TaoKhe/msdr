library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_servo_pi is
  generic (
    ERR_WIDTH   : integer := 32;
    INC_WIDTH   : integer := 32;
    KP_SHIFT    : integer := 10;        -- Kp = 1 / 2^KP_SHIFT
    KI_SHIFT    : integer := 18;        -- Ki = 1 / 2^KI_SHIFT
    I_FRAC      : integer := 0;
    INC_TRIM_MAX: integer := 0;
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

architecture rtl of time_servo_pi is

  ---------------------------------------------------------------------------
  -- Internal constants
  ---------------------------------------------------------------------------
  constant STEP_THR_POS : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(STEP_THRESH, ERR_WIDTH);

  constant STEP_THR_NEG : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(-STEP_THRESH, ERR_WIDTH);

  ---------------------------------------------------------------------------
  -- Tach moi he so dich thanh CAP (dich phai, dich trai), mot trong hai luon
  -- bang 0. Khong duoc viet shift_right(x, KP_SHIFT) voi KP_SHIFT am: doi so
  -- thu hai cua shift_right/shift_left la NATURAL, mot hang so am lam HONG
  -- ELABORATE chu khong phai canh bao.
  ---------------------------------------------------------------------------
  function npos(x : integer) return natural is
  begin
    if x > 0 then
      return x;
    else
      return 0;
    end if;
  end function;

  constant KP_R : natural := npos( KP_SHIFT);
  constant KP_L : natural := npos(-KP_SHIFT);

  -- Dich thuc te cua nhanh I: error -> i_term da nhan 2^I_FRAC.
  --   i_delta = (error << I_FRAC) >> KI_SHIFT = error >> (KI_SHIFT - I_FRAC)
  -- I_SH < 0 => dich trai => KHONG con vung chet.
  constant I_SH : integer := KI_SHIFT - I_FRAC;
  constant KI_R : natural := npos( I_SH);
  constant KI_L : natural := npos(-I_SH);

  -- Be rong integrator mo rong (phan nguyen INC_WIDTH + I_FRAC bit le)
  constant IW : integer := INC_WIDTH + I_FRAC;

  constant I_LIM : signed(IW-1 downto 0) :=
    shift_left(to_signed(INC_TRIM_MAX, IW), I_FRAC);

  ---------------------------------------------------------------------------
  -- PI state
  ---------------------------------------------------------------------------
  signal inc_reg            : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal p_term_reg         : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal i_term_reg         : signed(IW-1 downto 0)        := (others => '0');

  signal step_req_reg       : std_logic := '0';
  signal step_offset_us_reg : signed(ERR_WIDTH-1 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- Pipeline stage 1
  ---------------------------------------------------------------------------
  signal sample_valid_reg   : std_logic := '0';
  signal step_pending_reg   : std_logic := '0';
  signal step_offset_reg    : signed(ERR_WIDTH-1 downto 0) := (others => '0');
  signal p_scaled_reg       : signed(INC_WIDTH-1 downto 0) := (others => '0');
  signal i_scaled_reg       : signed(IW-1 downto 0)        := (others => '0');

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
    variable err_w   : signed(IW-1 downto 0);
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
          err_w   := resize(error_us, IW);

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

            -- P term: p = -error * 2^-KP_SHIFT (KP_L = 0 khi KP_SHIFT >= 0,
            -- KP_R = 0 khi KP_SHIFT <= 0 -> dung mot phep dich duy nhat).
            -- Bien do: |error| bi time_sync_top chan o OUTLIER_THRESH_SUB (0.2 s
            -- = 4e7 sub-tick), nen voi KP_SHIFT = -2: |p| <= 1.6e8, va
            -- inc_nominal + p <= 1.88e9 < 2^31-1. Ha KP_SHIFT duoi -3 phai kiem
            -- tra lai bien nay.
            p_scaled_reg <= -shift_left(shift_right(err_ext, KP_R), KP_L);

            -- I delta tren mien da mo rong I_FRAC bit le
            i_scaled_reg <= shift_left(shift_right(err_w, KI_R), KI_L);
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
    variable i_next    : signed(IW-1 downto 0);
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

            -- Anti-windup: kep truc tiep trang thai I. Hieu luc o CA HAI che do
            -- (NCO so va VCXO/DAC), khac voi cong i_freeze chi song khi
            -- vcxo_ctrl_en = '1'.
            if INC_TRIM_MAX > 0 then
              if i_next > I_LIM then
                i_next := I_LIM;
              elsif i_next < -I_LIM then
                i_next := -I_LIM;
              end if;
            end if;

            inc_next := inc_nom_s + p_scaled_reg
                        + resize(shift_right(i_next, I_FRAC), INC_WIDTH);

            p_term_reg <= p_scaled_reg;
            i_term_reg <= i_next;
            inc_reg    <= inc_next;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;

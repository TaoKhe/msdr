library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity local_time_nco is
  generic (
    SECOND_WIDTH : integer := 40;
    USEC_WIDTH   : integer := 27;
    PHASE_WIDTH  : integer := 36;      -- NCO accumulator width; 36 @250MHz -> inc LSB ~ 3.6 ns/s rate trim
    ERR_WIDTH    : integer := 32;
    FRAC_BITS    : integer := 8;       -- sub-microsecond phase output width (1/2^FRAC_BITS us units)
    USEC_PER_SEC : integer := 1000000  -- scale-down for fast simulation only (HW: 1e6)
    );
  port (
    clk : in  std_logic; -- logic clock domain
    rst : in  std_logic; -- active-high synchronous reset

    -- NCO control input
    inc : in  unsigned(PHASE_WIDTH-1 downto 0); -- phase increment command

    -- hard-step control for large time errors
    step_req       : in  std_logic;                  -- 1-cycle request to apply hard time step
    step_offset_us : in  signed(ERR_WIDTH-1 downto 0); -- requested step offset in microseconds

    -- absolute time load (one-time coarse alignment): when load_req='1', set local time
    -- directly to {load_sec, load_usec} (overrides the natural tick AND the hard step).
    load_req  : in  std_logic := '0';
    load_sec  : in  unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
    load_usec : in  unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');

    -- local time outputs
    sec_loc  : out unsigned(SECOND_WIDTH-1 downto 0); -- local time seconds
    usec_loc : out unsigned(USEC_WIDTH-1 downto 0);   -- local time microseconds

    -- sub-microsecond phase: top FRAC_BITS of the NCO accumulator. Together with
    -- usec_loc this gives local phase with 1/2^FRAC_BITS us resolution (~3.9 ns
    -- at FRAC_BITS=8), coherent with usec_loc (updated in the same process).
    frac_us : out unsigned(FRAC_BITS-1 downto 0);

    -- debug/monitor
    tick_us : out std_logic -- 1-cycle pulse per generated microsecond
    );
end entity;

architecture rtl of local_time_nco is

  constant MAX_STEP_USEC : integer := USEC_PER_SEC - 1;

  constant MAX_STEP_POS : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(MAX_STEP_USEC, ERR_WIDTH);
  constant MAX_STEP_NEG : signed(ERR_WIDTH-1 downto 0) :=
    to_signed(-MAX_STEP_USEC, ERR_WIDTH);

  constant USEC_EXT_WIDTH : integer := USEC_WIDTH + 2;

  constant ZERO_USEC_S : signed(USEC_EXT_WIDTH-1 downto 0) :=
    to_signed(0, USEC_EXT_WIDTH);

  constant USEC_PER_SEC_S : signed(USEC_EXT_WIDTH-1 downto 0) :=
    to_signed(USEC_PER_SEC, USEC_EXT_WIDTH);

  signal phase_acc : unsigned(PHASE_WIDTH-1 downto 0) := (others => '0');
  signal sec_reg   : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal usec_reg  : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');
  signal tick_reg  : std_logic := '0';

begin

  sec_loc  <= sec_reg;
  usec_loc <= usec_reg;
  frac_us  <= phase_acc(PHASE_WIDTH-1 downto PHASE_WIDTH-FRAC_BITS);
  tick_us  <= tick_reg;

  process(clk)
    variable acc_ext       : unsigned(PHASE_WIDTH downto 0);
    variable tick_v        : std_logic;

    variable sec_next      : unsigned(SECOND_WIDTH-1 downto 0);
    variable usec_next     : unsigned(USEC_WIDTH-1 downto 0);

    variable err_sat_v     : signed(ERR_WIDTH-1 downto 0);
    variable delta_us_v    : signed(USEC_EXT_WIDTH-1 downto 0);
    variable usec_ext_v    : signed(USEC_EXT_WIDTH-1 downto 0);
    variable new_usec_ext_v: signed(USEC_EXT_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        phase_acc <= (others => '0');
        sec_reg   <= (others => '0');
        usec_reg  <= (others => '0');
        tick_reg  <= '0';

      else
        ---------------------------------------------------------------------
        -- 1) NCO phase update
        ---------------------------------------------------------------------
        acc_ext   := ('0' & phase_acc) + ('0' & inc);
        phase_acc <= acc_ext(PHASE_WIDTH-1 downto 0);
        tick_v    := acc_ext(PHASE_WIDTH);
        tick_reg  <= tick_v;

        ---------------------------------------------------------------------
        -- 2) default next-state = current state
        ---------------------------------------------------------------------
        sec_next  := sec_reg;
        usec_next := usec_reg;

        ---------------------------------------------------------------------
        -- 3) apply natural 1-us tick first
        ---------------------------------------------------------------------
        if tick_v = '1' then
          if usec_next = to_unsigned(USEC_PER_SEC - 1, USEC_WIDTH) then
            usec_next := (others => '0');
            sec_next  := sec_next + 1;
          else
            usec_next := usec_next + 1;
          end if;
        end if;

        ---------------------------------------------------------------------
        -- 4) apply hard step on top of updated time
        --    local_new = local - error
        ---------------------------------------------------------------------
        if step_req = '1' then
          err_sat_v := step_offset_us;

          if err_sat_v > MAX_STEP_POS then
            err_sat_v := MAX_STEP_POS;
          elsif err_sat_v < MAX_STEP_NEG then
            err_sat_v := MAX_STEP_NEG;
          end if;

          delta_us_v := resize(-err_sat_v, USEC_EXT_WIDTH);
          usec_ext_v := resize(signed('0' & usec_next), USEC_EXT_WIDTH);

          new_usec_ext_v := usec_ext_v + delta_us_v;

          if (new_usec_ext_v >= ZERO_USEC_S) and
            (new_usec_ext_v < USEC_PER_SEC_S) then

            usec_next := unsigned(new_usec_ext_v(USEC_WIDTH-1 downto 0));

          elsif new_usec_ext_v >= USEC_PER_SEC_S then
            new_usec_ext_v := new_usec_ext_v - USEC_PER_SEC_S;
            usec_next      := unsigned(new_usec_ext_v(USEC_WIDTH-1 downto 0));
            sec_next       := sec_next + 1;

          else
            new_usec_ext_v := new_usec_ext_v + USEC_PER_SEC_S;
            usec_next      := unsigned(new_usec_ext_v(USEC_WIDTH-1 downto 0));

            if sec_next /= (sec_next'range => '0') then
              sec_next := sec_next - 1;
            else
              sec_next := (others => '0');
            end if;
          end if;
        end if;

        ---------------------------------------------------------------------
        -- 4b) absolute load (one-time coarse alignment): force local time to
        --     {load_sec, load_usec}, overriding the natural tick / hard step this
        --     cycle, and restart the NCO phase cleanly at the load instant.
        ---------------------------------------------------------------------
        if load_req = '1' then
          sec_next  := load_sec;
          -- Defensive clamp: never load an out-of-range microsecond (>= USEC_PER_SEC) into
          -- usec_reg. The 1-us wrap test below is (usec = USEC_PER_SEC-1); if usec started
          -- beyond that point it would never wrap and the second counter would freeze forever.
          -- A valid RX Subsecond is always < 1e6; anything else is treated as 0.
          if load_usec < to_unsigned(USEC_PER_SEC, USEC_WIDTH) then
            usec_next := load_usec;
          else
            usec_next := (others => '0');
          end if;
          phase_acc <= (others => '0');
        end if;

        ---------------------------------------------------------------------
        -- 5) single write to registers
        ---------------------------------------------------------------------
        sec_reg  <= sec_next;
        usec_reg <= usec_next;
      end if;
    end if;
  end process;

end architecture;

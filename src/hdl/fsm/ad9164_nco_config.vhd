library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- AD9164 main-NCO frequency hopping controller (FFH, "Main NCO Frequency
-- Hopping" -- AD9164 datasheet Rev. D p.57).
--
-- The NCO FTW is updated in AUTOMATIC UPDATE mode instead of the
-- FTW_LOAD_REQ/ACK handshake: FTW_REQ_MODE (reg 0x113, bits[6:4]) = 0b110
-- makes the 48-bit FTW latch the instant the MSB byte FTW5 (reg 0x119) is
-- written. A hop is therefore the six FTW byte writes 0x114..0x119 in
-- ascending (LSB-first) order, and takes effect atomically on the final SPI
-- write. The byte order is functional, not cosmetic: writing 0x119 first
-- (as the old LOAD_REQ sequence did) would trigger the update while the
-- five lower bytes still hold the previous frequency.
--
-- One-time arming writes (repeated only after reset or after off_nco has
-- torn the NCO down):
--   0x111 = 0x40  NCO_EN, integer-NCO mode (Table 35). The previous value
--                 0x44 also set MODULUS_EN (bit 2) with ACC_MODULUS/ACC_DELTA
--                 left at 0 -- dual-modulus mode with an unprogrammed modulus.
--   0x113 = 0x60  FTW_REQ_MODE = 0b110: auto-update on FTW5 write.
--   0x800 = HOPF_MODE_CFG  hop phase behaviour (Table 37, bits[7:6]):
--                 00 phase continuous, 01 phase discontinuous (accumulator
--                 reset on every FTW update), 10 phase coherent (31-NCO bank).
entity ad9164_nco_config is
    port (
        clk           : in  std_logic; -- 300 MHz
        reset_n       : in  std_logic;
        start_config  : in  std_logic;
        off_nco       : in  std_logic;
        target_freq_hz: in  unsigned(31 downto 0); -- Input frequency in Hz

        -- SPI Master Interface
        spi_busy      : in  std_logic;
        spi_start     : out std_logic;
        spi_data      : out std_logic_vector(23 downto 0);
        done          : out std_logic;

        -- Debug taps for the fsm_main ILA (ila_fsm). Pure observers: they expose
        -- internal state so the AD9164 NCO reprogramming can be traced on hardware
        -- (which register, what FTW, in which state) without guessing from the
        -- serialized SPI bus alone.
        dbg_state     : out std_logic_vector(2 downto 0);  -- see STATE_CODE below
        dbg_reg_index : out std_logic_vector(3 downto 0);
        dbg_ftw       : out std_logic_vector(47 downto 0)  -- ftw_final (48-bit FTW)
    );
end entity;

architecture rtl of ad9164_nco_config is

    -- K = 2^48 / 3e9 = 93825 (0x16E81)
    constant CLK_RATIO_K : unsigned(47 downto 0) := x"000000016E81";

    -- Register table layout (see the process below):
    --   IDX_ARM_FIRST..IDX_ARM_LAST : arming writes (0x111 / 0x113 / 0x800)
    --   IDX_FTW_FIRST..IDX_HOP_LAST : FTW0..FTW5 (0x114..0x119, LSB first)
    --   IDX_NCO_OFF                 : single NCO-disable write (0x111 = 0x00)
    constant IDX_ARM_FIRST : integer := 0;
    constant IDX_FTW_FIRST : integer := 3;
    constant IDX_HOP_LAST  : integer := 8;
    constant IDX_NCO_OFF   : integer := 9;

    -- 0x800 HOPF_CTRL bits[7:6]: 00 = phase continuous switch (datasheet
    -- default). Change to x"40" for phase discontinuous (deterministic phase
    -- start on every hop) or x"80" for phase coherent via the 32-NCO bank.
    constant HOPF_MODE_CFG : std_logic_vector(7 downto 0) := x"00";

    type state_type is (IDLE, CALC_PIPE_1, CALC_PIPE_2, SEND_CMD, WAIT_START, WAIT_SPI, NEXT_REG, FINISHED);
    signal state      : state_type := IDLE;
    signal reg_index  : integer range 0 to 12 := 0;

    -- '1' once the arming writes have been delivered and the NCO is enabled in
    -- auto-update mode; subsequent hops then skip straight to the six FTW
    -- writes. Cleared by reset and by off_nco (which zeroes 0x111).
    signal nco_armed  : std_logic := '0';

    -- Calculation signals
    signal ftw_full   : unsigned(79 downto 0); -- 32-bit * 48-bit result
    signal ftw_final  : unsigned(47 downto 0);

    signal curr_addr  : std_logic_vector(15 downto 0);
    signal curr_data  : std_logic_vector(7 downto 0);

    -- Numeric encoding of state_type for the ILA (state_type itself is an enum and
    -- would be encoded by synthesis in an unpredictable way).
    function STATE_CODE (s : state_type) return std_logic_vector is
    begin
        case s is
            when IDLE        => return "000";
            when CALC_PIPE_1 => return "001";
            when CALC_PIPE_2 => return "010";
            when SEND_CMD    => return "011";
            when WAIT_START  => return "100";
            when WAIT_SPI    => return "101";
            when NEXT_REG    => return "110";
            when FINISHED    => return "111";
        end case;
    end function;

begin

    dbg_state     <= STATE_CODE(state);
    dbg_reg_index <= std_logic_vector(to_unsigned(reg_index, 4));
    dbg_ftw       <= std_logic_vector(ftw_final);

    -- Register table (AD9164 datasheet Rev. D, Table 45 register summary)
    process(reg_index, ftw_final)
    begin
        case reg_index is
            -- Arming writes (skipped on hops while nco_armed = '1')
            when 0  => curr_addr <= x"0111"; curr_data <= x"40";          -- NCO_EN, integer NCO (Table 35)
            when 1  => curr_addr <= x"0113"; curr_data <= x"60";          -- FTW_REQ_MODE = 0b110: auto-update on FTW5 write
            when 2  => curr_addr <= x"0800"; curr_data <= HOPF_MODE_CFG;  -- HOPF_CTRL: hop phase mode (Table 37)
            -- Hop: FTW LSB -> MSB; the 0x119 write is the hop instant
            when 3  => curr_addr <= x"0114"; curr_data <= std_logic_vector(ftw_final(7 downto 0));
            when 4  => curr_addr <= x"0115"; curr_data <= std_logic_vector(ftw_final(15 downto 8));
            when 5  => curr_addr <= x"0116"; curr_data <= std_logic_vector(ftw_final(23 downto 16));
            when 6  => curr_addr <= x"0117"; curr_data <= std_logic_vector(ftw_final(31 downto 24));
            when 7  => curr_addr <= x"0118"; curr_data <= std_logic_vector(ftw_final(39 downto 32));
            when 8  => curr_addr <= x"0119"; curr_data <= std_logic_vector(ftw_final(47 downto 40));
            when others => curr_addr <= x"0111"; curr_data <= x"00";      -- NCO Disable (off_nco entry, IDX_NCO_OFF)
        end case;
    end process;

    -- Control FSM
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state      <= IDLE;
            reg_index  <= 0;
            spi_start  <= '0';
            done       <= '0';
            nco_armed  <= '0';
            ftw_full   <= (others => '0');
            ftw_final  <= (others => '0');
        elsif rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    if start_config = '1' then
                        state <= CALC_PIPE_1;
                    elsif off_nco = '1' then
                        -- Disable NCO.
                        -- 2026-08-03 fix: was "reg_index <= 0", but index 0 is the
                        -- NCO_EN write. off_nco therefore replayed the whole register
                        -- burst and re-enabled the NCO with the previous hop's FTW
                        -- still loaded -- measured on hardware: during the 600 MHz
                        -- (PLL/LO) segment the DAC was held at the 1200 MHz FTW
                        -- 0x666666F48C00 and rewritten continuously. The "NCO Disable"
                        -- entry (0x0111 = 0x00) sits in the "when others" branch, which
                        -- the hop indices can never reach. Point off_nco at IDX_NCO_OFF
                        -- so that branch is selected, and it is a single write.
                        reg_index <= IDX_NCO_OFF;
                        nco_armed <= '0'; -- 0x111 is being zeroed: next hop must re-arm
                        state     <= SEND_CMD;
                    end if;
                -- Pipelined calculation for 300MHz timing closure
                when CALC_PIPE_1 =>
                    ftw_full <= target_freq_hz * CLK_RATIO_K;
                    state    <= CALC_PIPE_2;

                when CALC_PIPE_2 =>
                    ftw_final <= ftw_full(47 downto 0);
                    if nco_armed = '1' then
                        reg_index <= IDX_FTW_FIRST; -- fast hop: six FTW writes only
                    else
                        reg_index <= IDX_ARM_FIRST; -- first hop after reset/off: arm, then hop
                    end if;
                    state     <= SEND_CMD;

                when SEND_CMD =>
                    -- Frame: [W(0) + Addr(15 bits) + Data(8 bits)]
                    spi_data  <= curr_addr & curr_data;
                    spi_start <= '1';
                    state     <= WAIT_START;

                -- Wait for spi_master to ACCEPT the command (busy rises) before
                -- waiting for it to finish. Without this, WAIT_SPI samples busy
                -- one cycle too early (still '0'), races to NEXT_REG and the next
                -- register is issued while the master is busy -> it is dropped,
                -- losing every other register write.
                when WAIT_START =>
                    spi_start <= '0';
                    if spi_busy = '1' then
                        state <= WAIT_SPI;
                    end if;

                when WAIT_SPI =>
                    spi_start <= '0';
                    if spi_busy = '0' then
                        state <= NEXT_REG;
                    end if;

                when NEXT_REG =>
                    -- ">=" not "=": the off_nco path enters at IDX_NCO_OFF (the
                    -- NCO-disable entry), which is a single write and must terminate
                    -- here too. With "=" it would walk past the end of the range.
                    if reg_index >= IDX_HOP_LAST then
                        state <= FINISHED;
                    else
                        reg_index <= reg_index + 1;
                        state     <= SEND_CMD;
                    end if;

                when FINISHED =>
                    done  <= '1';
                    if reg_index = IDX_HOP_LAST then
                        nco_armed <= '1'; -- a hop sequence completed: NCO enabled + auto-update armed
                    end if;
                    state <= IDLE;

            end case;
        end if;
    end process;

end architecture;

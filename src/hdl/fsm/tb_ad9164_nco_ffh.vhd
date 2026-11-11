library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench for the FFH (Main NCO Frequency Hopping) rework of
-- ad9164_nco_config. Instantiates the real spi_master (24-bit, CLK_DIV=1,
-- exactly as fsm_main wires it), deserializes the MOSI stream, and checks
-- the exact register/value sequence:
--   1st hop after reset : 0x111=0x40, 0x113=0x60, 0x800=HOPF, FTW 0x114..0x119
--   2nd hop (armed)     : FTW 0x114..0x119 only (six writes, MSB 0x119 last)
--   off_nco             : single 0x111=0x00
--   hop after off       : full arm + FTW again
-- Run headless:
--   xvhdl --2008 spi_master.vhd ad9164_nco_config.vhd tb_ad9164_nco_ffh.vhd
--   xelab --relax tb_ad9164_nco_ffh -s tb_nco
--   xsim tb_nco -R
entity tb_ad9164_nco_ffh is
end entity;

architecture sim of tb_ad9164_nco_ffh is

    constant CLK_PERIOD : time := 3.333 ns; -- 300 MHz

    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal start_config : std_logic := '0';
    signal off_nco      : std_logic := '0';
    signal target_freq  : unsigned(31 downto 0) := (others => '0');
    signal spi_busy     : std_logic;
    signal spi_start    : std_logic;
    signal spi_data     : std_logic_vector(23 downto 0);
    signal done         : std_logic;
    signal sclk         : std_logic;
    signal mosi         : std_logic;
    signal ss_n         : std_logic;

    type word_arr_t is array (0 to 31) of std_logic_vector(23 downto 0);
    signal words  : word_arr_t := (others => (others => '0'));
    signal wcount : integer := 0;

    constant K : unsigned(47 downto 0) := x"000000016E81";

    function ftw_of(f : natural) return unsigned is
        variable p : unsigned(79 downto 0);
    begin
        p := to_unsigned(f, 32) * K;
        return p(47 downto 0);
    end function;

    -- FTW byte write expected at table position i (0 = 0x114/LSB .. 5 = 0x119/MSB)
    function ftw_word(ftw : unsigned(47 downto 0); i : integer) return std_logic_vector is
        variable addr : unsigned(15 downto 0);
    begin
        addr := to_unsigned(16#0114# + i, 16);
        return std_logic_vector(addr) & std_logic_vector(ftw(8*i + 7 downto 8*i));
    end function;

begin

    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.ad9164_nco_config
        port map (
            clk            => clk,
            reset_n        => reset_n,
            start_config   => start_config,
            off_nco        => off_nco,
            target_freq_hz => target_freq,
            spi_busy       => spi_busy,
            spi_start      => spi_start,
            spi_data       => spi_data,
            done           => done,
            dbg_state      => open,
            dbg_reg_index  => open,
            dbg_ftw        => open
        );

    spi : entity work.spi_master
        generic map (
            DATA_WIDTH => 24,
            CLK_DIV    => 1
        )
        port map (
            clk      => clk,
            reset_n  => reset_n,
            enable   => spi_start,
            tx_data  => spi_data,
            rx_data  => open,
            busy     => spi_busy,
            rx_valid => open,
            sclk     => sclk,
            mosi     => mosi,
            miso     => '0',
            ss_n     => ss_n
        );

    -- MOSI deserializer: mosi is updated on sclk falling edges, so it is
    -- stable at every rising edge; exactly 24 rising edges occur per frame.
    monitor : process
        variable sr : std_logic_vector(23 downto 0) := (others => '0');
        variable n  : integer := 0;
    begin
        wait until rising_edge(sclk);
        if ss_n = '0' then
            sr := sr(22 downto 0) & mosi;
            n  := n + 1;
            if n = 24 then
                words(wcount) <= sr;
                wcount        <= wcount + 1;
                n             := 0;
            end if;
        end if;
    end process;

    stimulus : process
        constant F1 : natural := 1_200_000_000;
        constant F2 : natural :=   600_000_000;
        variable exp    : word_arr_t;
        variable nexp   : integer := 0;
        variable nfail  : integer := 0;

        procedure hop(f : natural) is
        begin
            target_freq  <= to_unsigned(f, 32);
            wait until rising_edge(clk);
            start_config <= '1';
            wait until rising_edge(clk);
            start_config <= '0';
            wait until done = '1';
            wait until rising_edge(clk);
        end procedure;

        procedure nco_off is
        begin
            -- fsm_main holds off_nco high until dds_config_done and (being a
            -- registered output) releases it one clock AFTER done pulses. The
            -- DUT's IDLE therefore samples off_nco = '1' once more and issues a
            -- second, idempotent 0x111=0x00 write. That double-write is the real
            -- system behaviour (pre-existing, harmless) and is expected here.
            off_nco <= '1';
            wait until done = '1';
            wait until rising_edge(clk);
            off_nco <= '0';
            wait until done = '1'; -- the stray second off write
            wait for 5 * CLK_PERIOD; -- let the DUT settle back to IDLE
        end procedure;

        procedure expect_arm is
        begin
            exp(nexp)     := x"011140"; -- NCO_EN, integer NCO
            exp(nexp + 1) := x"011360"; -- FTW_REQ_MODE = 0b110 (auto-update on FTW5)
            exp(nexp + 2) := x"080000"; -- HOPF_CTRL: phase continuous
            nexp := nexp + 3;
        end procedure;

        procedure expect_ftw(f : natural) is
            variable ftw : unsigned(47 downto 0);
        begin
            ftw := ftw_of(f);
            for i in 0 to 5 loop
                exp(nexp) := ftw_word(ftw, i);
                nexp := nexp + 1;
            end loop;
        end procedure;

    begin
        wait for 10 * CLK_PERIOD;
        reset_n <= '1';
        wait for 5 * CLK_PERIOD;

        hop(F1);              expect_arm; expect_ftw(F1); -- full: arm + hop
        hop(F2);              expect_ftw(F2);             -- armed: 6 writes only
        nco_off;              exp(nexp) := x"011100"; exp(nexp + 1) := x"011100"; nexp := nexp + 2;
        hop(F1);              expect_arm; expect_ftw(F1); -- re-arm after off

        wait for 100 * CLK_PERIOD;

        if wcount /= nexp then
            report "word count mismatch: got " & integer'image(wcount) &
                   " expected " & integer'image(nexp) severity error;
            nfail := nfail + 1;
        end if;
        for i in 0 to nexp - 1 loop
            if words(i) /= exp(i) then
                report "word " & integer'image(i) & " mismatch: got x" &
                       to_hstring(words(i)) & " expected x" & to_hstring(exp(i))
                       severity error;
                nfail := nfail + 1;
            end if;
        end loop;

        if nfail = 0 then
            report "TB_RESULT: PASS (" & integer'image(wcount) & " SPI words verified)"
                severity note;
        else
            report "TB_RESULT: FAIL (" & integer'image(nfail) & " errors)"
                severity error;
        end if;
        std.env.finish;
    end process;

end architecture;

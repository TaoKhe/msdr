library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    generic (
        DATA_WIDTH : integer := 32;
        CLK_DIV    : integer := 5
    );
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        enable    : in  std_logic;
        tx_data   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rx_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        busy      : out std_logic;
        rx_valid  : out std_logic;
        sclk      : out std_logic;
        mosi      : out std_logic;
        miso      : in  std_logic;
        ss_n      : out std_logic
    );
end spi_master;

architecture Behavioral of spi_master is
    type state_type is (IDLE, LOAD, TRANSF, DONE);
    signal state         : state_type := IDLE;
    signal shift_reg_tx  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal shift_reg_rx  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal clk_cnt       : integer range 0 to CLK_DIV+1 := 0;
    signal bit_cnt       : integer range 0 to DATA_WIDTH := 0;
    signal sclk_int      : std_logic := '0';
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
            ss_n <= '1';
            --smosi <= '1';
            busy <= '0';
            rx_valid <= '0';
            sclk_int <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    busy <= '0';
                    ss_n <= '1';
                    sclk_int <= '0';
                    rx_valid <= '0';
                    if enable = '1' then
                        state <= LOAD;
                        busy <= '1';
                    end if;

                when LOAD =>
                    shift_reg_tx <= tx_data;
                    mosi <= tx_data(DATA_WIDTH-1); 
                    bit_cnt <= 0;
                    clk_cnt <= 0;
                    ss_n <= '0';
                    state <= TRANSF;

                when TRANSF =>
                    if clk_cnt >= CLK_DIV - 1 then
                        clk_cnt <= 0;
                        sclk_int <= not sclk_int;


                        if sclk_int = '0' then 
                            shift_reg_rx <= shift_reg_rx(DATA_WIDTH-2 downto 0) & miso;

                        else
                            if bit_cnt >= DATA_WIDTH - 1 then
                                state <= DONE;
                            else
                                mosi <= shift_reg_tx(DATA_WIDTH-2);
                                shift_reg_tx <= shift_reg_tx(DATA_WIDTH-2 downto 0) & '0';
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

                when DONE =>
                    rx_data <= shift_reg_rx;
                    rx_valid <= '1';
                    busy <= '0';
                    ss_n <= '1';
                    --mosi <= '1';
                    state <= IDLE;
            end case;
        end if;
    end process;

    sclk <= sclk_int;
end Behavioral;
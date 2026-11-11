library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--    spi_tx_csn_0        <= spi_tx_csn_s(0);--- ac61416 thresholds 
--    spi_tx_csn_1        <= spi_tx_csn_s(1);---dac61416 gates bias
--    spi_tx_csn_2        <= spi_tx_csn_s(2); ----CPLD on TX card
--    spi_tx_csn_3        <= spi_tx_csn_s(3);--DAC SMPS
--    spi_tx_csn_4        <= spi_tx_csn_s(4);--BITE Rx
--    spi_tx_csn_5        <= spi_tx_csn_s(5);-- FLASH
entity ub_tx_spi is
  port (
    spi_csn    : in    std_logic_vector(9 downto 0);
    spi_clk    : in    std_logic;
    spi_mosi   : in    std_logic;
    spi_miso_i : in    std_logic;
    spi_miso_o : out   std_logic;
    spi_sdio   : inout std_logic
  );
end entity ub_tx_spi;

architecture rtl of ub_tx_spi is

  -- Internal registers
  -- Initialized to 0 as in the Verilog code ('d0)
  signal spi_count   : unsigned(5 downto 0) := (others => '0');
  signal spi_rd_wr_n : std_logic := '0';
  signal spi_enable  : std_logic := '0';

  -- Internal signals
  signal spi_csn_s    : std_logic;
  signal spi_enable_s : std_logic;
  signal spi_miso_io  : std_logic;

  -- Component declaration for the external IO buffer
  component ad_iobuf is
    generic (
      DATA_WIDTH : integer := 1
    );
    port (
      dio_t : in    std_logic;
      dio_i : in    std_logic;
      dio_o : out   std_logic;
      dio_p : inout std_logic
    );
  end component ad_iobuf;

begin

  -- ==========================================
  -- Combinational logic
  -- ==========================================
  
  -- Equivalent to Verilog reduction AND: & spi_csn
  spi_csn_s <= '1' when spi_csn = "111111111" else '0';

  spi_enable_s <= spi_enable and ((not spi_csn(6)) or (not spi_csn(7)));

  -- Output multiplexer
  spi_miso_o <= spi_miso_io when (spi_enable_s = '1') else spi_miso_i;

  -- ==========================================
  -- Sequential logic 1 (Rising Edge)
  -- ==========================================
  process(spi_clk, spi_csn_s)
  begin
    if spi_csn_s = '1' then
      spi_count   <= (others => '0');
      spi_rd_wr_n <= '0';
    elsif rising_edge(spi_clk) then
      -- Increment counter up to 6'h3f (63)
      if spi_count < 63 then
        spi_count <= spi_count + 1;
      end if;

      if spi_count = 0 then
        spi_rd_wr_n <= spi_mosi;
      end if;
    end if;
  end process;

  -- ==========================================
  -- Sequential logic 2 (Falling Edge)
  -- ==========================================
  process(spi_clk, spi_csn_s)
  begin
    if spi_csn_s = '1' then
      spi_enable <= '0';
    elsif falling_edge(spi_clk) then
      if spi_count = 16 then
        spi_enable <= spi_rd_wr_n;
      end if;
    end if;
  end process;

  -- ==========================================
  -- IO Buffer Instantiation
  -- ==========================================

  spi_miso_io <= spi_sdio;
  spi_sdio <= spi_mosi when (spi_enable_s = '0') else 'Z';
  
end architecture rtl;
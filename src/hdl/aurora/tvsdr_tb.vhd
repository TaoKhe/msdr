library ieee;
use ieee.std_logic_1164.all;

entity tvsdr_tb is
end tvsdr_tb;

architecture behav of tvsdr_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component tvsdr_rfu
        port (
            -- System Interface
            rstn_i  : in std_logic;
            FPGA_CLK_300M_P: in std_logic;
            FPGA_CLK_300M_N: in std_logic;
--            -- GTX Reference Clock Interface
--            Aurora_refclk_p: in std_logic;
--            Aurora_refclk_n: in std_logic;
            tx_ref_clk     : in std_logic;
            -- GTX Serial I/O
            Aurora_Rxp : in std_logic_vector(0 downto 0);
            Aurora_Rxn : in std_logic_vector(0 downto 0);
            Aurora_Txp : out std_logic_vector(0 downto 0);
            Aurora_Txn : out std_logic_vector(0 downto 0)
        );
    end component;

    component tvsdr_mbu
        port (
            -- System Interface
            rstn_i  : in std_logic;
            FPGA_CLK_300M_P: in std_logic;
            FPGA_CLK_300M_N: in std_logic;
            -- GTX Reference Clock Interface
--            Aurora_refclk_p: in std_logic;
--            Aurora_refclk_n: in std_logic;
            tx_ref_clk     : in std_logic;
            -- GTX Serial I/O
            Aurora_Rxp : in std_logic_vector(0 downto 0);
            Aurora_Rxn : in std_logic_vector(0 downto 0);
            Aurora_Txp : out std_logic_vector(0 downto 0);
            Aurora_Txn : out std_logic_vector(0 downto 0)
        );
    end component;

    -- Signals for ports
    signal rstn_i  : std_logic := '0';
    signal FPGA_CLK_300M_P : std_logic := '0';
    signal FPGA_CLK_300M_N : std_logic := '1';  -- Differential, N is inverse of P
    signal Aurora_refclk_p : std_logic := '0';
    signal Aurora_refclk_n : std_logic := '1';  -- Differential
    signal Aurora1_Rxp : std_logic_vector(0 downto 0) := (others => '0');
    signal Aurora1_Rxn : std_logic_vector(0 downto 0) := (others => '1');  -- Differential
    signal Aurora1_Txp : std_logic_vector(0 downto 0);
    signal Aurora1_Txn : std_logic_vector(0 downto 0);
    
   -- signal Aurora_refclk_n : std_logic := '1';  -- Differential
    signal Aurora2_Rxp : std_logic_vector(0 downto 0) := (others => '0');
    signal Aurora2_Rxn : std_logic_vector(0 downto 0) := (others => '1');  -- Differential
    signal Aurora2_Txp : std_logic_vector(0 downto 0);
    signal Aurora2_Txn : std_logic_vector(0 downto 0);
    -- Clock periods (adjust as needed)
    constant CLK_300M_PERIOD : time := 3.333 ns;  -- 300 MHz
    constant REFCLK_PERIOD : time := 3.333 ns;  
    constant CLK_250M_PERIOD : time := 4 ns; 

begin

    -- Instantiate the Unit Under Test (UUT)
    uut1: tvsdr_rfu
        port map (
            rstn_i => rstn_i,
            FPGA_CLK_300M_P => FPGA_CLK_300M_P,
            FPGA_CLK_300M_N => FPGA_CLK_300M_N,
--            Aurora_refclk_p => Aurora_refclk_p,
--            Aurora_refclk_n => Aurora_refclk_n,
            tx_ref_clk => Aurora_refclk_p,
            Aurora_Rxp => Aurora1_Rxp,
            Aurora_Rxn => Aurora1_Rxn,
            Aurora_Txp => Aurora1_Txp,
            Aurora_Txn => Aurora1_Txn
        );
    uut2: tvsdr_mbu
        port map (
            rstn_i => rstn_i,
            FPGA_CLK_300M_P => FPGA_CLK_300M_P,
            FPGA_CLK_300M_N => FPGA_CLK_300M_N,
--            Aurora_refclk_p => Aurora_refclk_p,
--            Aurora_refclk_n => Aurora_refclk_n,
            tx_ref_clk => Aurora_refclk_p,
            Aurora_Rxp => Aurora2_Rxp,
            Aurora_Rxn => Aurora2_Rxn,
            Aurora_Txp => Aurora2_Txp,
            Aurora_Txn => Aurora2_Txn
        );
      Aurora2_Rxp <=   Aurora1_Txp;
      Aurora2_Rxn <=   Aurora1_Txn;
      Aurora1_Rxp <=   Aurora2_Txp;
      Aurora1_Rxn <=   Aurora2_Txn;
    -- Generate 300 MHz differential clock
    process
    begin
        FPGA_CLK_300M_P <= '0';
        FPGA_CLK_300M_N <= '1';
        wait for CLK_300M_PERIOD / 2;
        FPGA_CLK_300M_P <= '1';
        FPGA_CLK_300M_N <= '0';
        wait for CLK_300M_PERIOD / 2;
    end process;
    
    

    -- Generate Aurora reference differential clock
    process
    begin
        Aurora_refclk_p <= '0';
        Aurora_refclk_n <= '1';
        wait for REFCLK_PERIOD / 2;
        Aurora_refclk_p <= '1';
        Aurora_refclk_n <= '0';
        wait for REFCLK_PERIOD / 2;
    end process;

    -- Reset process (active low)
    process
    begin
        rstn_i <= '0';
        wait for 100 ns;  -- Hold reset for 100 ns
        rstn_i <= '1';
        wait;
    end process;

end behav;
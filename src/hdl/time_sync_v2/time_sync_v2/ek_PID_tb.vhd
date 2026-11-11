
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;

entity ek_PID_tb is
end ek_PID_tb;

architecture rtl of ek_PID_tb is

	component ek_PID
	  generic ( SECOND_WIDTH   	: integer := 40;
				USEC_WIDTH   	: integer := 27;
				ERR_WIDTH   	: integer := 32;
				USEC_PER_SEC    : integer := 1000000;
				DAC_BITS 		: integer := 18);
	  port     (clk 			: in   std_logic; -- logic clock domain
				rst 			: in   std_logic; -- active-high synchronous reset
				error_us  		: in   signed(ERR_WIDTH-1 downto 0);
				tick    		: in   std_logic;
				dac_ready		: in   std_logic;
				dac_code		: out  std_logic_vector(DAC_BITS-1 downto 0);
				dac_code_valid  : out  std_logic := '0');
		end component;

	constant SECOND_WIDTH   : integer := 40;
	constant USEC_WIDTH   	: integer := 27;
	constant ERR_WIDTH   	: integer := 32;
	constant USEC_PER_SEC   : integer := 1000000;
	constant DAC_BITS 		: integer := 18;		
	signal int  			: integer := 131071;
	signal clk 				: std_logic := '0'; -- logic clock domain
	signal nco_clk			: std_logic := '0'; -- logic clock domain
	signal rst 				: std_logic := '1'; -- active-high synchronous reset
	signal error_us  		: signed(ERR_WIDTH-1 downto 0) := (others => '0');
	signal summming			: integer := 1;
	signal tick    			: std_logic := '0';
	signal dac_ready		: std_logic := '1';
	signal dac_code			: std_logic_vector(DAC_BITS-1 downto 0);
	signal dac_code_valid  	: std_logic := '0';
	signal cnt 				: integer range 0 to 15 := 0;
	signal error_us_integer : integer := 0;

	begin
	
	process
		begin
			wait for 500 ps;
			nco_clk <= '0';
			wait for 500 ps;
			nco_clk <= '1';
		end process;
		
	process
		begin
			wait for 500 ns;
			clk <= '0';
			wait for 5.0 ns;
			clk <= '1';
		end process;
		
	process
		begin
			wait for 5.0 us;
			rst <= '0';
			wait;
		end process;
		
	error_us <= to_signed(error_us_integer, ERR_WIDTH);
	
	process(clk)
		begin
			if rising_edge(clk) then
				if (cnt = 15) then
					cnt <= 0;
					tick <= '1';
					if (error_us_integer = -262143) then
						error_us_integer <= error_us_integer + 1;
						summming <= +1;
					elsif (error_us_integer = 262143) then
						error_us_integer <= error_us_integer - 1;
						summming <= -1;
					else
						error_us_integer <= error_us_integer + summming;
					end if;
					
					cnt <= 0;
				else
					cnt <= cnt + 1;
					tick <= '0';
				end if;
			end if;
		end process;
	
		dut : ek_PID
			generic map(SECOND_WIDTH   	=> 40,
						USEC_WIDTH   	=> 27,
						ERR_WIDTH   	=> 32,
						USEC_PER_SEC    => 1000000,
						DAC_BITS 		=> 18)
			  port map (clk 			=> clk,
						rst 			=> rst,
						error_us  		=> error_us,
						tick    		=> tick,
						dac_ready		=> dac_ready,
						dac_code		=> dac_code,
						dac_code_valid  => dac_code_valid);
	
end architecture;

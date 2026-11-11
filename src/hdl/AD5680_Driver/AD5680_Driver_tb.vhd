----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: ADF41510_Driver_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gpio_types_pkg.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;

entity AD5680_Driver_tb is
end AD5680_Driver_tb;

architecture Behavioral of AD5680_Driver_tb is

	signal fsm_clk_in   	: STD_LOGIC := '0';
	signal dac_vcso_sync    : STD_LOGIC := '0';
	signal dac_vcso  		: STD_LOGIC := '0';
	signal dac_vcso_sclk   	: STD_LOGIC := '0';
    signal dac_data_in 		: std_logic_vector( 17 downto 0) := (others => '0');    

	
begin

	process
		begin
			wait for 5.0 ns;
			fsm_clk_in <= '0';
			wait for 5.0 ns;
			fsm_clk_in <= '1';
		end process;
			
	DUT  : entity work.AD5680_Driver
		Port map (clk   			=> fsm_clk_in,
				  dac_vcso_sync    	=> dac_vcso_sync,
				  dac_vcso  		=> dac_vcso,
				  dac_vcso_sclk   	=> dac_vcso_sclk,
				  dac_data_in		=> dac_data_in);
	
	process(fsm_clk_in)
		variable counter : integer range 0 to 10750 := 0;
		begin
			if rising_edge(fsm_clk_in) then
				if (counter = 10750) then
					counter := 0;
					dac_data_in <= dac_data_in + 100;
				else
					counter := counter + 1;
				end if;
			end if;
		end process;		
end Behavioral;

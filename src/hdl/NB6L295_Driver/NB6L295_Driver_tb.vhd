----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: NB6L295_Driver_tb - Behavioral
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

entity NB6L295_Driver_tb is
end NB6L295_Driver_tb;

architecture Behavioral of NB6L295_Driver_tb is

	signal clk   			: std_logic := '0';
	signal conf_NB6L295    	: std_logic := '0';
	signal spi_tx_mosi_in   : std_logic := '0';
	signal spi_tx_clk_in    : std_logic := '0';
	signal spi_tx_mosi_out  : std_logic := '0';
	signal spi_tx_clk_out   : std_logic := '0';
	signal dac_ph_en_1v8    : std_logic := '0';
	signal dac_ph_sload_1v8 : std_logic := '0';

begin

	process
		begin
			wait for 5.0 ns;
			clk 			<= '0';
			spi_tx_mosi_in 	<= '0';
			spi_tx_clk_in 	<= '1';
			wait for 5.0 ns;
			clk 			<= '1';
			spi_tx_mosi_in 	<= '1';
			spi_tx_clk_in 	<= '0';
		end process;
			
	process
		begin
			wait for 100.0 us;
			conf_NB6L295 <= '1';
			wait for 10.0 us;
			conf_NB6L295 <= '0';
		end process;
						  
	DUT  : entity work.NB6L295_Driver
    Port map   (clk       			=> clk,
				conf_NB6L295		=> conf_NB6L295,
				spi_tx_mosi_in   	=> spi_tx_mosi_in,
				spi_tx_clk_in		=> spi_tx_clk_in,
				spi_tx_mosi_out  	=> spi_tx_mosi_out,
				spi_tx_clk_out		=> spi_tx_clk_out,
				dac_ph_en_1v8     	=> dac_ph_en_1v8,
				dac_ph_sload_1v8  	=> dac_ph_sload_1v8);
		
end Behavioral;

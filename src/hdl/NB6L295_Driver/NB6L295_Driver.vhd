----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2026 15:09:14
-- Design Name: 
-- Module Name: NB6L295_Driver - Behavioral
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

entity NB6L295_Driver is
    Port (clk       		: in  std_logic;
          conf_NB6L295		: in  std_logic;
          spi_tx_mosi_in   	: in  std_logic;
          spi_tx_clk_in		: in  std_logic;
          spi_tx_mosi_out  	: out std_logic;
          spi_tx_clk_out	: out std_logic;
          dac_ph_en_1v8     : out std_logic;
   		  dac_ph_sload_1v8  : out std_logic);
end NB6L295_Driver;

architecture Behavioral of NB6L295_Driver is

	signal conf_NB6L295_mem : std_logic := '1';
	signal fsm_NB6L295		: integer range 0 to 30 := 0;
	signal clk_cnt			: integer range 0 to 9 := 0;
	signal switch_to_SPI	: std_logic := '1';
	signal spi_tx_clk_outs	: std_logic := '0';
	signal spi_tx_mosi_outs	: std_logic := '0';
	signal bit_cnt			: integer range 0 to 10 := 10;
	signal word_cnt			: integer range 0 to 1 := 0;
	type byte_array_2 is array (0 to 1) of std_logic_vector(10 downto 0);
	constant word			: byte_array_2 := ("00000000000",
											   "00000000001");
										
begin

	spi_tx_mosi_out <= spi_tx_mosi_in 	when (switch_to_SPI = '1') else spi_tx_mosi_outs;
	spi_tx_clk_out  <= spi_tx_clk_in 	when (switch_to_SPI = '1') else spi_tx_clk_outs;
	
	process(clk)
		begin	
			if rising_edge(clk) then
				if (clk_cnt = 9) then
					clk_cnt <= 0;
					conf_NB6L295_mem <= conf_NB6L295;
					if ((conf_NB6L295_mem = '0') and (conf_NB6L295 = '1')) then
						fsm_NB6L295 		<= 0;
						spi_tx_mosi_outs	<= '0';
						spi_tx_clk_outs		<= '0';
						dac_ph_en_1v8		<= '1';
						dac_ph_sload_1v8 	<= '0';
						bit_cnt 			<= 10;
						word_cnt 			<= 0;
					else
						case fsm_NB6L295 is
							when 0		=>	switch_to_SPI 		<= '0';
											fsm_NB6L295 		<= 1;
							when 1		=>	fsm_NB6L295 		<= 2;	
							when 2		=>	if (bit_cnt = 0) then
												bit_cnt 	<= 10;
												fsm_NB6L295 <= 4;
											else
												bit_cnt 		<= bit_cnt - 1;
												fsm_NB6L295 	<= 3;
											end if;
											spi_tx_mosi_outs	<= word(word_cnt)(bit_cnt);
											spi_tx_clk_outs		<= '0';
							when 3		=>	spi_tx_clk_outs		<= '1';
											fsm_NB6L295 		<= 2;
							when 4		=>	spi_tx_clk_outs		<= '1';
											fsm_NB6L295 		<= 5;
							when 5		=>	spi_tx_clk_outs		<= '0';
											fsm_NB6L295 		<= 6;
							when 6		=>	dac_ph_sload_1v8 	<= '1';
											fsm_NB6L295 		<= 7;
							when 7		=>	dac_ph_sload_1v8 	<= '0';
											fsm_NB6L295 	<= 8;
							when 8		=>	if (word_cnt = 1) then
												fsm_NB6L295 	<= 9;
												dac_ph_en_1v8 	<= '0';
											else
												word_cnt 		<= 1;
												bit_cnt 		<= 10;
												fsm_NB6L295 	<= 2;
											end if;
							when others =>	switch_to_SPI 		<= '1';
											spi_tx_mosi_outs	<= '0';
											spi_tx_clk_outs		<= '0';
											dac_ph_en_1v8		<= '0';
											dac_ph_sload_1v8 	<= '0';		
						end case;
					end if;
				else
					clk_cnt <= clk_cnt + 1;
				end if;
			end if;
		end process;
	
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.07.2026 15:57:21
-- Design Name: 
-- Module Name: gpio_band_decoder - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;

entity gpio_band_decoder is
    Port ( Freq_in 		: in std_logic_vector(31 downto 0);
           Set 			: in std_logic;
           Tx			: in std_logic;
           FSM_clk 		: in std_logic;
           Freq_error 	: out std_logic;
           gpio 		: out std_logic_vector (0 to 64));
end gpio_band_decoder;

architecture Behavioral of gpio_band_decoder is

	component gpio_BRAM
		  port (clka : in std_logic;
				addra : in std_logic_vector(6 DOWNTO 0);
				douta : out std_logic_vector(64 DOWNTO 0));
	end component;

	signal addra : std_logic_vector( 6 downto 0) := (others => '0');
	
begin

	process(FSM_clk)
		begin	
			if rising_edge(FSM_clk) then
				if (Set = '1') then
					if ((Freq_in < (30*10**6 - 1))) then
						Freq_error <= '1';
					else
						Freq_error <= '0';
					end if;
				end if;
			end if;
		end process;
		

	gpio_BRAM_inst : gpio_BRAM
	  PORT MAP (clka 	=> FSM_clk,
				addra 	=> addra,
				douta 	=> gpio);

end Behavioral;

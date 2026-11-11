----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: AD_9164_Driver - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;
use ieee.std_logic_arith.conv_std_logic_vector;

entity AD_9164_Driver_tb is
end AD_9164_Driver_tb;

architecture Behavioral of AD_9164_Driver_tb is

	signal clk		   		: STD_LOGIC := '0';
	signal enable  			: STD_LOGIC := '0';
	signal csn  			: STD_LOGIC := '0';
	signal mosi  			: STD_LOGIC := '0';
	signal sclk  			: STD_LOGIC := '0';
	signal Set_DAC_freq		: STD_LOGIC := '0';
	signal cnt				: integer range 0 to 2000 := 0;
	signal freq_in			: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

begin

	process
		begin
			wait for 2.5 ns;
			clk <= '0';
			wait for 2.5 ns;
			clk <= '1';
		end process;

	process
		begin
			wait for 350 us;
			enable <= '1';
		end process;
				
	process(clk)
		begin
			if rising_edge(clk) then
				if (cnt = 1000) then
					freq_in <= conv_std_logic_vector(1000*10**6, 32);
					Set_DAC_freq <= '1';
					cnt <= cnt + 1;
				elsif (cnt = 2000) then
					freq_in <= conv_std_logic_vector(1001*10**6, 32);
					Set_DAC_freq <= '1';
					cnt <= 0;
				else
					cnt <= cnt + 1;
					Set_DAC_freq <= '0';
				end if;
			end if;
		end process;
		
			
	DUT  : entity work.AD_9164_Driver
		Port map   (clk				=> clk,
					enable    		=> enable,
					freq_in    		=> freq_in,
					Set_DAC_freq	=> Set_DAC_freq,
					sclk      		=> sclk,
					csn        		=> csn,
					mosi			=> mosi);
					
end Behavioral;

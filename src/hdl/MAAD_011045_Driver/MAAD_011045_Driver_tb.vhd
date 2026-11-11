----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: MAAD_011045_Driver_tb - Behavioral
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

entity MAAD_011045_Driver_tb is
end MAAD_011045_Driver_tb;

architecture Behavioral of MAAD_011045_Driver_tb is

component MAAD_011045_Driver
    Port (clk    		: in   STD_LOGIC;
          enable    	: in   STD_LOGIC;
          att_sin    	: out  STD_LOGIC;
          att_clk     	: out  STD_LOGIC;
          att_le     	: out  STD_LOGIC;
          att_val  		: in   STD_LOGIC_VECTOR(5 downto 0));
end component;

	signal clk   	: STD_LOGIC := '0';
	signal att_le   : STD_LOGIC := '0';
	signal att_sin  : STD_LOGIC := '0';
	signal att_clk  : STD_LOGIC := '0';
	signal att_val  : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal enable   : STD_LOGIC := '0';

begin

	process
		begin
			wait for 3.3333 ns;
			clk <= '0';
			wait for 3.3333 ns;
			clk <= '1';
		end process;
	
	process
		begin
			wait for 1050 us;
			enable <= '1';
			wait;
		end process;
		
	process
		begin
			wait for 100 us;
			att_val <= "010100";
			wait for 100 us;
			att_val <= "011100";
		end process;
			
	DUT  : MAAD_011045_Driver
		Port map (clk       => clk,
				  enable	=> enable,
				  att_le    => att_le,
				  att_sin   => att_sin,
				  att_clk   => att_clk,
				  att_val   => att_val);
					
end Behavioral;

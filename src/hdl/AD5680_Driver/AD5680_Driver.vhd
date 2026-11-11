----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2026 15:09:14
-- Design Name: 
-- Module Name: AD5680_Driver - Behavioral
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

entity AD5680_Driver is
    Port (clk       	: in  std_logic;
          dac_vcso_sync : out std_logic;
          dac_vcso      : out std_logic;
          dac_vcso_sclk	: out std_logic;
          dac_data_in	: in  std_logic_vector(17 downto 0));
end AD5680_Driver;

architecture Behavioral of AD5680_Driver is

    type fsm_reset_type is (write, wait10);
    signal fsm_reset    	: fsm_reset_type := wait10;   
	signal reg_mem			: std_logic_vector(23 downto 0) := x"000000";
	signal dac_vcso_sclks	: integer range 0 to 3 := 0;
	signal clk_cnt			: std_logic := '0';
	signal toggle			: std_logic := '0';
	signal bit_cnt			: integer range 0 to 23 := 23;
	signal wait_cnt			: integer range 0 to 10752 := 0;
										
begin

	reg_mem <= "0000" & dac_data_in & "00";
	
	process(clk)
		begin	
			if rising_edge(clk) then
			
				clk_cnt <= not clk_cnt;
				
				if (clk_cnt = '0') then
					case fsm_reset is
						when 	write	=>	toggle <= not toggle;
											if (toggle = '0') then
												dac_vcso_sync   <= '0';
												dac_vcso_sclk	<= '1';
												dac_vcso    	<= reg_mem(bit_cnt);
											else
												dac_vcso_sclk	<= '0';
												bit_cnt     	<= bit_cnt - 1;
												if (bit_cnt = 0) then
													fsm_reset   <= wait10;
												end if;
											end if;	
						when 	wait10	=>	if (wait_cnt = 10752) then -- 9300 Hz repetition rate
												fsm_reset   	<= write;
												wait_cnt		<= 0;
											else
												wait_cnt 		<= wait_cnt + 1;
											end if;
											dac_vcso_sync   <= '1';
											dac_vcso_sclk	<= '1';
											dac_vcso    	<= '0';
											bit_cnt     	<= 23;  
						when others 	=>	fsm_reset   	<= write;
											dac_vcso_sync   <= '1';
											dac_vcso_sclk	<= '1'; 
											dac_vcso    	<= '0';
											bit_cnt     	<= 23;  
					end case;
				end if;
			end if;
		end process;
	
end Behavioral;

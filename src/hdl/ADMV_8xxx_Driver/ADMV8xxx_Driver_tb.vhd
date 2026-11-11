----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: ADMV8xxx_Driver_tb - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use ieee.std_logic_arith.conv_std_logic_vector;

entity ADMV8xxx_Driver_tb is
end ADMV8xxx_Driver_tb;

architecture Behavioral of ADMV8xxx_Driver_tb is

	signal fsm_clk   		: STD_LOGIC := '0';
	signal PP_An_B  		: STD_LOGIC_VECTOR(1 downto 0) := "00";
	signal enable_fsm		: STD_LOGIC := '0';
	signal Set				: STD_LOGIC := '0';
	signal hb_1_tbpf_csn  	: STD_LOGIC := '0';
	signal hb_2_tbpf_csn  	: STD_LOGIC := '0';
	signal hb_3_tbpf_csn  	: STD_LOGIC := '0';
	signal hb_4_tbpf_csn  	: STD_LOGIC := '0';
	signal hb_tbpf_sdi  	: STD_LOGIC := '0';
	signal hb_tbpf_sdo  	: STD_LOGIC := '0';
	signal hb_tbpf_sclk  	: STD_LOGIC := '0';
	signal sclk_mem  		: STD_LOGIC := '0';
	signal cnt		  		: integer range 0 to 40000 := 0;
	signal freq_in			: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

begin

	process
		begin
			wait for 5.0 ns;
			fsm_clk <= '0';
			wait for 5.0 ns;
			fsm_clk <= '1';
		end process;
	
	process
		begin
			wait for 550.0 us;
			enable_fsm <= '1';
		end process;
		
	process(fsm_clk)
		begin
			if rising_edge(fsm_clk) then
				case cnt is
					when 10000	=>	freq_in <= conv_std_logic_vector (800*10**6, 32);
									PP_An_B <= PP_An_B + 1;
									Set 	<= '1';
									cnt 	<= cnt + 1;
		
					when 20000	=>	freq_in <= conv_std_logic_vector (900*10**6, 32);
									PP_An_B	<= PP_An_B + 1;
									Set 	<= '1';
									cnt 	<= cnt + 1;
		
					when 30000	=>	freq_in <= conv_std_logic_vector (1600*10**6, 32);
									PP_An_B <= PP_An_B + 1;
									Set 	<= '1';
									cnt 	<= cnt + 1;
		
					when 40000	=>	freq_in <= conv_std_logic_vector (1700*10**6, 32);
									PP_An_B	<= PP_An_B + 1;
									Set 	<= '1';
									cnt 	<= 0;
									
					when others	=>	cnt 	<= cnt + 1;
									Set 	<= '0';
				end case;
			end if;
		end process;
			
	DUT  : entity work.ADMV8xxx_Driver
		Port map   (fsm_clk				=> fsm_clk,
					enable				=> enable_fsm,
    	   			freq_in          	=> freq_in,
    	   			Set					=> Set,
					PP          		=> PP_An_B(1),
					hb_tbpf_sdi        	=> hb_tbpf_sdi,
					hb_tbpf_sdo        	=> hb_tbpf_sdo,
					hb_tbpf_sclk       	=> hb_tbpf_sclk,
					hb_1_tbpf_csn      	=> hb_1_tbpf_csn,
					hb_2_tbpf_csn      	=> hb_2_tbpf_csn,
					hb_3_tbpf_csn      	=> hb_3_tbpf_csn,
					hb_4_tbpf_csn      	=> hb_4_tbpf_csn);
					
end Behavioral;

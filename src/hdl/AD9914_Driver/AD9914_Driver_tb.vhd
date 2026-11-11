----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2026 17:20:25
-- Design Name: 
-- Module Name: AD9914_Driver_tb - Behavioral
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

entity AD9914_Driver_tb is
end AD9914_Driver_tb;

architecture Behavioral of AD9914_Driver_tb is

	signal dds_a_sync_clk    :  STD_LOGIC := '0';
	signal dds_b_sync_clk    :  STD_LOGIC := '0';
	signal fsm_clk           :  STD_LOGIC := '0';
	signal dds_data          :  STD_LOGIC_VECTOR(31 downto 5) := (others => '0');
	signal dds_a_syncio      :  STD_LOGIC := '0';
	signal dds_b_syncio      :  STD_LOGIC := '0';
	signal dds_sdo           :  STD_LOGIC := '0';
	signal dds_sdio          :  STD_LOGIC := '0';
	signal dds_scl           :  STD_LOGIC := '0';
	signal dds_dav_a         :  STD_LOGIC := '0';
	signal dds_dav_b         :  STD_LOGIC := '0';
	signal dds_a_0_csn       :  STD_LOGIC := '0';
	signal dds_b_0_csn       :  STD_LOGIC := '0';
	signal dds_in            :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal reset             :  STD_LOGIC := '0';
	signal dds_a_ioupdate    :  STD_LOGIC := '0';
	signal dds_b_ioupdate    :  STD_LOGIC := '0';
	signal DDS_MASTER_RESET  :  STD_LOGIC := '0';
	signal cnt    			 :  integer range 0 to 4000 := 0; 
	
begin
	process
		begin
			wait for 4.0 ns;
			dds_a_sync_clk <= '0';
			dds_b_sync_clk <= '1';
			wait for 4.0 ns;
			dds_a_sync_clk <= '1';
			dds_b_sync_clk <= '0';
		end process;

	process
		begin
			wait for 3.3333 ns;
			fsm_clk <= '0';
			wait for 3.3333 ns;
			fsm_clk <= '1';
		end process;
	
	process
		begin
			wait for 1050 us;
			reset <= '1';
			wait for 3.3333 ns;
			reset <= '0';
		end process;
		

	process(fsm_clk)
		begin
			if rising_edge(fsm_clk) then
				case cnt is
					when 1000	=>	dds_in 		<= x"AAAAAAAA"; -- 301 MHz
									dds_dav_a 	<= '1';
									cnt			<= cnt + 1;
	
					when 2000 	=>	dds_in 		<= x"BBBBBBBB";
									dds_dav_b 	<= '1';
									cnt			<= cnt + 1;
	
					when 3000 	=>	dds_in 		<= x"CCCCCCCC";
									dds_dav_a 	<= '1';
									cnt			<= cnt + 1;
	
					when 4000 	=>	dds_in 		<= x"DDDDDDDD";
									dds_dav_b 	<= '1';
									cnt			<= 0;
									
					when others =>	cnt			<= cnt + 1;
									dds_dav_a 	<= '0';
									dds_dav_b 	<= '0';
				end case;
			end if;
		end process;
			
	DUT  : entity work.AD9914_Driver
		generic map(Delay_cnt => 1000) -- 1000 for simulation otherwise 75000000
		Port map   (dds_a_sync_clk    => dds_a_sync_clk,
					dds_b_sync_clk    => dds_b_sync_clk,
					fsm_clk           => fsm_clk,
					dds_data          => dds_data,
					dds_a_syncio      => dds_a_syncio,
					dds_b_syncio      => dds_b_syncio,
					dds_sdo           => dds_sdo,
					dds_sdio          => dds_sdio,
					dds_scl           => dds_scl,
					dds_a_0_csn       => dds_a_0_csn,
					dds_b_0_csn       => dds_b_0_csn,
					dds_in            => dds_in,
					dds_dav_a         => dds_dav_a,
					dds_dav_b         => dds_dav_b,
					reset             => reset,
					dds_a_ioupdate    => dds_a_ioupdate,
					dds_b_ioupdate    => dds_b_ioupdate,
					DDS_MASTER_RESET  => DDS_MASTER_RESET);
				
end Behavioral;

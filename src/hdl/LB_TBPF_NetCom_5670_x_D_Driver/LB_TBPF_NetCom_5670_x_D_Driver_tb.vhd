----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2026 10:03:18
-- Design Name: 
-- Module Name: LB_TBPF_NetCom_5670_x_D_Driver - Behavioral
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

entity LB_TBPF_NetCom_5670_x_D_Driver_tb is
end LB_TBPF_NetCom_5670_x_D_Driver_tb;

architecture Behavioral of LB_TBPF_NetCom_5670_x_D_Driver_tb is

	signal fsm_clk   		: STD_LOGIC := '0';
	signal PP_An_B  		: STD_LOGIC := '0';
	signal tune_rdy_1		: STD_LOGIC := '0';
	signal tune_rdy_2		: STD_LOGIC := '0';
	signal lb_tx_tbpf1_csn  : STD_LOGIC := '0';
	signal lb_tx_tbpf2_csn  : STD_LOGIC := '0';
	signal lb_tx_tbpf_mosi  : STD_LOGIC := '0';
	signal lb_tx_tbpf_sclk  : STD_LOGIC := '0';
	signal sclk_mem  		: STD_LOGIC := '0';
	signal freq_in			: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
	signal enable     		: STD_LOGIC := '0';
	signal tune_rdy_cnt		: integer range 0 to 2999 := 0;

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
			enable <= '0';
			wait for 1050 us;
			enable <= '1';
			wait;
		end process;
		
	process
		begin
			wait for 100 us;
			freq_in <= x"1EFE9200";
			PP_An_B 		<= not PP_An_B;
			wait for 100 us;
			freq_in <= x"01C9C380";
			PP_An_B 		<= not PP_An_B;
		end process;
		
	process(fsm_clk)
		begin
			if rising_edge(fsm_clk) then
				sclk_mem <= lb_tx_tbpf_sclk;
				if ((sclk_mem = '1') and (lb_tx_tbpf_sclk = '0')) then
					tune_rdy_cnt <= 0;
					if (PP_An_B = '1') then
						tune_rdy_1 <= '0';
					else
						tune_rdy_2 <= '0';
					end if;
				else
					if (tune_rdy_cnt = 2999) then
						if (PP_An_B = '1') then
							tune_rdy_1 <= '1';
						else
							tune_rdy_2 <= '1';
						end if;
					else
						tune_rdy_cnt <= tune_rdy_cnt + 1;
					end if;
				end if;
			end if;
		end process;
			
	DUT  : entity work.LB_TBPF_NetCom_5670_x_D_Driver
		Port map   (fsm_clk				=> fsm_clk,
					freq_in          	=> freq_in,
					enable          	=> enable,
					tune_rdy_1          => tune_rdy_1,
					tune_rdy_2          => tune_rdy_2,
					PP          		=> PP_An_B,
					sclk          		=> lb_tx_tbpf_sclk,
					csn1          		=> lb_tx_tbpf1_csn,
					csn2          		=> lb_tx_tbpf2_csn,
					mosi				=> lb_tx_tbpf_mosi);
					
end Behavioral;

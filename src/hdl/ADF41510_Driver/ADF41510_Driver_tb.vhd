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
library UNISIM;
use UNISIM.VComponents.all;

entity ADF41510_Driver_tb is
end ADF41510_Driver_tb;

architecture Behavioral of ADF41510_Driver_tb is

	signal fsm_clk_in   : STD_LOGIC := '0';
	signal MUX_A2    : STD_LOGIC := '0';
	signal pll_le    : STD_LOGIC := '0';
	signal pll_data  : STD_LOGIC := '0';
	signal pll_clk   : STD_LOGIC := '0';
	signal INT_A    : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	signal INT_B    : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	signal reset     : STD_LOGIC := '0';
	signal PLL_A_NB     : STD_LOGIC := '0';
	signal PLL_B_NB     : STD_LOGIC := '0';
    signal dds_a_in : std_logic_vector( 31 downto 0) := (others => '0');    
    signal dds_b_in : std_logic_vector( 31 downto 0) := (others => '0');   
    signal dds_a_in_mem : std_logic_vector( 31 downto 0) := (others => '0'); 							  
	signal dds_b_in_mem : std_logic_vector( 31 downto 0) := (others => '0'); 							  
	signal reset_cnt : integer range 0 to 100000000 := 100000; 							  
--	signal reset_cnt : integer range 0 to 100000000 := 100000000; 							  	
	signal cycle_cnt_A : integer range 0 to 400 := 0; 	
	signal cycle_cnt_B : integer range 0 to 400 := 0; 	
	
begin

	process
		begin
			wait for 5.0 ns;
			fsm_clk_in <= '0';
			wait for 5.0 ns;
			fsm_clk_in <= '1';
		end process;
	
	process
		begin
			wait for 130 ms;
			MUX_A2 <= '1';
			wait for 1 ms;
			MUX_A2 <= '0';
		end process;
		
	process
		begin
			wait for 30 ms;
				dds_a_in 			<= x"12345678";
				dds_b_in 			<= x"ABCDEF01";
				INT_A				<= "0101010";
				INT_B				<= "1111111";
			wait for 30 ms;
				dds_b_in 			<= x"12345678";
				dds_a_in 			<= x"ABCDEF01";
				INT_B				<= "0101010";
				INT_A				<= "1111111";
		end process;
 
    process(fsm_clk_in)
    	begin
    		if rising_edge(fsm_clk_in) then    		
    		    dds_a_in_mem <= dds_a_in;
    		    dds_b_in_mem <= dds_b_in;
    		    
    			if (dds_a_in_mem /= dds_a_in) then
    				cycle_cnt_A <= 0;
    			end if;
    
				if  (cycle_cnt_A = 400) then
					PLL_A_NB		<= '1';
				else
					PLL_A_NB		<= '0';
					cycle_cnt_A 	<= cycle_cnt_A + 1;
				end if;

    			if (dds_b_in_mem /= dds_b_in) then
    				cycle_cnt_B <= 0;
    			end if;
    
				if  (cycle_cnt_B = 400) then
					PLL_B_NB		<= '1';
				else
					PLL_B_NB		<= '0';
					cycle_cnt_B 	<= cycle_cnt_B + 1;
				end if;
				
				if (MUX_A2 = '1') then
					reset 	  <= '1';
					reset_cnt <= 1000;
				elsif (reset_cnt > 15) then
					reset_cnt <= reset_cnt - 1;
					reset 	  <= '0';
				elsif (reset_cnt = 0) then
					reset 	  <= '0';
				else
					reset_cnt <= reset_cnt - 1;
					reset 	  <= '1';
				end if;
    		end if;
    	end process;
			
	DUT  : entity work.ADF41510_Driver
		Port map (fsm_clk   => fsm_clk_in,
				  pll_le    => pll_le,
				  pll_data  => pll_data,
				  pll_clk   => pll_clk,
				  reset     => reset,
				  INT_in    => INT_A);
					
end Behavioral;

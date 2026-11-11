----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2026 15:09:14
-- Design Name: 
-- Module Name: ADF41510_Driver - Behavioral
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

entity ADF41510_Driver is
    Port (fsm_clk       : in  std_logic;
          pll_le        : out std_logic;
          pll_data      : out std_logic;
          pll_clk      	: out std_logic;
          enable		: in  std_logic;
          INT_in        : in  std_logic_vector(6 downto 0));
end ADF41510_Driver;

architecture Behavioral of ADF41510_Driver is

    type fsm_reset_type is (reset_0, reset_1, some_clks, check_INT, set_Reg_0);
    signal fsm_reset    : fsm_reset_type := reset_0;   
	type reg_array is array(1 to 13) of std_logic_vector(31 downto 0);
	constant reg_mem	: reg_array := (x"1FFFFFF1", -- R1 -- Frac 1
										x"00000002", -- R2
										x"00000003", -- R3 -- Frac 3
										x"00000004", -- R4
										x"5E430005", -- R5 R divider on = 3
										x"001C8086", -- R6
										--x"009C8086", -- R6 PD pol inverted
										x"04200007", -- R7
										x"00000008", -- R8
										x"00000009", -- R9
										x"0000000A", -- R10
										x"8000000B", -- R11
										x"4800000C", -- R12 Mux out N
										--x"3800000C", -- R12 Mux out R
										x"0000000D");-- R13
	signal reg_pointer	: integer range 0 to 13 := 0;
	signal spi_clk		: integer range 0 to 3 := 0;
	signal pll_clk_cnt	: integer range 0 to 3 := 0;
	signal pll_clks		: std_logic := '0';
	signal first_time	: std_logic := '1';
	signal bit_cnt		: integer range 0 to 40 := 33;
	signal Reg_0		: std_logic_vector(10 downto 0);
	signal INT_in_mem_0	: std_logic_vector(6 downto 0) := "0000000";
	signal INT_in_mem_1	: std_logic_vector(6 downto 0) := "0000000";
										
begin

	Reg_0 <= INT_in & "0000";
	
	process(fsm_clk)
		begin	
			if rising_edge(fsm_clk) then
			
				INT_in_mem_0 <= INT_in;
				INT_in_mem_1 <= INT_in_mem_0;
				
				if (enable = '0') then -- to initialize ADF41510
					fsm_reset 	<= reset_0;
					pll_le  	<= '0';
					pll_data  	<= '1';
					pll_clk_cnt	<= 0;
					pll_clks 	<= '0';
					spi_clk 	<= 0;
					bit_cnt		<= 33;
					reg_pointer	<= 13;
					first_time	<= '1';
				else
					case fsm_reset is
						when 	reset_0	=>	if (spi_clk = 3) then
												case bit_cnt is
													when  2 to 33  =>  	bit_cnt     <= bit_cnt - 1;
																		pll_data    <= reg_mem(reg_pointer)(bit_cnt - 2);
													when  	1  	    =>  bit_cnt     <= bit_cnt - 1;
																		pll_le      <= '1';
													when 	0      =>   fsm_reset   <= reset_1; 
																		reg_pointer <= reg_pointer - 1;
																		bit_cnt     <= 33;  
													when others    =>   bit_cnt     <= bit_cnt - 1;
												end case;
												spi_clk 	<= 0;
												pll_clks 	<= '0';
												pll_clk_cnt <= 0;
											else
												spi_clk 	<= spi_clk + 1;
												
												if (spi_clk = 1) then
													if (bit_cnt /= 0) then
														pll_clks 	<= '1';
														pll_le      <= '0';  
													end if;
												end if;
											end if;
						when 	reset_1	=>	if (reg_pointer = 0) then
												fsm_reset   <= some_clks;
												bit_cnt		<= 20;
												pll_clk_cnt	<= 3;
											else
												fsm_reset   <= reset_0;
												bit_cnt		<= 33; 
											end if;
											pll_le      <= '0';  
											
						when some_clks  =>	if (bit_cnt > 0) then
												if (pll_clk_cnt = 1) then
													pll_clks	<= '1';
													bit_cnt		<= bit_cnt - 1;
												end if;
												if (pll_clk_cnt /= 3) then
													pll_clk_cnt	<= pll_clk_cnt + 1;
												else
													pll_clk_cnt	<= 0;
													pll_clks	<= '0';
												end if;
											else
												if (pll_clk_cnt /= 3) then
													pll_clk_cnt	<= pll_clk_cnt + 1;
												else
													bit_cnt		<= 33; 
													fsm_reset   <= check_INT;
													pll_clk_cnt	<= 0;
													pll_clks	<= '0';
												end if;
											end if;
											pll_data    <= '0';
											pll_le  	<= '0';
						when check_INT	=>	if ((INT_in_mem_1 /= INT_in_mem_0) or (first_time = '1')) then		-- to update R0 with new INT value			
												fsm_reset   <= set_Reg_0;
												bit_cnt     <= 12;
												pll_le      <= '0';
												pll_clk_cnt	<= 0;
												pll_clks	<= '0';
											else
												if (pll_clk_cnt = 1) then
													pll_clks	<= '1';
												elsif (pll_clk_cnt = 3) then
													pll_clks	<= '0';
												end if;
												if (pll_clk_cnt = 3) then
													pll_clk_cnt	<= 0;
												else
													pll_clk_cnt	<= pll_clk_cnt + 1;
												end if;  -- clock is continuous to save time at INT change
											end if;
											pll_data    <= '0';
											spi_clk 	<= 0;
											first_time	<= '0';
						when set_Reg_0	=>	if (spi_clk = 3) then
												case bit_cnt is
													when  2 to 12   =>  bit_cnt     <= bit_cnt - 1;
																		pll_data    <= Reg_0(bit_cnt - 2);
																		pll_clks	<= '0';
													when  	1  	    =>  bit_cnt     <= bit_cnt - 1;
																		pll_data    <= '0';
																		pll_clks	<= '1';
																		pll_le      <= '1';
													when 	0       =>  fsm_reset   <= check_INT;
																		bit_cnt     <= 33;
																		pll_le      <= '0';
													when others     =>  bit_cnt     <= 33;
												end case;
												spi_clk <= 0;
											else
												if (spi_clk = 1) then
													if (bit_cnt /= 0) then
														pll_clks	<= '1';
													end if;
												end if;
												spi_clk <= spi_clk + 1;
											end if;
						when others 	=>	fsm_reset   <= reset_0;
											pll_clks	<= '0';
					end case;
				end if;
			end if;
		end process;

	pll_clk <= pll_clks;
	
end Behavioral;

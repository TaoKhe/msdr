----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2026 17:24:39
-- Design Name: 
-- Module Name: MAAD_011045_Driver - Behavioral
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
--use work.gpio_types_pkg.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;

entity MAAD_011045_Driver is
    Port (clk    		: in   STD_LOGIC;
          enable    	: in   STD_LOGIC;
          att_sin    	: out  STD_LOGIC;
          att_clk     	: out  STD_LOGIC;
          att_le     	: out  STD_LOGIC;
          att_val  		: in   STD_LOGIC_VECTOR(5 downto 0));
end MAAD_011045_Driver;

architecture Behavioral of MAAD_011045_Driver is

    type fsm_att_type is (att_0, att_1, att_2);
    signal fsm_att          : fsm_att_type := att_0;
    signal reset_vector     : std_logic_vector(5 downto 0) := (others => '1');
    signal att_val_mem_0    : std_logic_vector(5 downto 0) := (others => '0');
    signal att_val_mem_1    : std_logic_vector(5 downto 0) := (others => '0');
    signal spi_clk_cnt      : integer range 0 to 31 := 0;
    signal bit_cnt          : integer range 0 to 9 := 9;   
    signal rewrite_cnt      : integer range 0 to 65535 := 0;  
    signal from_reset		: std_logic := '1'; 
    
begin
                                                   
    process(clk)
        begin
            if rising_edge(clk) then
            	att_val_mem_0 <= att_val;
            	att_val_mem_1 <= att_val_mem_0;
            	
            	if (enable = '0') then
            		fsm_att <= att_0;
            		reset_vector <= (others => '1');
            		from_reset <= '1';
            	elsif ((att_val_mem_1 /= att_val_mem_0) or (from_reset = '1')) then
            		reset_vector	<= att_val;
            		fsm_att 		<= att_0;
            		from_reset 		<= '0';
            	else
					case fsm_att is
					   when att_0     =>  	att_sin        	<= '0';
											att_clk        	<= '0';
											att_le       	<= '0';
											spi_clk_cnt 	<= 0;
											bit_cnt			<= 9;
											fsm_att 		<= att_1;
					   when att_1     =>  	if (spi_clk_cnt = 9) then
													case bit_cnt is
													when  9  		=>  bit_cnt       <= bit_cnt - 1;
																		att_clk       <= '0';
													when  3 to 8    =>  bit_cnt       <= bit_cnt - 1;
																		att_sin       <= reset_vector(bit_cnt - 3);
																		bit_cnt       <= bit_cnt - 1;
																		att_clk       <= '0';
													when  2   		=>  bit_cnt       <= bit_cnt - 1;
																		att_clk       <= '0';
													when  1   		=>  att_le        <= '1';
																		bit_cnt       <= bit_cnt - 1;
													when others    =>   att_le        <= '0';  -- wait a reset otain attenuator change 
																		fsm_att 	  <= att_2;             
												end case;
												spi_clk_cnt <= 0;
											else
												spi_clk_cnt <= spi_clk_cnt + 1;
												if ((spi_clk_cnt = 4) and (bit_cnt > 1)) then
													att_clk <= '1';
												end if;
											end if;                                                                
						when others    =>   if (rewrite_cnt = 65535) then
												fsm_att <= att_0;
												rewrite_cnt <= 0;
											else
												rewrite_cnt <= rewrite_cnt + 1;
											end if;                      
					end case;
				end if;
			end if;
        end process;

end Behavioral;

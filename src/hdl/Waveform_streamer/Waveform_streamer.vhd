----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2026 13:05:41
-- Design Name: 
-- Module Name: Waveform_streamer - Behavioral
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

entity Waveform_streamer is
    Port (  clk				: in  std_logic;
			rst				: in  std_logic;
			IQout_tlast     : out std_logic:= '0';
			IQout_tdata     : out std_logic_vector (31 downto 0) := (others => '0');
			IQout_tvalid    : out std_logic:= '0');  
end Waveform_streamer;

architecture Behavioral of Waveform_streamer is

	component Wavefor_storer_4k
		port (	clka 	: in  std_logic;
				addra 	: in  std_logic_vector(11 downto 0);
				douta 	: out std_logic_vector(31 downto 0));
	end component;
	
	signal Wavefor_storer_4k_addra : std_logic_vector(11 downto 0) := (others => '0');
	
begin

	IQout_tvalid <= '1';
	
	Wavefor_storer_4k_inst : Wavefor_storer_4k
		port map (	clka 	=> clk,
					addra 	=> Wavefor_storer_4k_addra,
					douta 	=> IQout_tdata);
					
	process(clk)
		begin
			if rising_edge(clk) then
				if (rst = '1') then
					Wavefor_storer_4k_addra <= (others => '0');
				else
					if (Wavefor_storer_4k_addra = "111111111111") then
						Wavefor_storer_4k_addra <= "000001100000";
					else
						Wavefor_storer_4k_addra <= Wavefor_storer_4k_addra + 1;
					end if;
				end if;
				if (Wavefor_storer_4k_addra = "111111111111") then
					IQout_tlast <= '1';
				else
					IQout_tlast <= '0';
				end if;
			end if;
		end process;

end Behavioral;

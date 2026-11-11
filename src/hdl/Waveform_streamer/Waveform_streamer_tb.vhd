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

entity Waveform_streamer_tb is
end Waveform_streamer_tb;

architecture Behavioral of Waveform_streamer_tb is
	
	component Waveform_streamer
		Port (  clk				: in  std_logic;
				rst				: in  std_logic;
				IQout_tlast     : out std_logic:= '0';
				IQout_tdata     : out std_logic_vector (31 downto 0) := (others => '0');
				IQout_tvalid    : out std_logic:= '0');  
	end component;

	signal clk			: std_logic := '0';
	signal IQout_tlast	: std_logic := '0';
	signal IQout_tvalid	: std_logic := '0';
	signal IQout_tdata 	: std_logic_vector(31 downto 0) := (others => '0');
	signal Iout_tdata 	: std_logic_vector(15 downto 0) := (others => '0');
	signal Qout_tdata 	: std_logic_vector(15 downto 0) := (others => '0');
	
begin

	process
		begin
			wait for 2.0 ns;
			clk <= '0';
			wait for 2.0 ns;
			clk <= '1';
		end process;
	
	Iout_tdata <= IQout_tdata(31 downto 16);
	Qout_tdata <= IQout_tdata(15 downto 0);

	Waveform_streamer_inst : Waveform_streamer
		Port map (  clk				=> clk,
					rst				=> '0',
					IQout_tlast		=> IQout_tlast,
					IQout_tdata		=> IQout_tdata,
					IQout_tvalid	=> IQout_tvalid);
				
end Behavioral;

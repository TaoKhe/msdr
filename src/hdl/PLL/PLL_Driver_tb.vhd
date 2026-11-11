----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.06.2026 14:19:34
-- Design Name: 
-- Module Name: PLL_Driver_tb - Behavioral
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

library UNISIM;
use UNISIM.VComponents.all;

entity PLL_Driver_tb is
end PLL_Driver_tb;

architecture Behavioral of PLL_Driver_tb is

component PLL_Driver
    Port ( 	clk			: in  std_logic;
    		adc_clk_in	: in  std_logic;
    		Freq_in 	: in  std_logic_vector(31 downto 0);
    		TX_RXn		: in  std_logic;
    		Tx_bw		: in  std_logic_vector(7 downto 0);
    		Rx_bw		: in  std_logic_vector(7 downto 0);
    		Set			: in  std_logic;
    		PP 			: in  std_logic;
    		dds_dav_a	: out std_logic;
    		dds_dav_b	: out std_logic;
    		dds 		: out std_logic_vector(31 downto 0);
    		DAC_freq	: out std_logic_vector(31 downto 0);
    		INT_A 		: out std_logic_vector(6 downto 0);
    		INT_B 		: out std_logic_vector(6 downto 0));
end component;

type freq_array is array (0 to 11) of std_logic_vector(31 downto 0);
signal	Freq_in_a	: freq_array := ( 	conv_std_logic_vector(160*10**6, 32),
										conv_std_logic_vector(300*10**6, 32),
										conv_std_logic_vector(520*10**6, 32),
										conv_std_logic_vector(755*10**6, 32),
										conv_std_logic_vector(901*10**6, 32),
										conv_std_logic_vector(1000*10**6, 32),
										conv_std_logic_vector(1100*10**6, 32),
										conv_std_logic_vector(521*10**6, 32),
										conv_std_logic_vector(1250*10**6, 32),
										x"838962E7",
										conv_std_logic_vector(2600*10**6, 32),
										x"A0562480"); -- 2690 MHz
										
signal	TX_RXn		: std_logic := '0';
signal	Freq_in		: std_logic_vector(31 downto 0) := (others => '0');
signal	man_freq_mem	: std_logic_vector(31 downto 0) := (others => '0');
signal	provv_bw		: std_logic_vector(7 downto 0) := "00000000";
signal	provv_bw_mem	: std_logic_vector(7 downto 0) := "00000000";
signal	Rx_bw			: std_logic_vector(7 downto 0) := "00000000";
signal	Set_freq		: std_logic := '0';
signal	set_TBPF_freq	: std_logic := '0';
signal	PP 			: std_logic := '0';
signal	dds_dav_a	: std_logic := '0';
signal	dds_dav_b	: std_logic := '0';
signal	dds 		: std_logic_vector(31 downto 0);
signal	DAC_freq	: std_logic_vector(31 downto 0);
signal	INT_A 		: std_logic_vector(6 downto 0);
signal	INT_B 		: std_logic_vector(6 downto 0);
signal	Set_cnt		: integer range 0 to 500000 := 0;
signal	set_cnt1		: integer range 0 to 100000 := 0;
signal	freq_pnt	: integer range 0 to 11 := 0;
signal	clk			: std_logic := '0';
signal	adc_clk_in	: std_logic := '0';
	
begin
	
	process
		begin
			wait for 5.0 ns;
			clk <= '1';
			wait for 5.0 ns;
			clk <= '0';
		end process;
		
	process
		begin
			wait for 1.6666 ns;
			adc_clk_in <= '1';
			wait for 1.6666 ns;
			adc_clk_in <= '0';
		end process;
		
	process(clk)
		begin
			if rising_edge(clk) then
				if (Set_cnt = 500000) then
					Set_cnt <= 0;
					provv_bw <= "00000001";		
					if (freq_pnt = 11) then
						freq_pnt <= 0;
						PP 		 <= not PP;
						if (PP = '1') then
							TX_RXn <= not TX_RXn;
						end if;
					else
						freq_pnt <= freq_pnt + 1;
					end if;
					
					Freq_in	<= Freq_in_a(freq_pnt);
				else
					Set_cnt <= Set_cnt + 1;
				end if;

				if (Set_cnt = 2500) then
					provv_bw <= "00000010";		
				end if;				

			end if;
		end process;
		
		
	    process(clk)
    	begin
			if rising_edge(clk) then
				man_freq_mem <= Freq_in;
				provv_bw_mem <= provv_bw;
				
				if ((man_freq_mem /= Freq_in) or (provv_bw_mem /= provv_bw)) then -- this code because freq_in and bw don't arrive at the same time Claudio 030726
					set_cnt1 <= 0;
				else
					if (set_cnt1 /= 100000) then  -- this because RFU Serial Switch Controller does'n send simultaneously frequency and bandwidth
						set_cnt1 <= set_cnt1 + 1;
					end if;
				end if;
				
				if (set_cnt1 = 99999) then
					Set_freq <= '1';
				else
					Set_freq <= '0';
				end if;
				
				if (man_freq_mem /= Freq_in) then
					set_TBPF_freq <= '1';
				else
					set_TBPF_freq <= '0';
				end if;
			end if;
		end process;
	
	PLL_Driver_inst : PLL_Driver
		Port map( 	clk			=> clk,
					adc_clk_in	=> adc_clk_in,
					Freq_in 	=> Freq_in,
					TX_RXn		=> TX_RXn,
					Tx_bw		=> provv_bw,
					Rx_bw		=> provv_bw,
					Set			=> Set_freq,
					PP 			=> PP,
					dds_dav_a	=> dds_dav_a,
					dds_dav_b	=> dds_dav_b,
					dds 		=> dds,
					DAC_freq	=> DAC_freq,
					INT_A 		=> INT_A,
					INT_B 		=> INT_B);


end Behavioral;

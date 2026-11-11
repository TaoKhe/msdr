----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.05.2026 15:17:12
-- Design Name: 
-- Module Name: ADMV8xxx_Driver - Behavioral
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

entity ADMV8xxx_Driver is
    Port (  fsm_clk 		: in  std_logic;
    	    Freq_in 		: in  std_logic_vector(31 downto 0);
    	    Set          	: in  std_logic;
            enable			: in  std_logic;
            PP				: in  std_logic;
			hb_tbpf_sdi     : out std_logic;
			hb_tbpf_sdo     : in  std_logic;
			hb_tbpf_sclk    : out std_logic;
			hb_1_tbpf_csn   : out std_logic;  -- 1250-2600 MHz PP '1'
			hb_2_tbpf_csn   : out std_logic;  -- 1250-2600 MHz PP '0'
			hb_3_tbpf_csn   : out std_logic;  --  520-1250 MHz PP '1'
			hb_4_tbpf_csn   : out std_logic); --  520-1250 MHz PP '0'
end ADMV8xxx_Driver;

architecture Behavioral of ADMV8xxx_Driver is

    constant Reset 			: std_logic_vector(23 downto 0) := x"000081";
    constant Reg_0 			: std_logic_vector(23 downto 0) := x"00003C";
    constant INTERP_word 	: std_logic_vector(23 downto 0) := x"005001";
    signal fsm_reset    : integer range 0 to 15 := 0;   
	signal Set_mem		: std_logic := '0';
	signal sclks		: std_logic := '0';
	signal first_run	: std_logic := '1';
	signal ADMV8513		: std_logic := '0';
	signal ADMV8526		: std_logic := '0';
	signal Set_reg		: integer range 0 to 2 := 0;
	signal bit_cnt		: integer range -1 to 23 := 23;
	signal FreqC    	: std_logic_vector(31 downto 0) := (others => '0');
	signal Freq_in_mem	: std_logic_vector(31 downto 0) := (others => '0');
	signal FCLOAD_long	: std_logic_vector(47 downto 0);
	signal FCLOADs		: std_logic_vector(7 downto 0);
	signal FC_word		: std_logic_vector(23 downto 0);
	
begin

	FCLOADs 	<= std_logic_vector(FCLOAD_long(43 downto 36));	-- fixed-point rescale
	FC_word 	<= x"0020" & FCLOADs; -- write at address x"020" frequency value
	
	process(fsm_clk)
		variable toggle : integer range 0 to 7 := 0;
		begin	
			if rising_edge(fsm_clk) then
				if (Set = '1') then
					Freq_in_mem 	<= Freq_in;
					hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
					hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
					hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
					hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
					Set_mem			<= '1';
					sclks			<= '0';
					Set_reg			<= 0;
					bit_cnt			<= 23;
					toggle 			:= 0;
				else
					if (toggle /= 7) then
						toggle := toggle + 1;
					else
						toggle := 0;
						if (enable = '0') then
							hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
							hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
							hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
							hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
							hb_tbpf_sdi		<= '0';
							sclks			<= '0';
							Set_reg			<= 0;
							bit_cnt			<= 23;
							first_run		<= '1';
						elsif (first_run = '1') then	
							case fsm_reset is			
								when 0			=>	bit_cnt     	<= bit_cnt - 1;
													if (Set_reg = 0) then
														hb_tbpf_sdi		<= Reset(bit_cnt);
													elsif (Set_reg = 1) then
														hb_tbpf_sdi		<= Reg_0(bit_cnt);
													else
														hb_tbpf_sdi		<= INTERP_word(bit_cnt);
													end if;
													hb_1_tbpf_csn	<= '0';  -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= '0';  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= '0';  --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= '0';  --  520-1250 MHz PP '0'
													fsm_reset   	<= 1;			
													
								when 1			=> 	if (sclks = '1') then
														bit_cnt     	<= bit_cnt - 1;
														if (Set_reg = 0) then
															hb_tbpf_sdi		<= Reset(bit_cnt);
														elsif (Set_reg = 1) then
															hb_tbpf_sdi		<= Reg_0(bit_cnt);
														else
															hb_tbpf_sdi		<= INTERP_word(bit_cnt);
														end if;
														if (bit_cnt = 0) then
															fsm_reset  	<= 2;
														end if;
													end if;
													sclks <= not sclks;
													
								when 2		 	=>	sclks			<= '1';
													fsm_reset   	<= 3;
													
								when 3 			=>	sclks			<= '0';
													fsm_reset   	<= 4;
													
								when 4 			=>	hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
													if (Set_reg = 2) then
														first_run	<= '0';  -- setup finished
														fsm_reset   <= 8;
													else
														Set_reg 	<= Set_reg + 1;
														bit_cnt		<= 23;
														fsm_reset   <= 0;
													end if;
													hb_tbpf_sdi	  	<= '0';	
								when 8 			=>	null;
																
								when others 	=>	hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
													hb_tbpf_sdi	  	<= '0';
							end case;
						elsif (Set_mem = '1') then
							Set_mem <= '0';
							if ((Freq_in > x"1EFE91FF") and (Freq_in < x"4A817C80")) then -- range 520 - 1249.999999 MHz
								ADMV8513 		<= '1';
								ADMV8526 		<= '0';
								first_run		<= '0';
								fsm_reset		<= 0;
							elsif ((Freq_in > x"4A817C7F") and (Freq_in < x"A0EEBB01")) then -- range 1250 - 2700 MHz
								ADMV8513 		<= '0';
								ADMV8526 		<= '1';					
								first_run		<= '0';
								fsm_reset		<= 0;
							else
								ADMV8513 		<= '0';
								ADMV8526 		<= '0';
								fsm_reset		<= 8;
							end if;
							
							hb_tbpf_sdi	  	<= '0';
							sclks	 		<= '0';
							bit_cnt     	<= 23;
						else
							case fsm_reset is			
								when 0			=>	if (ADMV8513 = '1') then
														FreqC <= Freq_in - x"1EFE9200"; -- -520 MHz   Range 1300 - 520 = 780 MHz
													else
														FreqC <= Freq_in - x"4A817C80"; -- -1250 MHz  Range 2600 - 1250 = 1350 MHz
													end if;
													
													fsm_reset   <= 1;			
													
								when 1			=> 	fsm_reset   	<= 2;
													
								when 2 			=>	if (ADMV8513 = '1') then
														FCLOAD_long <= FreqC * x"57DF";
													else
														FCLOAD_long <= FreqC * x"32B5";
													end if;
													fsm_reset   	<= 3;
													
								when 3 			=>	bit_cnt     	<= 23;
													sclks			<= '0';
													fsm_reset   	<= 4;
													
								when 4			=>	hb_1_tbpf_csn	<= not (ADMV8526 and      PP);   -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= not (ADMV8526 and (not PP));  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= not (ADMV8513 and      PP);   --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= not (ADMV8513 and (not PP));  --  520-1250 MHz PP '0'
													bit_cnt     	<= bit_cnt - 1;
													hb_tbpf_sdi	    <= INTERP_word(bit_cnt);
													fsm_reset   	<= 5;
													
								when 5 			=>	if (sclks = '1') then
														bit_cnt     	<= bit_cnt - 1;
														hb_tbpf_sdi	    <= FC_word(bit_cnt);
														if (bit_cnt = 0) then
															fsm_reset   <= 6;
														end if;
													end if;
													sclks <= not sclks;
													
								when 6			=> 	sclks <= '1';
													fsm_reset   <= 7;
													
								when 7			=> 	sclks <= '0';
													fsm_reset   <= 8;
													
								when 8	 		=>	hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
													sclks			<= '0';
													
								when others 	=>	hb_1_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '1'
													hb_2_tbpf_csn	<= '1';  -- 1250-2600 MHz PP '0'
													hb_3_tbpf_csn	<= '1';  --  520-1250 MHz PP '1'
													hb_4_tbpf_csn	<= '1';  --  520-1250 MHz PP '0'
													sclks			<= '0';
							end case;
						end if;
					end if;
				end if;
			end if;
		end process;
		
	hb_tbpf_sclk <= sclks;
	
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2026 15:09:14
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gpio_types_pkg.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;

entity LB_TBPF_NetCom_5670_x_D_Driver is
    Port   (fsm_clk     : in  std_logic;
			enable      : in  std_logic;
			Set      	: in  std_logic;
			freq_in     : in  std_logic_vector(31 downto 0);
			tune_rdy_1  : in  std_logic;
			tune_rdy_2  : in  std_logic;
			PP       	: in  std_logic;
			error       : out std_logic;
			sclk        : out std_logic;
			csn1        : out std_logic;
			csn2        : out std_logic;
			mosi        : out std_logic);	
end LB_TBPF_NetCom_5670_x_D_Driver;

architecture Behavioral of LB_TBPF_NetCom_5670_x_D_Driver is

	component LB_TBPF_mult
		port (  CLK : IN std_logic;
				A : in  std_logic_vector(31 DOWNTO 0);
				P : out std_logic_vector(46 DOWNTO 0));
		end component;


    type fsm_reset_type is (check_set, wait_mult, check_freq, set_Reg);
    signal fsm_reset   	 : fsm_reset_type := check_freq;   
	signal spi_clk			: integer range 0 to 24 := 0;
	signal clk_cnt			: integer range 0 to 17 := 0;
	signal sclks			: std_logic := '0';
	signal first_time		: std_logic := '1';
	signal bit_cnt			: integer range 0 to 16 := 16;
	signal not_ready_cnt_1	: integer range 0 to 8191 := 0;
	signal not_ready_cnt_2	: integer range 0 to 8191 := 0;
	signal wait_cnt			: integer range 0 to 8 := 0;
	signal frq_in	    	: std_logic_vector(15 downto 0) := (others => '0');
	signal freq_in_mem		: std_logic_vector(31 downto 0) := (others => '0');
	signal frq_in_resc		: std_logic_vector(15 downto 0) := (others => '0');
	signal P 				: std_logic_vector(46 downto 0);
	
begin

	LB_TBPF_mult_inst : LB_TBPF_mult
		port map (	CLK		=> fsm_clk,
					A		=> freq_in_mem(31 downto 0),
					P		=> P);
					
	frq_in_resc 	<= "000" & std_logic_vector(P(43 downto 31));	-- fixed-point rescale

	process(fsm_clk)
		begin	
			if rising_edge(fsm_clk) then		

				--P 				<= freq_in(31 downto 0) * x"431C";	-- freq * (2^32 / 125000)-- DSP48E2 multiplication

				if (enable = '0') then -- to initialize TBPF
					fsm_reset 	<= check_freq;
					csn1	  	<= '1';
					csn2	  	<= '1';
					mosi	  	<= '1';
					clk_cnt		<= 0;
					sclks	 	<= '0';
					spi_clk 	<= 0;
					first_time	<= '1';
				else
					case fsm_reset is
						when check_set	=>	if ((Set = '1') or (first_time = '1')) then		-- to update TBPF with new freq value		
												freq_in_mem <= freq_in;
												wait_cnt 	<= 8;
												fsm_reset   <= wait_mult;
											end if;
											csn1	  	<= '1';
											csn2	  	<= '1';
						when wait_mult	=>	if (wait_cnt = 0) then
												fsm_reset   <= check_freq;
											else
												wait_cnt 	<= wait_cnt - 1;
											end if;
						when check_freq	=>	fsm_reset   <= set_Reg;
											mosi	    <= frq_in_resc(15);
											csn1	  	<= PP       and (not first_time);
											csn2	  	<= (not PP) and (not first_time);
											clk_cnt		<= 0;
											sclks		<= '0';
											spi_clk 	<= 0; 
											first_time	<= '0';
											bit_cnt     <= 16;
											error 		<= '0';
						when set_Reg	=>	if (spi_clk = 24) then
												case bit_cnt is
													when  2 to 16   =>  bit_cnt     <= bit_cnt - 1;
																		mosi	    <= frq_in_resc(bit_cnt - 2);
																		sclks		<= '0';
																		spi_clk 	<= 0;
													when  	1  	    =>  bit_cnt     <= bit_cnt - 1;
																		mosi	    <= '0';
																		sclks		<= '0';
																		spi_clk 	<= 0;
													when  	0  	    =>  if (tune_rdy_1 = '1') and (PP = '1') then
																			csn1	    <= '1';
																			fsm_reset   <= check_set;
																		elsif (tune_rdy_2 = '1') and (PP = '0') then
																			csn2	    <= '1';
																			fsm_reset   <= check_set;
																		else
																			if (tune_rdy_1 = '0') then
																				if (not_ready_cnt_1 /= 8191) then
																					not_ready_cnt_1 <= not_ready_cnt_1 + 1;
																				else
																					not_ready_cnt_1 <= 0;
																					fsm_reset   <= check_set;
																					error 		<= '1';
																				end if;
																			end if;
																			if (tune_rdy_2 = '0') then
																				if (not_ready_cnt_2 /= 8191) then
																					not_ready_cnt_2 <= not_ready_cnt_2 + 1;
																				else
																					not_ready_cnt_2 <= 0;
																					fsm_reset   <= check_set;
																					error 		<= '1';
																				end if;
																			end if;
																		end if;
													when others     =>  fsm_reset   <= check_set;
												end case;
											else
												if (spi_clk = 12) then
													if (bit_cnt /= 0) then
														sclks		<= '1';
													end if;
												end if;
												if (bit_cnt /= 0) then
													spi_clk <= spi_clk + 1;
												else
													spi_clk <= 24;
												end if;
											end if;
						when others 	=>	fsm_reset   <= check_set;
											sclks		<= '0';
					end case;
				end if;
			end if;
		end process;

	sclk <= sclks;
	
end Behavioral;

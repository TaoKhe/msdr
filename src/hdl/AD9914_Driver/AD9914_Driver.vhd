----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2026 17:24:39
-- Design Name: 
-- Module Name: AD9914_Driver - Behavioral
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

entity AD9914_Driver is
	generic (Delay_cnt : integer := 7500000);
    Port (dds_a_sync_clk    : in  STD_LOGIC;
          dds_b_sync_clk    : in  STD_LOGIC;
          fsm_clk           : in  STD_LOGIC;
          dds_data          : out STD_LOGIC_VECTOR(31 downto 5);
          dds_a_syncio      : out STD_LOGIC;
          dds_b_syncio      : out STD_LOGIC;
          dds_sdo           : out STD_LOGIC;
          dds_sdio          : out STD_LOGIC;
          dds_scl           : out STD_LOGIC;
          dds_a_0_csn       : out STD_LOGIC;
          dds_b_0_csn       : out STD_LOGIC;
          dds_in          	: in  STD_LOGIC_VECTOR(31 downto 0);
          dds_dav_a         : in  STD_LOGIC;
          dds_dav_b         : in  STD_LOGIC;
          reset             : in  STD_LOGIC;
          dds_a_ioupdate    : out STD_LOGIC := '0';
          dds_b_ioupdate    : out STD_LOGIC := '0';
          DDS_MASTER_RESET 	: out STD_LOGIC);
end AD9914_Driver;

architecture Behavioral of AD9914_Driver is
    type fsm_ioupdate_type is (ioupdate_0, ioupdate_1, ioupdate_2, ioupdate_3, ioupdate_4, ioupdate_5, ioupdate_6, ioupdate_7);
    signal fsm_ioupdate_a   : fsm_ioupdate_type := ioupdate_0;
    signal fsm_ioupdate_b   : fsm_ioupdate_type := ioupdate_0;
    signal enable_io_update : std_logic := '0';
    signal setting_a 		: std_logic := '0';
    signal setting_aSR 		: std_logic := '0';
    signal setting_aSR_CLR	: std_logic := '0';
    signal setting_b 		: std_logic := '0';
    signal setting_bSR 		: std_logic := '0';
    signal setting_bSR_CLR	: std_logic := '0';
    signal reset_dds_1_cnt  : integer range 0 to 31000 := 0;
    signal dds_ins          : std_logic_vector(31 downto 0) := (others => '0');
    signal dds_a_ins        : std_logic_vector(31 downto 0) := (others => '0');
    signal dds_b_ins        : std_logic_vector(31 downto 0) := (others => '0');
    signal no_change_a_cnt	: integer range 0 to 7500000 := Delay_cnt;
    signal no_change_b_cnt	: integer range 0 to 7500000 := Delay_cnt;
begin
                                                                 
--         process(dds_a_sync_clk, reset) -- this is to update frequency when it changes or every 100 mS
         process(fsm_clk, reset) -- this is to update frequency when it changes or every 100 mS
            begin
            	if (reset = '1') then
            		dds_a_ioupdate <= '0';
            		no_change_a_cnt <= 0;
            		fsm_ioupdate_a <= ioupdate_0;
            		DDS_MASTER_RESET <= '1';
--                elsif rising_edge(dds_a_sync_clk) then
                elsif rising_edge(fsm_clk) then
                	DDS_MASTER_RESET <= '0';
                    case fsm_ioupdate_a is
						when ioupdate_0 	=>  if (dds_dav_a = '1') then
													fsm_ioupdate_a <= ioupdate_1;
--													no_change_a_cnt <= 0;
--												else
--													if (no_change_a_cnt = 7500000) then
--														fsm_ioupdate_a 	<= ioupdate_1;
--														no_change_a_cnt <= 0;
--													else
--														no_change_a_cnt <= no_change_a_cnt + 1;
--														fsm_ioupdate_a 	<= ioupdate_0;
--													end if;
												end if;
												dds_a_ioupdate 	<= '0';
												setting_a		<= '0';
						when ioupdate_1 	=>  dds_a_ins 		<= dds_in;
												setting_a		<= '1';
												fsm_ioupdate_a 	<= ioupdate_2;
						when ioupdate_2 	=>  setting_a		<= '0';
												fsm_ioupdate_a 	<= ioupdate_3;
						when ioupdate_3 	=>  dds_a_ioupdate 	<= '1';
												fsm_ioupdate_a 	<= ioupdate_0;
						when others			=>  fsm_ioupdate_a 	<= ioupdate_0;
					end case;
                end if;
            end process;       
        
--         process(dds_b_sync_clk, reset) -- this is to update frequency when it changes or every 100 mS
         process(fsm_clk, reset) -- this is to update frequency when it changes or every 100 mS
            begin
            	if (reset = '1') then
            		dds_b_ioupdate <= '0';
            		no_change_b_cnt <= 0;
            		fsm_ioupdate_b <= ioupdate_0;
--                elsif rising_edge(dds_b_sync_clk) then
                elsif rising_edge(fsm_clk) then
                    case fsm_ioupdate_b is
						when ioupdate_0 	=>  if (dds_dav_b = '1') then
													fsm_ioupdate_b <= ioupdate_1;
--													no_change_b_cnt <= 0;
--												else
--													if (no_change_b_cnt = 7500000) then
--														fsm_ioupdate_b 	<= ioupdate_1;
--														no_change_b_cnt <= 0;
--													else
--														no_change_b_cnt <= no_change_b_cnt + 1;
--														fsm_ioupdate_b 	<= ioupdate_0;
--													end if;
												end if;
												dds_b_ioupdate 	<= '0';
												setting_b		<= '0';
						when ioupdate_1 	=>  dds_b_ins 		<= dds_in;
												setting_b		<= '1';
												fsm_ioupdate_b 	<= ioupdate_2;
						when ioupdate_2 	=>  setting_b		<= '0';
												fsm_ioupdate_b 	<= ioupdate_3;
						when ioupdate_3 	=>  dds_b_ioupdate 	<= '1';
												fsm_ioupdate_b 	<= ioupdate_0;
						when others			=>  fsm_ioupdate_b 	<= ioupdate_0;
					end case;
                end if;
            end process;
        
        fdce_a : FDCE generic map (INIT => '0')	port map (D => '1', C =>  setting_a, CLR =>  setting_bSR_CLR, CE => '1', Q => setting_aSR);  
        setting_aSR_CLR <= setting_aSR and setting_a;
        fdce_b : FDCE generic map (INIT => '0')	port map (D => '1', C =>  setting_b, CLR =>  setting_aSR_CLR, CE => '1', Q => setting_bSR);  
    	setting_bSR_CLR <= setting_bSR and setting_b;
    	
        dds_ins <= dds_a_ins when (setting_aSR = '1' ) else dds_b_ins;
           
        dds_a_0_csn             <= dds_ins(16);--dds_csns     when (enable_io_update = '0') else dds_ins(0);
        dds_b_0_csn             <= dds_ins(16);--dds_csns     when (enable_io_update = '0') else dds_ins(0);
        dds_scl                 <= dds_ins(17);--dds_scls     when (enable_io_update = '0') else dds_ins(1);
        dds_sdio                <= dds_ins(18);--dds_sdios    when (enable_io_update = '0') else dds_ins(2);
        dds_sdo                 <= dds_ins(19);
        dds_a_syncio            <= dds_ins(20);
        dds_b_syncio            <= dds_ins(20);
        dds_data(15 downto 5)   <= dds_ins(31 downto 21);
        dds_data(31 downto 16)  <= dds_ins(15 downto 0);
        
end Behavioral;

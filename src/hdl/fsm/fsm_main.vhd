----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/07/2025 03:16:42 PM
-- Design Name: 
-- Module Name: top_file - Behavioral
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

use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;


entity fsm_main is
  generic(
    N_GPIO                          : integer := 65                
  );
  port (
    fsm_clk_in                      : in  std_logic;							  
    adc_clk_in                      : in  std_logic;								  
    fsm_rstn_in                     : in  std_logic;								  
    enable_fsm                      : in  std_logic;								  
    gpio_outs                    	: out std_logic_vector ( 64 downto 0 ) := (others => '0');

    CFG_LUT_addr                    : out STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
    CFG_LUT_clk                     : out STD_LOGIC := '0';
    CFG_LUT_din                     : in STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
    CFG_LUT_en                      : out STD_LOGIC := '0';
    CFG_LUT_rst                     : out STD_LOGIC := '0';
    CFG_LUT_we                      : out STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');

    cfg_reload_in                   : in  std_logic;

    gpio_test_in                    : in std_logic;
    gpio_mask_ub_in                 : in std_logic_vector( N_GPIO - 1 downto 0) := (others => '0'); 

    command1_in                    : in std_logic_vector( 31 downto 0) ;
    command2_in                    : in std_logic_vector( 31 downto 0) ;
    command3_in                    : in std_logic_vector( 31 downto 0) ;
    command4_in                    : in std_logic_vector( 31 downto 0) ;
    command5_in                    : in std_logic_vector( 31 downto 0) ;
	lb_rx_tbpf_mosi     			: inout std_logic;
    lb_rx_tbpf_sclk     			: inout std_logic;
    lb_rx_tbpf1_csn     			: inout std_logic;
    lb_rx_tbpf2_csn    				: inout std_logic;
    lb_tx_tbpf_mosi     			: inout std_logic;
    lb_tx_tbpf_sclk     			: inout std_logic;
    lb_tx_tbpf2_csn     			: inout std_logic;
    lb_tx_tbpf1_csn     			: inout std_logic;											  
    Frame_Length_in                 : in std_logic_vector (47 downto 0):= (others => '0');
    Tx_freq_in                      : in std_logic_vector (47 downto 0):= (others => '0');
    Rx_freq_in                      : in std_logic_vector (47 downto 0):= (others => '0');
    Next_Frame_Transmit_Time_in     : in std_logic_vector (26 downto 0):= (others => '0');
    Power_Tx_in                     : in std_logic_vector (7 downto 0):= (others => '0');
    Rx_bw_in                        : in std_logic_vector (7 downto 0):= (others => '0');
    Tx_bw_in                        : in std_logic_vector (7 downto 0):= (others => '0');
    Next_Frame_Receive_Time_in      : in std_logic_vector (26 downto 0):= (others => '0');
    Second_from_2000_in             : in std_logic_vector (39 downto 0):= (others => '0');
    Subsecond_in                    : in std_logic_vector (26 downto 0):= (others => '0');
    trx_config_in                   : in std_logic := '0';

    Current_second_from_2000_in     : in std_logic_vector (39 downto 0):= (others => '0');
    Current_Subsecond_in            : in std_logic_vector (26 downto 0):= (others => '0');   
    running_config_valid_in         : in std_logic := '0';  

    -- ADDED: tx_ctrl command/status interface
    tx_command_in       : in  std_logic_vector(31 downto 0);
    tx_card_status_out  : out std_logic_vector(31 downto 0);
    SPI_CPLD_MISO_in    : in  std_logic;
    SPI_CPLD_MOSI_out   : out std_logic;
    SPI_CPLD_SCLK_out   : out std_logic;
    SPI_CPLD_CSN_out    : out std_logic;

    ---- SPI interfaces------------------------------------------------------------------
    --------ad9164 NCO Config SPI Interface
    ad9164_csn                    : out std_logic;
    ad9164_sclk                   : out std_logic;
    ad9164_mosi                   : out std_logic;
    ---- pll configuration SPI Interface
--    pll_a_ad9914_clk           : out std_logic;
--    pll_a_ad9914_data          : out std_logic;
--    pll_a_ad9914_le            : out std_logic;

    pll_a_adf41510_clk           : out std_logic;
    pll_a_adf41510_mosi          : out std_logic;
    pll_a_adf41510_csn           : out std_logic;

--    pll_b_ad9914_clk           : out std_logic;
--    pll_b_ad9914_data          : out std_logic;
--    pll_b_ad9914_le            : out std_logic;

    pll_b_adf41510_clk           : out std_logic;
    pll_b_adf41510_mosi          : out std_logic;
    pll_b_adf41510_csn            : out std_logic;
    ------GPIO interfaces------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- Band 64: Filter/PLL/DAC/ADC Control
    -----------------------------------------------------------------------
    -- Switches
    if_fb_sw_1          : out std_logic;
    if_fb_sw_0          : out std_logic;
    hb_tpfb_sw_2        : out std_logic;
    hb_tpfb_sw_1        : out std_logic;
    hb_tpfb_sw_0        : out std_logic;
    hb_tpfb_sw_0n       : out std_logic;
    lb_rx_tbpf_sw_1     : out std_logic;
    lb_rx_tbpf_sw_2     : out std_logic;
    lb_sw_1             : out std_logic;
    lb_sw_2             : out std_logic;
    lb_tx_tbpf_sw_1     : out std_logic;
    lb_tx_tbpf_sw_2     : out std_logic;
    hb_fb_sw_1          : out std_logic;
    hb_fb_sw_0          : out std_logic; 
    -- DAC Control
    dac_txenable        : out std_logic;
    -- Misc Control
    PG_ADC_PLL          : in std_logic:= '1'; -- Power Good?
    PG_VCVCSO           : in std_logic := '1';
    -- TX Attenuator & HB Feedback
    hb_fb_tx            : out std_logic;
    -----------------------------------------------------------------------
    -- Band 65
    -----------------------------------------------------------------------
    lo_ps               : out std_logic_vector(7 downto 0); -- Phase shifters?
    
    -- More Filter Controls
    hb_fb_sw_2n         : out std_logic;
    hb_fb_sw_2          : out std_logic;

    -- Status / Ready Signals (Inputs)
    lb_tx_tbpf_1_tune_rdy   : in std_logic := '1';
    lb_tx_tbpf_2_tune_rdy   : in std_logic := '1';
    lb_rx_tbpf_1_tune_rdy_a : in std_logic := '1';
    lb_rx_tbpf_1_tune_rdy_b : in std_logic := '1';
    lb_rx_tbpf_2_tune_rdy_a : in std_logic := '1';
    lb_rx_tbpf_2_tune_rdy_b : in std_logic := '1';						  
	hb_tbpf_sdi         	: inout std_logic;
	hb_tbpf_sdo         	: in  std_logic;
	hb_tbpf_sclk        	: inout std_logic;
	hb_1_tbpf_csn       	: inout std_logic;
	hb_2_tbpf_csn      	 	: inout std_logic;
	hb_3_tbpf_csn       	: inout std_logic;
	hb_4_tbpf_csn       	: inout std_logic;				  
    pll_504_locked          : in std_logic := '1';
    pll_917_locked          : in std_logic := '1';

    -----------------------------------------------------------------------
    -- Band 66: ADC Interface & Data
    -----------------------------------------------------------------------
   -- gpio_mux            : out std_logic_vector(7 downto 0); -- Control bits? 
    dac_ph_en_1v8       : out std_logic;
    dac_ph_sload_1v8    : out std_logic;
    pingpong_An_b       : out std_logic;
    TX_RF_OFF_1V8       : out std_logic;
    vcxo_cp             : out std_logic;
    -----------------------------------------------------------------------
    -- Band 84-85: DDC / DDS Interface
    -----------------------------------------------------------------------
    lo_div2_en_b        : out std_logic;
    lo_div2_en_a        : out std_logic;
    hb_sw               : out std_logic;
    RTX_PUSH_GATE       : out std_logic;
    -- GPIO Mux LE
    GPIO_MUXED			                : out std_logic_vector(7 downto 0);
    GPIO_MUX_LE_0		                : out std_logic;
    GPIO_MUX_LE_1		                : in  std_logic:= '1'; -- PG_VCO
    GPIO_MUX_LE_2	                    : in  std_logic:= '1'; -- DDS_A_PLL_LOCKED
    GPIO_MUX_LE_3		                : in  std_logic:= '1'; -- DDS_B_PLL_LOCKED
    
    dds_a_sync_clk    					: in  std_logic := '0';
	dds_b_sync_clk    					: in  std_logic := '0';
	--fsm_clk           				: in  std_logic;
	dds_data          					: out std_logic_vector(31 downto 5);
	dds_a_syncio      					: out std_logic;
	dds_b_syncio      					: out std_logic;
	dds_sdo           					: out std_logic;
	dds_sdio          					: out std_logic;
	dds_scl           					: out std_logic;
	dds_a_0_csn       					: out std_logic;
	dds_b_0_csn       					: out std_logic;
	tx_att_sin          				: out std_logic;
    tx_att_clk          				: out std_logic;
    tx_att_le           				: out std_logic;
    if_fb_si           					: out std_logic;
    if_fb_clk           				: out std_logic;
    if_fb_le           					: out std_logic;
    rtx_att_sin           				: out std_logic;
    rtx_att_clk           				: out std_logic;
    rtx_att_le           				: out std_logic;																			
	--dds_a_in          					: in  STD_LOGIC_VECTOR(31 downto 0);
	--dds_b_in          					: in  STD_LOGIC_VECTOR(31 downto 0);
	--reset             					: in  STD_LOGIC;
	dds_a_ioupdate    					: out STD_LOGIC := '0';
	dds_b_ioupdate    					: out STD_LOGIC := '0';
	ADC_AFE_PWUP         				: in  std_logic;
    ADC_AFE_PM         					: in  std_logic;
    EN_RX         						: in  std_logic;
    EN_TX         						: in  std_logic;
    EN_LO         						: in  std_logic;
    EN_RTX         						: in  std_logic;
    DDS_PWR_DWN         				: in  std_logic;
    ADC_PDWN         					: in  std_logic;
    rx_dds_config_tvalid           		: out std_logic;		
	rx_dds_config_tdata          		: out std_logic_vector(31 downto 0));
end entity fsm_main;

architecture behaviour of fsm_main is 
	component ila_32 port (clk : IN STD_LOGIC; probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)); end component;																				  																																																																							
	component ila_16_bit	port (	clk 	: IN STD_LOGIC;			probe0 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0)); end component;	
																											  																																																																							
    CONSTANT PLL_IDLE : std_logic_vector(3 downto 0) := "0001";
    CONSTANT PLL_CAL : std_logic_vector(3 downto 0) := "0010";
    CONSTANT PLL_SETUP: std_logic_vector(3 downto 0) := "0011";
    CONSTANT PLLA_SETUP: std_logic_vector(3 downto 0) := "0100";
    CONSTANT PLLB_SETUP : std_logic_vector(3 downto 0) := "0101";
    CONSTANT PLL_SWITCH : std_logic_vector(3 downto 0) := "0110";
    CONSTANT PLL_WAIT: std_logic_vector(3 downto 0) := "0111";
    CONSTANT PLL_UNKNOWN : std_logic_vector(3 downto 0) := "0000";

    CONSTANT TX_LB : std_logic_vector(2 downto 0) := "001";
    CONSTANT TX_HB : std_logic_vector(2 downto 0) := "010";
    CONSTANT RX_LB : std_logic_vector(2 downto 0) := "011";
    CONSTANT RX_HB : std_logic_vector(2 downto 0) := "100";
    CONSTANT RF_IDLE : std_logic_vector(2 downto 0):= "000";

    CONSTANT FREQ_30 : std_logic_vector(47 downto 0)  := x"000001C9C380";  --30MHz
    CONSTANT FREQ_161 : std_logic_vector(47 downto 0) := x"00000998AA40"; --161MHz
    CONSTANT FREQ_350 : std_logic_vector(47 downto 0) := x"000014DC9380"; --350MHz 
    CONSTANT FREQ_520 : std_logic_vector(47 downto 0) := x"00001EFE9200"; --520MHz
    CONSTANT FREQ_600 : std_logic_vector(47 downto 0) := x"000023C34600"; --600MHz 
    CONSTANT FREQ_756 : std_logic_vector(47 downto 0) := x"00002D0FA500"; --756MHz
    CONSTANT FREQ_901 : std_logic_vector(47 downto 0) := x"000035B42B40"; --901MHz  
    CONSTANT FREQ_1200 : std_logic_vector(47 downto 0) := x"000047868C00"; --1.2GMHz 
    CONSTANT FREQ_1223 : std_logic_vector(47 downto 0) := x"000048E57FC0"; --1.223GHz
    CONSTANT FREQ_2700 : std_logic_vector(47 downto 0) := x"0000A0EEBB00"; --2.7GHz 
    -- don vi subsecond da doi 1 us -> 10 ns tu 30/7/2026 (usec_loc_s dem
    -- toi 100_000_000 moi giay, xem tvsdr_fpga.vhd onepps_s). Hang so cu 1_000_000 lam
    -- nhanh wrap trong CAL_TRIGGER_TIME cong thieu 100 lan => moc chuyen hop roi vao
    -- ~10 ms dau giay thay vi cuoi giay. Ten hang so doi lai cho khong con goi nham don vi.
    CONSTANT ONE_SECOND_TICKS : std_logic_vector(26 downto 0) := "101" & x"F5E100"; --100,000,000 tick x 10 ns
    -- Frequency-band boundaries from "Global Setting"/"Freq_LO_Rev_B" tabs (Hz).
    CONSTANT FREQ_160  : std_logic_vector(47 downto 0) := x"000009896800"; --160 MHz
    CONSTANT FREQ_755  : std_logic_vector(47 downto 0) := x"00002D0062C0"; --755 MHz
    CONSTANT FREQ_1000 : std_logic_vector(47 downto 0) := x"00003B9ACA00"; --1000 MHz
    CONSTANT FREQ_1250 : std_logic_vector(47 downto 0) := x"00004A817C80"; --1250 MHz
    CONSTANT FREQ_1610 : std_logic_vector(47 downto 0) := x"00005FF6A680"; --1610 MHz
    CONSTANT FREQ_2020 : std_logic_vector(47 downto 0) := x"00007866C100"; --2020 MHz
    CONSTANT FREQ_2560 : std_logic_vector(47 downto 0) := x"000098968000"; --2560 MHz
    CONSTANT FREQ_2600 : std_logic_vector(47 downto 0) := x"00009AF8DA00"; --2600 MHz

    -- Per-band GPIO masks from "Global Setting" (PP=1, Ppn=0). bit i -> gpio_out(i).
    -- NBWF = 25/50/75 kHz waveforms; WBWF = 2/4/8/40 MHz (differ only in if_fb_sw_0, bit 63).

    constant GPIO_TX_NBWF_MASK_30_160 : std_logic_vector(64 downto 0) := "00000011001110001011111100010110100110111001000000000000001100000"; -- 0x006717E2D37200060
    constant GPIO_TX_WBWF_MASK_30_160 : std_logic_vector(64 downto 0) := "01000011001110001011111100010110100110111001000000000000001100000"; -- 0x086717E2D37200060
    constant GPIO_TX_NBWF_MASK_160_350 : std_logic_vector(64 downto 0) := "00000011101110001011111100010110100110111001000000000010101100000"; -- 0x007717E2D37200560
    constant GPIO_TX_WBWF_MASK_160_350 : std_logic_vector(64 downto 0) := "01000011101110001011111100010110100110111001000000000010101100000"; -- 0x087717E2D37200560
    constant GPIO_TX_NBWF_MASK_350_520 : std_logic_vector(64 downto 0) := "00000011111101001011111100010110100110011000000000000010101010000"; -- 0x007E97E2D33000550
    constant GPIO_TX_WBWF_MASK_350_520 : std_logic_vector(64 downto 0) := "01000011111101001011111100010110100110011000000000000010101010000"; -- 0x087E97E2D33000550
    constant GPIO_TX_NBWF_MASK_520_600 : std_logic_vector(64 downto 0) := "00100011110000110011111100001110101000011000000000000010101010000"; -- 0x047867E1D43000550
    constant GPIO_TX_WBWF_MASK_520_600 : std_logic_vector(64 downto 0) := "01100011110000110011111100001110101000011000000000000010101010000"; -- 0x0C7867E1D43000550
    constant GPIO_TX_NBWF_MASK_600_901 : std_logic_vector(64 downto 0) := "00100011000000110011111100001010111111011000000000000000000000000"; -- 0x046067E15FB000000
    constant GPIO_TX_WBWF_MASK_600_901 : std_logic_vector(64 downto 0) := "00100011000000110011111100001010111111011000000000000000000000000"; -- 0x046067E15FB000000
    constant GPIO_TX_NBWF_MASK_901_1223 : std_logic_vector(64 downto 0) := "00100011000001110011111100001010111111011000000000000000000000000"; -- 0x0460E7E15FB000000
    constant GPIO_TX_WBWF_MASK_901_1223 : std_logic_vector(64 downto 0) := "00100011000001110011111100001010111111011000000000000000000000000"; -- 0x0460E7E15FB000000
    constant GPIO_TX_NBWF_MASK_1223_1250 : std_logic_vector(64 downto 0) := "00000011000010110011111100001110111101011000000000000101010010000"; -- 0x006167E1DEB000A90
    constant GPIO_TX_WBWF_MASK_1223_1250 : std_logic_vector(64 downto 0) := "01000011000010110011111100001110111101011000000000000101010010000"; -- 0x086167E1DEB000A90
    constant GPIO_TX_NBWF_MASK_1250_1610 : std_logic_vector(64 downto 0) := "00011011000010110011111100001110111101011000000000000101010010000"; -- 0x036167E1DEB000A90
    constant GPIO_TX_WBWF_MASK_1250_1610 : std_logic_vector(64 downto 0) := "01011011000010110011111100001110111101011000000000000101010010000"; -- 0x0B6167E1DEB000A90
    constant GPIO_TX_NBWF_MASK_1610_2020 : std_logic_vector(64 downto 0) := "00011011000011110011111100001110111101011000000000000101010010000"; -- 0x0361E7E1DEB000A90
    constant GPIO_TX_WBWF_MASK_1610_2020 : std_logic_vector(64 downto 0) := "01011011000011110011111100001110111101011000000000000101010010000"; -- 0x0B61E7E1DEB000A90
    constant GPIO_TX_NBWF_MASK_2020_2560 : std_logic_vector(64 downto 0) := "00011011000000101011111100001110111101011000000000000101010010000"; -- 0x036057E1DEB000A90
    constant GPIO_TX_WBWF_MASK_2020_2560 : std_logic_vector(64 downto 0) := "01011011000000101011111100001110111101011000000000000101010010000"; -- 0x0B6057E1DEB000A90
    constant GPIO_TX_NBWF_MASK_2560_2700 : std_logic_vector(64 downto 0) := "00000011000001101011111100001110111101011000000000000101010010000"; -- 0x0060D7E1DEB000A90
    constant GPIO_TX_WBWF_MASK_2560_2700 : std_logic_vector(64 downto 0) := "01000011000001101011111100001110111101011000000000000101010010000"; -- 0x0860D7E1DEB000A90
    constant GPIO_RX_NBWF_MASK_30_160 : std_logic_vector(64 downto 0) := "00000010001010001011111100110101011111111001000000000000001100000"; -- 0x004517E6AFF200060
    constant GPIO_RX_WBWF_MASK_30_160 : std_logic_vector(64 downto 0) := "01000010001010001011111100110101011111111001000000000000001100000"; -- 0x084517E6AFF200060
    constant GPIO_RX_NBWF_MASK_160_350 : std_logic_vector(64 downto 0) := "00000010101010001011111100110101011111111001000000000010101100000"; -- 0x005517E6AFF200560
    constant GPIO_RX_WBWF_MASK_160_350 : std_logic_vector(64 downto 0) := "00000010101010001011111100110101011111111001000000000010101100000"; -- 0x005517E6AFF200560
    constant GPIO_RX_NBWF_MASK_350_520 : std_logic_vector(64 downto 0) := "00000010011010001011111100110101011111011000000000000010101010000"; -- 0x004D17E6AFB000550
    constant GPIO_RX_WBWF_MASK_350_520 : std_logic_vector(64 downto 0) := "01000010011010001011111100110101011111011000000000000010101010000"; -- 0x084D17E6AFB000550
    constant GPIO_RX_NBWF_MASK_520_755 : std_logic_vector(64 downto 0) := "00100011001000010011111100111101111110111000000000000000001100000"; -- 0x046427E7BF7000060
    constant GPIO_RX_WBWF_MASK_520_755 : std_logic_vector(64 downto 0) := "01100011001000010011111100111101111110111000000000000000001100000"; -- 0x0C6427E7BF7000060
    constant GPIO_RX_NBWF_MASK_755_901 : std_logic_vector(64 downto 0) := "00100011001000010011111100111101111110111000000000000010101100000"; -- 0x046427E7BF7000560
    constant GPIO_RX_WBWF_MASK_755_901 : std_logic_vector(64 downto 0) := "01100011001000010011111100111101111110111000000000000010101100000"; -- 0x0C6427E7BF7000560
    constant GPIO_RX_NBWF_MASK_901_1000 : std_logic_vector(64 downto 0) := "00100011001001010011111100111101111110111000000000000010101100000"; -- 0x0464A7E7BF7000560
    constant GPIO_RX_WBWF_MASK_901_1000 : std_logic_vector(64 downto 0) := "01100011001001010011111100111101111110111000000000000010101100000"; -- 0x0C64A7E7BF7000560
    constant GPIO_RX_NBWF_MASK_1000_1223 : std_logic_vector(64 downto 0) := "00100011001001010011111100111101111110111000000000000010101100000"; -- 0x0464A7E7BF7000560
    constant GPIO_RX_WBWF_MASK_1000_1223 : std_logic_vector(64 downto 0) := "01100011001001010011111100111101111110111000000000000010101100000"; -- 0x0C64A7E7BF7000560
    constant GPIO_RX_NBWF_MASK_1223_1250 : std_logic_vector(64 downto 0) := "00100011001010010011111100111101111110011000000000000101001010000"; -- 0x046527E7BF3000A50
    constant GPIO_RX_WBWF_MASK_1223_1250 : std_logic_vector(64 downto 0) := "01100011001010010011111100111101111110011000000000000101001010000"; -- 0x0C6527E7BF3000A50
    constant GPIO_RX_NBWF_MASK_1250_1610 : std_logic_vector(64 downto 0) := "00011011001010010011111100111101111110011000000000000101001010000"; -- 0x036527E7BF3000A50
    constant GPIO_RX_WBWF_MASK_1250_1610 : std_logic_vector(64 downto 0) := "01011011001010010011111100111101111110011000000000000101001010000"; -- 0x0B6527E7BF3000A50
    constant GPIO_RX_NBWF_MASK_1610_2020 : std_logic_vector(64 downto 0) := "00011011001011010011111100111101111110011000000000000101001010000"; -- 0x0365A7E7BF3000A50
    constant GPIO_RX_WBWF_MASK_1610_2020 : std_logic_vector(64 downto 0) := "01011011001011010011111100111101111110011000000000000101001010000"; -- 0x0B65A7E7BF3000A50
    constant GPIO_RX_NBWF_MASK_2020_2600 : std_logic_vector(64 downto 0) := "00011011001000001011111100111101111110011000000000000101001010000"; -- 0x036417E7BF3000A50
    constant GPIO_RX_WBWF_MASK_2020_2600 : std_logic_vector(64 downto 0) := "01011011001000001011111100111101111110011000000000000101001010000"; -- 0x0B6417E7BF3000A50
    constant GPIO_RX_NBWF_MASK_2600_2700 : std_logic_vector(64 downto 0) := "00000011001010001011111100111101111110011000000000000101001010000"; -- 0x006517E7BF3000A50
    constant GPIO_RX_WBWF_MASK_2600_2700 : std_logic_vector(64 downto 0) := "01000011001010001011111100111101111110011000000000000101001010000"; -- 0x086517E7BF3000A50
        
    signal dds_a_in : std_logic_vector( 31 downto 0) := (others => '0');    
    signal dds_b_in : std_logic_vector( 31 downto 0) := (others => '0');    
     signal reset : std_logic_vector(0 downto 0) := "0";   
    
    CONSTANT BRAM_LUT_SIZE : integer := 128;

    type fsm_state is (IDLE,TX,RX,PLL_CONFIG, DDS_CONFIG, CAL_TRIGGER_TIME, WAIT_TRIGGER,PLL_PINGPONG,TX_SW_GPIO_CONFIG, RX_SW_GPIO_CONFIG, POWER_CONFIG);
    signal current_state,next_state : fsm_state;
    signal tx_switch_delay : std_logic_vector(14 downto 0) := (others => '0');
    signal rx_switch_delay : std_logic_vector(14 downto 0) := (others => '0');
    signal gpio_request : std_logic;
    signal gpio_mask,current_gpio_mask : std_logic_vector(0 to N_GPIO - 1);
    signal gpio_mask_ub : std_logic_vector( N_GPIO - 1 downto 0);
    -- WBWF (2/4/8/40 MHz, BW code >= 0x04) selects the wide IF filter (if_fb_sw_0);
    -- NBWF (25/50/75 kHz) the narrow one. Used to pick NBWF vs WBWF GPIO mask.
    signal wideband_tx, wideband_rx : std_logic;
    signal TX_RXn : std_logic;


    signal DDS_32BIT_MODE 		: std_logic := '0';
    signal DDS_MASTER_RESET     : std_logic := '0'; 
    signal RTX_01 			    : std_logic := '0';
    signal RTX_02 			    : std_logic := '0';
    signal RTX_09 			    : std_logic := '0';
    signal RTX_11 			    : std_logic := '0';
    signal RTX_13 			    : std_logic := '0';
    signal RTX_14 			    : std_logic := '0';
    signal RTX_15 			    : std_logic := '0';
    signal RTX_16 			    : std_logic := '0';
    signal RTX_17 			    : std_logic := '0';
    signal RTX_18 			    : std_logic := '0';
    signal RTX_19 			    : std_logic := '0';
    signal RTX_20 			    : std_logic := '0';
    signal IF_FB_SW_2 			: std_logic := '0';
    signal IF_70_RX_SW_V1 	: std_logic := '0';
    signal IF_70_RX_SW_V2 	: std_logic := '0';
    signal PP_An_B 			    : std_logic := '0';
    signal HB_RX_TBPF_SW_0 	: std_logic := '0';
    signal HB_RX_TBPF_SW_0n : std_logic := '1';
    signal LO_DIV_EN 			  : std_logic := '0';
    signal LB_LPF_SW_1            : std_logic := '0';
    signal LB_LPF_SW_2            : std_logic := '0';
    signal LB_LPF_SW_3            : std_logic := '0';
    signal LB_LPF_SW_4            : std_logic := '0';
    
    signal HB_LPF_SW_1            : std_logic := '0';
    signal HB_LPF_SW_2            : std_logic := '0';
    signal HB_LPF_SW_3            : std_logic := '0';
    signal HB_LPF_SW_4            : std_logic := '0';    
    
    signal LB_LPF_SW 			  : std_logic_vector(1 to 4) := (others =>'0');
    signal HB_LPF_SW	 		  : std_logic_vector(1 to 3) := (others =>'0');
    signal PLL_A_EN 			  : std_logic := '0';
    signal PLL_A_NB 			  : std_logic := '0';
    signal PLL_B_EN 			  : std_logic := '0';
    signal PLL_B_NB 			  : std_logic := '0';
    signal DDS_A_VCO 			: std_logic_vector(1 downto 0);
    signal DDS_B_VCO 			: std_logic_vector(1 downto 0);
    signal LO_HB_A 			    : std_logic := '0';
    signal LO_HB_B 			    : std_logic := '0';
    signal OL_ADC_504 			: std_logic := '0';
    signal OL_ADC_917 			: std_logic := '0';
    signal MUX_A0 			    : std_logic := '0';
    signal MUX_A1 			    : std_logic := '0';
    signal MUX_A2 			    : std_logic := '0';
    signal MUX_A3 			    : std_logic := '0';

    signal PG_VCO			      : std_logic;
    signal DDS_A_PLL_LOCKED	: std_logic;
    signal DDS_B_PLL_LOCKED	: std_logic;


    -- 19/10/2026: 0x3415 = 13333 viet theo gia dinh chu ky sai. fsm_clk = 150 MHz (6,667 ns):
    -- setup <= 20 us -> 3000 chu ky (0x0BB8). CFG_LUT o 65 ghi de gia tri nay.
    signal pll_setup_time              : std_logic_vector(15 downto 0) := x"0BB8";
    -- switch <= 4 us. Hang nay o DON VI TICK 10 ns (tru vao next_pll_switch_time o
    -- CAL_TRIGGER_TIME): 400 tick (0x0190) = 4 us. Bo dem switch_cnt trong hop_exec_proc
    -- nhan 3/2 de doi sang chu ky fsm_clk (= 600 chu ky). CFG_LUT o 66 ghi de gia tri nay.
    signal pll_switching_time          : std_logic_vector(15 downto 0) := x"0190";
    signal config_trx       : std_logic;

    signal  gpio_profile    : gpio_profile_array_t(0 to N_GPIO - 1);
    -----BRAM COntrol signals
    type bram_state_type is (BRAM_IDLE, BRAM_READING, BRAM_FINISH);
    signal bram_state : bram_state_type := BRAM_IDLE;

    signal bram_read_counter  : unsigned(15 downto 0) := (others => '0');
    signal reg_write_counter : unsigned(15 downto 0) := (others => '0');
    signal valid_pipeline : std_logic := '0'; 
    signal loading_done        : std_logic;
    signal rf_state       : std_logic_vector(2 downto 0);

    signal pll_state : std_logic_vector(3 downto 0);

    signal txhb_txhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txlb_txhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txlb_txlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txhb_txlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txhb_rxhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txhb_rxlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txlb_rxhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal txlb_rxlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxhb_txhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxhb_txlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxlb_txhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxlb_txlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxhb_rxhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxhb_rxlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxlb_rxhb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal rxlb_rxlb_early_value : std_logic_vector(14 downto 0) := (others => '0');
    signal lb_rx_tbpf_freq : std_logic_vector(31 downto 0) := (others => '0');
    signal lb_tx_tbpf_freq : std_logic_vector(31 downto 0) := (others => '0');																							 
    signal man_freq : std_logic_vector(31 downto 0) := (others => '0');																		   
    signal man_freq_mem : std_logic_vector(31 downto 0) := (others => '0');																		   
    signal Set_freq            : std_logic := '0';
    signal set_TBPF_freq       : std_logic := '0';
    signal ad9164_start_config : std_logic;
    signal gpio_actual_mask : std_logic_vector( N_GPIO - 1 downto 0);
    signal gpio_out : std_logic_vector( N_GPIO - 1 downto 0);
    signal gpio_actual_request : std_logic;

    -- ADDED: tx_ctrl status signals
    signal tx_bite_rx_ld            : std_logic;
    signal tx_lb_pa_current_alr     : std_logic;
    signal tx_lb_drv_current_alr    : std_logic;
    signal tx_hb_pa_current_alr     : std_logic;
    signal tx_hb_drv_current_alr    : std_logic;
    signal tx_hb_pre_current_alr    : std_logic;
    signal tx_lb_fwd_power_alr      : std_logic;
    signal tx_lb_rwd_power_alr      : std_logic;
    signal tx_hb_fwd_power_alr      : std_logic;
    signal tx_hb_rwd_power_alr      : std_logic;
    signal tx_cpld_rev              : std_logic_vector(7 downto 0);

    signal ad9164_off_nco : std_logic;
    signal dds_config_done  :std_logic;
    signal next_frequency : std_logic_vector(47 downto 0);
    signal next_bandwith : std_logic_vector(7 downto 0);
    signal gpio_test_in_dly : std_logic;
    -- 9/9/2026: GPIO arbiter uB <-> main FSM (parallel control, no lost request)
    signal gpio_busy           : std_logic;                                   -- gpio_fsm running a sequence
    signal ub_gpio_pend        : std_logic;                                   -- uB request waiting
    signal fsm_gpio_pend       : std_logic;                                   -- main FSM request waiting
    signal ub_gpio_pend_mask   : std_logic_vector( N_GPIO - 1 downto 0);
    signal fsm_gpio_pend_mask  : std_logic_vector( N_GPIO - 1 downto 0);
    signal fsm_gpio_reapply    : std_logic;                                   -- uB wrote since last FSM mask -> re-apply band mask at next *_SW_GPIO_CONFIG
    signal in_sw_gpio_cfg      : std_logic;
    signal in_sw_gpio_cfg_d1   : std_logic;
    signal in_sw_gpio_cfg_d2   : std_logic;
    signal bram_debug : std_logic_vector(1 downto 0);
    signal INT_A : std_logic_vector(6 downto 0);
    signal INT_B : std_logic_vector(6 downto 0);
    signal U468_att_val : std_logic_vector(5 downto 0) := "111111";
    signal U148_att_val : std_logic_vector(5 downto 0) := "111111";
    signal U473_att_val : std_logic_vector(5 downto 0) := "111111";
    signal valid_pipeline_dly : std_logic;
   
    signal hop_tx_freq : std_logic_vector(47 downto 0) := (others => '0');
    signal hop_rx_freq : std_logic_vector(47 downto 0) := (others => '0');
    signal hop_trx     : std_logic := '0';
    signal hop_tx_bw   : std_logic_vector(7 downto 0) := (others => '0');
    signal hop_rx_bw   : std_logic_vector(7 downto 0) := (others => '0');
    signal hop_ntx     : std_logic_vector(26 downto 0) := (others => '0');
    signal hop_nrx     : std_logic_vector(26 downto 0) := (others => '0');

    signal next_gpio_switch_time : std_logic_vector(26 downto 0);
    signal next_pll_switch_time : std_logic_vector(26 downto 0);
	signal cycle_cnt_A : integer range 0 to 400 := 0;
    signal cycle_cnt_B : integer range 0 to 400 := 0;									   
	signal reset_en  : std_logic := '1';
	signal ad9164_uB_mosi  : std_logic := '0';
	signal ad9164_fsm_mosi  : std_logic := '0';
	signal ad9164_uB_csn  : std_logic := '0';
	signal ad9164_fsm_csn  : std_logic := '0';
	signal ad9164_uB_sclk  : std_logic := '0';
	signal ad9164_fsm_sclk  : std_logic := '0';
	signal lb_rx_tbpf_1_tune_rdy : std_logic;
	signal lb_rx_tbpf_2_tune_rdy : std_logic;							   							  
	signal probe_ila_16_bit : std_logic_vector(15 downto 0) := (others => '0'); 							  
	signal reset_cnt : integer range 0 to 100000 := 100000; 
	signal freq_cnt : integer range 0 to 100000 := 100000; 
	signal which_freq : integer range 0 to 5 := 5; 
	signal DAC_freq : std_logic_vector( 31 downto 0) := (others => '0'); 		
	signal Set_DAC_freq : std_logic;
	signal dds_calc : std_logic_vector( 31 downto 0) := (others => '0'); 		
	signal dds_a_calc_dav : std_logic;	
	signal dds_b_calc_dav : std_logic;
	signal provv_bw : std_logic_vector(7 downto 0) := (others => '0'); 	
	signal provv_bw_mem : std_logic_vector(7 downto 0) := (others => '0'); 	
	signal set_cnt : integer range 0 to 100000 := 0;	
	



    component ila_fsm_dbg is
      port (
        clk     : in std_logic;
        probe0  : in std_logic_vector(3 downto 0);   -- current_state (FSM_CODE)
        probe1  : in std_logic_vector(3 downto 0);   -- from_state: nguon cua lan chuyen gan nhat
        probe2  : in std_logic_vector(3 downto 0);   -- to_state  : dich cua lan chuyen gan nhat
        probe3  : in std_logic_vector(0 downto 0);   -- state_change (1 chu ky moi lan doi trang thai)
        probe4  : in std_logic_vector(3 downto 0);   -- pll_state (fsm_pll_lut)
        probe5  : in std_logic_vector(31 downto 0);  -- fsm_cond: dieu kien chuyen trang thai, TUC THOI
        probe6  : in std_logic_vector(31 downto 0);  -- fsm_cond chot tai dung luc chuyen -> "vi sao no di"
        probe7  : in std_logic_vector(31 downto 0);  -- next_frequency (Hz) = Tx_freq neu trx=1, nguoc lai Rx_freq
        probe8  : in std_logic_vector(26 downto 0);  -- Current_Subsecond_in (10 ns/tick)
        probe9  : in std_logic_vector(26 downto 0);  -- next_gpio_switch_time
        probe10 : in std_logic_vector(26 downto 0);  -- next_pll_switch_time
        probe11 : in std_logic_vector(26 downto 0);  -- Next_Frame_Transmit_Time_in (metadata)
        probe12 : in std_logic_vector(26 downto 0);  -- Next_Frame_Receive_Time_in  (metadata)
        probe13 : in std_logic_vector(23 downto 0);  -- metadata {Tx_bw, Rx_bw, Power_Tx}
        probe14 : in std_logic_vector(64 downto 0);  -- gpio_actual_mask (mask phat sang gpio_fsm)
        probe15 : in std_logic_vector(64 downto 0);  -- gpio_out (trang thai chan GPIO thuc te)
        probe16 : in std_logic_vector(15 downto 0)   -- dem so lan chuyen trang thai
      );
    end component ila_fsm_dbg;

    -- state_change 
    signal state_d            : fsm_state;
    signal from_state         : fsm_state;
    signal to_state           : fsm_state;
    signal state_change       : std_logic := '0';
    signal state_change_cnt   : unsigned(15 downto 0) := (others => '0');
    -- fsm conditions
    signal fsm_cond           : std_logic_vector(31 downto 0);
    signal fsm_cond_d1        : std_logic_vector(31 downto 0) := (others => '0');
    signal fsm_cond_d2        : std_logic_vector(31 downto 0) := (others => '0');
    signal fsm_cond_at_change : std_logic_vector(31 downto 0) := (others => '0');
    signal meta_bw_pwr        : std_logic_vector(23 downto 0);

    signal from_state_code    : std_logic_vector(3 downto 0);
    signal to_state_code      : std_logic_vector(3 downto 0);
    signal next_freq_hz       : std_logic_vector(31 downto 0);
    signal state_change_cnt_v : std_logic_vector(15 downto 0);

    signal fsm_state_code   : std_logic_vector(3 downto 0);

    ---------------------------------------------------------------------------
    -- 19/10/2026 (phuong an B, docs/FSM_T7_vs_Claudio.html muc 9): thay fsm_pll_lut
    -- + ad9164_nco_config bang hop_exec_proc lai PLL_Driver / AD_9164_Driver.
    ---------------------------------------------------------------------------
    signal fsm_busy      : std_logic;                        -- '1' khi current_state /= IDLE
    signal hop_set       : std_logic := '0';                 -- xung Set cho PLL_Driver
    signal hop_mask      : std_logic_vector(64 downto 0);    -- mask bang tan cua hop nay
    signal hop_bw        : std_logic_vector(7 downto 0);     -- ma bw cho PLL_Driver.calc_IF
    signal pp_cur        : std_logic := '0';                 -- LO dang dung: 0 = A, 1 = B
    signal dac_req       : std_logic := '0';                 -- yeu cau ghi AD9164 dang cho
    signal dac_set       : std_logic := '0';                 -- xung Set_DAC_freq cho AD_9164_Driver
    signal dac_inflight  : std_logic := '0';                 -- AD_9164_Driver dang ghi theo yeu cau cua FSM
    signal dac_freq_hop  : std_logic_vector(31 downto 0) := (others => '0');
    signal dac_hop_sel   : std_logic;
    signal ad9164_busy   : std_logic;
    signal ad9164_busy_d : std_logic := '0';
    signal dac_wd        : unsigned(11 downto 0) := (others => '0');  -- watchdog yeu cau DAC
    signal setup_cnt     : unsigned(15 downto 0) := (others => '0');
    signal switch_cnt    : unsigned(16 downto 0) := (others => '0');
    signal switch_target : unsigned(16 downto 0);
    signal calc_cnt      : unsigned(5 downto 0)  := (others => '0');
    type pll_phase_t is (P_IDLE, P_CALC, P_SETUP, P_READY, P_SWITCH);
    signal pll_phase     : pll_phase_t := P_IDLE;
    -- mux duong thu cong (uB) / duong hop (FSM)
    signal drv_freq      : std_logic_vector(31 downto 0);
    signal drv_txrxn     : std_logic;
    signal drv_bw        : std_logic_vector(7 downto 0);
    signal drv_set       : std_logic;
    signal drv_pp        : std_logic;
    signal dac_drv_set   : std_logic;
    signal dac_drv_freq  : std_logic_vector(31 downto 0);

    -- Mask bang tan theo (tan so, NBWF/WBWF, TX/RX): cung bang va cung bien voi
    -- gpio_fsm_proc. Dung de lay ba bit IF_FB_SW (26, 64, 63) cho PLL_Driver tai
    -- PLL_CONFIG, truoc khi GPIO thuc su chuyen o *_SW_GPIO_CONFIG.
    function band_mask(f : std_logic_vector(47 downto 0); wb : std_logic; tx : std_logic)
        return std_logic_vector is
    begin
        if tx = '1' then
            if    (f < FREQ_160)  then if wb = '1' then return GPIO_TX_WBWF_MASK_30_160;    else return GPIO_TX_NBWF_MASK_30_160;    end if;
            elsif (f < FREQ_350)  then if wb = '1' then return GPIO_TX_WBWF_MASK_160_350;   else return GPIO_TX_NBWF_MASK_160_350;   end if;
            elsif (f < FREQ_520)  then if wb = '1' then return GPIO_TX_WBWF_MASK_350_520;   else return GPIO_TX_NBWF_MASK_350_520;   end if;
            elsif (f < FREQ_600)  then if wb = '1' then return GPIO_TX_WBWF_MASK_520_600;   else return GPIO_TX_NBWF_MASK_520_600;   end if;
            elsif (f < FREQ_901)  then if wb = '1' then return GPIO_TX_WBWF_MASK_600_901;   else return GPIO_TX_NBWF_MASK_600_901;   end if;
            elsif (f < FREQ_1223) then if wb = '1' then return GPIO_TX_WBWF_MASK_901_1223;  else return GPIO_TX_NBWF_MASK_901_1223;  end if;
            elsif (f < FREQ_1250) then if wb = '1' then return GPIO_TX_WBWF_MASK_1223_1250; else return GPIO_TX_NBWF_MASK_1223_1250; end if;
            elsif (f < FREQ_1610) then if wb = '1' then return GPIO_TX_WBWF_MASK_1250_1610; else return GPIO_TX_NBWF_MASK_1250_1610; end if;
            elsif (f < FREQ_2020) then if wb = '1' then return GPIO_TX_WBWF_MASK_1610_2020; else return GPIO_TX_NBWF_MASK_1610_2020; end if;
            elsif (f < FREQ_2560) then if wb = '1' then return GPIO_TX_WBWF_MASK_2020_2560; else return GPIO_TX_NBWF_MASK_2020_2560; end if;
            else                       if wb = '1' then return GPIO_TX_WBWF_MASK_2560_2700; else return GPIO_TX_NBWF_MASK_2560_2700; end if;
            end if;
        else
            if    (f < FREQ_160)  then if wb = '1' then return GPIO_RX_WBWF_MASK_30_160;    else return GPIO_RX_NBWF_MASK_30_160;    end if;
            elsif (f < FREQ_350)  then if wb = '1' then return GPIO_RX_WBWF_MASK_160_350;   else return GPIO_RX_NBWF_MASK_160_350;   end if;
            elsif (f < FREQ_520)  then if wb = '1' then return GPIO_RX_WBWF_MASK_350_520;   else return GPIO_RX_NBWF_MASK_350_520;   end if;
            elsif (f < FREQ_755)  then if wb = '1' then return GPIO_RX_WBWF_MASK_520_755;   else return GPIO_RX_NBWF_MASK_520_755;   end if;
            elsif (f < FREQ_901)  then if wb = '1' then return GPIO_RX_WBWF_MASK_755_901;   else return GPIO_RX_NBWF_MASK_755_901;   end if;
            elsif (f < FREQ_1000) then if wb = '1' then return GPIO_RX_WBWF_MASK_901_1000;  else return GPIO_RX_NBWF_MASK_901_1000;  end if;
            elsif (f < FREQ_1223) then if wb = '1' then return GPIO_RX_WBWF_MASK_1000_1223; else return GPIO_RX_NBWF_MASK_1000_1223; end if;
            elsif (f < FREQ_1250) then if wb = '1' then return GPIO_RX_WBWF_MASK_1223_1250; else return GPIO_RX_NBWF_MASK_1223_1250; end if;
            elsif (f < FREQ_1610) then if wb = '1' then return GPIO_RX_WBWF_MASK_1250_1610; else return GPIO_RX_NBWF_MASK_1250_1610; end if;
            elsif (f < FREQ_2020) then if wb = '1' then return GPIO_RX_WBWF_MASK_1610_2020; else return GPIO_RX_NBWF_MASK_1610_2020; end if;
            elsif (f < FREQ_2600) then if wb = '1' then return GPIO_RX_WBWF_MASK_2020_2600; else return GPIO_RX_NBWF_MASK_2020_2600; end if;
            else                       if wb = '1' then return GPIO_RX_WBWF_MASK_2600_2700; else return GPIO_RX_NBWF_MASK_2600_2700; end if;
            end if;
        end if;
    end function;

    function FSM_CODE (s : fsm_state) return std_logic_vector is
    begin
        case s is
            when IDLE               => return x"0";
            when TX                 => return x"1";
            when RX                 => return x"2";
            when PLL_CONFIG         => return x"3";
            when DDS_CONFIG         => return x"4";
            when CAL_TRIGGER_TIME   => return x"5";
            when WAIT_TRIGGER       => return x"6";
            when PLL_PINGPONG       => return x"7";
            when TX_SW_GPIO_CONFIG  => return x"8";
            when RX_SW_GPIO_CONFIG  => return x"9";
            when POWER_CONFIG       => return x"A";
        end case;
    end function;

begin
    CFG_LUT_clk <= fsm_clk_in;
    CFG_LUT_rst <= '0';
    -- Dung ban chot: next_frequency chay vao ad9164_nco_config.target_freq_hz va fsm_pll_lut.next_frequency_in.
    next_frequency <= hop_tx_freq when hop_trx = '1' else hop_rx_freq;
    next_bandwith  <= hop_tx_bw   when hop_trx = '1' else hop_rx_bw;
    wideband_tx    <= '1' when hop_tx_bw >= x"04" else '0';
    wideband_rx    <= '1' when hop_rx_bw >= x"04" else '0';
    i_GPIO_Mux_wrapper : entity work.GPIO_Mux_wrapper
    port map(
        CLK                 => fsm_clk_in,
		GPIO_MUXED			=> GPIO_MUXED,
        GPIO_MUX_LE_0		=> GPIO_MUX_LE_0,
        GPIO_MUX_LE_1		=> GPIO_MUX_LE_1,
        GPIO_MUX_LE_2	    => GPIO_MUX_LE_2,
        GPIO_MUX_LE_3		=> GPIO_MUX_LE_3,										   														   
        ADC_AFE_PWUP        => ADC_AFE_PWUP,
        ADC_AFE_PM          => ADC_AFE_PM,
        EN_RX               => EN_RX,
        EN_TX               => EN_TX,
        EN_LO               => EN_LO,
        EN_RTX              => EN_RTX,
        DDS_PWR_DWN      	=> DDS_PWR_DWN,
        ADC_PDWN         	=> ADC_PDWN,
		  
        RTX_01              => RTX_01,
        RTX_02              => RTX_02,
        RTX_09              => RTX_09,
        RTX_11              => RTX_11,
        RTX_13              => RTX_13,
        RTX_14              => RTX_14,
        RTX_15              => RTX_15,
        RTX_16              => RTX_16,
        RTX_17              => RTX_17,
        RTX_18              => RTX_18,
        RTX_19              => RTX_19,
        RTX_20              => RTX_20,
        
        IF_FB_SW_2          => IF_FB_SW_2,
        IF_70_RX_SW_V1      => IF_70_RX_SW_V1,
        IF_70_RX_SW_V2      => IF_70_RX_SW_V2,
        PP_An_B             => PP_An_B,
        HB_RX_TBPF_SW_0     => HB_RX_TBPF_SW_0,
        LO_DIV_EN           => LO_DIV_EN,
        
        LB_LPF_SW        => LB_LPF_SW(1 to 3),



        HB_LPF_SW        => HB_LPF_SW(1 to 2),
        
        PLL_A_EN            => PLL_A_EN,
        PLL_A_NB            => PLL_A_NB,
        PLL_B_EN            => PLL_B_EN,
        PLL_B_NB            => PLL_B_NB,
        DDS_A_VCO        	=> DDS_A_VCO,
        DDS_B_VCO        	=> DDS_B_VCO,
        
        LO_HB_A             => LO_HB_A,
        LO_HB_B             => LO_HB_B,
        OL_ADC_504          => OL_ADC_504,
        OL_ADC_917          => OL_ADC_917,
        MUX_A0              => MUX_A0,
        MUX_A1              => MUX_A1,
        MUX_A2              => MUX_A2,
        MUX_A3              => MUX_A3,
		PG_VCO           	=> PG_VCO,
        DDS_A_PLL_LOCKED 	=> DDS_A_PLL_LOCKED,
        DDS_B_PLL_LOCKED 	=> DDS_B_PLL_LOCKED
    );

    -- ADDED: instantiate TX_CTRL for SPI_CPLD path and command/status
    i_tx_ctrl : entity work.TX_CTRL
    port map (
        CLK_i                => fsm_clk_in,
        SPI_TX_CSn_2_o       => SPI_CPLD_CSN_out,
        SPI_TX_SCLK_o        => SPI_CPLD_SCLK_out,
        SPI_TX_MISO_i        => SPI_CPLD_MISO_in,
        SPI_TX_MOSI_o        => SPI_CPLD_MOSI_out,

        BITE_RX_LD_o         => tx_bite_rx_ld,
        LB_PA_CURRENT_ALR_o  => tx_lb_pa_current_alr,
        LB_DRV_CURRENT_ALR_o => tx_lb_drv_current_alr,
        HB_PA_CURRENT_ALR_o  => tx_hb_pa_current_alr,
        HB_DRV_CURRENT_ALR_o => tx_hb_drv_current_alr,
        HB_PRE_CURRENT_ALR_o => tx_hb_pre_current_alr,
        LB_FWD_POWER_ALR_o   => tx_lb_fwd_power_alr,
        LB_RWD_POWER_ALR_o   => tx_lb_rwd_power_alr,
        HB_FWD_POWER_ALR_o   => tx_hb_fwd_power_alr,
        HB_RWD_POWER_ALR_o   => tx_hb_rwd_power_alr,
        CPLD_REV_o           => tx_cpld_rev,
        TX_VDD_PGOOD_o       => open,
        RTX_PUSH_GATE_o      => open,
        SMPS_SYNC_RTX_o      => open,

        SMPS_SYNC_i          => tx_command_in(0),
        LB_PA_CURRENT_i      => tx_command_in(1),
        LB_DRV_CURRENT_i     => tx_command_in(2),
        HB_PA_CURRENT_i      => tx_command_in(3),
        HB_DRV_CURRENT_i     => tx_command_in(4),
        HB_PRE_CURRENT_i     => tx_command_in(5),
        LB_SW_4_RTX_i        => tx_command_in(6),
        LB_SW_3_RTX_i        => tx_command_in(7),
        LB_SW_2_RTX_i        => tx_command_in(8),
        LB_SW_1_RTX_i        => tx_command_in(9),
        HB_SW_4_RTX_i        => tx_command_in(10),
        HB_SW_3_RTX_i        => tx_command_in(11),
        HB_SW_2_RTX_i        => tx_command_in(12),
        HB_SW_1_RTX_i        => tx_command_in(13),
        RF_OFF_i             => tx_command_in(14),
        RESET_o              => open
    );

    ----- FPGA GPIOs-----------------------------------------------------
    -- Switches
  ----- FPGA GPIOs-----------------------------------------------------
    -- Switches
    if_fb_sw_1          <= gpio_out(64);
    if_fb_sw_0          <= gpio_out(63);
    hb_tpfb_sw_2        <= gpio_out(62);
    hb_tpfb_sw_1        <= gpio_out(61);
    hb_tpfb_sw_0        <= gpio_out(60);
    hb_tpfb_sw_0n       <= gpio_out(59);
    lb_rx_tbpf_sw_1     <= gpio_out(58);
    lb_rx_tbpf_sw_2     <= gpio_out(57);
    lb_sw_1             <= gpio_out(56);
    lb_sw_2             <= gpio_out(55);
    lb_tx_tbpf_sw_1     <= gpio_out(54);
    lb_tx_tbpf_sw_2     <= gpio_out(53);
    hb_fb_sw_1          <= gpio_out(52);
    hb_fb_sw_0          <= gpio_out(51); 
    -- TX Attenuator & HB Feedback
    hb_fb_tx            <= gpio_out(50);
    -----------------------------------------------------------------------
    -- Band 65
    -----------------------------------------------------------------------
    --lo_ps               <= (others => '0'); -- Phase shifters?  
    lo_ps(7 downto 0)     <=  command3_in(7 downto 0); -- lo_ps_b & lo_ps_a Phase shifters?
    hb_fb_sw_2n         <= gpio_out(49);
    hb_fb_sw_2          <= gpio_out(48);
--	ADC_AFE_PWUP      <= gpio_out(46);
--    ADC_AFE_PM        <= gpio_out(45);
--    EN_RX             <= gpio_out(44);
--    EN_TX             <= gpio_out(43);
--    EN_LO             <= gpio_out(42);
--    EN_RTX            <= gpio_out(41);
--    DDS_PWR_DWN       <= gpio_out(40);
--    ADC_PDWN          <= gpio_out(39);
    RTX_01            <= gpio_out(38);
    RTX_02            <= gpio_out(37);
    RTX_09            <= gpio_out(36);
    RTX_11            <= gpio_out(35);
    RTX_13            <= gpio_out(34);
    RTX_14            <= gpio_out(33);
    RTX_15            <= gpio_out(32);
    RTX_16            <= gpio_out(31);
    RTX_17            <= gpio_out(30);
    RTX_18            <= gpio_out(29);
    RTX_19            <= gpio_out(28);
    RTX_20            <= gpio_out(27);
    IF_FB_SW_2        <= gpio_out(26);
    IF_70_RX_SW_V1    <= gpio_out(25);
    IF_70_RX_SW_V2    <= gpio_out(24);
    -- 19/10/2026: FSM so huu ping-pong (pp_cur lat o PLL_PINGPONG). Bit 23 cua 46 mask
    -- bang tan deu = 0 nen uB van dao duoc qua gpio_mask_ub_in(23).
    PP_An_B           <= pp_cur xor gpio_out(23);
    HB_RX_TBPF_SW_0   <= gpio_out(22);
    LO_DIV_EN         <= gpio_out(21);
    lo_div2_en_a      <= gpio_out(21);
    lo_div2_en_b      <= gpio_out(21);
    LB_LPF_SW(1)      <= gpio_out(20);
    LB_LPF_SW(2)      <= gpio_out(19);
    LB_LPF_SW(3)      <= gpio_out(18);
    HB_LPF_SW(1)      <= gpio_out(17);
    HB_LPF_SW(2)      <= gpio_out(16);
								 
    PLL_A_EN          <= '1';--gpio_out(15);
    --PLL_A_NB          <= gpio_out(14);
    PLL_B_EN          <= '1';--gpio_out(13);
	--PLL_B_NB          <= gpio_out(12);
	 
    DDS_A_VCO         <= gpio_out(11 downto 10);
	DDS_B_VCO         <= gpio_out(9 downto 8); 
    LO_HB_A           <= gpio_out(7);
    LO_HB_B           <= gpio_out(6);
    OL_ADC_504        <= gpio_out(5);
    OL_ADC_917        <= gpio_out(4);
    MUX_A0            <= gpio_out(3);
    MUX_A1            <= gpio_out(2);
    MUX_A2            <= gpio_out(1);
    MUX_A3            <= gpio_out(0);
    ---------------------------------------------------------------------------
    
    -- bo fsm_pll_lut va ad9164_nco_config. main_fsm_proc GIU NGUYEN; hai tin hieu no can
    -- (pll_state, dds_config_done) do hop_exec_proc tao ra tu PLL_Driver va
    -- AD_9164_Driver, dung dung MA CU (PLL_WAIT = "0111", PLL_IDLE = "0001").
    --
    --   PLL_CONFIG   : chu ky dau phat hop_set -> PLL_Driver tinh IF / LO = f+IF / INT /
    --                  dds cho PLL dang RANH (PP = not pp_cur). Khi dds_dav_a/b len
    --                  (ADF41510_Driver va AD9914_Driver bat dau ghi) dem pll_setup_time
    --                  chu ky cho PLL khoa -> pll_state = PLL_WAIT.
    --   PLL_PINGPONG : chu ky dau lat pp_cur (doi LO A<->B tren pingpong_An_b) va ghi IF
    --                  (DAC_freq cua PLL_Driver) vao AD9164; dem pll_switching_time x 3/2
    --                  chu ky (hang o tick 10 ns, fsm_clk 6,667 ns) -> pll_state = PLL_IDLE.
    --   DDS_CONFIG   : chu ky dau ghi tan so hop thang vao AD9164 (duong NCO, khong dung LO).
    --   dds_config_done = canh xuong AD_9164_Driver.busy sau MOT yeu cau cua FSM.
    -- Khi current_state = IDLE, cac mux tro ve duong thu cong tu uB (man_freq, Set_freq,
    -- provv_bw, TX_RXn, PP_An_B) nhu truoc.
    ---------------------------------------------------------------------------
    fsm_busy <= '1' when current_state /= IDLE else '0';

    -- ma bw cho PLL_Driver.calc_IF = ba bit IF_FB_SW cua mask bang tan se duoc ap
    -- o *_SW_GPIO_CONFIG: bit 26 & 64 & 63 (cung thu tu voi provv_bw).
    hop_mask <= band_mask(next_frequency, wideband_tx, '1') when hop_trx = '1'
           else band_mask(next_frequency, wideband_rx, '0');
    hop_bw   <= "00000" & hop_mask(26) & hop_mask(64) & hop_mask(63);

    -- tick 10 ns -> chu ky 6,667 ns: nhan 3/2 (400 tick -> 600 chu ky, sai so 0)
    switch_target <= resize(unsigned(pll_switching_time), 17)
                   + resize(unsigned('0' & pll_switching_time(15 downto 1)), 17);

    hop_exec_proc : process(fsm_clk_in)
    begin
        if rising_edge(fsm_clk_in) then
            if fsm_rstn_in = '0' then
                pll_phase       <= P_IDLE;
                pp_cur          <= '0';
                hop_set         <= '0';
                dac_set         <= '0';
                dac_req         <= '0';
                dac_inflight    <= '0';
                dds_config_done <= '0';
                ad9164_busy_d   <= '0';
                setup_cnt       <= (others => '0');
                switch_cnt      <= (others => '0');
                calc_cnt        <= (others => '0');
                dac_wd          <= (others => '0');
            else
                hop_set       <= '0';                    -- xung 1 chu ky
                dac_set       <= '0';
                ad9164_busy_d <= ad9164_busy;

                -- (1) Tien trinh pha PLL, chay DOC LAP voi current_state: main_fsm_proc co the
                --     roi PLL_PINGPONG som (dds_config_done, nhu T7) hoac roi PLL_CONFIG o chu
                --     ky dau neu pll_state con sot PLL_WAIT; pha van phai tu hoan tat.
                if pll_phase = P_CALC then
                    if (dds_a_calc_dav = '1') or (dds_b_calc_dav = '1') then
                        pll_phase <= P_SETUP;                         -- INT/dds da ra, driver bat dau ghi
                        setup_cnt <= (others => '0');
                    else
                        -- PLL_Driver chi nhan Set o wait_set; neu dang ban vi mot Set thu cong
                        -- ngay truoc do thi xung bi mat -> phat lai sau 64 chu ky
                        calc_cnt <= calc_cnt + 1;
                        if calc_cnt = 63 then hop_set <= '1'; end if;
                    end if;
                elsif pll_phase = P_SETUP then
                    setup_cnt <= setup_cnt + 1;                       -- cho PLL khoa (pll_setup_time)
                    if setup_cnt >= unsigned(pll_setup_time) then
                        pll_phase <= P_READY;
                    end if;
                elsif pll_phase = P_SWITCH then
                    switch_cnt <= switch_cnt + 1;                     -- pll_switching_time x 3/2
                    if switch_cnt >= switch_target then
                        pll_phase <= P_IDLE;
                    end if;
                end if;

                -- (2) Su kien theo trang thai FSM (gan sau de thang (1) trong cung chu ky)
                case current_state is
                    when PLL_CONFIG =>
                        if state_d /= PLL_CONFIG then                 -- chu ky dau: kich PLL_Driver
                            hop_set   <= '1';
                            calc_cnt  <= (others => '0');
                            pll_phase <= P_CALC;
                        end if;
                    when PLL_PINGPONG =>
                        if state_d /= PLL_PINGPONG then               -- moc hop: lat LO, ghi IF vao DAC
                            pp_cur       <= not pp_cur;
                            dac_req      <= '1';
                            dac_freq_hop <= DAC_freq;
                            switch_cnt   <= (others => '0');
                            pll_phase    <= P_SWITCH;
                        end if;
                    when DDS_CONFIG =>
                        if state_d /= DDS_CONFIG then                 -- duong NCO: DAC phat thang f hop
                            dac_req      <= '1';
                            dac_freq_hop <= next_frequency(31 downto 0);
                            -- Hop RX voi 600 < Rx_freq <= 1200: main_fsm_proc di PLL_CONFIG (IDLE ep
                            -- RX vao PLL) roi RX_SW_GPIO_CONFIG lai re DDS_CONFIG, khong qua
                            -- PLL_PINGPONG. LO da duoc chuan bi o PLL_CONFIG thi van phai chuyen
                            -- tai moc nay, neu khong pll_phase sot P_READY va LO khong doi.
                            if pll_phase = P_READY then
                                pp_cur     <= not pp_cur;
                                switch_cnt <= (others => '0');
                                pll_phase  <= P_SWITCH;
                            end if;
                        end if;
                    when IDLE =>
                        if pll_phase = P_READY then pll_phase <= P_IDLE; end if;   -- khong de sot
                    when others => null;                              -- CAL/WAIT/SW: giu pha
                end case;

                -- yeu cau ghi AD9164: giu toi khi AD_9164_Driver ranh (no chi nhan Set_DAC_freq
                -- o check_freq), roi bao done tai canh xuong busy cua dung lan ghi do.
                if (dac_req = '1') and (ad9164_busy = '0') and (dac_set = '0') then
                    dac_set      <= '1';
                    dac_req      <= '0';
                    dac_inflight <= '1';
                    dac_wd       <= (others => '0');
                end if;
                if (dac_inflight = '1') and (ad9164_busy_d = '1') and (ad9164_busy = '0') then
                    dds_config_done <= '1';
                    dac_inflight    <= '0';
                elsif (dac_req = '1') or (dac_inflight = '1') then
                    -- watchdog: enable_fsm = 0 lam AD_9164_Driver bo qua Set -> khong bao gio
                    -- co busy. Sau 4095 chu ky (27 us) bao done de main_fsm_proc khong ket.
                    dac_wd <= dac_wd + 1;
                    if dac_wd = 4095 then
                        dds_config_done <= '1';
                        dac_req         <= '0';
                        dac_inflight    <= '0';
                    else
                        dds_config_done <= '0';
                    end if;
                else
                    dds_config_done <= '0';
                end if;
            end if;
        end if;
    end process;

    pll_state <= PLL_IDLE   when pll_phase = P_IDLE  else
                 PLL_CAL    when pll_phase = P_CALC  else
                 PLL_SETUP  when pll_phase = P_SETUP else
                 PLL_WAIT   when pll_phase = P_READY else
                 PLL_SWITCH;

    -- mux duong thu cong (uB, khi IDLE) / duong hop (FSM)
    drv_freq     <= next_frequency(31 downto 0) when fsm_busy = '1' else man_freq;
    drv_txrxn    <= hop_trx        when fsm_busy = '1' else TX_RXn;
    drv_bw       <= hop_bw         when fsm_busy = '1' else provv_bw;
    drv_set      <= hop_set        when fsm_busy = '1' else Set_freq;
    drv_pp       <= (not pp_cur)   when fsm_busy = '1' else PP_An_B;   -- hop: lap trinh PLL dang ranh
    dac_hop_sel  <= fsm_busy or dac_req or dac_inflight;
    dac_drv_set  <= dac_set        when dac_hop_sel = '1' else Set_DAC_freq;
    dac_drv_freq <= dac_freq_hop   when dac_hop_sel = '1' else DAC_freq;



    -- pll_a_ad9914_spi : entity work.spi_master
    -- generic map(
        -- DATA_WIDTH       => 32,
        -- CLK_DIV => 1
    -- )
    -- port map(
        -- clk       => fsm_clk_in,
        -- reset_n   => fsm_rstn_in,
        -- enable    => not pll_csn(0),
        -- tx_data   => pll_command,
        -- rx_data   => open,
        -- busy      => open,
        -- rx_valid  => open,
        -- sclk      => open,--pll_a_ad9914_clk,
        -- mosi      => open,--pll_a_ad9914_data,
        -- miso      => '0',
        -- ss_n      => open--pll_a_ad9914_le
    -- );

    -- pll_b_ad9914_spi : entity work.spi_master
    -- generic map(
        -- DATA_WIDTH       => 32,
        -- CLK_DIV => 1
    -- )
    -- port map(
        -- clk       => fsm_clk_in,
        -- reset_n   => fsm_rstn_in,
        -- enable    => not pll_csn(1),
        -- tx_data   => pll_command,
        -- rx_data   => open,
        -- busy      => open,
        -- rx_valid  => open,
        -- sclk      => open,--pll_b_ad9914_clk,
        -- mosi      => open,--pll_b_ad9914_data,
        -- miso      => '0',
        -- ss_n      => open--pll_b_ad9914_le

    -- );

    -- pll_a_adf41510_spi : entity work.spi_master
    -- generic map(
        -- DATA_WIDTH       => 32,
        -- CLK_DIV => 1
    -- )
    -- port map(   
        -- clk       => fsm_clk_in,
        -- reset_n   => fsm_rstn_in,
        -- enable    => not pll_csn(2),
        -- tx_data   => pll_command,
        -- rx_data   => open,
        -- busy      => open,
        -- rx_valid  => open,
        -- sclk      => pll_a_adf41510_clk,
        -- mosi      => pll_a_adf41510_mosi,
        -- miso      => '0',
        -- ss_n      => pll_a_adf41510_csn 
    -- );

    -- pll_b_adf41510_spi : entity work.spi_master
    -- generic map(
        -- DATA_WIDTH       => 32,
        -- CLK_DIV => 1
    -- )
    -- port map(

        -- clk       => fsm_clk_in,
        -- reset_n   => fsm_rstn_in,
        -- enable    => not pll_csn(3),
        -- tx_data   => pll_command,
        -- rx_data   => open,
        -- busy      => open,
        -- rx_valid  => open,
        -- sclk      => pll_b_adf41510_clk,
        -- mosi      => pll_b_adf41510_mosi,
        -- miso      => '0',
        -- ss_n      => pll_b_adf41510_csn 
    --);

    -- GPIO arbiter. Both sources (uB rising edge of gpio_test_in, main FSM
    -- gpio_request) are 1-cycle pulses and gpio_fsm only accepts a request while idle,
    -- so the old "forward the pulse" code lost every request that arrived while a
    -- GPIO sequence was running (P1) and dropped the FSM request when both came in
    -- the same cycle (P2). Now each source has a pending latch (latest mask wins);
    -- a pending request is issued as soon as gpio_fsm is idle and no issue is in
    -- flight. Main FSM first (time-critical band switch), then uB. A uB issue raises
    -- fsm_gpio_reapply so the FSM re-applies its band mask at the next
    -- *_SW_GPIO_CONFIG even if the band did not change (P3): a uB write is a manual
    -- override that lasts until the next scheduled band switch.
    process_gpio_mask : process(fsm_clk_in)
    begin  
        if rising_edge(fsm_clk_in) then
            if(fsm_rstn_in = '0')then
                gpio_test_in_dly    <= '0';
                gpio_actual_request <= '0';
                ub_gpio_pend        <= '0';
                fsm_gpio_pend       <= '0';
                fsm_gpio_reapply    <= '0';
            else
                gpio_test_in_dly <= gpio_test_in;
                gpio_actual_request <= '0';
                -- issue one pending request when gpio_fsm is idle and nothing is in flight
                if (gpio_busy = '0') and (gpio_actual_request = '0') then
                    if fsm_gpio_pend = '1' then
                        gpio_actual_mask    <= fsm_gpio_pend_mask;
                        gpio_actual_request <= '1';
                        fsm_gpio_pend       <= '0';
                        fsm_gpio_reapply    <= '0';
                    elsif ub_gpio_pend = '1' then
                        gpio_actual_mask    <= ub_gpio_pend_mask;
                        gpio_actual_request <= '1';
                        ub_gpio_pend        <= '0';
                        fsm_gpio_reapply    <= '1';
                    end if;
                end if;
                -- latch new requests (after the issue block so a request arriving in the
                -- same cycle as an issue is kept for the next round)
                -- 19/10/2026 (D3): khoi phuc latch pend cua T7 9/9/2026. Ban cu ghi thang
                -- gpio_actual_request o day, nhanh else ghi de khoi phat o tren (phep gan
                -- cuoi thang) nen ub_gpio_pend/fsm_gpio_pend khong bao gio len: mat P1-P3.
                if gpio_test_in = '1' and gpio_test_in_dly = '0' then
                    ub_gpio_pend      <= '1';
                    ub_gpio_pend_mask <= gpio_mask_ub_in;
                end if;
                if gpio_request = '1' then
                    fsm_gpio_pend      <= '1';
                    fsm_gpio_pend_mask <= gpio_mask;
                end if;
            end if;
         end if;
    end process;




--    ILA_GPIO_INS: ENTITY work.ila_4
--    PORT MAP (
--        clk => fsm_clk_in,
--        probe0(0) => cfg_reload_in,
--        probe1(0) => valid_pipeline,
--        probe2 => gpio_out,
--        probe3 => gpio_actual_mask,
--        probe4(0) => gpio_actual_request,
        
        
--        probe5 => CFG_LUT_addr ,
--        probe6 => CFG_LUT_din,
--        probe7(0) => CFG_LUT_en ,
--        probe8(0) => CFG_LUT_rst ,
--        probe9 => CFG_LUT_we,
--        probe10 => bram_debug,
--        probe11 => std_logic_vector(reg_write_counter),
--        probe12 => std_logic_vector(bram_read_counter) 
        
--    );

--    ILA_CMD: ENTITY work.ila_1
--    PORT MAP(
--        clk    => fsm_clk_in,
--        probe0 => command1_in,
--        probe1 => command2_in,
--        probe2 => command3_in,
--        probe3 => command4_in,
--        probe4 => command5_in
--    );

    i_gpio_fsm : entity work.gpio_fsm
    generic map(GPIO_NUM => N_GPIO)
    port map(
        clk_in          => fsm_clk_in,
        rstn_in         => fsm_rstn_in,
        gpio_request_in => gpio_actual_request,
        gpio_mask       => gpio_actual_mask,
        gpio_profile_in => gpio_profile,
        gpio_busy_out   => gpio_busy,
        gpio_out        => gpio_out
    );

    -- ADDED: map tx_ctrl status buses to output
    tx_card_status_out(31 downto 18) <= (others => '0');
    tx_card_status_out(17 downto 0) <=   tx_bite_rx_ld &
										 tx_lb_pa_current_alr &
										 tx_lb_drv_current_alr &
										 tx_hb_pa_current_alr &
										 tx_hb_drv_current_alr &
										 tx_hb_pre_current_alr &
										 tx_lb_fwd_power_alr &
										 tx_lb_rwd_power_alr &
										 tx_hb_fwd_power_alr &
										 tx_hb_rwd_power_alr &
										 tx_cpld_rev;

    -- BRAM Configuration Loading FSM
    process(fsm_clk_in)
    begin
        if rising_edge(fsm_clk_in) then
            if fsm_rstn_in = '0' then
                bram_state <= BRAM_IDLE;
                bram_read_counter <= (others => '0');
                reg_write_counter <= (others => '0');
                CFG_LUT_en <= '0';
                CFG_LUT_addr <= (others => '0');
                valid_pipeline <= '0';
                loading_done <= '0';
                bram_debug <= "00";
                valid_pipeline_dly <= '0';
            else
                valid_pipeline_dly <= valid_pipeline;
                case bram_state is
                    when BRAM_IDLE =>
                        bram_debug <= "00";
                        loading_done <= '0';
                        bram_read_counter <= (others => '0');
                        reg_write_counter <= (others => '0');
                        valid_pipeline <= '0';                
                        if cfg_reload_in = '1' then
                            bram_state <= BRAM_READING;
                            CFG_LUT_en <= '1';
                        else
                            CFG_LUT_en <= '0';
                        end if;
                    when BRAM_READING =>
                        bram_debug <= "01";
                        if bram_read_counter < BRAM_LUT_SIZE * 4 then
                            CFG_LUT_addr(bram_read_counter'length - 1 downto 0) <= std_logic_vector(bram_read_counter);
                            bram_read_counter <= bram_read_counter + 4;
                            valid_pipeline <= '1';
                        else
                            CFG_LUT_en <= '0'; 
                            --valid_pipeline <= '0';
                        end if;
                        if (valid_pipeline_dly = '1' ) then
                            reg_write_counter <= reg_write_counter + 1;
                            if (to_integer(reg_write_counter) < N_GPIO) then
                                gpio_profile(to_integer(reg_write_counter)) <= CFG_LUT_din;
                            elsif(to_integer(reg_write_counter) = N_GPIO ) then
                                pll_setup_time <= CFG_LUT_din (pll_setup_time'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 1) then
                                pll_switching_time <= CFG_LUT_din (pll_switching_time'length - 1 downto 0);   
        
                            elsif(to_integer(reg_write_counter) = N_GPIO + 2) then
                                txhb_txhb_early_value <= CFG_LUT_din (txhb_txhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 3) then
                                txlb_txhb_early_value <= CFG_LUT_din (txlb_txhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 4) then
                                rxlb_txhb_early_value <= CFG_LUT_din (rxlb_txhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 5) then
                                rxhb_txhb_early_value <= CFG_LUT_din (rxhb_txhb_early_value'length - 1 downto 0);
        
                            elsif(to_integer(reg_write_counter) = N_GPIO + 6) then
                                txhb_txlb_early_value <= CFG_LUT_din (txhb_txlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 7) then
                                txlb_txlb_early_value <= CFG_LUT_din (txlb_txlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 8) then
                                rxlb_txlb_early_value <= CFG_LUT_din (rxlb_txlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 9) then
                                rxhb_txlb_early_value <= CFG_LUT_din (rxhb_txlb_early_value'length - 1 downto 0);
        
                            elsif(to_integer(reg_write_counter) = N_GPIO + 10) then
                                txhb_rxhb_early_value <= CFG_LUT_din (txhb_rxhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 11) then
                                txlb_rxhb_early_value <= CFG_LUT_din (txlb_rxhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 12) then
                                rxhb_rxhb_early_value <= CFG_LUT_din (rxhb_rxhb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 13) then
                                rxlb_rxhb_early_value <= CFG_LUT_din (rxlb_rxhb_early_value'length - 1 downto 0);
        
                            elsif(to_integer(reg_write_counter) = N_GPIO + 14) then
                                txhb_rxlb_early_value <= CFG_LUT_din (txhb_rxlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 15) then
                                txlb_rxlb_early_value <= CFG_LUT_din (txlb_rxlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 16) then
                                rxhb_rxlb_early_value <= CFG_LUT_din (rxhb_rxlb_early_value'length - 1 downto 0);
                            elsif(to_integer(reg_write_counter) = N_GPIO + 17) then
                                rxlb_rxlb_early_value <= CFG_LUT_din (rxlb_rxlb_early_value'length - 1 downto 0);
                                bram_state <= BRAM_FINISH;
                            end if;
--                            if reg_write_counter = BRAM_LUT_SIZE then
--                                bram_state <= BRAM_FINISH;
--                            end if;
                       end if;
                    when BRAM_FINISH =>
                        bram_debug <= "10";
                        loading_done <= '1';
                        CFG_LUT_en <= '0';
                        valid_pipeline <= '0';
                        if cfg_reload_in = '0' then
                            bram_state <= BRAM_IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;



    -- latch configuration 
    hop_latch_proc: process(fsm_clk_in)
    begin
        if rising_edge(fsm_clk_in) then
            if fsm_rstn_in = '0' then
                hop_tx_freq <= (others => '0');
                hop_rx_freq <= (others => '0');
                hop_trx     <= '0';
                hop_tx_bw   <= (others => '0');
                hop_rx_bw   <= (others => '0');
                hop_ntx     <= (others => '0');
                hop_nrx     <= (others => '0');
            elsif (current_state = IDLE) and (running_config_valid_in = '1') then
                hop_tx_freq <= Tx_freq_in;
                hop_rx_freq <= Rx_freq_in;
                hop_trx     <= trx_config_in;
                hop_tx_bw   <= Tx_bw_in;
                hop_rx_bw   <= Rx_bw_in;
                hop_ntx     <= Next_Frame_Transmit_Time_in;
                hop_nrx     <= Next_Frame_Receive_Time_in;
            end if;
        end if;
    end process;


    main_fsm_proc: process(fsm_clk_in)
    begin
    if rising_edge(fsm_clk_in) then
        if fsm_rstn_in = '0' then
            current_state <= IDLE;
            ad9164_start_config <= '0';
        else
            ad9164_start_config <= '0'; -- default: 1-cycle pulse, asserted only on entry to DDS_CONFIG
            case(current_state) is
                when IDLE =>
                    ad9164_off_nco <= '0';
                    if(running_config_valid_in = '1')then
                        if (trx_config_in = '1') and (Tx_freq_in > FREQ_600) and (Tx_freq_in <= FREQ_1200) then ---600MHZ < Tx_freq <= 1.2GHz
                            current_state <= CAL_TRIGGER_TIME;
                        else
                            current_state <= PLL_CONFIG;
                        end if;
                        if(trx_config_in = '1') then ------TX frame
                            case rf_state is
                                when TX_HB =>
                                    if (Tx_freq_in >= FREQ_600)then ---600MHZ < Tx_freq 
                                        tx_switch_delay <= txhb_txhb_early_value;
                                    else
                                        tx_switch_delay <= txhb_txlb_early_value;
                                    end if;
                                when TX_LB =>
                                    if (Tx_freq_in >= FREQ_600)then ---600MHZ < Tx_freq 
                                        tx_switch_delay <= txlb_txhb_early_value;
                                    else
                                        tx_switch_delay <= txlb_txlb_early_value;
                                    end if;
                                when RX_HB =>
                                    if (Rx_freq_in >= FREQ_600)then ---600MHZ < Rx_freq 
                                        tx_switch_delay <= rxhb_txhb_early_value;
                                    else
                                        tx_switch_delay <= rxhb_txlb_early_value;
                                    end if;
                                when RX_LB =>
                                    if (Rx_freq_in >= FREQ_600)then ---600MHZ < Rx_freq 
                                        tx_switch_delay <= rxlb_txhb_early_value;
                                    else
                                        tx_switch_delay <= rxlb_txlb_early_value;
                                    end if;
                                when others =>
                                    tx_switch_delay <= (others => '0');
                            end case;
                        else
                            case rf_state is
                                when TX_HB =>
                                    if (Tx_freq_in >= FREQ_600)then ---600MHZ < Tx_freq 
                                        rx_switch_delay <= txhb_rxhb_early_value;
                                    else
                                        rx_switch_delay <= txhb_rxlb_early_value;
                                    end if;
                                when TX_LB =>
                                    if (Tx_freq_in >= FREQ_600)then ---600MHZ < Tx_freq 
                                        rx_switch_delay <= txlb_rxhb_early_value;
                                    else
                                        rx_switch_delay <= txlb_rxlb_early_value;
                                    end if;
                                when RX_HB =>
                                    if (Rx_freq_in >= FREQ_600)then ---600MHZ < Rx_freq 
                                        rx_switch_delay <= rxhb_rxhb_early_value;
                                    else
                                        rx_switch_delay <= rxhb_rxlb_early_value;
                                    end if;
                                when RX_LB =>
                                    if (Rx_freq_in >= FREQ_600)then ---600MHZ < Rx_freq 
                                        rx_switch_delay <= rxlb_rxhb_early_value;
                                    else
                                        rx_switch_delay <= rxlb_rxlb_early_value;
                                    end if;
                                when others =>
                                    rx_switch_delay <= (others => '0');
                           end case;
                        end if; ------RX frame
                    end if;
                when PLL_CONFIG => 
                    if(pll_state = PLL_WAIT) then
                        current_state <= CAL_TRIGGER_TIME;
                    end if;
                when DDS_CONFIG => 
                    if(dds_config_done = '1') then
                        current_state <= IDLE;
                    end if;
                when CAL_TRIGGER_TIME => 
                     -----update the PLL Switching time
                        if(hop_trx = '1') then ------TX frame
                        if(hop_ntx >= pll_switching_time)then
                            next_pll_switch_time <= hop_ntx - pll_switching_time;
                        else
                            next_pll_switch_time <= hop_ntx + ONE_SECOND_TICKS - pll_switching_time;
                        end if;
                    else
                        if(hop_nrx >= pll_switching_time)then
                            next_pll_switch_time <= hop_nrx - pll_switching_time;
                        else
                            next_pll_switch_time <= hop_nrx + ONE_SECOND_TICKS - pll_switching_time;
                        end if;
                    end if;
                -----update the GPIO Switching time
                    if(hop_trx = '1') then ------TX frame
                        if(hop_ntx >= tx_switch_delay)then
                            next_gpio_switch_time <= hop_ntx - tx_switch_delay;
                        else
                            next_gpio_switch_time <= hop_ntx + ONE_SECOND_TICKS - tx_switch_delay;
                        end if;
                    else
                        if(hop_nrx >= rx_switch_delay)then
                            next_gpio_switch_time <= hop_nrx - rx_switch_delay;
                        else
                            next_gpio_switch_time <= hop_nrx + ONE_SECOND_TICKS- rx_switch_delay;
                        end if;
                    end if;
                    current_state <= WAIT_TRIGGER;
                when WAIT_TRIGGER =>
                    if(hop_trx = '1') then ------TX frame
                        if(Current_Subsecond_in >= next_gpio_switch_time)then
                            current_state <= TX_SW_GPIO_CONFIG;
                        end if;
                    else
                        if(Current_Subsecond_in >= next_gpio_switch_time)then
                            current_state <= RX_SW_GPIO_CONFIG;
                        end if;
                    end if;
                when TX_SW_GPIO_CONFIG =>
                    if(Current_Subsecond_in >= next_pll_switch_time )then
                        if (hop_tx_freq > FREQ_600) and (hop_tx_freq <= FREQ_1200) then ---600MHZ < Tx_freq <= 1.2GHz : use AD9164 DAC NCO
                            current_state <= DDS_CONFIG;
                            ad9164_start_config <= '1'; -- kick off NCO FTW computation/SPI write
                        else
                            current_state <= PLL_PINGPONG;
                        end if;
                    end if;
                when RX_SW_GPIO_CONFIG =>
                    if(Current_Subsecond_in >= next_pll_switch_time)then
                        if (hop_rx_freq > FREQ_600) and (hop_rx_freq <= FREQ_1200) then ---600MHZ < Rx_freq <= 1.2GHz : use AD9164 DAC NCO
                            current_state <= DDS_CONFIG;
                            ad9164_start_config <= '1'; -- kick off NCO FTW computation/SPI write
                        else
                            current_state <= PLL_PINGPONG;
                        end if;
                    end if;
                when PLL_PINGPONG =>
                    ad9164_off_nco <= '1';
                    -- 2026-08-03: added "or dds_config_done" (user fix, ported from the
                    -- t7_fpga_v.0.51 tree). Waiting ONLY on pll_state=PLL_IDLE deadlocked
                    -- here: HW showed current_state=PLL_PINGPONG 100% of 25600 samples and
                    -- pll_state stuck at PLL_WAIT, so after the first 600 MHz segment the
                    -- FSM never returned to IDLE, never consumed another running_config_valid
                    -- (start_config 0/25600) and left off_nco='1' re-writing the AD9164 NCO
                    -- burst forever. off_nco makes ad9164_nco_config run its register
                    -- sequence and pulse done, so dds_config_done gives a bounded exit.
                    if(pll_state = PLL_IDLE) or (dds_config_done = '1') then
                        current_state <= IDLE;
                    end if;
                when others =>
                    current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    rf_state_proc: process(fsm_clk_in)
    begin
        if fsm_rstn_in = '0' then
            rf_state <= RF_IDLE;
        else
            if (current_state = PLL_PINGPONG) then
                if(hop_trx = '1') then
                    if (hop_tx_freq > FREQ_600)then ---600MHZ < Tx_freq 
                        rf_state <= TX_HB;
                    else
                        rf_state <= TX_LB;
                    end if;
                else
                    if (hop_rx_freq > FREQ_600)then ---600MHZ < Rx_freq 
                        rf_state <= RX_HB;
                    else
                        rf_state <= RX_LB;
                    end if;
                end if;
            end if;
        end if;
    end process;
    in_sw_gpio_cfg <= '1' when (current_state = TX_SW_GPIO_CONFIG) or (current_state = RX_SW_GPIO_CONFIG) else '0';
    gpio_fsm_proc: process(fsm_clk_in)
    begin  
        if rising_edge(fsm_clk_in) then
            if fsm_rstn_in = '0' then
                gpio_request <= '0';
                gpio_mask <= (others => '0');
                current_gpio_mask <= (others => '0');
                in_sw_gpio_cfg_d1 <= '0';
                in_sw_gpio_cfg_d2 <= '0';
            else
                in_sw_gpio_cfg_d1 <= in_sw_gpio_cfg;
                in_sw_gpio_cfg_d2 <= in_sw_gpio_cfg_d1;
                case current_state is
                  when TX_SW_GPIO_CONFIG =>
                    -- TX bands per "Global Setting" (NBWF/WBWF by bandwidth)
                    if (hop_tx_freq < FREQ_160) then ---30-160 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_30_160; else gpio_mask <= GPIO_TX_NBWF_MASK_30_160; end if;
                    elsif (hop_tx_freq < FREQ_350) then ---160-350 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_160_350; else gpio_mask <= GPIO_TX_NBWF_MASK_160_350; end if;
                    elsif (hop_tx_freq < FREQ_520) then ---350-520 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_350_520; else gpio_mask <= GPIO_TX_NBWF_MASK_350_520; end if;
                    elsif (hop_tx_freq < FREQ_600) then ---520-600 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_520_600; else gpio_mask <= GPIO_TX_NBWF_MASK_520_600; end if;
                    elsif (hop_tx_freq < FREQ_901) then ---600-901 MHz (DAC-direct)
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_600_901; else gpio_mask <= GPIO_TX_NBWF_MASK_600_901; end if;
                    elsif (hop_tx_freq < FREQ_1223) then ---901-1223 MHz (DAC-direct)
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_901_1223; else gpio_mask <= GPIO_TX_NBWF_MASK_901_1223; end if;
                    elsif (hop_tx_freq < FREQ_1250) then ---1223-1250 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_1223_1250; else gpio_mask <= GPIO_TX_NBWF_MASK_1223_1250; end if;
                    elsif (hop_tx_freq < FREQ_1610) then ---1250-1610 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_1250_1610; else gpio_mask <= GPIO_TX_NBWF_MASK_1250_1610; end if;
                    elsif (hop_tx_freq < FREQ_2020) then ---1610-2020 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_1610_2020; else gpio_mask <= GPIO_TX_NBWF_MASK_1610_2020; end if;
                    elsif (hop_tx_freq < FREQ_2560) then ---2020-2560 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_2020_2560; else gpio_mask <= GPIO_TX_NBWF_MASK_2020_2560; end if;
                    elsif (hop_tx_freq < FREQ_2700) then ---2560-2700 MHz
                      if wideband_tx = '1' then gpio_mask <= GPIO_TX_WBWF_MASK_2560_2700; else gpio_mask <= GPIO_TX_NBWF_MASK_2560_2700; end if;
                    end if;
                  when RX_SW_GPIO_CONFIG =>
                    -- RX bands per Rev_33 "Global Setting" (NBWF/WBWF by bandwidth)
                    if (hop_rx_freq < FREQ_160) then ---30-160 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_30_160; else gpio_mask <= GPIO_RX_NBWF_MASK_30_160; end if;
                    elsif (hop_rx_freq < FREQ_350) then ---160-350 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_160_350; else gpio_mask <= GPIO_RX_NBWF_MASK_160_350; end if;
                    elsif (hop_rx_freq < FREQ_520) then ---350-520 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_350_520; else gpio_mask <= GPIO_RX_NBWF_MASK_350_520; end if;
                    elsif (hop_rx_freq < FREQ_755) then ---520-755 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_520_755; else gpio_mask <= GPIO_RX_NBWF_MASK_520_755; end if;
                    elsif (hop_rx_freq < FREQ_901) then ---755-901 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_755_901; else gpio_mask <= GPIO_RX_NBWF_MASK_755_901; end if;
                    elsif (hop_rx_freq < FREQ_1000) then ---901-1000 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_901_1000; else gpio_mask <= GPIO_RX_NBWF_MASK_901_1000; end if;
                    elsif (hop_rx_freq < FREQ_1223) then ---1000-1223 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_1000_1223; else gpio_mask <= GPIO_RX_NBWF_MASK_1000_1223; end if;
                    elsif (hop_rx_freq < FREQ_1250) then ---1223-1250 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_1223_1250; else gpio_mask <= GPIO_RX_NBWF_MASK_1223_1250; end if;
                    elsif (hop_rx_freq < FREQ_1610) then ---1250-1610 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_1250_1610; else gpio_mask <= GPIO_RX_NBWF_MASK_1250_1610; end if;
                    elsif (hop_rx_freq < FREQ_2020) then ---1610-2020 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_1610_2020; else gpio_mask <= GPIO_RX_NBWF_MASK_1610_2020; end if;
                    elsif (hop_rx_freq < FREQ_2600) then ---2020-2600 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_2020_2600; else gpio_mask <= GPIO_RX_NBWF_MASK_2020_2600; end if;
                    elsif (hop_rx_freq < FREQ_2700) then ---2600-2700 MHz
                      if wideband_rx = '1' then gpio_mask <= GPIO_RX_WBWF_MASK_2600_2700; else gpio_mask <= GPIO_RX_NBWF_MASK_2600_2700; end if;
                    end if;
                  when others =>
                    gpio_request <= '0';
                    -- 9/9/2026 (P4): do NOT write gpio_mask <= current_gpio_mask here. Together
                    -- with the compare below it swapped the two registers every cycle when
                    -- *_SW_GPIO_CONFIG lasted a single cycle (tx_switch_delay <= pll_switching_time):
                    -- gpio_request stuck at '1' and the issued mask alternated BAND/0 forever.
                    -- gpio_mask simply holds its value outside the *_SW_GPIO_CONFIG states.
                end case;
                --Generate gpio_request only if there is a change in gpio_mask, or once per
                --*_SW_GPIO_CONFIG entry when the uB overrode the GPIOs since our last request
                --(2nd cycle in the state: gpio_mask already holds the band mask)
                if(current_gpio_mask /= gpio_mask) then
                  gpio_request <= '1';
                  current_gpio_mask <= gpio_mask;
                elsif (fsm_gpio_reapply = '1') and (in_sw_gpio_cfg_d1 = '1') and (in_sw_gpio_cfg_d2 = '0') then
                  gpio_request <= '1';
                else
                  gpio_request <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- pll_fsm_proc (setup_trigger / pll_transition_trigger) bo 19/10/2026: hop_exec_proc thay the.
	
	process(fsm_clk_in)
    	begin
			if rising_edge(fsm_clk_in) then
				man_freq_mem <= man_freq;
				provv_bw_mem <= provv_bw;
				
				if ((man_freq_mem /= man_freq) or (provv_bw_mem /= provv_bw)) then -- this code because freq_in and bw don't arrive at the same time Claudio 030726
					set_cnt <= 0;
				else
					if (set_cnt /= 100000) then  -- this because RFU Serial Switch Controller does'n send simultaneously frequency and bandwidth
						set_cnt <= set_cnt + 1;
					end if;
				end if;
				
				if (set_cnt = 99999) then
					Set_freq <= '1';
				else
					Set_freq <= '0';
				end if;
				
				if (man_freq_mem /= man_freq) then
					set_TBPF_freq <= '1';
				else
					set_TBPF_freq <= '0';
				end if;
			end if;
		end process;
	
	provv_bw <= "00000" & IF_FB_SW_2 & if_fb_sw_1 & if_fb_sw_0;
	
    PLL_Driver_inst : entity work.PLL_Driver
		Port map   (clk				=> fsm_clk_in,
					adc_clk_in		=> adc_clk_in,
					Freq_in         => drv_freq,     -- 19/10/2026: mux uB / hop (xem hop_exec_proc)
					TX_RXn          => drv_txrxn,
					Tx_bw          	=> drv_bw,
					Rx_bw          	=> drv_bw,
					Set          	=> drv_set,
					PP          	=> drv_pp,
					dds_dav_a       => dds_a_calc_dav,
					dds_dav_b       => dds_b_calc_dav,
					dds          	=> dds_calc,
					DAC_freq		=> DAC_freq,
					Set_DAC_freq	=> Set_DAC_freq,
					INT_A			=> INT_A,
					INT_B			=> INT_B,
					rx_dds_config_tvalid => rx_dds_config_tvalid,
					rx_dds_config_tdata  => rx_dds_config_tdata);

 	ADF41510_Driver_a : entity work.ADF41510_Driver
		Port map   (fsm_clk				=> fsm_clk_in,
					pll_le				=> pll_a_adf41510_csn,
					pll_data			=> pll_a_adf41510_mosi,
					pll_clk				=> pll_a_adf41510_clk,
					enable				=> enable_fsm,
					INT_in				=> INT_A);   

	ADF41510_Driver_b : entity work.ADF41510_Driver
		Port map   (fsm_clk				=> fsm_clk_in,
					pll_le				=> pll_b_adf41510_csn,
					pll_data			=> pll_b_adf41510_mosi,
					pll_clk				=> pll_b_adf41510_clk,
					enable				=> enable_fsm,
					INT_in				=> INT_B);
    
	AD9914_Driver_inst : entity work.AD9914_Driver
		generic map(Delay_cnt => 7500000)
		Port map   (dds_a_sync_clk		=> dds_a_sync_clk,
					dds_b_sync_clk		=> dds_b_sync_clk,
					fsm_clk           	=> fsm_clk_in,
					dds_data          	=> dds_data,
					dds_a_syncio      	=> dds_a_syncio,
					dds_b_syncio     	=> dds_b_syncio,
					dds_sdo           	=> dds_sdo,
					dds_sdio          	=> dds_sdio,
					dds_scl           	=> dds_scl,
					dds_a_0_csn       	=> dds_a_0_csn,
					dds_b_0_csn       	=> dds_b_0_csn,
					dds_in          	=> dds_calc,
          			dds_dav_a        	=> dds_a_calc_dav,
          			dds_dav_b        	=> dds_b_calc_dav,
					reset             	=> reset(0),
					dds_a_ioupdate    	=> dds_a_ioupdate,
					dds_b_ioupdate    	=> dds_b_ioupdate,
					DDS_MASTER_RESET	=> DDS_MASTER_RESET);

    MAAD_011045_Driver_inst : entity work.MAAD_011045_Driver
		Port map   (clk					=> fsm_clk_in,
					enable				=> enable_fsm,
					att_sin          	=> tx_att_sin,
					att_clk          	=> tx_att_clk,
					att_le          	=> tx_att_le,
					att_val				=> U468_att_val);

	U148_MAAD_011045_Driver_inst : entity work.MAAD_011045_Driver
		Port map   (clk					=> fsm_clk_in,
					enable	     		=> enable_fsm,
					att_sin          	=> if_fb_si,
					att_clk          	=> if_fb_clk,
					att_le          	=> if_fb_le,
					att_val				=> U148_att_val);
					
	U473_MAAD_011045_Driver_inst : entity work.MAAD_011045_Driver
		Port map   (clk					=> fsm_clk_in,
					enable	     		=> enable_fsm,
					att_sin          	=> rtx_att_sin,
					att_clk          	=> rtx_att_clk,
					att_le          	=> rtx_att_le,
					att_val				=> U473_att_val);

	lb_rx_tbpf_1_tune_rdy <= lb_rx_tbpf_1_tune_rdy_a or lb_rx_tbpf_1_tune_rdy_b;
	
	lb_rx_tbpf_2_tune_rdy <= lb_rx_tbpf_2_tune_rdy_a or lb_rx_tbpf_2_tune_rdy_b;
				
	RX_LB_TBPF_inst : entity work.LB_TBPF_NetCom_5670_x_D_Driver
		Port map   (fsm_clk				=> fsm_clk_in,
					enable         		=> enable_fsm,
					freq_in          	=> man_freq,
					Set          		=> set_TBPF_freq,
					tune_rdy_1         	=> lb_rx_tbpf_1_tune_rdy,
					tune_rdy_2         	=> lb_rx_tbpf_2_tune_rdy,
					PP          		=> PP_An_B,
					error          		=> open,
					sclk          		=> lb_rx_tbpf_sclk,
					csn1          		=> lb_rx_tbpf1_csn,
					csn2          		=> lb_rx_tbpf2_csn,
					mosi				=> lb_rx_tbpf_mosi);							 
 
 	TX_LB_TBPF_inst : entity work.LB_TBPF_NetCom_5670_x_D_Driver
		Port map   (fsm_clk				=> fsm_clk_in,
					enable         		=> enable_fsm,
					freq_in          	=> man_freq,
					Set          		=> set_TBPF_freq,
					tune_rdy_1         	=> lb_tx_tbpf_1_tune_rdy,
					tune_rdy_2         	=> lb_tx_tbpf_2_tune_rdy,
					PP          		=> PP_An_B,
					error          		=> open,
					sclk          		=> lb_tx_tbpf_sclk,
					csn1          		=> lb_tx_tbpf1_csn,
					csn2          		=> lb_tx_tbpf2_csn,
					mosi				=> lb_tx_tbpf_mosi);
					
	TX_HB_TBPF_inst : entity work.ADMV8xxx_Driver
		Port map   (fsm_clk				=> fsm_clk_in,
					enable				=> enable_fsm,
    	   			freq_in          	=> man_freq,
    	   			Set          		=> set_TBPF_freq,
					PP          		=> PP_An_B,
					hb_tbpf_sdi        	=> hb_tbpf_sdi,
					hb_tbpf_sdo        	=> hb_tbpf_sdo,
					hb_tbpf_sclk       	=> hb_tbpf_sclk,
					hb_1_tbpf_csn      	=> hb_1_tbpf_csn,
					hb_2_tbpf_csn      	=> hb_2_tbpf_csn,
					hb_3_tbpf_csn      	=> hb_3_tbpf_csn,
					hb_4_tbpf_csn      	=> hb_4_tbpf_csn);

 	AD_9164_Driver_inst : entity work.AD_9164_Driver
		Port map   (clk					=> fsm_clk_in,
					Set_DAC_freq		=> dac_drv_set,   -- 19/10/2026: mux uB / hop
					enable				=> enable_fsm,
					freq_in          	=> dac_drv_freq,
					busy				=> ad9164_busy,
					sclk          		=> ad9164_sclk,
					csn          		=> ad9164_csn,
					mosi				=> ad9164_mosi);	

dac_txenable <= TX_RXn;
															 
process(fsm_clk_in)
    	begin
    		if rising_edge(fsm_clk_in) then
    		    -- next_frequency(47 downto 16 + 0x17B	
--				dds_a_in 			<= command1_in;
--				dds_b_in 			<= command2_in;
				U468_att_val 		<= command4_in(5 downto 0);
				U148_att_val 		<= command4_in(11 downto 6);
				
				if (U468_att_val = "111111") then
					TX_RXn <= '0';
				else
					TX_RXn <= '1';
				end if;

				U473_att_val 		<= command4_in(17 downto 12);
				
--				INT_A				<= command4_in(24 downto 18);
--				INT_B				<= command4_in(31 downto 25);	
				
--				if (freq_cnt = 100000) then
--					freq_cnt <= 0;
--					if (command5_in(31 downto  0) = x"00000000") then
--						if (conv_integer(man_freq) > (1170*10**6)) then
--							man_freq	<= conv_std_logic_vector(601*10**6, 32);
--						else
--							man_freq	<= man_freq + conv_std_logic_vector(10*10**6, 32);
--						end if;
--					else
						man_freq 		<= command5_in(31 downto  0);
--					end if;
--				else
--					freq_cnt <= freq_cnt + 1;
--				end if;
				
--				if (Tx_freq_in(31 downto  0) = x"00000000") then
--					man_freq 			<= command5_in(31 downto  0);
--				else
--					man_freq 			<= Tx_freq_in(31 downto  0);
--				end if;
				
			--	PLL_A_NB          	<= gpio_out(14);
			--	PLL_B_NB          	<= gpio_out(12);
    		
											   
    		    
    			if (dds_a_calc_dav = '1') then
    				cycle_cnt_A <= 0;
    			end if;
    
				if  (cycle_cnt_A = 400) then
					PLL_A_NB		<= '1';
				else
					PLL_A_NB		<= '0';
					cycle_cnt_A 	<= cycle_cnt_A + 1;
				end if;

    			if (dds_b_calc_dav = '1') then
    				cycle_cnt_B <= 0;
    			end if;
    
				if  (cycle_cnt_B = 400) then
					PLL_B_NB		<= '1';
				else
					PLL_B_NB		<= '0';
					cycle_cnt_B 	<= cycle_cnt_B + 1;
				end if;
				
				if (enable_fsm = '0') then
					reset(0) 	  <= '1';
					reset_cnt <= 100000;
				elsif (reset_cnt > 15) then
					reset_cnt <= reset_cnt - 1;
					reset(0) 	   <= '0';
				elsif (reset_cnt = 0) then
					reset(0) 	  <= '0';
				else
					reset_cnt <= reset_cnt - 1;
					reset(0) 	  <= '1';
				end if;			
    		end if;			
    	end process;
    	
	vcxo_cp 		<= enable_fsm;
	pingpong_An_b   <= PP_An_B;
    gpio_outs 		<= gpio_out;
					 

    ---------------------------------------------------------------------------
    -- ILA DEBUG MAY TRANG THAI CHINH (ila_fsm_dbg) -- chuyen tu t7_fpga_v0.5
    --
    -- Tat ca trong MOT core, va STORAGE QUALIFIER chay theo `state_change` nen
    -- moi mau luu lai la MOT lan chuyen trang thai -> depth 1024 = 1024 lan
    -- chuyen (~25 vong hop) thay vi 1024 chu ky clock.
    --
    -- Cach doc: probe1/probe2 cho biet lan chuyen gan nhat di TU dau DEN dau,
    -- probe6 cho biet dieu kien nao dang dung tai dung chu ky FSM quyet dinh.
    -- Bang ma trang thai va nhan probe: scripts/hw_fsm_debug.tcl
    ---------------------------------------------------------------------------
    fsm_state_code <= FSM_CODE(current_state);

    ---------------------------------------------------------------------------
    -- state_change
    -- state_d = current_state tre 1 chu ky. Khi chung khac nhau thi vua co mot
    -- lan chuyen trang thai: bat state_change 1 chu ky va CHOT nguon/dich, nen
    -- from_state/to_state GIU NGUYEN toi lan chuyen ke tiep (doc duoc ca luc
    -- dang dung yen, khong chi tai canh).
    ---------------------------------------------------------------------------
    state_change_proc : process (fsm_clk_in)
    begin
        if rising_edge(fsm_clk_in) then
            if fsm_rstn_in = '0' then
                state_d            <= IDLE;
                from_state         <= IDLE;
                to_state           <= IDLE;
                state_change       <= '0';
                state_change_cnt   <= (others => '0');
                fsm_cond_d1        <= (others => '0');
                fsm_cond_d2        <= (others => '0');
                fsm_cond_at_change <= (others => '0');
            else
                state_d     <= current_state;
                fsm_cond_d1 <= fsm_cond;
                fsm_cond_d2 <= fsm_cond_d1;
                if current_state /= state_d then
                    state_change     <= '1';
                    from_state       <= state_d;
                    to_state         <= current_state;
                    state_change_cnt <= state_change_cnt + 1;
                    -- FSM quyet dinh o chu ky n-1, current_state doi o n, so sanh nay
                    -- thay o n+1. fsm_cond_d1 tai n+1 = fsm_cond(n-1) = dung chu ky
                    -- quyet dinh. Dung fsm_cond_d2 se lech 1 chu ky, moi dieu kien
                    -- dang xung 1 nhip (dds_config_done, running_config_valid) deu vo hinh.
                    fsm_cond_at_change <= fsm_cond_d1;
                else
                    state_change <= '0';
                end if;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- fsm_cond: DUNG cac dieu kien ma main_fsm_proc dung de chuyen trang thai,
    -- viet lai nguyen van de doc ILA la biet ngay nhanh nao dang mo/dong.
    ---------------------------------------------------------------------------
    fsm_cond(0)  <= running_config_valid_in;                                    -- IDLE: co config moi
    fsm_cond(1)  <= trx_config_in;                                              -- 1 = TX frame, 0 = RX frame
    fsm_cond(2)  <= '1' when Tx_freq_in <  FREQ_600  else '0';
    fsm_cond(3)  <= '1' when Tx_freq_in > FREQ_1200 else '0';
    fsm_cond(4)  <= '1' when (Tx_freq_in >= FREQ_600) and (Tx_freq_in <= FREQ_1200) else '0';  -- TX -> duong NCO
    fsm_cond(5)  <= '1' when Rx_freq_in <  FREQ_600  else '0';
    fsm_cond(6)  <= '1' when Rx_freq_in > FREQ_1200 else '0';
    fsm_cond(7)  <= '1' when (Rx_freq_in >= FREQ_600) and (Rx_freq_in <= FREQ_1200) else '0';  -- RX -> duong NCO
    fsm_cond(8)  <= '1' when pll_state = PLL_WAIT else '0';                     -- PLL_CONFIG -> CAL_TRIGGER_TIME
    fsm_cond(9)  <= '1' when pll_state = PLL_IDLE else '0';                     -- PLL_PINGPONG -> IDLE
    fsm_cond(10) <= dds_config_done;                                            -- DDS_CONFIG -> IDLE / thoat PINGPONG
    fsm_cond(11) <= '1' when Current_Subsecond_in >= next_gpio_switch_time else '0'; -- WAIT_TRIGGER -> *_SW_GPIO_CONFIG
    fsm_cond(12) <= '1' when Current_Subsecond_in >= next_pll_switch_time  else '0'; -- *_SW_GPIO_CONFIG -> DDS/PINGPONG
    fsm_cond(13) <= ad9164_start_config;
    fsm_cond(14) <= ad9164_off_nco;
    fsm_cond(15) <= enable_fsm;
    fsm_cond(16) <= fsm_rstn_in;
    fsm_cond(17) <= loading_done;
    fsm_cond(18) <= gpio_request;
    fsm_cond(19) <= gpio_actual_request;
    fsm_cond(20) <= gpio_busy;
    fsm_cond(21) <= ub_gpio_pend;
    fsm_cond(22) <= fsm_gpio_pend;
    fsm_cond(23) <= fsm_gpio_reapply;
    fsm_cond(24) <= in_sw_gpio_cfg;
    fsm_cond(25) <= cfg_reload_in;
    fsm_cond(26) <= gpio_test_in;
    fsm_cond(27) <= wideband_tx;
    fsm_cond(28) <= wideband_rx;
    fsm_cond(31 downto 29) <= rf_state;

    -- Dat ten net cho tung probe: ten nay di thang vao .ltx nen tren may test
    -- probe hien ra la "from_state_code", "fsm_cond"... chu khong phai ten tong hop.
    meta_bw_pwr        <= Tx_bw_in & Rx_bw_in & Power_Tx_in;
    from_state_code    <= FSM_CODE(from_state);
    to_state_code      <= FSM_CODE(to_state);
    next_freq_hz       <= next_frequency(31 downto 0);
    state_change_cnt_v <= std_logic_vector(state_change_cnt);

    ila_fsm_dbg_inst : ila_fsm_dbg
    port map (
        clk       => fsm_clk_in,
        probe0    => fsm_state_code,
        probe1    => from_state_code,
        probe2    => to_state_code,
        probe3(0) => state_change,
        probe4    => pll_state,
        probe5    => fsm_cond,
        probe6    => fsm_cond_at_change,
        probe7    => next_freq_hz,
        probe8    => Current_Subsecond_in,
        probe9    => next_gpio_switch_time,
        probe10   => next_pll_switch_time,
        probe11   => Next_Frame_Transmit_Time_in,
        probe12   => Next_Frame_Receive_Time_in,
        probe13   => meta_bw_pwr,
        probe14   => gpio_actual_mask,
        probe15   => gpio_out,
        probe16   => state_change_cnt_v
    );

end behaviour;

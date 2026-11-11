
			
-- Engineer: 
-- 
-- Create Date: 25.11.2025 17:15:48
-- Design Name: 
-- Module Name: GPIO_DeMux - Behavioral
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
																				  

						 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gpio_types_pkg.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY GPIO_Mux_wrapper IS
		  
	PORT (  CLK			        : in  std_logic;
			GPIO_MUXED			: out std_logic_vector(7 downto 0);
											
											
			GPIO_MUX_LE_0		: out std_logic;
											
											
											
			GPIO_MUX_LE_1		: in  std_logic; -- PG_VCO
			GPIO_MUX_LE_2	    : in  std_logic; -- DDS_A_PLL_LOCKED
			GPIO_MUX_LE_3		: in  std_logic; -- DDS_B_PLL_LOCKED
			DDS_MASTER_RESET 	: in  std_logic := '0';
			ADC_AFE_PWUP 		: in  std_logic := '0';
			ADC_AFE_PM 			: in  std_logic := '0';
			EN_RX 			    : in  std_logic := '0';
			EN_TX 			    : in  std_logic := '0';
			EN_LO 			    : in  std_logic := '0';
			EN_RTX 			    : in  std_logic := '0';
			EN_SMPS_SYNC 		: in  std_logic := '0';
			DDS_PWR_DWN 		: in  std_logic := '0';
			ADC_PDWN 			: in  std_logic := '0';

			RTX_01 			    : in  std_logic := '0';
			RTX_02 			    : in  std_logic := '0';
			RTX_09 			    : in  std_logic := '0';
			RTX_11 			    : in  std_logic := '0';
			RTX_13 			    : in  std_logic := '0';
			RTX_14 			    : in  std_logic := '0';
			RTX_15 			    : in  std_logic := '0';
			RTX_16 			    : in  std_logic := '0';
			RTX_17 			    : in  std_logic := '0';
			RTX_18 			    : in  std_logic := '0';
			RTX_19 			    : in  std_logic := '0';
			RTX_20 			    : in  std_logic := '0';
			IF_FB_SW_2 			: in  std_logic := '0';
			IF_70_RX_SW_V1 		: in  std_logic := '0';
			IF_70_RX_SW_V2 		: in  std_logic := '0';
			PP_An_B 			: in  std_logic := '0';
			HB_RX_TBPF_SW_0 	: in  std_logic := '0';
			LO_DIV_EN 			: in  std_logic := '0';

			LB_LPF_SW 			: in  std_logic_vector(1 to 3);
			HB_LPF_SW	 		: in  std_logic_vector(1 to 2);
			PLL_A_EN 			: in  std_logic := '0';
			PLL_A_NB 			: in  std_logic := '0';
			PLL_B_EN 			: in  std_logic := '0';
			PLL_B_NB 			: in  std_logic := '0';
			DDS_A_VCO 			: in  std_logic_vector(1 downto 0);
			DDS_B_VCO 			: in  std_logic_vector(1 downto 0);
			LO_HB_A 			: in  std_logic := '0';
			LO_HB_B 			: in  std_logic := '0';
			OL_ADC_504 			: in  std_logic := '0';
			OL_ADC_917 			: in  std_logic := '0';
			MUX_A0 			    : in  std_logic := '0';
			MUX_A1 			    : in  std_logic := '0';
			MUX_A2 			    : in  std_logic := '0';
														
		    MUX_A3 			    : in  std_logic := '0';
				
			PG_VCO			    : out std_logic;
			DDS_A_PLL_LOCKED	: out std_logic;
			DDS_B_PLL_LOCKED	: out std_logic);
		end GPIO_Mux_wrapper;

architecture behaviour OF GPIO_Mux_wrapper is
															 
	 
				
		 
										   
		
												
											
										  
									 
									 
									 
									  

		
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  

	signal GPIO_Vector 	: std_logic_vector(47 downto 0);
	signal toggle 		: std_logic_vector(3 downto 0);
	signal cnt 			: integer range 0 to 100000 := 0;
									   
											   
										 

	component GPIO_Mux is
		port (  CLK			        : in  std_logic;
				GPIO_MUXED			: out std_logic_vector(7 downto 0);
				GPIO_MUX_LE_0		: out std_logic;								
				GPIO_TO_MUX			: in  std_logic_vector(47 downto 0));
		end component;

begin 
										
										
										
										

	GPIO_Vector(47)     <=  DDS_MASTER_RESET;
	GPIO_Vector(46)     <=  ADC_AFE_PWUP;
	GPIO_Vector(45)     <=  ADC_AFE_PM;
	GPIO_Vector(44)     <=  EN_RX;
	GPIO_Vector(43)     <=  EN_TX;
	GPIO_Vector(42) 	<=  EN_LO;
	GPIO_Vector(41) 	<=  EN_RTX;
	GPIO_Vector(40) 	<=  DDS_PWR_DWN;
	GPIO_Vector(39) 	<=  ADC_PDWN;
	GPIO_Vector(38) 	<=  RTX_01;
	GPIO_Vector(37) 	<=  RTX_02;
	GPIO_Vector(36) 	<=  RTX_09;
	GPIO_Vector(35) 	<=  RTX_11;
	GPIO_Vector(34) 	<=  RTX_13;
	GPIO_Vector(33) 	<=  RTX_14;
	GPIO_Vector(32) 	<=  RTX_15;
	GPIO_Vector(31) 	<=  RTX_16;
	GPIO_Vector(30) 	<=  RTX_17;
	GPIO_Vector(29) 	<=  RTX_18;
	GPIO_Vector(28) 	<=  RTX_19;
	GPIO_Vector(27) 	<=  RTX_20;
	GPIO_Vector(26) 	<=  IF_FB_SW_2;
	GPIO_Vector(25) 	<=  IF_70_RX_SW_V1;
	GPIO_Vector(24) 	<=  IF_70_RX_SW_V2;
	GPIO_Vector(23) 	<=  PP_An_B;
	GPIO_Vector(22) 	<=  HB_RX_TBPF_SW_0;
	GPIO_Vector(21) 	<=  LO_DIV_EN;
	GPIO_Vector(20) 	<=  LB_LPF_SW(1);
	GPIO_Vector(19) 	<=  LB_LPF_SW(2);
	GPIO_Vector(18) 	<=  LB_LPF_SW(3);
	GPIO_Vector(17) 	<=  HB_LPF_SW(1);
	GPIO_Vector(16) 	<=  HB_LPF_SW(2);
	GPIO_Vector(15) 	<=  PLL_A_EN;
	GPIO_Vector(14) 	<=  PLL_A_NB;
	GPIO_Vector(13) 	<=  PLL_B_EN;
	GPIO_Vector(12) 	<=  PLL_B_NB;
	GPIO_Vector(11) 	<=  DDS_A_VCO(1);
	GPIO_Vector(10) 	<=  DDS_A_VCO(0);
	GPIO_Vector(9) 		<=  DDS_B_VCO(1);
	GPIO_Vector(8) 		<=  DDS_B_VCO(0);
	GPIO_Vector(7) 		<=  LO_HB_A;
	GPIO_Vector(6) 		<=  LO_HB_B;
	GPIO_Vector(5) 		<=  OL_ADC_504;
	GPIO_Vector(4) 		<=  OL_ADC_917;
	GPIO_Vector(3) 		<=  MUX_A0;
	GPIO_Vector(2) 		<=  MUX_A1;
	GPIO_Vector(1) 		<=  MUX_A2;
	GPIO_Vector(0)  	<=  MUX_A3;
	
	PG_VCO			    <= GPIO_MUX_LE_1;
	DDS_A_PLL_LOCKED	<= GPIO_MUX_LE_2;
	DDS_B_PLL_LOCKED	<= GPIO_MUX_LE_3;
					
									  
									  
										 
										 
									 
									 
									 
									 
				
	GPIO_Mux_inst : GPIO_Mux
		port map (  CLK				=> CLK,
					GPIO_MUXED		=> GPIO_MUXED,
					GPIO_MUX_LE_0	=> GPIO_MUX_LE_0,
					GPIO_TO_MUX		=> GPIO_Vector);

END behaviour;

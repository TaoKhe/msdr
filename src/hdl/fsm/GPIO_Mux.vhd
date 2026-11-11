----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2025 17:15:48
-- Design Name: 
-- Module Name: GPIO_MUX - Behavioral
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

library xil_defaultlib;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity GPIO_Mux is
	port   (CLK			                : in  std_logic;
			GPIO_MUXED			        : out std_logic_vector(7 downto 0);
			GPIO_MUX_LE_0			    : out std_logic;
			GPIO_MUX_LE_1			    : out std_logic;
			GPIO_MUX_LE_2			    : out std_logic;
			GPIO_MUX_LE_3			    : out std_logic;
			GPIO_TO_MUX			        : in  std_logic_vector(47 downto 0));
		end GPIO_Mux;

architecture behaviour OF GPIO_Mux is

	signal test			: std_logic;
	signal GPIO_TO_MUXs			: std_logic_vector(15 downto 0) := (others => '1');
	signal state				: integer range 0 to 2 := 0;

begin 
             					
	Mux : process(CLK)
        begin
            if rising_edge(CLK) then
                case state is                                       
                    when 0     	=>  GPIO_MUX_LE_0 	<= '0';
                    				GPIO_TO_MUXs 	<= 	GPIO_TO_MUX(47 downto 32);
                    				state  <= 1;                 
                    when 1     	=>  GPIO_MUX_LE_0 	<= '1';
                    				GPIO_TO_MUXs 	<= 	GPIO_TO_MUX(31 downto 16);
                    				state  <= 2;                                 
                    when others	=>	GPIO_MUX_LE_0 	<= '0';
                    				GPIO_TO_MUXs 	<= 	GPIO_TO_MUX(15 downto 0);
                    				state  <= 0;  	       	
                end case;
            end if;
        end process;

    GPIO_MUX_ODDR_generate : for n in 0 to 7 generate
       begin
           GPIO_MUX_ODDRE1_inst : ODDRE1
   			generic map(IS_C_INVERTED 	=> '0',           		-- Optional inversion for C
      					IS_D1_INVERTED 	=> '0',           		-- Unsupported, do not use
      					IS_D2_INVERTED 	=> '0',           		-- Unsupported, do not use
      					SIM_DEVICE 		=> "ULTRASCALE_PLUS", 	-- Set the device version for simulation functionality
      					SRVAL 			=> '0')                 -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
   			port map (	Q 	=> GPIO_MUXED(n),   				-- 1-bit output: Data output to IOB
						C 	=> CLK,   							-- 1-bit input: High-speed clock input
						D1 	=> GPIO_TO_MUXs(n * 2), 			-- 1-bit input: Parallel data input 1
						D2 	=> GPIO_TO_MUXs((n * 2) + 1), 		-- 1-bit input: Parallel data input 2
						SR 	=> '0');  							-- 1-bit input: Active-High Async Reset
    end generate;
end behaviour;

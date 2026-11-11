library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vcxo_dac_driver is
  generic ( DAC_BITS        	: integer := 18);     -- DAC code width
  port    ( clk 				: in  std_logic; -- mapper clock domain
			dac_code_in   		: in  std_logic_vector(DAC_BITS-1 downto 0); -- servo command increment
			dac_code_in_valid  	: in  std_logic; -- servo command increment
			-- DAC command output (grouped for external SPI wrapper)
			dac_code       		: out std_logic_vector(DAC_BITS-1 downto 0); -- DAC code command
			dac_code_valid 		: out std_logic;                      -- 1-cycle pulse when DAC code is applied
			ready  				: out std_logic); -- high: driver can accept new enable_update
end entity;

architecture rtl of vcxo_dac_driver is

	type DAC_fsm_type is (wait_code, wait_255_uS);
	signal DAC_fsm    	: DAC_fsm_type := wait_code; 
	signal dac_cnt 		: integer range 0 to 25499 := 0;

  begin

	process(clk)
		begin
			if rising_edge(clk) then
				case DAC_fsm is
					when wait_code		=>  if (dac_code_in_valid = '1') then
												dac_code 		<= dac_code_in;
												dac_code_valid 	<= '1';
												ready 			<= '0';
												dac_cnt 		<= 0;
												DAC_fsm 		<= wait_255_uS;
											else
												ready 		<= '1';	
											end if;
					when wait_255_uS	=>  if (dac_cnt = 25499) then
												dac_cnt 	<= 0;
												ready 		<= '1';
												DAC_fsm 	<= wait_code;
											else
												dac_cnt 	<= dac_cnt + 1;
											end if;
											dac_code_valid 	<= '0';
					when others 		=> 	DAC_fsm 	<= wait_code;
											ready 		<= '1';
											dac_cnt 	<= 0;
				end case;
			end if;
		end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.conv_std_logic_vector;

entity ek_PID is
  generic ( SECOND_WIDTH   	: integer := 40;
			USEC_WIDTH   	: integer := 27;
			ERR_WIDTH   	: integer := 32;
			USEC_PER_SEC    : integer := 1000000;
			DAC_BITS 		: integer := 18);
  port     (clk 			: in   std_logic; -- logic clock domain
			rst 			: in   std_logic; -- active-high synchronous reset
			error_us  		: in   signed(ERR_WIDTH-1 downto 0);
			tick    		: in   std_logic;
			cfg_mode 		: in  std_logic_vector(2 downto 0); -- runtime mode select for state machine
			dac_ready		: in   std_logic;
			dac_code		: out  std_logic_vector(DAC_BITS-1 downto 0);
			load_cnt		: out  std_logic := '0';
			dac_code_valid  : out  std_logic := '0');
	end entity;

architecture rtl of ek_PID is

	type PID_fsm_type is (Wait_error, Aquire_error, Corr_Int, Calc_int, Corr_Prop, Add_prop, Calc_Done, wait_next);
	signal max_err				: integer := USEC_PER_SEC / 1000;
	signal PID_fsm    			: PID_fsm_type := wait_next; 
	signal dac_code_s   		: std_logic_vector(DAC_BITS-1 downto 0);
	signal int  				: integer := 0;
	signal prop  				: integer := 0;
	signal corr  				: integer := 0;
	signal error_us_i			: integer := 0;
	signal error_us_prop		: integer := 0;
	signal error_us_int			: integer := 0;
	signal dac_code_valid_s		: std_logic := '0';
	signal load_first_time		: std_logic := '1';

	begin
	
		
		
		process(clk)
			begin
				if rising_edge(clk) then
					if (rst = '1') then
						if (dac_ready = '1')  then
							dac_code_s <= "100000000000000000";
							dac_code_valid_s <= '1';
						else
							dac_code_valid_s <= '0';
						end if;
						int <= 131071;
					else
						if (tick = '1') then
							PID_fsm <= Wait_error;
							dac_code_valid_s 		<= '0';
						elsif (dac_ready = '1')  then
							load_cnt	<= '0';
							case PID_fsm is
								when Wait_error		=>  dac_code_valid_s 		<= '0';
														PID_fsm 				<= Aquire_error;
								
								when Aquire_error	=>  if (load_first_time = '1') then
															load_cnt			<= '1';
															int 				<= 0;
															load_first_time 	<= '0';
															dac_code_s			<= conv_std_logic_vector((131071 - corr), 18);
															dac_code_valid_s 	<= '1';
															PID_fsm 			<= Wait_error;
														elsif (error_us > max_err) then
															error_us_i 			<= max_err;
															load_cnt			<= '1';
															dac_code_s			<= conv_std_logic_vector((131071 - corr), 18);
															dac_code_valid_s 	<= '1';
															PID_fsm 		<= Wait_error;
														elsif (error_us < -max_err) then
															error_us_i 			<= -max_err;
															load_cnt			<= '1';
															dac_code_s			<= conv_std_logic_vector((131071 - corr), 18);
															dac_code_valid_s 	<= '1';
															PID_fsm 			<= Wait_error;
														else
															error_us_i 			<= to_integer(error_us);
															load_cnt			<= '0';
															PID_fsm 			<= Corr_Int;
														end if;
														
								when Corr_Int		=> 	error_us_int <= error_us_i;
														PID_fsm 	<= Calc_int;
														
								when Calc_int		=> 	if (error_us_int > 0) then
															if ((int + error_us_int) < 131071) then
																int <= int + error_us_int;
															else
																int <= 131071;
															end if;
														elsif (error_us_int < 0) then
															if ((int + error_us_int) > -131071) then
																int <= int + error_us_int;
															else
																int <= -131071;
															end if;
														end if;
														prop 			<= error_us_int;
														PID_fsm 		<= Corr_Prop;
														
								when Corr_Prop		=>  error_us_prop 	<= error_us_int / 2; -- /8
														PID_fsm 		<= Add_prop;
														
								when Add_prop		=> 	if (error_us_prop > 0) then
															if ((int + error_us_prop) < 131071) then
																corr <= int + error_us_prop;
															else
																corr <= 131071;
															end if;
														elsif (error_us_prop < 0) then
															if ((int + error_us_prop) > -131071) then
																corr <= int + error_us_prop;
															else
																corr <= -131071;
															end if;
														end if;
														PID_fsm 			<= Calc_Done;
														
								when Calc_Done	=>  	if (cfg_mode = "111") then
															dac_code_s			<= conv_std_logic_vector((262143), 18);
														elsif (cfg_mode = "110") then
															dac_code_s			<= conv_std_logic_vector((0), 18);
														else
															dac_code_s			<= conv_std_logic_vector((131071 - corr), 18);
														end if;
														dac_code_valid_s 	<= '1';
														PID_fsm 			<= wait_next;
								when wait_next		=>	dac_code_valid_s 	<= '0';
								when others 		=>	dac_code_valid_s 	<= '0';
							end case;
						else
							dac_code_valid_s <= '0';
							load_cnt	<= '0';
						end if;
					end if;
				end if;
			end process;

	dac_code_valid 	<= dac_code_valid_s;
	dac_code 		<= dac_code_s(DAC_BITS-1 downto 0);
	
end architecture;

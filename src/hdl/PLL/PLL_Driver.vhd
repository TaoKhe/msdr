library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.conv_std_logic_vector;
library UNISIM;
use UNISIM.VComponents.all;

entity PLL_Driver is
    Port ( 	clk				: in  std_logic;
    		adc_clk_in		: in  std_logic;
    		Freq_in 		: in  std_logic_vector(31 downto 0);
    		TX_RXn			: in  std_logic;
    		Tx_bw			: in  std_logic_vector(7 downto 0);
    		Rx_bw			: in  std_logic_vector(7 downto 0);
    		Set				: in  std_logic;
    		PP 				: in  std_logic;
    		dds_dav_a		: out std_logic;
    		dds_dav_b		: out std_logic;
    		dds 			: out std_logic_vector(31 downto 0);
    		DAC_freq		: out std_logic_vector(31 downto 0);
    		Set_DAC_freq	: out std_logic;
    		INT_A 			: out std_logic_vector(6 downto 0);
    		INT_B 			: out std_logic_vector(6 downto 0);
    		rx_dds_config_tdata		: out std_logic_vector(31 downto 0);
    		rx_dds_config_tvalid    : out std_logic);
end PLL_Driver;

architecture Behavioral of PLL_Driver is
	
	component mult_INT
		port (  CLK : in  std_logic;
				A 	: in  std_logic_vector(32 downto 0);
				P 	: out std_logic_vector(42 downto 0));
		end component;
		
	component mult_DDS
		port (  CLK : in  std_logic;
				A 	: in  std_logic_vector(32 downto 0);
				B 	: in  std_logic_vector(35 downto 0);
				P 	: out std_logic_vector(68 downto 0));
		end component;
		
	component Adder_32
		port (  A 	: in std_logic_vector(31 downto 0);
				B 	: in std_logic_vector(31 downto 0);
				CLK : in std_logic;
				S 	: out std_logic_vector(31 downto 0));
		end component;
		
	signal rx_dds_config_tvalid_100 : std_logic := '1';
	signal div_by_2 : std_logic := '1';
	signal Freq_error : std_logic := '1';
	signal rx_dds_config_tvalid_vect : std_logic_vector(4 downto 0) := (others => '0');
	signal IF_Freq : std_logic_vector(31 downto 0) := (others => '0');
	signal LO_Freq : std_logic_vector(32 downto 0) := (others => '0');
	signal INT_P : std_logic_vector(42 downto 0) := (others => '0');
	signal DDS_P : std_logic_vector(68 downto 0) := (others => '0');
	signal bw : std_logic_vector(2 downto 0) := (others => '0');
	signal LO_Freq_32 : std_logic_vector(31 downto 0) := (others => '0');
	signal MULT : std_logic_vector(35 downto 0) := (others => '0');
	signal INT : integer range 0 to 127 := 0;
	
	signal wait_cnt : integer range 0 to 15 := 0;
	signal LO_mult : integer range 1 to 2 := 1;

	type  mult_array_type is array (0 to 127) of std_logic_vector(35 downto 0);
	constant mult_array : mult_array_type := (	x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"F455FEACD", x"DBE6FECEB", x"C7E944BBF", x"B7407F019", x"A927D7B2B", x"9D12B6016", x"9299FF347",
												x"89705F413", x"815AB4012", x"7A2AFF566", x"73BCF1E61", x"6DF37F675", x"68B72400E", x"63F4A25DF", x"5F9C15BE0",
												x"5BA03F80C", x"57F5FF85E", x"5493EBD95", x"5171FF8EF", x"4E895B00B", x"4BD4113E7", x"494CFF9A3", x"46EFAD08E",
												x"44B82FA09", x"42A316E95", x"40AD5A009", x"3ED448CD5", x"3D157FAB3", x"3B6EDD154", x"39DE78F30", x"38629D3B9",
												x"36F9BFB3A", x"35A27C965", x"345B92007", x"3323DC007", x"31FA512EF", x"30DDFFBC2", x"2FCE0ADF0", x"2EC9A898E",
												x"2DD01FC06", x"2CE0C6498", x"2BFAFFC2F", x"2B1E3C006", x"2A49F5ECA", x"297DB27DF", x"28B8FFC77", x"27FB74259",
												x"2744AD805", x"269450A20", x"25EA089F3", x"2545864E6", x"24A67FCD1", x"240CB0111", x"2377D6847", x"22E7B6AAF",
												x"225C17D04", x"21D4C4BD5", x"21518B74A", x"20D23CF4D", x"2056AD004", x"1FDEB1EA0", x"1F6A2466A", x"1EF8DF61A",
												x"1E8ABFD59", x"1E1FA4A89", x"1DB76E8AA", x"1D51FFD74", x"1CEF3C798", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000",
												x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000", x"000000000");

	type fsm_freq_type is (	wait_set,
							calc_IF,
							calc_LO,
							wait_calc_LO,
							mult_by_2,
							calc_int,
							wait_mult,
							get_INT,
							calc_DDS,
							wait_calc_DDS,
							store_DDS);
							
	signal fsm_freq   : fsm_freq_type := calc_IF;
	
	begin
	
	    bw 			<= Tx_bw(2 downto 0)		when (TX_RXn = '1') else Rx_bw(2 downto 0);
	    INT 		<= conv_integer(INT_P(41 downto 35));
	    
	    Adder_32_inst : Adder_32
			port map (  A 	=> Freq_in,
						B 	=> IF_Freq,
						CLK => clk,
						S	=> LO_Freq_32);
	    
		mult_INT_inst : mult_INT  -- multipy by 729
			port map (  CLK => clk,
						A 	=> LO_Freq,
						P 	=> INT_P); --  / 2^34 to have INT
						
		mult_DDS_inst : mult_DDS
			port map (  CLK => clk,
						A 	=> LO_Freq,
						B 	=> MULT,
						P 	=> DDS_P);
  
	process(clk)
		begin	
			if rising_edge(clk) then
				case fsm_freq is
					when wait_set		=>	if (Set = '1') then
												fsm_freq <= calc_IF;
											end if;
											dds_dav_a <= '0';
											dds_dav_b <= '0';
											
					when calc_IF		=>	if ((Freq_in > (600*10**6 - 1)) and (Freq_in < 1200*10**6) and (TX_RXn = '1')) then
												DAC_Freq 	<= Freq_in;
											else
												case bw is
													when "100" 			=>	IF_Freq 	<= conv_std_logic_vector(433920000, 32);
																			DAC_Freq 	<= conv_std_logic_vector(433920000, 32);
																			if (TX_RXn = '0') then
																					rx_dds_config_tdata  <= x"0EF34D6A";
    																				rx_dds_config_tvalid_100 <= '1';
    																		end if;
																			
													when "101"			=>	IF_Freq 	<= conv_std_logic_vector(435000000, 32);
																			DAC_Freq 	<= conv_std_logic_vector(435000000, 32);
																			if (TX_RXn = '0') then
																					rx_dds_config_tdata  <= x"0EB851EC";
    																				rx_dds_config_tvalid_100 <= '1';
    																		end if;
																			
													when "110"			=>	null;
													
													when "111"			=>	null;
													
													when "000"			=>	IF_Freq 	<= conv_std_logic_vector(840800000, 32);
																			DAC_Freq 	<= conv_std_logic_vector(840800000, 32);
																			if (TX_RXn = '0') then
																					rx_dds_config_tdata  		<= x"10418937";
    																				rx_dds_config_tvalid_100 	<= '1';
    																		end if;
																			
													when "001"			=>	IF_Freq 	<= conv_std_logic_vector(845000000, 32);
																			DAC_Freq 	<= conv_std_logic_vector(845000000, 32);
																			if (TX_RXn = '0') then
																					rx_dds_config_tdata  		<= x"0F5C28F6";
    																				rx_dds_config_tvalid_100	 <= '1';
    																		end if;
																			
													when "010"			=>	null;
													   --"011"
													when others 		=>	IF_Freq 	<= conv_std_logic_vector(840000000, 32);
																			DAC_Freq 	<= conv_std_logic_vector(840000000, 32);
																			if (TX_RXn = '0') then
																					rx_dds_config_tdata  		<= x"106D3A07";
    																				rx_dds_config_tvalid_100 	<= '1';
    																		end if;
												end case;
											end if;
											
											if (Freq_in < 350*10**6) then
												LO_mult <= 2;
											else
												LO_mult <= 1;
											end if;
											
											Set_DAC_freq <= '1';
											fsm_freq 	<= calc_LO;
											
					when calc_LO		=>	wait_cnt 	<= 1;		--LO_Freq_32 <= Freq_in + IF_Freq;
											Set_DAC_freq <= '0';
											rx_dds_config_tvalid_100 <= '0';
											fsm_freq 	<= wait_calc_LO;
											
					when wait_calc_LO	=>	if (wait_cnt = 0) then
												fsm_freq <= mult_by_2;
											else
												wait_cnt <= wait_cnt - 1;
											end if;
											
					when mult_by_2		=> 	if (LO_mult = 2) then
												LO_Freq <= LO_Freq_32 & '0';
											else
												LO_Freq <= '0' & LO_Freq_32;
											end if;
											fsm_freq 	<= calc_int;
											
					when calc_int		=> 	wait_cnt 	<= 4;		--INT_P <= LO_Freq * conv_std_logic_vector(729, 10);
											fsm_freq 	<= wait_mult;
											
					when wait_mult		=>	if (wait_cnt = 0) then
												fsm_freq <= get_INT;
											else
												wait_cnt <= wait_cnt - 1;
											end if;
											
					when get_INT		=>  if (PP = '0') then
												INT_A 	<= INT_P(41 downto 35);
											else
												INT_B 	<= INT_P(41 downto 35);
											end if;
											
											MULT 		<= mult_array(conv_integer(INT_P(41 downto 35)));
											fsm_freq 	<= calc_DDS;
											
					when calc_DDS		=>	wait_cnt 	<= 4;	--DDS_P 		<= LO_Freq * MULT;
											fsm_freq 	<= wait_calc_DDS;
											
					when wait_calc_DDS	=>	if (wait_cnt = 0) then
												fsm_freq <= store_DDS;
											else
												wait_cnt <= wait_cnt - 1;
											end if;
											
					when store_DDS		=>	if (PP = '0') then
												dds_dav_a <= '1';
											else
												dds_dav_b <= '1';
											end if;
											dds 		<= DDS_P(67 downto 36);
											fsm_freq 	<= wait_set;
					when others 		=> 	fsm_freq 	<= wait_set;
				end case;
			end if;
		end process;

	process(adc_clk_in)
		begin	
			if rising_edge(adc_clk_in) then
				rx_dds_config_tvalid_vect <= rx_dds_config_tvalid_vect(3 downto 0) & rx_dds_config_tvalid_100;
				if ((rx_dds_config_tvalid_vect(4) = '1') and (rx_dds_config_tvalid_vect(3) = '0')) then
					rx_dds_config_tvalid <= '1';
				else
					rx_dds_config_tvalid <= '0';
				end if;
			end if;
		end process;
	


end Behavioral;

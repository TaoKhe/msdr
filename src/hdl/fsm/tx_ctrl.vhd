library ieee;	
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library machxo2; 
use machxo2.all;

ENTITY TX_CTRL IS
PORT(  
        CLK_i					: in  std_logic;
        SPI_TX_CSn_2_o			: out std_logic; -- CPLD
        SPI_TX_SCLK_o			: out std_logic; 
        SPI_TX_MISO_i			: in  std_logic;
        SPI_TX_MOSI_o			: out std_logic;
        
        BITE_RX_LD_o			: out std_logic;
        LB_PA_CURRENT_ALR_o		: out std_logic;
        LB_DRV_CURRENT_ALR_o	: out std_logic;
        HB_PA_CURRENT_ALR_o		: out std_logic;
        HB_DRV_CURRENT_ALR_o	: out std_logic;
        HB_PRE_CURRENT_ALR_o	: out std_logic;
        LB_FWD_POWER_ALR_o		: out std_logic;
        LB_RWD_POWER_ALR_o		: out std_logic;
        HB_FWD_POWER_ALR_o		: out std_logic;
        HB_RWD_POWER_ALR_o		: out std_logic;
        CPLD_REV_o    			: out std_logic_vector(7 downto 0) := (others => '0');
        TX_VDD_PGOOD_o			: out std_logic;
        RTX_PUSH_GATE_o			: out std_logic;
        SMPS_SYNC_RTX_o			: out std_logic;

        SMPS_SYNC_i			    : in  std_logic;
        LB_PA_CURRENT_i			: in  std_logic;
        LB_DRV_CURRENT_i		: in  std_logic;
        HB_PA_CURRENT_i			: in  std_logic;
        HB_DRV_CURRENT_i		: in  std_logic;
        HB_PRE_CURRENT_i		: in  std_logic;
        
        LB_SW_4_RTX_i			: in  std_logic;
        LB_SW_3_RTX_i			: in  std_logic;
        LB_SW_2_RTX_i			: in  std_logic;
        LB_SW_1_RTX_i			: in  std_logic;
        HB_SW_4_RTX_i			: in  std_logic;
        HB_SW_3_RTX_i			: in  std_logic;
        HB_SW_2_RTX_i			: in  std_logic;
        HB_SW_1_RTX_i			: in  std_logic;

        LB_SW_4_RTX_o			: out  std_logic;
        LB_SW_3_RTX_o			: out  std_logic;
        LB_SW_2_RTX_o			: out  std_logic;
        LB_SW_1_RTX_o			: out  std_logic;
        HB_SW_4_RTX_o			: out  std_logic;
        HB_SW_3_RTX_o			: out  std_logic;
        HB_SW_2_RTX_o			: out  std_logic;
        HB_SW_1_RTX_o			: out  std_logic;

        
        RF_OFF_i			    : in  std_logic;
        RESET_o				    : out std_logic);
end TX_CTRL ;

ARCHITECTURE behaviour OF TX_CTRL IS	

    component spi_master is
        generic (
            DATA_WIDTH : integer := 32;
            CLK_DIV    : integer := 5
        );
        port (
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            enable    : in  std_logic;
            tx_data   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            rx_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            busy      : out std_logic;
            rx_valid  : out std_logic;
            sclk      : out std_logic;
            mosi      : out std_logic;
            miso      : in  std_logic;
            ss_n      : out std_logic
        );
    end component;
    
    signal	CLKs					:std_logic;
    signal	VDD_PGOODs			    :std_logic := '1';
    signal	RTX_PUSH_GATEs			:std_logic := '0';
    signal	RESETs					:std_logic := '1';
    
    signal	BITE_RX_ENs				:std_logic := '0';
    signal  DAC_SETUP_DONEs			:std_logic := '1';
    
    signal	BITE_RX_LDs				:std_logic;
    signal	LB_PA_CURRENT_ALRs		:std_logic;
    signal	LB_DRV_CURRENT_ALRs		:std_logic;
    signal	HB_PA_CURRENT_ALRs		:std_logic;
    signal	HB_DRV_CURRENT_ALRs		:std_logic;
    signal	HB_PRE_CURRENT_ALRs		:std_logic;
    signal	LB_FWD_POWER_ALRs		:std_logic;
    signal	LB_RWD_POWER_ALRs		:std_logic;
    signal	HB_FWD_POWER_ALRs		:std_logic;
    signal	HB_RWD_POWER_ALRs		:std_logic;
    signal  CPLD_REVs    			:std_logic_vector(7 downto 0) := (others => '0');

    signal SPI_MOSI_VECTORs		:std_logic_vector (31 downto 0):= (others => '0');
    signal SPI_MISO_VECTORs		:std_logic_vector (31 downto 0):= (others => '0');
    
    signal 	 PKT_CNT 				: integer range 0 to 100000 := 0;
    signal 	 Timer 				    : integer range 0 to 10000000 := 0;
    constant Time_Out_30uS 		    : integer := 3000;
    
    -- SPI Master Control Signals
    signal spi_enable   : std_logic := '0';
    signal spi_busy     : std_logic;
    signal spi_rx_valid : std_logic;
			
BEGIN
			CLKs <= CLK_i;
			
			START_RESET : process(CLKs)
				begin
					if rising_edge(CLKs) then
						if(Timer = Time_Out_30uS)then		
							RESETs 	<= '0';			
						else
							RESETs 	<= '1';
							Timer 	<= Timer + 1;
						end if;
					end if;
				end process START_RESET;
				
			-- Tạo dữ liệu gửi đi
			SPI_MOSI_VECTORs(31 downto 7) <= (others => '0');

			SPI_MOSI_VECTORs (6)	<=	LB_PA_CURRENT_i;
			SPI_MOSI_VECTORs (5)	<=	LB_DRV_CURRENT_i;
			SPI_MOSI_VECTORs (4)	<=	HB_PA_CURRENT_i;
			SPI_MOSI_VECTORs (3)	<=	HB_DRV_CURRENT_i;
			SPI_MOSI_VECTORs (2)	<=	HB_PRE_CURRENT_i;
			SPI_MOSI_VECTORs (1)	<=	BITE_RX_ENs;
			SPI_MOSI_VECTORs (0)	<=	DAC_SETUP_DONEs;
			

			-- Kích hoạt truyền SPI theo chu kỳ
			SPI_TRIGGER : process(CLKs)
			begin
				if rising_edge(CLKs) then
					spi_enable <= '0'; -- Default
					
--					if PKT_CNT = 100000 then
--						PKT_CNT <= 0;
--						if spi_busy = '0' then
--							spi_enable <= '1'; -- Kích hoạt 1 chu kỳ clock
--						end if;
--					else
--						PKT_CNT <= PKT_CNT + 1;
--					end if;
					
					-- Cập nhật dữ liệu khi nhận xong
					if spi_rx_valid = '1' then
						BITE_RX_LDs			<=	SPI_MISO_VECTORs (17);
						LB_PA_CURRENT_ALRs	<=	SPI_MISO_VECTORs (16);
						LB_DRV_CURRENT_ALRs	<=	SPI_MISO_VECTORs (15);
						HB_PA_CURRENT_ALRs	<=	SPI_MISO_VECTORs (14);
						HB_DRV_CURRENT_ALRs	<=	SPI_MISO_VECTORs (13);
						HB_PRE_CURRENT_ALRs	<=	SPI_MISO_VECTORs (12);
						LB_FWD_POWER_ALRs	<=	SPI_MISO_VECTORs (11);
						LB_RWD_POWER_ALRs	<=	SPI_MISO_VECTORs (10);
						HB_FWD_POWER_ALRs	<=	SPI_MISO_VECTORs (9);
						HB_RWD_POWER_ALRs	<=	SPI_MISO_VECTORs (8);
						CPLD_REVs(7 downto 0) <= SPI_MISO_VECTORs(7 downto 0);
					end if;
				end if;
			end process SPI_TRIGGER;

			-- Khởi tạo Master
			CPLD_SPI: spi_master
			generic map (
				DATA_WIDTH => 32,
				CLK_DIV    => 5
			)
			port map (
				clk       => CLKs,
				reset_n   => '1',
				enable    => spi_enable,
				tx_data   => SPI_MOSI_VECTORs,
				rx_data   => SPI_MISO_VECTORs,
				busy      => spi_busy,
				rx_valid  => spi_rx_valid,
				sclk      => SPI_TX_SCLK_o,
				mosi      => SPI_TX_MOSI_o,
				miso      => SPI_TX_MISO_i,
				ss_n      => SPI_TX_CSn_2_o
			);
				
			TX_VDD_PGOOD_o 			<= VDD_PGOODs;
			RTX_PUSH_GATE_o 		<= RTX_PUSH_GATEs;
			RESET_o 				<= RESETs;
			BITE_RX_LD_o			<= BITE_RX_LDs;				
			LB_PA_CURRENT_ALR_o		<= LB_PA_CURRENT_ALRs;		
			LB_DRV_CURRENT_ALR_o	<= LB_DRV_CURRENT_ALRs;		
			HB_PA_CURRENT_ALR_o		<= HB_PA_CURRENT_ALRs;		
			HB_DRV_CURRENT_ALR_o	<= HB_DRV_CURRENT_ALRs;		
			HB_PRE_CURRENT_ALR_o	<= HB_PRE_CURRENT_ALRs;		
			LB_FWD_POWER_ALR_o		<= LB_FWD_POWER_ALRs;		
			LB_RWD_POWER_ALR_o		<= LB_RWD_POWER_ALRs;		
			HB_FWD_POWER_ALR_o		<= HB_FWD_POWER_ALRs;		
			HB_RWD_POWER_ALR_o		<= HB_RWD_POWER_ALRs;		
			CPLD_REV_o    			<= CPLD_REVs;  

			LB_SW_4_RTX_o			<= LB_SW_4_RTX_i;
			LB_SW_3_RTX_o			<= LB_SW_3_RTX_i;
			LB_SW_2_RTX_o			<= LB_SW_2_RTX_i;
			LB_SW_1_RTX_o			<= LB_SW_1_RTX_i;
			HB_SW_4_RTX_o			<= HB_SW_4_RTX_i;
			HB_SW_3_RTX_o			<= HB_SW_3_RTX_i;
			HB_SW_2_RTX_o			<= HB_SW_2_RTX_i;
			HB_SW_1_RTX_o			<= HB_SW_1_RTX_i;
				
END behaviour;
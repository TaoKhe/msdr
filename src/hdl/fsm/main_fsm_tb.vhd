library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm_main is
end entity tb_fsm_main;

architecture sim of tb_fsm_main is

    -- 1. Constants & Configuration
    constant CLK_PERIOD    : time := 6.667 ns; -- 150 MHz
    constant N_GPIO        : integer := 65;
    constant BRAM_LUT_SIZE : integer := 128; -- Tổng số ô nhớ trong BRAM

    -- 2. Signals for DUT
    signal fsm_clk_in    : std_logic := '0';
    signal fsm_rstn_in   : std_logic := '0';

    -- BRAM Interface
    signal CFG_LUT_addr  : std_logic_vector(31 downto 0);
    signal CFG_LUT_clk   : std_logic;
    signal CFG_LUT_din   : std_logic_vector(31 downto 0);
    signal CFG_LUT_en    : std_logic;
    signal CFG_LUT_rst   : std_logic;
    signal CFG_LUT_we    : std_logic_vector(3 downto 0);

    -- Inputs
    signal cfg_reload_in           : std_logic := '0';
    signal gpio_test_in            : std_logic := '0';
    signal gpio_mask_ub_in         : std_logic_vector(N_GPIO-1 downto 0) := (others => '0');
    signal trx_config_in           : std_logic := '1';
    signal running_config_valid_in : std_logic := '0';

    -- Schedule Config
    signal Frame_Length_in              : std_logic_vector(47 downto 0) := (others => '0');
    signal Tx_freq_in                   : std_logic_vector(47 downto 0) := x"000001C9C380";
    signal Rx_freq_in                   : std_logic_vector(47 downto 0) := (others => '0');
    signal Next_Frame_Transmit_Time_in  : std_logic_vector(26 downto 0) := (others => '0');
    signal Power_Tx_in                  : std_logic_vector(7 downto 0)  := x"10";
    signal Rx_bw_in                     : std_logic_vector(7 downto 0)  := (others => '0');
    signal Tx_bw_in                     : std_logic_vector(7 downto 0)  := x"01";
    signal Next_Frame_Receive_Time_in   : std_logic_vector(26 downto 0) := (others => '0');
    signal Second_from_2000_in          : std_logic_vector(39 downto 0) := (others => '0');
    signal Subsecond_in                 : std_logic_vector(26 downto 0) := (others => '0');

    -- System Time
    signal Current_second_from_2000_in  : std_logic_vector(39 downto 0) := (others => '0');
    signal Current_Subsecond_in         : std_logic_vector(26 downto 0) := (others => '0');

    -- Testbench Control
    signal sim_done : boolean := false;

    -- 3. BRAM Storage Type
    type ram_type is array (0 to BRAM_LUT_SIZE-1) of std_logic_vector(31 downto 0);
    
    -- Khởi tạo dữ liệu mẫu cho BRAM
    impure function init_bram return ram_type is
        variable tmp : ram_type := (others => (others => '0'));
    begin
        -- Nạp dữ liệu cho GPIO Profiles (0 đến 64)
        for i in 0 to N_GPIO-1 loop
            tmp(i) := std_logic_vector(to_unsigned(i + 16#A0#, 32)); 
        end loop;
        -- Nạp các tham số thời gian (Địa chỉ N_GPIO trở đi)
        tmp(N_GPIO)     := x"00000064"; -- pll_setup_time = 100
        tmp(N_GPIO + 1) := x"000000C8"; -- pll_switching_time = 200
        tmp(N_GPIO + 2) := x"00000010"; -- txhb_txhb_early_value
        tmp(N_GPIO + 3) := x"00000011"; -- txlb_txhb_early_value
        -- ... thêm các giá trị khác tùy ý
        return tmp;
    end function;

    signal bram_data : ram_type := init_bram;

begin

    -- 4. DUT Instantiation
    dut : entity work.fsm_main
        generic map ( N_GPIO => N_GPIO )
        port map (
            fsm_clk_in      => fsm_clk_in,
            fsm_rstn_in     => fsm_rstn_in,
            CFG_LUT_addr    => CFG_LUT_addr,
            CFG_LUT_clk     => CFG_LUT_clk,
            CFG_LUT_din     => CFG_LUT_din,
            CFG_LUT_en      => CFG_LUT_en,
            CFG_LUT_rst     => CFG_LUT_rst,
            CFG_LUT_we      => CFG_LUT_we,
            cfg_reload_in   => cfg_reload_in,
            gpio_test_in    => gpio_test_in,
            gpio_mask_ub_in => gpio_mask_ub_in,
            
            Frame_Length_in              => Frame_Length_in,
            Tx_freq_in                   => Tx_freq_in ,--x"000001C9C380",
            Rx_freq_in                   => Rx_freq_in,
            Next_Frame_Transmit_Time_in  => Next_Frame_Transmit_Time_in,
            Power_Tx_in                  => Power_Tx_in,
            Rx_bw_in                     => Rx_bw_in,
            Tx_bw_in                     => Tx_bw_in,
            Next_Frame_Receive_Time_in   => Next_Frame_Receive_Time_in,
            Second_from_2000_in          => Second_from_2000_in,
            Subsecond_in                 => Subsecond_in,
            trx_config_in                => trx_config_in,
            
            Current_second_from_2000_in => Current_second_from_2000_in,
            Current_Subsecond_in        => Current_Subsecond_in,
            running_config_valid_in     => running_config_valid_in,

            -- Bỏ qua các tín hiệu out không dùng đến hoặc để 'open'
            ad9164_csn      => open, ad9164_sclk => open, ad9164_mosi => open,
            pll_a_ad9914_le => open, pll_b_ad9914_le => open,
            PG_ADC_PLL      => '1', PG_VCVCSO => '1',
            pll_504_locked  => '1', pll_917_locked => '1',
            GPIO_MUX_LE_1   => '1', GPIO_MUX_LE_2 => '1', GPIO_MUX_LE_3 => '1'
        );

    -- 5. Clock Generation
    fsm_clk_in <= not fsm_clk_in after CLK_PERIOD / 2 when not sim_done else '0';

    -- 6. BRAM Emulator Process (Đọc dữ liệu từ LUT)
    process(fsm_clk_in)
    begin
        if rising_edge(fsm_clk_in) then
            if CFG_LUT_en = '1' then
                -- Chuyển đổi địa chỉ vector sang integer để truy xuất array
                -- Lưu ý: Nếu addr của bạn là địa chỉ byte (0, 4, 8...), hãy dịch bit: to_integer(unsigned(CFG_LUT_addr(31 downto 2)))
                CFG_LUT_din <= bram_data(to_integer(unsigned(CFG_LUT_addr)));
            end if;
        end if;
    end process;

    -- 7. Main Stimulus Process
    proc_main: process
    begin
        -- Reset ban đầu
        fsm_rstn_in <= '0';
        wait for 50 ns;
        fsm_rstn_in <= '1';
        wait for 50 ns;

        -- Giai đoạn 1: Nạp BRAM (Load configuration)
        report "Action: Triggering BRAM Reload...";
        cfg_reload_in <= '1';
        wait for CLK_PERIOD * 2;
        cfg_reload_in <= '0';

        -- Chờ FSM đọc xong toàn bộ BRAM (dựa trên BRAM_LUT_SIZE)
        wait for CLK_PERIOD * (BRAM_LUT_SIZE + 10);
        report "Action: BRAM Data has been loaded into internal registers.";

        -- Giai đoạn 2: Thiết lập thời điểm thực thi (Schedule)
        -- Đặt mục tiêu: Giây thứ 5, Subsecond thứ 1000
        --Second_from_2000_in <= std_logic_vector(to_unsigned(5, 40));
        Next_Frame_Transmit_Time_in        <= std_logic_vector(to_unsigned(1000, 27));
        running_config_valid_in <= '1';
        
        -- Giai đoạn 3: Chạy thời gian hệ thống (System Time)
        Current_second_from_2000_in <= std_logic_vector(to_unsigned(5, 40));
        
        report "Action: Increasing System Subsecond to trigger FSM...";
        -- Tăng Subsecond từ 990 đến 1010 để quan sát điểm giao thoa
        for i in 990 to 1050 loop
            Current_Subsecond_in <= std_logic_vector(to_unsigned(i, 27));
            wait for CLK_PERIOD;
            if i = 1000 then
                report "MATCH! System Time = Target Time.";
            end if;
        end loop;

        -- Đợi thêm để quan sát các hoạt động sau khi trigger (như truyền SPI)
        wait for 2 us;

        -- Kết thúc
        sim_done <= true;
        report "Simulation Finished.";
        wait;
    end process;

end architecture sim;
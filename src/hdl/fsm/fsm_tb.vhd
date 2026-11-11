library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gpio_types_pkg.all;

entity tb_gpio_fsm is
end tb_gpio_fsm;

architecture sim of tb_gpio_fsm is
    -- Parameters
    constant GPIO_NUM : integer := 8; -- Giảm xuống 8 để dễ quan sát simulation
    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal clk_in           : std_logic := '0';
    signal rstn_in          : std_logic := '0';
    signal gpio_request_in  : std_logic := '0';
    signal gpio_mask        : std_logic_vector(0 to GPIO_NUM - 1) := (others => '0');
    signal gpio_profile_in  : gpio_profile_array_t(0 to GPIO_NUM - 1) := (others => (others => '0'));
    signal gpio_out         : std_logic_vector(GPIO_NUM - 1 downto 0);
    signal gpio_state_done  : std_logic;

begin

    -- Unit Under Test (UUT)
    uut: entity work.gpio_fsm
        generic map (
            GPIO_NUM => GPIO_NUM
        )
        port map (
            clk_in          => clk_in,
            rstn_in         => rstn_in,
            gpio_request_in => gpio_request_in,
            gpio_mask       => gpio_mask,
            gpio_state_done => gpio_state_done,
            gpio_profile_in => gpio_profile_in,
            gpio_out        => gpio_out
        );

    -- Clock Generation
    clk_process : process
    begin
        clk_in <= '0';
        wait for CLK_PERIOD/2;
        clk_in <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -----------------------------------------------------------
        -- 1. Reset System
        -----------------------------------------------------------
        rstn_in <= '0';
        wait for 50 ns;
        rstn_in <= '1';
        wait for 20 ns;

        -----------------------------------------------------------
        -- 2. Configure Profiles
        -- Bit 31: Target State
        -- Bit 30-16: ON Delay (khi mask = '1')
        -- Bit 14-0: OFF Delay (khi mask = '0')
        -----------------------------------------------------------
        -- GPIO 0: Target = 1, ON Delay = 5 cycles
        gpio_profile_in(0) <= x"80050000"; 
        -- GPIO 1: Target = 0, ON Delay = 10 cycles
        gpio_profile_in(1) <= x"000A0000"; 
        -- GPIO 2: Target = 1, ON Delay = 2 cycles
        gpio_profile_in(2) <= x"80020000";

        wait for CLK_PERIOD;

        -----------------------------------------------------------
        -- 3. Trigger First Request (Mask set to '1' for some pins)
        -----------------------------------------------------------
        -- Set mask cho GPIO 0 và 1 lên '1'
        gpio_mask <= "00000011"; 
        gpio_request_in <= '1';
        wait for CLK_PERIOD;
        gpio_request_in <= '0';

        -- Chờ cho đến khi hoàn thành trạng thái (gpio_state_done = '1')
        -- Trong lúc này bạn sẽ thấy gpio_out thay đổi sau delay 5 và 10 cycles
        wait until falling_edge(clk_in) and (gpio_state_done = '1');
        wait for 100 ns;

        -----------------------------------------------------------
        -- 4. Trigger Second Request (Change Mask back to '0')
        -----------------------------------------------------------
        -- Đưa GPIO 0 về trạng thái 'OFF' (dựa trên bit 14-0 của profile)
        -- Lưu ý: Profile hiện tại bit 14-0 là 0, nên nó sẽ về trạng thái 'not bit 31' nhanh chóng
        gpio_mask <= "00000000";
        gpio_request_in <= '1';
        wait for CLK_PERIOD;
        gpio_request_in <= '0';

        wait until falling_edge(clk_in) and (gpio_state_done = '1');
        wait for 100 ns;

        -----------------------------------------------------------
        -- Finish Simulation
        -----------------------------------------------------------
        report "Simulation Finished Successfully";
        wait;
    end process;

end sim;
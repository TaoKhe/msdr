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
library ieee;
use ieee.std_logic_1164.all;

package gpio_types_pkg is
    type gpio_profile_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
end package gpio_types_pkg;

package body gpio_types_pkg is
end package body gpio_types_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gpio_types_pkg.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--Library xpm;
--use xpm.vcomponents.all;

entity gpio_fsm is
    generic(
        GPIO_NUM : integer := 64
    );
    port(
        clk_in              : in std_logic;
        rstn_in             : in std_logic;
        gpio_request_in     : in std_logic;
        --gpio_off          : in std_logic;
        gpio_mask           : in std_logic_vector(GPIO_NUM - 1 downto 0); -----the core changes state of the GPIO only which mask index is '1' .
        gpio_profile_in     : in gpio_profile_array_t(0 to GPIO_NUM - 1);
        gpio_state_done     : out std_logic;
        gpio_busy_out       : out std_logic;   -- 9/9/2026: '1' while a GPIO transition sequence is running (= gpio_change_reg)
        gpio_out            : out std_logic_vector(GPIO_NUM - 1 downto 0));
end gpio_fsm;

architecture behaviour of gpio_fsm is 
    signal gpio_change_reg : std_logic;
    --signal gpio_state_done : std_logic;
    signal gpio_on_counter: std_logic_vector(15 downto 0);
    --signal gpio_off_counter: integer range 0 to 65535 := 0;
    signal current_gpio_mask: std_logic_vector(GPIO_NUM - 1 downto 0);
    signal previous_gpio_mask: std_logic_vector( GPIO_NUM - 1 downto 0);
begin
    gpio_busy_out <= gpio_change_reg;
    gpio_latching_proc:process(clk_in)
    begin
        if(clk_in'event and clk_in = '1') then
            if(rstn_in = '0') then
                gpio_change_reg <= '0';
                current_gpio_mask <= (others => '0');
            else
                if(gpio_request_in = '1') and ((gpio_change_reg = '0'))then -----only accept the command  if TRX card is in stable state
                    gpio_change_reg <= '1';
                    current_gpio_mask <= gpio_mask;
                elsif(gpio_state_done = '1')then
                    gpio_change_reg <= '0';   
                    previous_gpio_mask <= current_gpio_mask;
                end if;
            end if;
        end if;
    end process;
    gpio_control_proc:process(clk_in)
    begin
        if(clk_in'event and clk_in = '1') then
            if(rstn_in = '0') then
                gpio_default_loop: for i in GPIO_NUM - 1 downto 0 loop
                    gpio_out(i)     <= not gpio_profile_in(i)(31) ;
                end loop;
                gpio_on_counter     <= (others => '0');
                --gpio_off_counter    <= 0;
            else
                if(gpio_change_reg = '1') then
                    gpio_on_counter <= gpio_on_counter + '1';
                    on_gpio_loop: for i in GPIO_NUM - 1 downto 0 loop
                        --if(previous_gpio_mask(i) /= current_gpio_mask(i)) then
                            if( current_gpio_mask(i) = '1') then
                                if(unsigned(gpio_on_counter) = unsigned('0' & gpio_profile_in(i)(30 downto 16)))then
                                    if( current_gpio_mask(i) = '1') then
                                        gpio_out(i)     <= gpio_profile_in(i)(31);
                                    end if;
                                end if;
                            else
                                if(unsigned(gpio_on_counter) = unsigned('0' & gpio_profile_in(i)(14 downto 0)))then
                                    if( current_gpio_mask(i) = '0') then
                                        gpio_out(i)     <= not gpio_profile_in(i)(31);
                                    end if;
                                end if;
                            end if;
                        --end if;
                    end loop;
                else
                    gpio_on_counter <= (others => '0'); 
                end if;
            end if;
        end if;
    end process;
--    process(all)
--        variable on_state   : std_logic := '1';
--        -- variable off_state   : std_logic := '1';
--    begin
--        on_state_loop: for i in 0 to GPIO_NUM - 1 loop
--            if( current_gpio_mask(i)) then
--                on_state := on_state and (gpio_out(i) xnor gpio_profile_in(i)(31));
--            else
--                on_state := on_state and (gpio_out(i) xor gpio_profile_in(i)(31));
--            end if;
--        end loop;
--        gpio_state_done <= on_state;
--    end process;
    process(clk_in)
        variable v_on_state : std_logic;
    begin
        if rising_edge(clk_in) then
            if rstn_in = '0' then
                gpio_state_done <= '0';
            else
                if(gpio_change_reg = '1') then
                    v_on_state := '1';
                    for i in 0 to GPIO_NUM - 1 loop
                        if (current_gpio_mask(i) = '1') then
                            v_on_state := v_on_state and (gpio_out(i) xnor gpio_profile_in(i)(31));
                        else
                            v_on_state := v_on_state and (gpio_out(i) xor gpio_profile_in(i)(31));
                        end if;
                    end loop;
                    gpio_state_done <= v_on_state; 
                else
                    gpio_state_done <= '0';
                end if;
            end if;
        end if;
    end process;
    
--    GPIO_ILA: ENTITY work.ila_3
--    PORT MAP(
--        clk => clk_in,
--        probe0(0) => gpio_request_in,
--        probe1 => current_gpio_mask,
--        probe2 => gpio_profile_in(0),
--        probe3 => gpio_on_counter,
--        probe4(0) => gpio_change_reg,
--        probe5(0) => gpio_state_done,
--        probe6 => gpio_out(7 downto 0),
--        probe7 => gpio_mask,
--        probe8 => gpio_profile_in(1),
--        probe9 => gpio_profile_in(2),
--        probe10 => gpio_profile_in(3),
--        probe11 => gpio_profile_in(4),
--        probe12 => gpio_profile_in(5),
--        probe13 => gpio_profile_in(6),
--        probe14 => gpio_profile_in(7),
--        probe15 => gpio_profile_in(8)      
--    );
    
    
end behaviour;

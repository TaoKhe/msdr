
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_interface is
    Port (
        clk         : in  std_logic; 
        rst         : in  std_logic; 
        start_read  : in  std_logic; -- 
        
       
        bram_addr   : out std_logic_vector(6 downto 0); 
        bram_dout   : in  std_logic_vector(31 downto 0);
        bram_en     : out std_logic; -- Enable BRAM
        
        done        : out std_logic;

        reg_out_0   : out std_logic_vector(31 downto 0);
        reg_out_47  : out std_logic_vector(31 downto 0) 
    );
end bram_interface;

architecture Behavioral of bram_interface is


    type reg_array_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal registers : reg_array_type := (others => (others => '0'));

    type state_type is (IDLE, READING, FINISH);
    signal state : state_type := IDLE;

    signal read_counter  : unsigned(6 downto 0) := (others => '0'); 
    signal write_counter : unsigned(6 downto 0) := (others => '0');
    signal valid_pipeline : std_logic := '0'; 

begin


    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                read_counter <= (others => '0');
                write_counter <= (others => '0');
                bram_en <= '0';
                bram_addr <= (others => '0');
                valid_pipeline <= '0';
                done <= '0';
            else
                case state is
                    
                    when IDLE =>
                        done <= '0';
                        read_counter <= (others => '0');
                        write_counter <= (others => '0');
                        valid_pipeline <= '0';
                        
                        if start_read = '1' then
                            state <= READING;
                            bram_en <= '1';
                        else
                            bram_en <= '0';
                        end if;


                    when READING =>

                        if read_counter < 64 then
                            bram_addr <= std_logic_vector(read_counter);
                            read_counter <= read_counter + 1;
                            valid_pipeline <= '1'; 
                        else
                            
                            bram_en <= '0'; 
                            valid_pipeline <= '0'; 
                        end if;
                        if valid_pipeline = '1' then
                            registers(to_integer(write_counter)) <= bram_dout;
                            write_counter <= write_counter + 1;
                        end if;

                        if write_counter = 64 then
                            state <= FINISH;
                        end if;


                    when FINISH =>
                        done <= '1';
                        bram_en <= '0';
                        if start_read = '0' then
                            state <= IDLE;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

    reg_out_0  <= registers(0);
    reg_out_47 <= registers(47);

end Behavioral;
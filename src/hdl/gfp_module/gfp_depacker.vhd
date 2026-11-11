----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2025 03:35:56 AM
-- Design Name: 
-- Module Name: gfp_packer - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gfp_depacker is
Port (
    gfp_clk_in                  : in std_logic;
    gfp_rstn_in                 : in std_logic;
    gfp_sink_data_in            : in std_logic_vector(7 downto 0);
    gfp_sink_valid_in           : in std_logic;
    gfp_sink_ready_out          : out std_logic;
   -- gfp_sink_last_in            : in std_logic;
    
    gfp_source_data_out        : out std_logic_vector(7 downto 0);
    gfp_source_valid_out       : out std_logic;
    gfp_source_ready_in        : in std_logic;
    gfp_source_last_out        : out std_logic
);
end gfp_depacker;

architecture Behavioral of gfp_depacker is
    constant HEADER_SIGNATURE : std_logic_vector(7 downto 0) := x"4E";
    component GFP_fifo_packetmode IS
    PORT (
        s_axis_aresetn : in std_logic;
        s_axis_aclk : in std_logic;
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;
        s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        s_axis_tlast : in std_logic;
        m_axis_tvalid : out std_logic;
        m_axis_tready: in std_logic;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_tlast : out std_logic;
        axis_wr_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        axis_rd_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    end component;


    signal gfp_sink_edge_valid : std_logic; 
    signal gfp_sink_valid_delay : std_logic;
    signal gfp_sink_last_delay : std_logic;
    signal gfp_sink_last : std_logic;
    signal crg_reg : std_logic_vector(7 downto 0); 
    --signal crc_out : std_logic_vector(7 downto 0); 
    signal header_checksum : std_logic_vector(7 downto 0);
    signal header_checksum_valid: std_logic;
    type gfp_state is (IDLE,PARSING_HEADER,HEADER_CHECKING, DATA_VALIDATION, DATA_DROPPING,OUT_DATA);
    signal current_state,next_state : gfp_state;

    signal header_valid : std_logic;
    signal header_valid_delay : std_logic;
    signal header_valid_delay1 : std_logic;
    signal header_valid_delay2 : std_logic;
    signal header_valid_delay3 : std_logic;

    signal fifo_write_enable: std_logic;
    signal fifo_read_enable: std_logic;
    signal gfp_fifo_data_out        : std_logic_vector(7 downto 0);
    signal gfp_fifo_valid_out       : std_logic;
    signal gfp_fifo_ready_in        : std_logic;
    signal gfp_fifo_last_out        : std_logic;

    signal packet_length            : std_logic_vector(15 downto 0);
    signal gfp_sample_counter       : std_logic_vector(15 downto 0);
    signal drop_invalid_sample      : std_logic;

begin
    gfp_sink_ready_out <= gfp_source_ready_in;
    process(gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1') then
            if(gfp_rstn_in = '0')then
                gfp_sink_edge_valid <= '0';
                gfp_sink_valid_delay <= '0';

            else
                gfp_sink_valid_delay    <= gfp_sink_valid_in;
                --gfp_sink_last_delay     <= gfp_sink_last;
                if(gfp_sink_valid_delay = '0') and (gfp_sink_valid_in = '1')then
                    gfp_sink_edge_valid <= '1';
                elsif(gfp_sink_last= '1')then
                    gfp_sink_edge_valid <= '0';
                end if;
--                if(gfp_source_ready_in = '1') then
--                    if(gfp_sink_valid_in = '1') then
--                        gfp_source_data_out <= gfp_sink_data_in;
--                        gfp_source_valid_out <= '1';
--                    elsif(gfp_sink_last_delay = '1') and (gfp_sink_valid_delay = '1')then
--                        gfp_source_data_out <= crg_reg;
--                        gfp_source_last_out  <= '1' ;            
--                    else
--                        gfp_source_valid_out     <= '0';
--                        gfp_source_last_out      <= '0';
--                    end if;
--                end if;
            end if;
        end if;
    end process;

    upper_fsm: process(current_state,gfp_sink_valid_in,gfp_sink_last,gfp_sink_last_delay,header_checksum_valid,gfp_sink_data_in)
    begin
        next_state <= current_state;
        case current_state is
            when IDLE =>
                if(gfp_sink_valid_in = '1') and (gfp_sink_data_in = HEADER_SIGNATURE) then
                    next_state <= HEADER_CHECKING;
                
                end if;
            when HEADER_CHECKING =>
                if(header_checksum_valid = '1') and (gfp_sink_valid_in = '1')  and  (header_checksum = gfp_sink_data_in) then
                    next_state <= DATA_VALIDATION;
                elsif(header_checksum_valid = '1') and (gfp_sink_valid_in = '1')  and  (header_checksum /= gfp_sink_data_in) then
                    next_state <= IDLE; 
                end if;    
            when DATA_VALIDATION =>
                if(gfp_sink_last = '1') and (gfp_sink_valid_in = '1') then
                     if(crg_reg = gfp_sink_data_in) then
                        next_state <= OUT_DATA;
                     end if;
                elsif(gfp_sink_last_delay = '1') and (gfp_sink_valid_in = '1') then
                    if(crg_reg = gfp_sink_data_in) then
                        next_state <= OUT_DATA;
                    else
                        next_state <= DATA_DROPPING;
                    end if;
                end if;
            when OUT_DATA => 
                if(gfp_sink_valid_in = '1') and (gfp_sink_data_in = HEADER_SIGNATURE) then
                    next_state <= HEADER_CHECKING;
                else
                    next_state <= IDLE;
                end if;
            when DATA_DROPPING =>
                if(gfp_sink_valid_in = '1') and (gfp_sink_data_in = HEADER_SIGNATURE) then
                    next_state <= HEADER_CHECKING;
                else
                    next_state <= IDLE;
                end if;
            when others =>
                next_state <= IDLE;
        end case;

    end process;

    lower_fsm: process(gfp_clk_in)
    begin 
        if(gfp_clk_in'event and gfp_clk_in = '1')then
            if(gfp_rstn_in = '0') then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    header_parsing_proc: process (gfp_clk_in)
    begin 
        if(gfp_clk_in'event and gfp_clk_in = '1')then
            if(gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1') then
                header_valid_delay      <=  header_valid;
                header_valid_delay1      <= header_valid_delay;     
                header_valid_delay2      <= header_valid_delay1;  
                header_valid_delay3      <= header_valid_delay2;  
                --header_checksum_valid    <= '0'; 
            end if;
            case current_state is
                when IDLE | OUT_DATA |  DATA_DROPPING =>
                    header_checksum <= HEADER_SIGNATURE;
                    header_valid    <= '0';
                    header_valid_delay <=  '0';
                    header_valid_delay1 <=  '0';
                    header_valid_delay2 <=  '0';
                    packet_length   <= (others => '0');
                    --header_checksum_valid    <= '0'; 
                when HEADER_CHECKING =>
                    if(gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1') then
                        header_valid <= '1';
                        header_checksum <= header_checksum + gfp_sink_data_in;
                    end if;
--                    if(header_valid_delay = '1') and (gfp_source_ready_in = '1')then
--                        header_checksum_valid <= '1';
--                    end if;
                    if(header_valid = '0') and (gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1')then
                        packet_length (15 downto 8) <= gfp_sink_data_in;
                    elsif(header_valid_delay = '0') and (gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1')then
                        packet_length (7 downto 0) <= gfp_sink_data_in;
                    end if;
                when others =>
                    NULL;
            end case;   
        end if;
    end process;
    header_checksum_valid <= header_valid_delay;

    drop_fifo_proc:process (gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1')then
            --if(gfp_sink_last = '1') and (gfp_sink_valid_in = '1') then
            --    if(crg_reg = gfp_sink_data_in) then
                if(current_state = DATA_VALIDATION) and (next_state = OUT_DATA) then
                    fifo_read_enable <= '1';
                elsif(current_state = DATA_VALIDATION) and (next_state = DATA_DROPPING) then
                    fifo_read_enable <= '0';
                elsif(gfp_fifo_last_out = '1') and (fifo_read_enable = '1') then
                    fifo_read_enable <= '0';
                end if;
            --end if;
        end if;
    end process;

    fifo_write_enable <= '1' when current_state = DATA_VALIDATION else '0';
    drop_invalid_sample <= '1' when  (current_state = IDLE) and  (gfp_sink_valid_in = '1') and (gfp_sink_data_in /= HEADER_SIGNATURE) else '0';
    tlast_proc: process(gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1') then
            if(gfp_rstn_in = '0') then
                gfp_sample_counter <= (others => '0');
            else
                if(current_state = IDLE) or (current_state = HEADER_CHECKING) then
                    gfp_sample_counter <= x"0000";
                    gfp_sink_last       <= '0';     
                    gfp_sink_last_delay <= '0'; 
                elsif(current_state = DATA_VALIDATION) then
                    gfp_sink_last_delay <= gfp_sink_last;
                    if(gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1')then
 
                        if(gfp_sample_counter = packet_length - x"0001") then
                            gfp_sink_last <= '1';
                            gfp_sample_counter <= (others => '0');
                        else
                            gfp_sink_last <= '0';
                            gfp_sample_counter <= gfp_sample_counter + '1';
                        end if;
                    --else
                    --    gfp_sink_last <= '0';
                    end if;    
                end if;    
            end if;
        end if;
    end process;

-- CRC polynomial coefficients: x^8 + x^2 + x + 1
--                              0x7 (hex)
-- CRC width:                   8 bits
-- CRC shift direction:         left (big endian)
-- Input word width:            8 bits

    crc_cal_proc: process(gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1') then
            if(gfp_rstn_in = '0') or (next_state = HEADER_CHECKING)then
                crg_reg <= (others => '0'); 
            else
                if(gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1') and (header_valid_delay1 = '1')  then
                    crg_reg(0) <= crg_reg(0) xor crg_reg(6) xor crg_reg(7) xor gfp_sink_data_in(0) xor gfp_sink_data_in(6) xor gfp_sink_data_in(7);
                    crg_reg(1) <= crg_reg(0) xor crg_reg(1) xor crg_reg(6) xor gfp_sink_data_in(0) xor gfp_sink_data_in(1) xor gfp_sink_data_in(6);
                    crg_reg(2) <= crg_reg(0) xor crg_reg(1) xor crg_reg(2) xor crg_reg(6) xor gfp_sink_data_in(0) xor gfp_sink_data_in(1) xor gfp_sink_data_in(2) xor gfp_sink_data_in(6);
                    crg_reg(3) <= crg_reg(1) xor crg_reg(2) xor crg_reg(3) xor crg_reg(7) xor gfp_sink_data_in(1) xor gfp_sink_data_in(2) xor gfp_sink_data_in(3) xor gfp_sink_data_in(7);
                    crg_reg(4) <= crg_reg(2) xor crg_reg(3) xor crg_reg(4) xor gfp_sink_data_in(2) xor gfp_sink_data_in(3) xor gfp_sink_data_in(4);
                    crg_reg(5) <= crg_reg(3) xor crg_reg(4) xor crg_reg(5) xor gfp_sink_data_in(3) xor gfp_sink_data_in(4) xor gfp_sink_data_in(5);
                    crg_reg(6) <= crg_reg(4) xor crg_reg(5) xor crg_reg(6) xor gfp_sink_data_in(4) xor gfp_sink_data_in(5) xor gfp_sink_data_in(6);
                    crg_reg(7) <= crg_reg(5) xor crg_reg(6) xor crg_reg(7) xor gfp_sink_data_in(5) xor gfp_sink_data_in(6) xor gfp_sink_data_in(7);
                end if;
            end if;
        end if;
    end process;

    GFP_DROP_FIFO: GFP_fifo_packetmode 
    PORT MAP(
        s_axis_aresetn => gfp_rstn_in,
        s_axis_aclk    => gfp_clk_in,
        s_axis_tvalid => gfp_sink_valid_in,
        s_axis_tready => open,
        s_axis_tdata => gfp_sink_data_in,
        s_axis_tlast => gfp_sink_last or drop_invalid_sample,
        m_axis_tvalid => gfp_fifo_valid_out,
        m_axis_tready => gfp_fifo_ready_in,
        m_axis_tlast => gfp_fifo_last_out,
        m_axis_tdata => gfp_fifo_data_out
    );

    gfp_source_data_out        <= gfp_fifo_data_out;
    gfp_source_valid_out       <= gfp_fifo_valid_out and fifo_read_enable;
    gfp_fifo_ready_in          <= gfp_source_ready_in;
    gfp_source_last_out        <= gfp_fifo_last_out;



end Behavioral;

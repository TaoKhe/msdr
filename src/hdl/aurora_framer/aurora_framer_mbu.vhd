----------------------------------------------------------------------------------
-- Company:  Eurotek
-- Engineer: 
-- 
-- Create Date: 25.04.2025 10:31:03
-- Design Name: 
-- Module Name: Aurora_Embedder - Behavioral
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;
Library xpm;
use xpm.vcomponents.all;
entity aurora_framer_mbu is
    Port (  Aurora_data_out             : out std_logic_vector (63 downto 0);
            Aurora_last_out             : out std_logic;
            Aurora_keep_out             : out std_logic_vector(7 downto 0);
            Aurora_valid_out            : out std_logic;
            Aurora_rdy_in               : in std_logic;
            Aurora_clk_in               : in std_logic;
            Aurora_rst_in               : in std_logic;
            
            GFP_data_in                 : in std_logic_vector(7 downto 0);
            GFP_valid_in                : in std_logic;
            GFP_ready_out               : out std_logic;
            GFP_last_in                 : in std_logic;
            
            Pointer                     : in std_logic_vector (2 downto 0);
            Sample_IQ                   : in std_logic_vector (31 downto 0);
            Sample_IQ_valid             : in std_logic;
            Sample_IQ_ready             : out std_logic;
            
            Frame_Length                : in std_logic_vector (47 downto 0);
            Tx_freq                     : in std_logic_vector (47 downto 0);
            Rx_freq                     : in std_logic_vector (47 downto 0);
            Next_Frame_Transmit_Time    : in std_logic_vector (26 downto 0);
            Power_Tx                    : in std_logic_vector (7 downto 0);
            Rx_bw                       : in std_logic_vector (7 downto 0);
            Tx_bw                       : in std_logic_vector (7 downto 0);
            Next_Frame_Receive_Time     : in std_logic_vector (26 downto 0);
            Second_from_2000            : in std_logic_vector (39 downto 0);
            Subsecond                   : in std_logic_vector (26 downto 0);
            
            init_clk_i                  : in std_logic;
            
            Sample_clk                  : in std_logic;
            Sample_rst_out              : out std_logic);
    end aurora_framer_mbu;

architecture Behavioral of aurora_framer_mbu is
--    component fifo_IQ IS
--      PORT (
--       -- srst : IN STD_LOGIC;
--        wr_clk : IN STD_LOGIC;
--        rd_clk : IN STD_LOGIC;
--        din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--        wr_en : IN STD_LOGIC;
--        rd_en : IN STD_LOGIC;
--        dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
--        rd_data_count   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
--        wr_data_count   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
--        full : OUT STD_LOGIC;
--        empty : OUT STD_LOGIC
--        --wr_rst_busy : OUT STD_LOGIC;
--        --rd_rst_busy : OUT STD_LOGIC
--      );
--    END component fifo_IQ;
    component IQ_stream_FIFO IS
    PORT (
        s_axis_aresetn : in std_logic;
        s_axis_aclk : in std_logic;
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;
        s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        m_axis_aclk : in std_logic;
        m_axis_tvalid : out std_logic;
        m_axis_tready: in std_logic;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        axis_wr_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        axis_rd_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END component IQ_stream_FIFO;
    
    component GFP_fifo_0 IS
    PORT (
        s_axis_aresetn : in std_logic;
        s_axis_aclk : in std_logic;
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;
        s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_aclk : in std_logic;
        m_axis_tvalid : out std_logic;
        m_axis_tready: in std_logic;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        axis_wr_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        axis_rd_data_count: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END component GFP_fifo_0;
    signal  word_40                     : integer;-- range 0 to 39 := 0;
    signal  wp                          : std_logic_vector (3 downto 0) := (others => '0');
    signal  fs                          : std_logic := '0';
    signal  tl                          : std_logic := '0';
    signal  TBD                         : std_logic_vector (7 downto 0) := (others => '0');
    signal  GFP_SIGNATURE               : std_logic_vector (7 downto 0) := x"AA";
    signal  Sample_Fifo_din             : std_logic_vector (63 downto 0) := (others => '0');
    signal  Sample_Fifo_highword         : std_logic_vector (31 downto 0) := (others => '0');
    signal  Sample_Fifo_full            : std_logic := '0';
    signal  Sample_Fifo_re              : std_logic := '0';
    signal  Sample_Fifo_re_dly          : std_logic := '0';
    signal  Sample_Fifo_re_dly1         : std_logic := '0';
    signal  Sample_Fifo_high            : std_logic;
    signal  Sample_Fifo_we              : std_logic := '0';
    signal  Sample_Fifo_almost_full     : std_logic := '0';
    signal  Sample_Fifo_empty           : std_logic := '0';
    signal  Sample_Fifo_almost_empty    : std_logic := '0';
    signal  Sample_Fifo_valid           : std_logic := '0';
    signal  Sample_Fifo_rd_data_count   : std_logic_vector (3 downto 0) := (others => '0');
    signal  Sample_Fifo_wr_rst_busy     : std_logic := '0';
    signal  Sample_Fifo_rd_rst_busy     : std_logic := '0';
    signal  Sample_Fifo_dout            : std_logic_vector (63 downto 0) := (others => '0');
    signal  Sample_rst_in               : std_logic;
    signal  latch_data_en               : std_logic;
    type    shift_reg is array (31 downto 0) of std_logic_vector (63 downto 0);
    signal  sample_delay                : shift_reg;
    signal latch_data_counter           : integer range 0 to 31;
    signal load_data_counter            : integer range 0 to 31;
    signal rd_data_count   :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wr_data_count   :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal read_trigger,read_trigger_sync,enable_frame : std_logic;
    signal sample_counter : std_logic_vector (47 downto 0);
    signal iq_sample_inframe : std_logic;
    signal packet_counter : integer := 0;
    signal packet_total_counter : integer := 0;
    signal word_in_packet : integer range 0 to 10;
    signal fifo_ready : std_logic;
    signal fifo_valid : std_logic;
    signal first_section : std_logic;
-------------------------GFP Port-------------------------------------------------------------------

    signal GFP_fifo_source_data        : std_logic_vector(7 downto 0);
    signal GFP_fifo_source_valid       : std_logic;
    signal GFP_fifo_source_ready       : std_logic;
    signal GFP_fifo_source_last        : std_logic;    
    
    signal GFP_fifo_sink_data        : std_logic_vector(7 downto 0);
    signal GFP_fifo_sink_valid       : std_logic;
    signal GFP_fifo_sink_ready       : std_logic;
    signal GFP_fifo_sink_last        : std_logic;      
    signal GFP_fifo_read_counter     : std_logic_vector(31 downto 0);
    signal GFP_fifo_write_counter    : std_logic_vector(31 downto 0);
    signal GFP1        : std_logic_vector(7 downto 0);
    signal GFP2        : std_logic_vector(7 downto 0);
    signal GFP3        : std_logic_vector(7 downto 0);

begin
--Sample_IQ_ready <=  (not Sample_Fifo_full) and Aurora_rdy_in;
Sample_IQ_ready <= fifo_ready;
read_trigger <= '1' when wr_data_count >= x"000000010" else '0';
Aurora_keep_out <= x"ff";
Sample_Fifo_re_dly1 <= fifo_valid and Sample_Fifo_re;
Sample_Fifo_empty <= not fifo_valid;
--read_trigger_inst : xpm_cdc_pulse
--   generic map (
--      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 1,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      REG_OUTPUT => 1,     -- DECIMAL; 0=disable registered output, 1=enable registered output
--      RST_USED => 0,       -- DECIMAL; 0=no reset, 1=implement reset
--      SIM_ASSERT_CHK => 1  -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
--   )
--   port map (
--      dest_pulse => read_trigger_sync, 
--      dest_clk => Aurora_clk_in,    
--      dest_rst => Aurora_rst_in,    
--      src_clk => Sample_rst_in,       
--      src_pulse => Sample_clk,   
--      src_rst => read_trigger    
--   );
read_trigger_inst : xpm_cdc_single
generic map (
    DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
    INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
)
port map (
    dest_out => read_trigger_sync, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

    dest_clk => Aurora_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
    src_clk => Sample_clk,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
    src_in => read_trigger      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
);

process(Sample_clk)
    begin
        if rising_edge(Sample_clk) then
            if(Sample_rst_in = '1') then
                Sample_Fifo_we <= '0';
                Sample_Fifo_high <= '1';
            --elsif (Sample_IQ_valid = '1') and ( Sample_Fifo_full = '0') then
            elsif (Sample_IQ_valid = '1') and ( fifo_ready = '1') then
                if(Sample_Fifo_high = '1')then
                    Sample_Fifo_highword <= Sample_IQ;
                    Sample_Fifo_we <=  '0';
                else
                Sample_Fifo_we <=  '1';
                Sample_Fifo_din <=  Sample_IQ & Sample_Fifo_highword;  
                end if;
                Sample_Fifo_high <= not Sample_Fifo_high;
            else
                Sample_Fifo_we <= '0';
            end if;
        end if;
    end process;
    
Sample_rst_in_cdc : xpm_cdc_single
generic map (
    DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
    INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
)
port map (
    dest_out => Sample_rst_in, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

    dest_clk => Sample_clk, -- 1-bit input: Clock signal for the destination clock domain.
    src_clk => Aurora_clk_in,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
    src_in => Aurora_rst_in      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
);
    Sample_rst_out <= Sample_rst_in;
    IQ_FIFO: IQ_stream_FIFO 
    PORT MAP(
        s_axis_aresetn => not Sample_rst_in,
        s_axis_aclk => Sample_clk,
        s_axis_tvalid => Sample_Fifo_we,
        s_axis_tready => fifo_ready,
        s_axis_tdata => Sample_Fifo_din,
        m_axis_aclk => Aurora_clk_in,
        m_axis_tvalid => fifo_valid,
        m_axis_tready => Sample_Fifo_re,
        m_axis_tdata => Sample_Fifo_dout,
        axis_wr_data_count => wr_data_count,
        axis_rd_data_count => rd_data_count
    );
    GFP_FIFO_INS: GFP_fifo_0
    PORT MAP(
        s_axis_aresetn        => '1',
        s_axis_aclk           => init_clk_i,
        s_axis_tvalid         => GFP_valid_in,
        s_axis_tready         => GFP_ready_out,
        s_axis_tdata          => GFP_data_in,
        m_axis_aclk           => Aurora_clk_in,
        m_axis_tvalid         => GFP_fifo_sink_valid,
        m_axis_tready         => GFP_fifo_sink_ready,
        m_axis_tdata          => GFP_fifo_sink_data,
        axis_wr_data_count    => GFP_fifo_write_counter,
        axis_rd_data_count    => GFP_fifo_read_counter
    );
    
--    ASYNC_FIFO: fifo_IQ 
--      PORT MAP(
--       -- srst => Aurora_rst_in,
--        wr_clk => Sample_clk,
--        rd_clk => Aurora_clk_in,
--        din => Sample_Fifo_din,
--        wr_en => Sample_Fifo_we,
--        rd_en => Sample_Fifo_re,
--        dout => Sample_Fifo_dout,
--        full => Sample_Fifo_full,
--        empty => Sample_Fifo_empty,
--        rd_data_count => rd_data_count,
--        wr_data_count => wr_data_count
--        --wr_rst_busy => Sample_Fifo_wr_rst_busy,
--        --rd_rst_busy => Sample_Fifo_rd_rst_busy
--      );   
    --fs <= '1' when word_40 = 3 else '0'   ;
    
    GFP_fifo_sink_ready <= '1' when (word_in_packet = 1) or ((word_in_packet = 2) and (packet_counter >= 5) and (packet_counter /= 216)and (packet_counter /= 217)) or ((word_in_packet = 3) and (packet_counter >= 5)and (packet_counter /= 216)and (packet_counter /= 217)) else '0'; 
    SFP_proc:process(Aurora_clk_in)
    begin
        if rising_edge(Aurora_clk_in) then
            if(Aurora_rst_in = '1')then
                GFP1    <= (others => '0'); 
                GFP2    <= (others => '0'); 
                GFP3    <= (others => '0'); 
            else
                if(word_in_packet = 1) then
                    if(GFP_fifo_sink_valid) then
                        GFP1 <= GFP_fifo_sink_data;
                    else
                        GFP1 <= x"FF";
                    end if;
                elsif(word_in_packet = 2) then
                    if(packet_counter >= 5)then
                        if(GFP_fifo_sink_valid) then
                            GFP2 <= GFP_fifo_sink_data;
                        else
                            GFP2 <= x"FF";
                        end if;
                    end if;
                elsif(word_in_packet = 3) then
                    if(packet_counter >= 5)then
                        if(GFP_fifo_sink_valid) then
                            GFP3 <= GFP_fifo_sink_data;
                        else
                            
                            GFP3 <= x"FF";
                        end if;
                    end if;
            end if;
            end if;
        end if;
    end process;
    process(Aurora_clk_in)
        begin
            if rising_edge(Aurora_clk_in) then
                if(Aurora_rst_in = '1')then
                    Aurora_valid_out  <= '0';
                    word_40         <= 0;
                    Sample_Fifo_re  <= '0';
                    Aurora_data_out <= (others =>'0');
                    wp              <= (others => '0');
                    latch_data_en   <= '0';
                    --sample_delay    <= (others => (others => '0'));
                    latch_data_counter <= 0;
                    Sample_Fifo_re_dly  <= '0';
                    --Sample_Fifo_re_dly1 <= '0';
                    load_data_counter   <= 0;
                    enable_frame <= '0';
                    word_in_packet <= 0;
                    packet_counter <= 0;
                    first_section <= '1';
                else
                    if(read_trigger_sync = '1')then
                        enable_frame <= '1';
                        first_section <= '1';
                    end if;
                    if(enable_frame = '1') then 
                        --Sample_Fifo_re_dly <= Sample_Fifo_re;
                        --Sample_Fifo_re_dly1 <= Sample_Fifo_re_dly;
                        if(Sample_Fifo_re_dly1  = '1') and ((latch_data_en = '1')or(Aurora_rdy_in = '0') or (word_in_packet = 0))then
                            latch_data_en <= '1';
                            sample_delay(latch_data_counter) <= Sample_Fifo_dout;
                            latch_data_counter <= latch_data_counter + 1;
                        end if;
                        if (Aurora_rdy_in = '1')  then
                            if(Frame_Length /= x"ffffffffffff")then
                                if(iq_sample_inframe = '1') then
                                    if(sample_counter >= Frame_Length - '1') then
                                        Aurora_last_out <= '1';
                                        word_40         <= 0;
                                        wp              <= (others => '0');
                                        sample_counter  <= (others => '0');
                                        packet_counter  <= 0;
                                        word_in_packet  <= 0;
                                        enable_frame    <= '0';
                                    else
                                        sample_counter  <= sample_counter + '1';
                                        Aurora_last_out <= '0';
                                    end if;
                                end if;
                            else
                                Aurora_last_out <= '0';
                            end if;
                            --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1') or (word_in_packet = 0))) then
                            --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1'))) then
                            if(Sample_Fifo_empty = '0')then
                                Aurora_valid_out <= '1';
                                case word_in_packet is 
                                    when 0 => 
                                        Sample_Fifo_re <= '1';
                                        word_in_packet <= 1;
                                        --if(packet_counter = 218) then
                                        --    Aurora_data_out (63 downto 48) <= x"8" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP_SIGNATURE;
                                        --else
                                        --    Aurora_data_out (63 downto 48) <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4))& GFP_SIGNATURE;
                                        --end if;
                                        if(first_section = '1') then
                                            case packet_counter is
                                                when 0  => --if(packet_counter = 218) then
                                                        --     Aurora_data_out <= x"8" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Rx_bw & x"00" & "00000" & Next_Frame_Receive_Time;
                                                        --else
                                                                Aurora_data_out <=  x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP_SIGNATURE & Frame_Length;
                                                        --end if;
                                                when 1  => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Tx_freq;
                                                when 2  => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Rx_freq;
                                                when 3  => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Tx_bw & Power_Tx & "00000" & Next_Frame_Transmit_Time;
                                                when 4  => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Rx_bw & x"00" & "00000" & Next_Frame_Receive_Time;
                                                when 5  => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & x"00" & Second_from_2000;
                                                when others  => 
                                                    Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & GFP2 & GFP3 & "00000" & Subsecond;
                                                    first_section <= '0';
                                            end case; 
                                        else
                                        if(packet_counter = 217) then
                                                Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Rx_freq;
                                        elsif(packet_counter = 218) then
                                                Aurora_data_out <= x"8" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & Rx_bw & x"00" & "00000" & Next_Frame_Receive_Time;
                                        else
                                                Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet,4)) & GFP1 & GFP2 & GFP3 & "00000" & Subsecond; 
                                        end if;
                                            Aurora_data_out (47 downto 0) <= GFP2 & GFP3 & "00000" & Subsecond;
                                        end if;
                                    when  1 =>
                                        word_in_packet <= 2;
                                        iq_sample_inframe <= '1';
                                        if(load_data_counter < latch_data_counter)then
                                            Aurora_data_out <= sample_delay(load_data_counter); 
                                            load_data_counter <= load_data_counter + 1;
                                        else
                                            load_data_counter <= 0;
                                            latch_data_counter <= 0;
                                            Aurora_data_out <= Sample_Fifo_dout; 
                                            latch_data_en <= '0';
                                        end if;  
                                        Sample_Fifo_re <= '1';
                                    when  2 =>
                                        word_in_packet <= 3;
                                        iq_sample_inframe <= '1';
                                        if(load_data_counter < latch_data_counter)then
                                            Aurora_data_out <= sample_delay(load_data_counter); 
                                            load_data_counter <= load_data_counter + 1;
                                        else
                                            load_data_counter <= 0;
                                            latch_data_counter <= 0;
                                            Aurora_data_out <= Sample_Fifo_dout; 
                                            latch_data_en <= '0';
                                        end if;  
                                        Sample_Fifo_re <= '1'; 
                                    when  3 =>
                                        word_in_packet <= 4;
                                        iq_sample_inframe <= '1';
                                        if(load_data_counter < latch_data_counter)then
                                            Aurora_data_out <= sample_delay(load_data_counter); 
                                            load_data_counter <= load_data_counter + 1;
                                        else
                                            load_data_counter <= 0;
                                            latch_data_counter <= 0;
                                            Aurora_data_out <= Sample_Fifo_dout; 
                                            latch_data_en <= '0';
                                        end if;  
                                        Sample_Fifo_re <= '1'; 
                                    when  4 =>
                                        --if(packet_counter >= 200) and ((packet_counter <= 217)) then
                                        if(packet_counter = 218)  then
                                            word_in_packet <= 0;
                                            Sample_Fifo_re <= '0';
                                            if(packet_counter = 218) then
                                                packet_counter <= 0;
                                            else
                                                packet_counter  <= packet_counter + 1;
                                            end if;
                                            packet_total_counter <= packet_total_counter + 1;
                                        else
                                            word_in_packet <= 5;
                                            Sample_Fifo_re <= '1';
                                        end if;
                                        iq_sample_inframe <= '1';
                                        if(load_data_counter < latch_data_counter)then
                                            Aurora_data_out <= sample_delay(load_data_counter); 
                                            load_data_counter <= load_data_counter + 1;
                                        else
                                            load_data_counter <= 0;
                                            latch_data_counter <= 0;
                                            Aurora_data_out <= Sample_Fifo_dout; 
                                            latch_data_en <= '0';
                                        end if;  
                                        
                                    when  5 =>
                                        word_in_packet <= 0;
                                        Sample_Fifo_re <= '0';
                                        packet_counter  <= packet_counter + 1;
                                        packet_total_counter <= packet_total_counter + 1;
                                        iq_sample_inframe <= '1';
                                        if(load_data_counter < latch_data_counter)then
                                            Aurora_data_out <= sample_delay(load_data_counter); 
                                            load_data_counter <= load_data_counter + 1;
                                        else
                                            load_data_counter <= 0;
                                            latch_data_counter <= 0;
                                            Aurora_data_out <= Sample_Fifo_dout; 
                                            latch_data_en <= '0';
                                        end if;  
                                        --Sample_Fifo_re <= '1';                  
                                    when others => null;
                                end case;
                            else
                                Aurora_valid_out <= '0';
                                Sample_Fifo_re <= '0';
                            end if;
                        else
                            Sample_Fifo_re <= '0';
                        end if;
                    end if;
                end if;
            end if;
    end process;
    
end Behavioral;

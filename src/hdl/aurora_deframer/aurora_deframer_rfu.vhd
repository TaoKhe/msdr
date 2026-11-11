----------------------------------------------------------------------------------
-- Company: Eurotek
-- Engineer: 
-- 
-- Create Date: 30.04.2025 18:56:39
-- Design Name: 
-- Module Name: Aurora_DeEmbedder - Behavioral
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
entity aurora_deframer_rfu is
    Port(  
        Aurora_data_in              : in  STD_LOGIC_VECTOR (63 downto 0);
        Aurora_keep_in              : in  STD_LOGIC_VECTOR (7 downto 0);
        Aurora_valid_in             : in  STD_LOGIC;
        Aurora_last_in              : in  STD_LOGIC;
        Sample_IQ                   : out STD_LOGIC_VECTOR (31 downto 0);
        Sample_IQ_valid             : out STD_LOGIC;
        Aurora_clk_in               : in  STD_LOGIC;
        Aurora_rst_in               : in std_logic;
        Sample_clk_in               : in  STD_LOGIC;
        LOCKED                      : out STD_LOGIC;
        Pointer                     : out std_logic_vector (2 downto 0);
        Frame_Length                : out std_logic_vector (47 downto 0);
        Tx_freq                     : out std_logic_vector (47 downto 0);
        Rx_freq                     : out std_logic_vector (47 downto 0);
        Next_Frame_Transmit_Time    : out std_logic_vector (26 downto 0);
        Power_Tx                    : out std_logic_vector (7 downto 0);
        Rx_bw                       : out std_logic_vector (7 downto 0);
        Tx_bw                       : out std_logic_vector (7 downto 0);
        Next_Frame_Receive_Time     : out std_logic_vector (26 downto 0);
        Second_from_2000            : out std_logic_vector (39 downto 0);
        Subsecond                   : out std_logic_vector (26 downto 0);
        
        GFP_data_out                : out std_logic_vector(7 downto 0);
        GFP_valid_out               : out std_logic
     );
end aurora_deframer_rfu;

architecture Behavioral of aurora_deframer_rfu is
    Constant JITTER_IGNORE : integer := 16; 
--    component fifo_IQ IS
--          PORT (
--            --srst : IN STD_LOGIC;
--            wr_clk : IN STD_LOGIC;
--            rd_clk : IN STD_LOGIC;
--            din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--            wr_en : IN STD_LOGIC;
--            rd_en : IN STD_LOGIC;
--            dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
--            full : OUT STD_LOGIC;
--            empty : OUT STD_LOGIC
--            --wr_rst_busy : OUT STD_LOGIC;
--            --rd_rst_busy : OUT STD_LOGIC
--     );
--     end component;
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
    end component;
    
    
    component IQ_conver_width is 
        port(
          aclk : in std_logic;
          aresetn : in std_logic;
          s_axis_tvalid : in std_logic;
          s_axis_tready : out std_logic;
          s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
          m_axis_tvalid : out std_logic;
          m_axis_tready : in std_logic;
          m_axis_tdata : out STD_LOGIC_VECTOR(31 DOWNTO 0)
       );
    end component;
    
    signal  word_40                     : integer range 0 to 39 := 0;
    signal  wp                          : std_logic_vector (2 downto 0) := (others => '0');
    signal  fs                          : std_logic := '0';
    signal  tl                          : std_logic := '0';
    signal  TBD                         : std_logic_vector (7 downto 0) := (others => '0');
    signal  GFP_SIGNATURE               : std_logic_vector (7 downto 0) := x"AA";  
    signal  Sample_Fifo_din             : std_logic_vector (63 downto 0) := (others => '0');
    signal  Sample_Fifo_full            : std_logic := '0';
    signal  Sample_Fifo_re              : std_logic := '0';
    signal  Sample_Fifo_we              : std_logic := '0';
    signal  Sample_Fifo_almost_full     : std_logic := '0';
    signal  Sample_Fifo_empty           : std_logic := '0';
    signal  Sample_Fifo_almost_empty    : std_logic := '0';
    signal  Sample_Fifo_valid           : std_logic := '0';
    signal  Sample_Fifo_wr_data_count   : std_logic_vector (3 downto 0) := (others => '0');
    signal  Sample_Fifo_wr_rst_busy     : std_logic := '0';
    signal  Sample_Fifo_rd_rst_busy     : std_logic := '0';
    signal  Sample_Fifo_dout            : std_logic_vector (63 downto 0) := (others => '0');
    signal  LOCKEDs,LOCKEDs_sync                     : std_logic := '0';   
    signal  Sample_rst_in               : std_logic;
    signal  Sample_I1                   :  STD_LOGIC_VECTOR (15 downto 0);
    signal  Sample_Q1                   :  STD_LOGIC_VECTOR (15 downto 0);
    signal  Sample_I0                   :  STD_LOGIC_VECTOR (15 downto 0);
    signal  Sample_Q0                   :  STD_LOGIC_VECTOR (15 downto 0);
    signal  Sample_IQ0                  :  STD_LOGIC_VECTOR (31 downto 0);
    
    signal  Sample_IQ_high,Sample_IQ_rate_matching    :  std_logic := '0';    
    signal  Sample_Fifo_re_dly,Sample_Fifo_re_dly1,Sample_Fifo_re_dly2 : std_logic;
    signal  Sample_IQ_delay : std_logic_vector(31 downto 0);
    signal  miss_order : std_logic := '0';
    signal sample_counter : std_logic_vector (47 downto 0);
    signal iq_sample_inframe : std_logic;
    signal packet_counter : integer := 0;
    signal word_in_packet : integer range 0 to 10;
    signal fifo_ready : std_logic;
    signal fifo_ready_dly,LOCKEDs_dly: std_logic_vector(128 downto 0);
    signal fifo_valid,fifo_valid_dly : std_logic;
    signal wr_data_count : std_logic_vector (31 downto 0);
    signal rd_data_count : std_logic_vector (31 downto 0);
    signal read_trigger,read_trigger_sync,enable_frame,enable_frame_dly : std_logic;
    signal first_section : std_logic;
    signal packet_total_counter : integer := 0;
    signal GFP1        : std_logic_vector(7 downto 0);
    signal GFP2        : std_logic_vector(7 downto 0);
    signal GFP3        : std_logic_vector(7 downto 0);
begin
    LOCKED <= LOCKEDs;
    read_trigger <= '1' when wr_data_count >= JITTER_IGNORE else '0';
    
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
          dest_clk => Sample_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
          src_clk => Aurora_clk_in,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
          src_in => read_trigger      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
       );
       
     locked_trigger_inst : xpm_cdc_single
       generic map (
          DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
          INIT_SYNC_FF => 1,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
          SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
          SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
       )
       port map (
          dest_out => LOCKEDs_sync, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                                -- is registered.
          dest_clk => Sample_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
          src_clk => Aurora_clk_in,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
          src_in => LOCKEDs      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
       );
    DeEmbed_proc : process(Aurora_clk_in)
        begin
            if rising_edge(Aurora_clk_in) then
                if(Aurora_rst_in = '1')then
                    word_40 <= 0;
                    LOCKEDs <= '0';
                    Frame_Length <= (others => '0');
                    Pointer <= (others => '0');
                    Tx_freq <= (others => '0');
                    Rx_freq <= (others => '0');
                    Power_Tx <= (others => '0');
                    Next_Frame_Transmit_Time <= (others => '0');
                    Rx_bw <= (others => '0');
                    Tx_bw <= (others => '0');
                    Next_Frame_Receive_Time <= (others => '0');
                    Second_from_2000 <= (others => '0');
                    Subsecond <= (others => '0');
                    packet_counter <= 0;
                    word_in_packet <= 0;
                    first_section <= '1';
                    packet_total_counter <= 0;
                elsif (Aurora_valid_in = '1') then
--                    if (word_in_packet = 0) and (packet_counter = 0)  then
--                        if (Aurora_data_in(63 downto 48) = x"A" & x"0" & GFP) then 
--                            LOCKEDs                 <= '1';
--                            Frame_Length            <= Aurora_data_in (47 downto 0);
--                            Pointer                 <= Aurora_data_in (58 downto 56);
--                            word_in_packet          <= 0;
--                            packet_counter          <= 0;
--                        else
--                            word_in_packet          <= 0;
--                            packet_counter          <= 0;
--                        end if;
----                    els
                    if (LOCKEDs = '0') and (Aurora_data_in(63 downto 48) = x"A" & x"0" & GFP_SIGNATURE) then
                        Frame_Length                <= Aurora_data_in (47 downto 0);
                        Pointer                     <= Aurora_data_in (58 downto 56);
                        LOCKEDs                     <= '1';
                        word_in_packet              <= 1;
                        packet_counter              <= 0;
                        packet_total_counter        <= 0;
                    else
                        if(LOCKEDs = '1')then 
                            if(Aurora_last_in = '1') then
                                    packet_counter <= 0;
                                    word_in_packet <= 0;
                                    LOCKEDs <= '0';
                            end if;
                            case word_in_packet is 
                                when 0 => 
                                    word_in_packet           <= 1;
                                    if(first_section = '1') then
                                        case packet_counter is
                                            when 0   =>
                                                  Frame_Length             <= Aurora_data_in (47 downto 0);
                                                  Pointer                  <= Aurora_data_in (58 downto 56);
                                            when 1   =>
                                                  GFP1                     <= Aurora_data_in (55 downto 48);
                                                  Tx_freq                  <= Aurora_data_in (47 downto 0);
                                                  Pointer                  <= Aurora_data_in (58 downto 56);
                                            when 2  => 
                                                  GFP1                     <= Aurora_data_in (55 downto 48);
                                                  Rx_freq                  <= Aurora_data_in (47 downto 0);
                                                  Pointer                  <= Aurora_data_in (58 downto 56);
                                            when 3  => 
                                                  GFP1                     <= Aurora_data_in (55 downto 48);
                                                  Power_Tx                 <= Aurora_data_in (39 downto 32);
                                                  Next_Frame_Transmit_Time <= Aurora_data_in (26 downto 0);
                                                  Pointer                  <= Aurora_data_in (58 downto 56);
                                            when 4  => 
                                                 GFP1                     <= Aurora_data_in (55 downto 48);
                                                 Rx_bw                    <= Aurora_data_in (47 downto 40);
                                                 Tx_bw                    <= Aurora_data_in (39 downto 32);
                                                 Next_Frame_Receive_Time  <= Aurora_data_in (26 downto 0);
                                                 Pointer                  <= Aurora_data_in (58 downto 56);
                                            when 5  => 
                                                GFP1                     <= Aurora_data_in (55 downto 48);
                                                Second_from_2000         <= Aurora_data_in (39 downto 0);
                                                Pointer                  <= Aurora_data_in (58 downto 56);
                                            when others  => 
                                                GFP1                     <= Aurora_data_in (55 downto 48);
                                                first_section           <= '0';
                                                Subsecond                <= Aurora_data_in (26 downto 0);
                                                Pointer                  <= Aurora_data_in (58 downto 56);
                                        end case;
                                     else
                                        first_section           <= '0';
                                        if(packet_counter /=218) and ((packet_counter /=217)) then
                                            GFP1                     <= Aurora_data_in (55 downto 48);
                                            GFP2                     <= Aurora_data_in (47 downto 40);
                                            GFP3                     <= Aurora_data_in (39 downto 32);
                                        else
                                            GFP1                     <= Aurora_data_in (55 downto 48);
                                        end if;
                                        Subsecond                <= Aurora_data_in (26 downto 0);
                                        Pointer                  <= Aurora_data_in (58 downto 56);
                                     end if;
                                     Sample_Fifo_we           <= '0';
                                when  1  =>              
                                    GFP_data_out             <= GFP1;
                                    GFP_valid_out             <= '1';                     
                                    word_in_packet           <= 2;
                                    Sample_Fifo_din          <= Aurora_data_in (63 downto 0);
                                    Sample_Fifo_we           <= not Sample_Fifo_full;
                                when  2 =>
                                    if(packet_counter /=218) and ((packet_counter /=217)) then
                                        GFP_data_out             <= GFP2;
                                        GFP_valid_out             <= '1'; 
                                    else
                                        --GFP_data_out             <= x"ff";
                                        GFP_valid_out             <= '0';
                                    end if;
                                    word_in_packet           <= 3;
                                    Sample_Fifo_din          <= Aurora_data_in (63 downto 0);
                                    Sample_Fifo_we           <= not Sample_Fifo_full;
                                when  3 =>
                                    if(packet_counter /=218) and ((packet_counter /=217)) then
                                        GFP_data_out             <= GFP3;
                                        GFP_valid_out             <= '1'; 
                                    else
                                        --GFP_data_out             <= x"ff";
                                        GFP_valid_out             <= '0';
                                    end if;
                                    word_in_packet           <= 4;
                                    Sample_Fifo_din          <= Aurora_data_in (63 downto 0);
                                    Sample_Fifo_we           <= not Sample_Fifo_full;
                                when  4 =>
                                     --GFP_data_out             <= x"ff";
                                     GFP_valid_out             <= '0';
                                     --if(packet_counter >= 200) and (packet_counter <= 217) then
                                     if(packet_counter = 218) then
                                        word_in_packet <= 0;
                                        if(packet_counter = 218) then
                                            packet_counter <= 0;
                                        else
                                            packet_counter  <= packet_counter + 1;
                                        end if;
                                        packet_total_counter <= packet_total_counter + 1;
                                     else
                                        word_in_packet <= 5;
                                    end if;

                                    Sample_Fifo_din          <= Aurora_data_in (63 downto 0);
                                    Sample_Fifo_we           <= not Sample_Fifo_full;
                                when  5 =>
                                    packet_counter <= packet_counter + 1;
                                    packet_total_counter <= packet_total_counter + 1;
                                    word_in_packet           <= 0;
                                    Sample_Fifo_din          <= Aurora_data_in (63 downto 0);
                                    Sample_Fifo_we           <= not Sample_Fifo_full;
                                when others => null;
                            end case;
                        else
                            Sample_Fifo_din          <= (others => '0');
                            Sample_Fifo_we           <= '0';
                        end if;
                    end if;
                else
                    Sample_Fifo_din     <= (others => '0');
                    Sample_Fifo_we      <='0';
                end if;
            end if;
        end process;
    
    
   Sample_rst_in_cdc : xpm_cdc_single
   generic map (
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
      INIT_SYNC_FF => 1,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 1, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
   )
   port map (
      dest_out => Sample_rst_in, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

      dest_clk => Sample_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk => Aurora_clk_in,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in => Aurora_rst_in      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
   
   -- Sample_Fifo_re <= (not Sample_Fifo_empty) and Sample_IQ_rate_matching;
--    ASYNC_FIFO: fifo_IQ 
--      PORT MAP(
--        --srst => Sample_rst_in,
--        wr_clk => Aurora_clk_in,
--        rd_clk => Sample_clk_in,
--        din => Sample_Fifo_din,
--        wr_en => Sample_Fifo_we,
--        rd_en => Sample_Fifo_re,
--        dout => Sample_Fifo_dout,
--        full => Sample_Fifo_full,
--        empty => Sample_Fifo_empty
--        --wr_rst_busy => Sample_Fifo_wr_rst_busy,
--        --rd_rst_busy => Sample_Fifo_rd_rst_busy
--      );
      
      --fifo_ready <= Sample_IQ_rate_matching and enable_frame;
      IQ_DEFRAMER_INS:IQ_stream_FIFO
      PORT MAP (
          s_axis_aresetn => not Aurora_rst_in,
          s_axis_aclk => Aurora_clk_in,
          s_axis_tvalid => Sample_Fifo_we,
          s_axis_tready => open,
          s_axis_tdata => Sample_Fifo_din,
          m_axis_aclk  => Sample_clk_in,
          m_axis_tvalid => fifo_valid,
          m_axis_tready => fifo_ready and (enable_frame or LOCKEDs_dly(JITTER_IGNORE)),
          m_axis_tdata => Sample_Fifo_dout,
          axis_wr_data_count => wr_data_count,
          axis_rd_data_count => rd_data_count
      );
      
      
      IQ_OUT_IFIFO: IQ_conver_width 
        port map(
          aclk  => Sample_clk_in,
          aresetn => '1',
          s_axis_tvalid => fifo_valid,
          s_axis_tready => fifo_ready,
          s_axis_tdata => Sample_Fifo_dout,
          m_axis_tvalid => Sample_IQ_rate_matching,
          m_axis_tready => '1',
          m_axis_tdata => Sample_IQ0
       );
      process(Sample_clk_in)
      begin
        if(Sample_clk_in'event and Sample_clk_in = '1')then
             if(Sample_rst_in = '1') then
                Sample_IQ <= (others => '0');
                Sample_IQ_valid <= '0';
             else
                Sample_IQ <= Sample_IQ0;
                Sample_IQ_valid <= Sample_IQ_rate_matching and (enable_frame_dly or LOCKEDs_dly(JITTER_IGNORE+1));
             end if;
        end if;
      end process;
    
      process(Sample_clk_in)
      begin
        if(Sample_clk_in'event and Sample_clk_in = '1')then
            if(Sample_rst_in = '1')  then
                enable_frame <= '0';
                enable_frame_dly <=  '0';
                LOCKEDs_dly <= (others => '0');
            else
                enable_frame_dly <= enable_frame;
                LOCKEDs_dly      <= LOCKEDs_dly(127 downto 0) & enable_frame;
                if(LOCKEDs_sync = '0')then
                    enable_frame <= '0';
                else
                    if(enable_frame = '0') then
                        if(read_trigger_sync = '1')then
                            enable_frame <= '1';
                        end if;
                    end if;
               end if;
            end if;
        end if;
      end process;

    test_process: process(Sample_clk_in)
    begin   
        if(Sample_clk_in'event and Sample_clk_in = '1')then
            if(Sample_rst_in = '1')then
                miss_order <= '0';
            else
                if(Sample_IQ_valid = '1') then
                    Sample_IQ_delay <= Sample_IQ;
                    if(Sample_IQ /= Sample_IQ_delay + 1 ) and (Sample_IQ > x"00000001") then
                        miss_order <= '1';
                    else 
                        miss_order <= '0';
                    end if;
                end if;
--                Sample_IQ_high <=  not Sample_IQ_high;
--                if(Sample_IQ_high = '1') then
--                    Sample_IQ <= Sample_I1 & Sample_Q1;
--                else
--                    Sample_IQ <= Sample_I0 & Sample_Q0;
--                end if;
            end if;
        end if;
    end process;
end Behavioral;

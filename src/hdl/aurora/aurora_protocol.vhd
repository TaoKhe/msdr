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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;
Library xpm;
use xpm.vcomponents.all;
entity aurora_protocol is
    Generic(
        RFU_MODE : string := "YES"
    );
    Port (
        -- System Interface
        aurora_clk_in                   : in std_logic:= '0';
        aurora_rst_in                   : in std_logic:= '0';  

        Aurora_IQin_tdata               : in std_logic_vector (63 downto 0):= (others => '0');
        Aurora_IQin_tkeep               : in std_logic_vector (7 downto 0):= (others => '0');
        Aurora_IQin_tvalid              : in std_logic:= '0';
        Aurora_IQin_tlast               : in std_logic:= '0';
        Aurora_IQin_tready              : out std_logic:= '0';  

        Aurora_IQout_tlast              : out std_logic:= '0';
        Aurora_IQout_tdata              : out std_logic_vector (63 downto 0):= (others => '0');
        Aurora_IQout_tkeep              : out std_logic_vector (7 downto 0):= (others => '0');
        Aurora_IQout_tvalid             : out std_logic:= '0';
        Aurora_IQout_tready             : in std_logic:= '0';  

        sample_IQin_data                : in std_logic_vector(63 downto 0):= (others => '0');  
        Sample_IQin_valid               : in std_logic:= '0';
        Sample_IQin_ready               : out std_logic:= '0';
        Sample_IQin_clk_375M	        : in std_logic:= '0'; 

        sample_IQout_data               : out std_logic_vector(31 downto 0):= (others => '0');  
        Sample_IQout_valid              : out std_logic:= '0';

        -- Sample-clock domain. The framer and deframer now run on independent
        -- sample clocks: the framer uses sample_clk_in / Sample_rst_in, while the
        -- deframer uses Sample_clk_deframer_in. The deframer has no sample-reset
        -- input, so only its clock is split out here.
        sample_clk_in                   : in std_logic:= '0';   -- framer sample clock
        Sample_rst_in                   : in std_logic:= '0';   -- framer sample reset
        Sample_clk_deframer_in          : in std_logic:= '0';   -- deframer sample clock


        GFPin_data                      : in std_logic_vector(7 downto 0):= (others => '1');
        GFPin_valid                     : in std_logic:= '0';
        GFPin_ready                     : out std_logic:= '0';
        GFPin_last                      : in std_logic:= '0';

        GFPout_data                     : out std_logic_vector(7 downto 0):= (others => '1');
        GFPout_valid                    : out std_logic:= '0';
        GFPout_ready                    : in std_logic:= '0';
        GFPout_last                     : out std_logic:= '0';

        GFP_clk_in                      : in std_logic := '0';
        GFP_rstn_in                     : in std_logic := '1';

        Frame_Length_in                 : in std_logic_vector (47 downto 0):= (others => '0');
        Tx_freq_in                      : in std_logic_vector (47 downto 0):= (others => '0');
        Rx_freq_in                      : in std_logic_vector (47 downto 0):= (others => '0');
        Next_Frame_Transmit_Time_in     : in std_logic_vector (26 downto 0):= (others => '0');
        Power_Tx_in                     : in std_logic_vector (7 downto 0):= (others => '0');
        Rx_bw_in                        : in std_logic_vector (7 downto 0):= (others => '0');
        Tx_bw_in                        : in std_logic_vector (7 downto 0):= (others => '0');
        Next_Frame_Receive_Time_in      : in std_logic_vector (26 downto 0):= (others => '0');
        Second_from_2000_in             : in std_logic_vector (39 downto 0):= (others => '0');
        Subsecond_in                    : in std_logic_vector (26 downto 0):= (others => '0');

        Frame_Length_out                : out std_logic_vector (47 downto 0):= (others => '0');
        Tx_freq_out                     : out std_logic_vector (47 downto 0):= (others => '0');
        Rx_freq_out                     : out std_logic_vector (47 downto 0):= (others => '0');
        Next_Frame_Transmit_Time_out    : out std_logic_vector (26 downto 0):= (others => '0');
        Power_Tx_out                    : out std_logic_vector (7 downto 0):= (others => '0');
        Rx_bw_out                       : out std_logic_vector (7 downto 0):= (others => '0');
        Tx_bw_out                       : out std_logic_vector (7 downto 0):= (others => '0');
        Next_Frame_Receive_Time_out     : out std_logic_vector (26 downto 0):= (others => '0');
        Second_from_2000_out            : out std_logic_vector (39 downto 0):= (others => '0');
        Subsecond_out                   : out std_logic_vector (26 downto 0):= (others => '0');
        timestamp_valid_out             : out std_logic;



        SAin_data                       : in std_logic_vector(31 downto 0) := (others => '1');
        SAin_valid                      : in std_logic  := '0';
        SAin_ready                      : out std_logic;
        SAin_last                       : in std_logic:= '0';

        SAout_data                      : out std_logic_vector(31 downto 0) := (others => '1');
        SAout_valid                     : out std_logic  := '0';
        SAout_ready                     : in std_logic:= '0';

        SA_clk_in                    : in std_logic := '0';
        SA_rstn_in                   : in std_logic := '0';

        -- Dummy frame control: '1' forces IQ=0 in framer (metadata still sent)
        dummy_frame_in               : in std_logic := '0';

        -- metadata_valid_out: 1-cycle pulse (Aurora_clk_in domain) from the deframer, once
        -- per frame at the first Subsecond = a complete RX timestamp/metadata set is valid.
        metadata_valid_out           : out std_logic
    );
end aurora_protocol;

architecture Behavioral of aurora_protocol is
    signal GFP_packer_source_data        : std_logic_vector(7 downto 0);
    signal GFP_packer_source_valid       : std_logic;
    signal GFP_packer_source_ready       : std_logic;
    signal GFP_packer_source_last        : std_logic;    

    signal GFP_depacker_sink_data        : std_logic_vector(7 downto 0);
    signal GFP_depacker_sink_valid       : std_logic;
    signal GFP_depacker_sink_ready       : std_logic;
    signal GFP_depacker_sink_last        : std_logic;

    -- Timestamp snapshot/hold (Aurora_clk domain). The deframer updates Subsecond on
    -- every packet and Second_from_2000 only on (re)sync, so neither is stable long
    -- enough for a multi-cycle CDC handshake on its own. On each deframer timestamp
    -- pulse we latch the coherent {Second, Subsecond} pair and HOLD it until the next
    -- pulse, then drive the entity outputs from the held snapshot. This guarantees the
    -- source presented to every downstream xpm_cdc_handshake (servo: aurora_clk ->
    -- sample_clk, and fsm_main: aurora_clk -> init_clk) is rock-stable across the whole
    -- transfer window, so the synchronized timestamp can never be torn across domains.
    signal Second_from_2000_deframer_s : std_logic_vector(39 downto 0);
    signal Subsecond_deframer_s        : std_logic_vector(26 downto 0);
    signal timestamp_valid_deframer_s  : std_logic;
    signal metadata_valid_deframer_s   : std_logic;


begin
    Aurora_IQin_tready <= '1';
    -- Re-drive the per-frame metadata_valid pulse straight to the entity output.
    metadata_valid_out <= metadata_valid_deframer_s;

    ---------------------------------------------------------------------------
    -- Coherent timestamp snapshot + hold, triggered by metadata_valid (one pulse per
    -- frame, when the RX metadata set incl. Second is complete). Sole driver of
    -- Second_from_2000_out / Subsecond_out / timestamp_valid_out (the deframer drives the
    -- *_deframer_s internal signals). Latching on the per-frame metadata_valid (not the
    -- per-rotation deframer strobe) holds the {Second, Subsecond} source rock-stable for
    -- the WHOLE inter-frame gap (>> any downstream CDC handshake window), so the servo's
    -- valid-timestamp can never be torn across aurora_clk -> sample_clk. timestamp_valid_out
    -- is retimed +1 cycle so it stays aligned with the just-latched, held snapshot.
    ---------------------------------------------------------------------------
    ts_snapshot_proc : process (aurora_clk_in)
    begin
      if rising_edge(aurora_clk_in) then
        if aurora_rst_in = '1' then
          Second_from_2000_out <= (others => '0');
          Subsecond_out        <= (others => '0');
          timestamp_valid_out  <= '0';
        else
          timestamp_valid_out <= '0';          -- 1-cycle strobe; default low
          if metadata_valid_deframer_s = '1' then
            Second_from_2000_out <= Second_from_2000_deframer_s;
            Subsecond_out        <= Subsecond_deframer_s;
            timestamp_valid_out  <= '1';
          end if;
        end if;
      end if;
    end process;
    gfp_packer_inst: entity work.gfp_packer
    port map(
        gfp_clk_in => gfp_clk_in,
        gfp_rstn_in => gfp_rstn_in,
        gfp_sink_data_in => GFPin_data,
        gfp_sink_valid_in => GFPin_valid,
        gfp_sink_ready_out => GFPin_ready,
        gfp_sink_last_in => GFPin_last,
        gfp_source_data_out => GFP_packer_source_data,
        gfp_source_valid_out => GFP_packer_source_valid,
        gfp_source_ready_in => GFP_packer_source_ready,
        gfp_source_last_out => GFP_packer_source_last
    );

    i_gfp_depacker : entity work.gfp_depacker
        port map(
            gfp_clk_in           => gfp_clk_in,
            gfp_rstn_in          => gfp_rstn_in,
            gfp_sink_data_in     => GFP_depacker_sink_data,
            gfp_sink_valid_in    => GFP_depacker_sink_valid,
            gfp_sink_ready_out   => GFP_depacker_sink_ready,
            --gfp_sink_last_in     => GFP_depacker_sink_last,
            gfp_source_data_out  => GFPout_data,
            gfp_source_valid_out => GFPout_valid,
            gfp_source_ready_in  => GFPout_ready,
            gfp_source_last_out  => GFPout_last
    );

    
    
   aurora_deframer_inst: entity work.aurora_deframer
    generic map(
       RFU_MODE => RFU_MODE
   )
    port map(
       Aurora_data_in => Aurora_IQin_tdata,
       Aurora_keep_in => Aurora_IQin_tkeep,
       Aurora_valid_in => Aurora_IQin_tvalid,
       Aurora_last_in => Aurora_IQin_tlast,

       Sample_IQ => sample_IQout_data,
       Sample_IQ_valid => Sample_IQout_valid,
       Aurora_clk_in => Aurora_clk_in,
       Aurora_rst_in => Aurora_rst_in,
       Sample_clk_in => Sample_clk_deframer_in,   -- deframer sample clock (independent from framer)
       --LOCKED => LOCKED,
       --Pointer => Pointer,
       Frame_Length => Frame_Length_out,
       Tx_freq => Tx_freq_out,
       Rx_freq => Rx_freq_out,
       Next_Frame_Transmit_Time => Next_Frame_Transmit_Time_out,
       Power_Tx => Power_Tx_out,
       Rx_bw => Rx_bw_out,
       Tx_bw => Tx_bw_out,
       Next_Frame_Receive_Time => Next_Frame_Receive_Time_out,
       Second_from_2000 => Second_from_2000_deframer_s,
       Subsecond => Subsecond_deframer_s,
       timestamp_valid_out  => timestamp_valid_deframer_s,
       SA_data_out => SAout_data,
       SA_valid_out => SAout_valid,
       SA_ready_in => SAout_ready,
       SA_clk => SA_clk_in,

       GFP_clk => GFP_clk_in,
       GFP_ready_in => GFP_depacker_sink_ready,
       GFP_data_out => GFP_depacker_sink_data,
       GFP_valid_out => GFP_depacker_sink_valid,
       -- dummy_frame_out left open; metadata_valid (per-frame pulse) -> internal signal,
       -- used as the timestamp-snapshot trigger AND re-driven to metadata_valid_out.
       metadata_valid => metadata_valid_deframer_s
   );

   aurora_framer_inst: entity work.aurora_framer
    generic map(
       RFU_MODE => RFU_MODE
   )
    port map(
       Aurora_data_out => Aurora_IQout_tdata,
       Aurora_last_out => Aurora_IQout_tlast,
       Aurora_keep_out => Aurora_IQout_tkeep,
       Aurora_valid_out => Aurora_IQout_tvalid,
       Aurora_rdy_in => Aurora_IQout_tready,
       Aurora_clk_in => Aurora_clk_in,
       Aurora_rst_in => Aurora_rst_in,
       GFP_data_in => gfp_packer_source_data,
       GFP_valid_in => gfp_packer_source_valid,
       GFP_ready_out => gfp_packer_source_ready,
       GFP_last_in => gfp_packer_source_last,
       GFP_clk_in => GFP_clk_in,
       GFP_rst_in => GFP_rstn_in,
       Sample_IQ => sample_IQin_data,
       Sample_IQ_valid => sample_IQin_valid,
       Sample_IQ_ready => Sample_IQin_ready,
       Sample_IQin_clk_375M => Sample_IQin_clk_375M,
       Frame_Length => Frame_Length_in,
       Tx_freq => Tx_freq_in,
       Rx_freq => Rx_freq_in,
       Next_Frame_Transmit_Time => Next_Frame_Transmit_Time_in,
       Power_Tx => Power_Tx_in,
       Rx_bw => Rx_bw_in,
       Tx_bw => Tx_bw_in,
       Next_Frame_Receive_Time => Next_Frame_Receive_Time_in,
       Second_from_2000 => Second_from_2000_in,
       Subsecond => Subsecond_in,
       SA_data_in => SAin_data,
       SA_valid_in => SAin_valid,
       SA_ready_out => SAin_ready,
       SA_last_in => SAin_last,
       SA_clk_in => SA_clk_in,
       SA_rst_in => SA_rstn_in,
       Sample_clk => Sample_clk_in,
       Sample_rst_in => Sample_rst_in,
       dummy_frame_in => dummy_frame_in
   );
   
   
--   ILA_GFP: ENTITY work.ila_gfp
--    PORT MAP(
--        clk => GFP_clk_in,
--        probe0(0) => GFPin_valid,
--        probe1 => GFPin_data,
--        probe2(0) => GFPin_ready,
--        probe3(0) => GFP_packer_source_valid,
--        probe4 => GFP_packer_source_data,
--        probe5(0) => GFP_packer_source_ready,
--        probe6 => GFP_depacker_sink_data,
--        probe7(0) => GFP_depacker_sink_valid,
--        probe8(0) => GFP_depacker_sink_ready,
--        probe9 => GFPout_data,
--        probe10(0) => GFPout_valid,
--        probe11(0) => GFPout_ready,
--        probe12(0) => GFPin_last,
--        probe13(0) => GFP_packer_source_last,
--        probe14(0) => GFPout_last,
--        probe15(0) => gfp_rstn_in
--    );

end Behavioral;

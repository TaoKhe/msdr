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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;
library xpm;
use xpm.vcomponents.all;
-- synthesis translate_off
use std.textio.all;
use ieee.std_logic_textio.all;
-- synthesis translate_on

entity aurora_deframer is
  generic (
    RFU_MODE : string := "YES"
  );

  port (
    Aurora_data_in  : in std_logic_vector (63 downto 0);
    Aurora_keep_in  : in std_logic_vector (7 downto 0);
    Aurora_valid_in : in std_logic;
    Aurora_last_in  : in std_logic;
    Sample_IQ       : out std_logic_vector (31 downto 0);
    Sample_IQ_valid : out std_logic;
    Aurora_clk_in   : in std_logic;
    Aurora_rst_in   : in std_logic;
    Sample_clk_in   : in std_logic;
    Frame_Length    : out std_logic_vector (47 downto 0);

    Tx_freq                  : out std_logic_vector (47 downto 0);
    Rx_freq                  : out std_logic_vector (47 downto 0);
    Next_Frame_Transmit_Time : out std_logic_vector (26 downto 0);
    Power_Tx                 : out std_logic_vector (7 downto 0);
    Rx_bw                    : out std_logic_vector (7 downto 0);
    Tx_bw                    : out std_logic_vector (7 downto 0);
    Next_Frame_Receive_Time  : out std_logic_vector (26 downto 0);
    Second_from_2000         : out std_logic_vector (39 downto 0);
    Subsecond                : out std_logic_vector (26 downto 0);
    timestamp_valid_out      : out std_logic;

    SA_data_out  : out std_logic_vector(31 downto 0) := (others => '1');
    SA_valid_out : out std_logic                     := '0';
    SA_ready_in  : in std_logic;
    SA_clk       : in std_logic := '0';

    GFP_clk       : in std_logic;
    GFP_ready_in  : in std_logic;
    GFP_data_out  : out std_logic_vector(7 downto 0);
    GFP_valid_out : out std_logic;

    -- dummy_frame_out: LEVEL = '1' while the dummy startup frame is in progress (pre-lock),
    -- '0' once the dummy frame ends and the link is locked (= not LOCKEDs).
    dummy_frame_out : out std_logic;

    -- metadata_valid: 1-cycle pulse = "a complete RX timestamp/metadata set is valid now".
    -- Fires at the FIRST Subsecond of each frame (Second_from_2000 arrives in the dummy
    -- frame; the first Subsecond, in the first normal packet, completes the absolute time).
    -- Re-armed every frame via Aurora_last_in (tlast) so it pulses once per frame.
    metadata_valid  : out std_logic
  );
end aurora_deframer;

architecture Behavioral of aurora_deframer is
  -- JITTER_IGNORE: length of the LOCKEDs_dly startup shift-register (sample_clk cycles).
  -- Kept = 128 because LOCKEDs_dly is 130 bits (indices 128/129 used). Do NOT raise
  -- without widening LOCKEDs_dly.
  constant JITTER_IGNORE : integer := 128;
  -- Elastic buffer (plesiochronous link): TX DDS 250 Msps and RX consumer 250 Msps are
  -- INDEPENDENT clocks (ppm drift), and the link delivers IQ in bursts (CC / header / SHORT
  -- gaps) while the DAC must take one sample EVERY Sample_clk. So Sample_IQ_valid stays '1'
  -- and underrun is absorbed by STUFFING (repeat the last sample) when the FIFO drops to
  -- IQ_LOW_THR — this both prevents an empty read AND rebuilds the standing FIFO level.
  -- High IQ_LOW_THR = strong jitter tolerance (deep standing cushion). Overrun (RX slower
  -- than TX) is bounded by the IQ FIFO depth (256) on the write side.
  constant FIFO_FILL_THR : integer := 128; -- startup: fill IQ FIFO to this (words) before enabling output
  constant IQ_LOW_THR    : integer := 64;  -- underrun stuff watermark (words) ~10x worst-case CC drain
  constant IQ_HIGH_THR   : integer := 224; -- overrun DROP watermark (of 256): suppress writes above this
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
  component IQ_stream_FIFO is
    port (
      s_axis_aresetn     : in std_logic;
      s_axis_aclk        : in std_logic;
      s_axis_tvalid      : in std_logic;
      s_axis_tready      : out std_logic;
      s_axis_tdata       : in std_logic_vector(63 downto 0);
      m_axis_aclk        : in std_logic;
      m_axis_tvalid      : out std_logic;
      m_axis_tready      : in std_logic;
      m_axis_tdata       : out std_logic_vector(63 downto 0);
      axis_wr_data_count : out std_logic_vector(31 downto 0);
      axis_rd_data_count : out std_logic_vector(31 downto 0)
    );
  end component;
  component IQ_conver_width is
    port (
      aclk          : in std_logic;
      aresetn       : in std_logic;
      s_axis_tvalid : in std_logic;
      s_axis_tready : out std_logic;
      s_axis_tdata  : in std_logic_vector(63 downto 0);
      m_axis_tvalid : out std_logic;
      m_axis_tready : in std_logic;
      m_axis_tdata  : out std_logic_vector(31 downto 0)
    );
  end component;
  component SA_stream_FIFO is
    port (
      s_axis_aresetn     : in std_logic;
      s_axis_aclk        : in std_logic;
      s_axis_tvalid      : in std_logic;
      s_axis_tready      : out std_logic;
      s_axis_tdata       : in std_logic_vector(31 downto 0);
      m_axis_aclk        : in std_logic;
      m_axis_tvalid      : out std_logic;
      m_axis_tready      : in std_logic;
      m_axis_tdata       : out std_logic_vector(31 downto 0);
      axis_wr_data_count : out std_logic_vector(31 downto 0);
      axis_rd_data_count : out std_logic_vector(31 downto 0)
    );
  end component;
  component GFP_fifo_0 is
    port (
      s_axis_aresetn     : in std_logic;
      s_axis_aclk        : in std_logic;
      s_axis_tvalid      : in std_logic;
      s_axis_tready      : out std_logic;
      s_axis_tdata       : in std_logic_vector(7 downto 0);
      m_axis_aclk        : in std_logic;
      m_axis_tvalid      : out std_logic;
      m_axis_tready      : in std_logic;
      m_axis_tdata       : out std_logic_vector(7 downto 0);
      axis_wr_data_count : out std_logic_vector(31 downto 0);
      axis_rd_data_count : out std_logic_vector(31 downto 0)
    );
  end component GFP_fifo_0;

  component ila_framer is
    port (
      clk    : in std_logic;
      probe0 : in std_logic_vector(0 downto 0);
      probe1 : in std_logic_vector(63 downto 0);
      probe2 : in std_logic_vector(0 downto 0);
      probe3 : in std_logic_vector(63 downto 0);
      probe4 : in std_logic_vector(63 downto 0);
      probe5 : in std_logic_vector(0 downto 0);
      probe6 : in std_logic_vector(3 downto 0);
      probe7 : in std_logic_vector(0 downto 0);
      probe8 : in std_logic_vector(4 downto 0);
      probe9 : in std_logic_vector(31 downto 0)
    );
  end component;


  component ila_deframer_meta_ip is
    port (
      clk    : in std_logic;
      probe0 : in std_logic_vector(0 downto 0);   -- ila_meta_qual (storage qualifier)
      probe1 : in std_logic_vector(63 downto 0);  -- Aurora_data_in (beat tho)
      probe2 : in std_logic_vector(26 downto 0);  -- Next_Frame_Transmit_Time (da giai ma)
      probe3 : in std_logic_vector(26 downto 0);  -- Next_Frame_Receive_Time  (da giai ma)
      probe4 : in std_logic_vector(3 downto 0);   -- frame_meta_idx
      probe5 : in std_logic_vector(3 downto 0);   -- word_in_packet
      probe6 : in std_logic_vector(7 downto 0);   -- dummy_pkt_count & burst_pkt
      probe7 : in std_logic_vector(7 downto 0);    -- co trang thai
      probe8 :in std_logic_vector(47 downto 0);    -- co trang thai
      probe9 :in std_logic_vector(47 downto 0)    -- co trang thai
    );
  end component;

  component fifo_test is
    port (
      wr_clk : in std_logic;
      rd_clk : in std_logic;
      din    : in std_logic_vector(63 downto 0);
      wr_en  : in std_logic;
      rd_en  : in std_logic;
      dout   : out std_logic_vector(63 downto 0);
      full   : out std_logic;
      empty  : out std_logic
    );
  end component fifo_test;

  signal word_40               : integer range 0 to 39          := 0;
  signal GFP_SIGNATURE         : std_logic_vector (7 downto 0)  := x"AA";
  signal Sample_Fifo_din       : std_logic_vector (63 downto 0) := (others => '0');
  signal Sample_Fifo_full      : std_logic                      := '0';
  signal Sample_Fifo_we        : std_logic                      := '0';
  signal Sample_Fifo_dout      : std_logic_vector (63 downto 0) := (others => '0');
  signal LOCKEDs, LOCKEDs_sync : std_logic                      := '0';
  signal Sample_rst_in         : std_logic;

  signal Sample_IQ0 : std_logic_vector (31 downto 0);

  signal Sample_IQ_rate_matching : std_logic := '0';

  signal Sample_IQ_delay : std_logic_vector(31 downto 0);
  signal miss_order      : std_logic := '0';
  signal iq_half         : std_logic := '0'; -- toggles per 32-bit beat (64->32 converter)

  signal packet_counter : integer := 0; -- kept for reference only
  signal word_in_packet : integer range 0 to 10;

  signal meta_counter : integer range 0 to 6  := 0;
  signal rate_sub     : integer range 0 to 18 := 0;
  signal is_short_pkt : std_logic             := '0';
  signal fifo_ready   : std_logic;
  signal iq_toggle    : std_logic := '0'; -- custom 64→32 demux: '0'=lower half, '1'=upper half
  signal hold_active  : std_logic := '0'; -- '1' when stall_cnt > 0 (CC-induced sample-hold active)
  -- last_iq_reg removed: sample-hold not used (Bresenham 7,1,8 + hysteresis keeps FIFO filled)
  signal iq_out_tready      : std_logic;
  signal iq_out_tready_sync : std_logic;
  -- LOCKEDs_dly: 130-bit shift register (JITTER_IGNORE=128, max index used = JITTER_IGNORE+1=129)
  signal LOCKEDs_dly                    : std_logic_vector(129 downto 0);
  signal fifo_valid                     : std_logic;
  signal wr_data_count                  : std_logic_vector (31 downto 0);
  signal rd_data_count                  : std_logic_vector (31 downto 0);
  signal enable_frame, enable_frame_dly : std_logic;
  signal first_section                  : std_logic;
  signal packet_total_counter           : integer := 0;
  signal GFP1                           : std_logic_vector(7 downto 0);
  signal GFP2                           : std_logic_vector(7 downto 0);
  signal GFP3                           : std_logic_vector(7 downto 0);
  signal GFP_fifo_source_data           : std_logic_vector(7 downto 0);
  signal GFP_fifo_source_valid          : std_logic;
  -- Dummy frame tracking (Rev N: 6 startup packets with top byte = x"00")
  signal dummy_pkt_count  : integer range 0 to 6 := 0; -- counts received dummy packets (0..5)
  signal dummy_in_pkt     : std_logic            := '0'; -- '1' = currently inside dummy packet beats 1..5
  signal dummy_frame_done : std_logic            := '0'; -- (legacy) 1-cycle pulse at dummy end
  -- ts_armed: re-arm flag for the metadata_valid pulse. Set at reset and at every frame end
  -- (Aurora_last_in / tlast); cleared when metadata_valid fires. Guarantees metadata_valid
  -- pulses once per frame, at the first Subsecond (first locked beat-0 of the frame).
  signal ts_armed         : std_logic            := '1';

  -- Periodic metadata-burst refresh: after the FIRST dummy locks the link, the MBU keeps
  -- sending the SAME 6-packet x 6-beat dummy burst (meta0=0xAA, meta1=Tx_freq, meta2=Rx_freq,
  -- meta3, meta4, meta5=Second) between data frames. LOCKEDs stays '1' (no FIFO-read toggle);
  -- a small self-contained decoder anchored on the meta0 (0xAA) marker re-decodes each burst
  -- so Second_from_2000 / Tx_freq / ... stay LIVE instead of frozen at the first dummy.
  -- burst_pkt = which of the 6 meta packets (0..5), burst_beat = beat within the 6-beat packet.
  signal meta_burst_active : std_logic            := '0';
  signal burst_pkt         : integer range 0 to 7 := 0;
  signal burst_beat        : integer range 0 to 7 := 0;

  -- Inline frame-start metadata: the MBU embeds meta0..meta5 in the FIRST 6 data-packet
  -- headers of EVERY frame (meta0 marked by 0xAA in [55:48]; meta1=Tx_freq, meta2=Rx_freq,
  -- meta3=Tx_bw/Power/NFTT, meta4=Rx_bw/NFRT, meta5=Second). Subsequent headers are normal
  -- (GFP1/2/3 = 0xff, i.e. [55:32]=0xffffff) and carry the 1-us Subsecond in [26:0]. The
  -- meta is in the header (beat 0) only; beats 1..7 of these packets are real IQ.
  signal in_frame_meta  : std_logic            := '0';
  signal frame_meta_idx : integer range 0 to 7 := 0;

  -- ila_meta_qual: beat header hop le (Aurora_valid_in = '1' va word_in_packet = 0).
  -- Chi dung lam STORAGE QUALIFIER cho ila_deframer_meta; khong tham gia datapath.
  signal ila_meta_qual : std_logic := '0';

  signal GFP_fifo_source_data_dly  : std_logic_vector(7 downto 0);
  signal GFP_fifo_source_valid_dly : std_logic;
  signal gfp_miss_order            : std_logic;
  -------------------------Spectrum Analyzer Port-------------------------------------------------------------------
  signal SA_source_data  : std_logic_vector(31 downto 0);
  signal SA_source_valid : std_logic;
  -- synthesis translate_off
  signal sim_clock_count : integer := 0; -- simulation-only cycle counter for dump
  -- synthesis translate_on
  signal wrong_sample, wrong_sample_sync : std_logic_vector(63 downto 0);
  signal fifo_empty, fifo_full           : std_logic;
  signal underrun                        : std_logic := '0'; -- '1' = IQ FIFO empty or <= IQ_LOW_THR (stuff)
  -- Parallel 1-bit "last" FIFO: carries Aurora_last_in (tlast / frame boundary) across the same
  -- CDC as the IQ FIFO, written/read in exact lockstep so its head tracks the IQ FIFO head. Lets
  -- the Sample_clk demux know which word is a frame's last beat and re-align iq_toggle there.
  signal iq_pop_s        : std_logic;                    -- IQ FIFO read-accept (tvalid AND tready)
  signal last_fifo_din   : std_logic_vector(0 downto 0); -- = Aurora_last_d1 (tlast aligned to Sample_Fifo_we)
  signal Aurora_last_d1  : std_logic := '0';             -- Aurora_last_in AND valid, registered 1 clk
  signal last_fifo_dout  : std_logic_vector(0 downto 0); -- head word's tlast bit (fwft)
  signal last_fifo_empty : std_logic;
  signal fifo_last_s     : std_logic;                    -- '1' = current IQ FIFO head word carried tlast
  -- frame_win: per-frame read window. '1' = actively reading a frame (IQ FIFO filled to
  -- FIFO_FILL_THR, tlast not yet reached). '0' = inter-frame rest gap (hold/refill). Gates the
  -- FIFO read (via underrun) and the miss_order check so neither runs during the frame-mode gap.
  signal frame_win       : std_logic := '0';
  signal chk_started     : std_logic := '0';  -- miss_order: '1' after the first real read sample
begin

  -- dummy_frame_out: LEVEL '1' while not yet locked (dummy startup frame in progress),
  -- '0' once the dummy frame ends and the link is locked.
  -- '1' during ANY dummy burst (startup: not LOCKEDs, or periodic refresh: meta_burst_active),
  -- '0' during locked data frames.
  dummy_frame_out <= (not LOCKEDs) or meta_burst_active;

  -- iq_out_tready: startup gate - enable IQ output only after FIFO has JITTER_IGNORE words.
  -- With balanced Bresenham (7,1,8), FIFO is stable at runtime (no drain, no overflow).
  iq_out_tready <= '1' when wr_data_count >= FIFO_FILL_THR else
    '0';

  iq_tready_cdc : xpm_cdc_single
  generic map(
    DEST_SYNC_FF   => 2, -- low latency: 2FF sufficient for slow-changing signal
    INIT_SYNC_FF   => 0, -- init to 0: startup must WAIT until IQ FIFO fills to FIFO_FILL_THR
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 1
  )
  port map
  (
    dest_out => iq_out_tready_sync,
    dest_clk => Sample_clk_in,
    src_clk  => Aurora_clk_in,
    src_in   => iq_out_tready
  );

  locked_trigger_inst : xpm_cdc_single
  generic map(
    DEST_SYNC_FF   => 4, -- DECIMAL; range: 2-10
    INIT_SYNC_FF   => 1, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    SRC_INPUT_REG  => 1 -- DECIMAL; 0=do not register input, 1=register input
  )
  port map
  (
    dest_out => LOCKEDs_sync, -- 1-bit output: src_in synchronized to the destination clock domain. This output
    -- is registered.
    dest_clk => Sample_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
    src_clk  => Aurora_clk_in, -- 1-bit input: optional; required when SRC_INPUT_REG = 1
    src_in   => LOCKEDs -- 1-bit input: Input signal to be synchronized to dest_clk domain.
  );
  RFU_FRAMER_GEN : if RFU_MODE = "YES" generate
    DeEmbed_proc : process (Aurora_clk_in)
    begin
      if rising_edge(Aurora_clk_in) then
        if (Aurora_rst_in = '1') then
          word_40      <= 0;
          LOCKEDs      <= '0';
          Frame_Length <= (others => '0');
          --Pointer <= (others => '0');
          Tx_freq                  <= (others => '0');
          Rx_freq                  <= (others => '0');
          Power_Tx                 <= (others => '0');
          Next_Frame_Transmit_Time <= (others => '0');
          Rx_bw                    <= (others => '0');
          Tx_bw                    <= (others => '0');
          Next_Frame_Receive_Time  <= (others => '0');
          Second_from_2000         <= (others => '0');
          Subsecond                <= (others => '0');
          packet_counter           <= 0;
          word_in_packet           <= 0;
          first_section            <= '1';
          packet_total_counter     <= 0;
          timestamp_valid_out      <= '0';
          -- rate-matching reset
          meta_counter <= 0;
          rate_sub     <= 0;
          is_short_pkt <= '0';
          -- dummy frame tracking
          dummy_pkt_count  <= 0;
          dummy_in_pkt     <= '0';
          dummy_frame_done <= '0';
          metadata_valid   <= '0';
          ts_armed         <= '1';  -- arm: first Subsecond after lock pulses metadata_valid
          -- periodic metadata-burst refresh tracking
          meta_burst_active <= '0';
          burst_pkt         <= 0;
          burst_beat        <= 0;
          in_frame_meta     <= '0';
          frame_meta_idx    <= 0;
        elsif (Aurora_valid_in = '1') then
          timestamp_valid_out <= '0';
          dummy_frame_done    <= '0'; -- default: no pulse
          metadata_valid      <= '0'; -- default low; 1-cycle pulse set at first Subsecond below
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
          -- Dummy packet detection (Rev N protocol)
          -- Framer sends 6 startup packets with bits[63:56]=x"00" (top byte=0).
          -- Beat 0: x"00" & meta_idx & GFP & payload  -> extract metadata
          -- Beats 1..5: all zeros                      -> skip FIFO write
          -- After 6th dummy packet -> LOCKEDs='1' -> normal operation.
          -- Normal/short packets: top nibble x"A"/x"8" -> processed normally.
          if (LOCKEDs = '0') then
            -- Pre-lock state: only accept dummy packets (top byte = x"00")
            if (Aurora_data_in(63 downto 56) = x"00") then
              Sample_Fifo_we  <= '0';
              Sample_Fifo_din <= (others => '0');
              if dummy_in_pkt = '0' then
                -- Beat 0 of a dummy packet: decode metadata by meta_counter
                -- Header format: x"00" & meta_idx_byte & GFP & payload
                -- bits[55:48] = GFP_SIGNATURE (meta 0) or GFP1
                -- bits[47:0]  = metadata payload (Frame_Length, Tx_freq, etc.)
                dummy_in_pkt   <= '1';
                word_in_packet <= 1;
                case Aurora_data_in(55 downto 48) is -- use meta byte as key
                  when x"AA" => -- meta 0: GFP_SIGNATURE=0xAA -> Frame_Length
                    Frame_Length <= Aurora_data_in(47 downto 0);
                  when others =>
                    -- metas 1-6: decode by packet count
                    case dummy_pkt_count is
                      when 1 =>
                        GFP1    <= Aurora_data_in(55 downto 48);
                        Tx_freq <= Aurora_data_in(47 downto 0);
                      when 2 =>
                        GFP1    <= Aurora_data_in(55 downto 48);
                        Rx_freq <= Aurora_data_in(47 downto 0);
                      when 3 =>
                        GFP1                     <= Aurora_data_in(55 downto 48);
                        Tx_bw                    <= Aurora_data_in(47 downto 40);
                        Power_Tx                 <= Aurora_data_in(39 downto 32);
                        Next_Frame_Transmit_Time <= Aurora_data_in(26 downto 0);
                      when 4 =>
                        GFP1                    <= Aurora_data_in(55 downto 48);
                        Rx_bw                   <= Aurora_data_in(47 downto 40);
                        Next_Frame_Receive_Time <= Aurora_data_in(26 downto 0);
                      when 5 =>
                        GFP1             <= Aurora_data_in(55 downto 48);
                        Second_from_2000 <= Aurora_data_in(39 downto 0);
                      when others => null;
                    end case;
                end case;
              else
                -- Beats 1..5 of dummy packet: all zeros, skip FIFO write
                if word_in_packet < 5 then
                  word_in_packet <= word_in_packet + 1;
                else
                  -- Beat 5 done -> end of this dummy packet
                  word_in_packet <= 0;
                  dummy_in_pkt   <= '0';
                  if dummy_pkt_count = 5 then
                    -- All 6 dummy packets received -> switch to normal
                    -- Fire 1-cycle pulse on dummy_frame_done
                    LOCKEDs          <= '1';
                    dummy_frame_done <= '1'; -- pulse: metadata now valid
                    dummy_pkt_count  <= 0;
                    meta_counter     <= 0;
                    first_section    <= '0'; -- metadata already loaded
                    rate_sub         <= 0;
                    is_short_pkt     <= '0';
                  else
                    dummy_pkt_count <= dummy_pkt_count + 1;
                  end if;
                end if;
              end if;
            end if;
            -- Ignore any non-dummy beats while not locked (top byte /= 0x00)
          else
            -- LOCKEDs stays '1' once locked; word_in_packet resets naturally.
            -- Removed per-packet LOCKEDs reset: caused ~21MHz CDC toggle -> FIFO gaps.
            if (meta_burst_active = '0') and (word_in_packet = 0)
               and (Aurora_data_in(63 downto 56) = x"00")
               and (Aurora_data_in(55 downto 48) = x"AA") then
              -- START of a periodic metadata burst: this valid beat is META0 (0xAA marker).
              -- Decode Frame_Length (meta0), arm the 6x6 burst counter; suppress FIFO/GFP.
              -- MUST gate on word_in_packet=0 (packet boundary): the IQ payload is NOT restricted
              -- to 0xAF.. -- the counter test stream (and real IQ) passes through 0x00aaXXXX, which
              -- has top=0x00 AND [55:48]=0xAA and would FALSE-TRIGGER this burst detect mid-packet,
              -- freezing word_in_packet and writing headers into the IQ FIFO (metadata-as-data).
              -- A real dummy-burst META0 only ever lands at a packet boundary (wip=0).
              meta_burst_active     <= '1';
              burst_pkt             <= 0;
              burst_beat            <= 1;          -- beats 1..5 of the meta0 packet follow
              Frame_Length          <= Aurora_data_in (47 downto 0);
              Sample_Fifo_we        <= '0';
              GFP_fifo_source_valid <= '0';
            elsif (meta_burst_active = '1') then
              -- Inside the burst: beat-0 of each dummy packet (burst_beat=0) carries
              -- meta[burst_pkt]; beats 1..5 are zeros. FIFO writes suppressed (IQ is silent).
              Sample_Fifo_we        <= '0';
              GFP_fifo_source_valid <= '0';
              if burst_beat = 0 then
                case burst_pkt is
                  when 1 =>
                    Tx_freq <= Aurora_data_in (47 downto 0);
                  when 2 =>
                    Rx_freq <= Aurora_data_in (47 downto 0);
                  when 3 =>
                    Tx_bw                    <= Aurora_data_in (47 downto 40);
                    Power_Tx                 <= Aurora_data_in (39 downto 32);
                    Next_Frame_Transmit_Time <= Aurora_data_in (26 downto 0);
                  when 4 =>
                    Rx_bw                   <= Aurora_data_in (47 downto 40);
                    Next_Frame_Receive_Time <= Aurora_data_in (26 downto 0);
                  when 5 =>
                    Second_from_2000 <= Aurora_data_in (39 downto 0);
                  when others =>
                    null;                          -- burst_pkt=0 (meta0) decoded at burst start
                end case;
                burst_beat <= 1;
              elsif burst_beat < 5 then
                burst_beat <= burst_beat + 1;      -- skip the 5 zero payload beats
              else
                burst_beat <= 0;                   -- 6-beat dummy packet done
                if burst_pkt = 5 then
                  meta_burst_active <= '0';        -- all 6 meta packets done -> burst complete
                  burst_pkt         <= 0;
                  word_in_packet    <= 0;          -- next data packet starts clean at beat 0
                  ts_armed          <= '1';        -- re-arm metadata_valid: fresh Second latched
                else
                  burst_pkt <= burst_pkt + 1;
                end if;
              end if;
            else
            case word_in_packet is
              when 0 =>
                word_in_packet <= 1;
                -- FIX: Detect short packet from header nibble (x"8"=short, x"A"=normal)
                -- Framer marks short packets with x"8" in bits[63:60] of beat 0.
                -- Pre-register is_short_pkt here; used at beat 4 to skip beat 5.
                -- This eliminates counter drift between framer and deframer.
                if Aurora_data_in(63 downto 60) = x"8" then
                  is_short_pkt <= '1';
                else
                  is_short_pkt <= '0';
                end if;
                -- Locked-mode beat-0 header = GFP1/2/3 + Subsecond ONLY (the MBU sends the
                -- full metadata rotation incl. Second_from_2000 / Tx_freq ONLY inside the
                -- dummy frame, NOT in locked data frames). Decoding by meta_counter here
                -- mis-reads normal headers (GFP=0xff) as meta pages -> garbage Second/Tx_freq,
                -- so we decode only what locked headers actually carry. Second_from_2000 keeps
                -- the last value latched from the dummy (refreshed by the dummy-refresh path).
                first_section <= '0';
                GFP1      <= Aurora_data_in (55 downto 48);
                GFP2      <= Aurora_data_in (47 downto 40);
                GFP3      <= Aurora_data_in (39 downto 32);
                -- Inline frame-start metadata (meta0..meta5) carried in the first 6 packet
                -- headers of EVERY frame, then normal headers carrying Subsecond. meta0 is
                -- marked by 0xAA in [55:48]; meta1..meta5 follow (counted from meta0). A normal
                -- header has GFP1/2/3 = 0xff ([55:32]=0xffffff) -- only THOSE carry an in-range
                -- 1-us Subsecond. (The inline meta headers also have GFP1=0xff but GFP2/GFP3 are
                -- payload, so [55:32] /= 0xffffff -- this is how we avoid latching e.g. a Tx_freq
                -- as a Subsecond, which previously froze the local NCO.)
                if Aurora_data_in (55 downto 48) = x"AA" then
                  -- meta0 marker: frame meta block begins
                  Frame_Length   <= Aurora_data_in (47 downto 0);
                  frame_meta_idx <= 1;
                  in_frame_meta  <= '1';
                  ts_armed       <= '1';   -- arm metadata_valid for this frame
                elsif in_frame_meta = '1' then
                  -- meta1..meta6 COUNTED from the meta0 marker, mirroring the framer's
                  -- first_section block (meta_counter 0..6). meta6 carries the Subsecond and is
                  -- identified by the COUNT, not by GFP1/2/3 = 0xff -> robust even if the GFP
                  -- side-channel ever carries non-0xff bytes in a normal header.
                  case frame_meta_idx is
                    when 1 =>
                      Tx_freq <= Aurora_data_in (47 downto 0);
                    when 2 =>
                      Rx_freq <= Aurora_data_in (47 downto 0);
                    when 3 =>
                      Tx_bw                    <= Aurora_data_in (47 downto 40);
                      Power_Tx                 <= Aurora_data_in (39 downto 32);
                      Next_Frame_Transmit_Time <= Aurora_data_in (26 downto 0);
                    when 4 =>
                      Rx_bw                   <= Aurora_data_in (47 downto 40);
                      Next_Frame_Receive_Time <= Aurora_data_in (26 downto 0);
                    when 5 =>
                      Second_from_2000 <= Aurora_data_in (39 downto 0);
                    when 6 =>
                      -- meta6 = first normal header (GFP + Subsecond): end of meta block.
                      Subsecond     <= Aurora_data_in (26 downto 0);
                      in_frame_meta <= '0';
                      if ts_armed = '1' then
                        metadata_valid <= '1';   -- {Second(meta5), Subsecond(meta6)} coherent
                        ts_armed       <= '0';
                      end if;
                    when others =>
                      in_frame_meta <= '0';
                  end case;
                  if frame_meta_idx < 6 then
                    frame_meta_idx <= frame_meta_idx + 1;
                  end if;
                else
                  -- normal data header after the meta block: Subsecond in [26:0], decoded by
                  -- POSITION (no GFP gating). metadata_valid already pulsed at meta6 this frame.
                  Subsecond <= Aurora_data_in (26 downto 0);
                  if ts_armed = '1' then
                    metadata_valid <= '1';
                    ts_armed       <= '0';
                  end if;
                end if;
                Sample_Fifo_we <= '0';
              when 1 =>
                if (meta_counter >= 1) or (first_section = '0') then
                  GFP_fifo_source_data  <= GFP1;
                  GFP_fifo_source_valid <= '1';
                else
                  GFP_fifo_source_valid <= '0';
                end if;
                word_in_packet  <= 2;
                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when 2 =>
                if first_section = '0' then
                  GFP_fifo_source_data  <= GFP2;
                  GFP_fifo_source_valid <= '1';
                else
                  GFP_fifo_source_valid <= '0';
                end if;
                word_in_packet  <= 3;
                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when 3 =>
                if first_section = '0' then
                  GFP_fifo_source_data  <= GFP3;
                  GFP_fifo_source_valid <= '1';
                else
                  GFP_fifo_source_valid <= '0';
                end if;
                word_in_packet  <= 4;
                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when 4 =>
                GFP_fifo_source_valid <= '0';
                -- FIX: is_short_pkt set from header nibble detection at beat 0
                -- Eliminates counter drift between TX framer and RX deframer.
                if (is_short_pkt = '1') then
                  word_in_packet       <= 0; -- short packet: skip beat 5
                  packet_total_counter <= packet_total_counter + 1;
                  if meta_counter = 6 then
                    meta_counter <= 0;
                    -- TIMESTAMP STROBE: a full metadata rotation just completed, so the
                    -- {Second_from_2000, Subsecond} register pair is a coherent sample at
                    -- this exact cycle (both are stable here). One pulse per rotation feeds
                    -- the time-sync servo (and fsm_main) with a fresh, well-spaced timestamp
                    -- valid -- far slower than any downstream CDC handshake latency, so the
                    -- captured data is never torn. (Replaces the dead first_section pulse.)
                    timestamp_valid_out <= '1';
                  else
                    meta_counter <= meta_counter + 1;
                  end if;
                else
                  word_in_packet <= 5; -- normal packet: go to beat 5
                end if;

                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when 5 =>
                -- Intermediate IQ beat: 7-beat LONG frame → advance to beat 6
                word_in_packet  <= 6;
                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when 6 =>
                -- Intermediate IQ beat: advance to beat 7
                GFP_fifo_source_valid <= '0';
                word_in_packet        <= 7;
                Sample_Fifo_din       <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we        <= not Sample_Fifo_full;
              when 7 =>
                -- Packet end (7 IQ beats: beats 1-7)
                packet_total_counter <= packet_total_counter + 1;
                word_in_packet       <= 0;
                if meta_counter = 6 then
                  meta_counter <= 0;
                  -- TIMESTAMP STROBE: see beat-4 note. One coherent pulse per metadata
                  -- rotation; {Second_from_2000, Subsecond} are stable at this cycle.
                  timestamp_valid_out <= '1';
                else
                  meta_counter <= meta_counter + 1;
                end if;
                Sample_Fifo_din <= Aurora_data_in (63 downto 0);
                Sample_Fifo_we  <= not Sample_Fifo_full;
              when others => null;
            end case;
            end if; -- end periodic-metadata-burst vs normal-data branch
          end if; -- LOCKEDs = '1' / '0'
          -- tlast hard-resync (only when locked): start the next frame at beat 0,
          -- mirroring MBU_FRAMER_GEN. Without this the RFU deframer would not realign
          -- after a finite-Frame_Length frame boundary (MBU framer asserts tlast there).
          if (LOCKEDs = '1') and (Aurora_last_in = '1') then
            word_in_packet <= 0;
            ts_armed       <= '1';   -- re-arm metadata_valid for the next frame
          end if;
        else
          -- Aurora_valid_in = '0' (gearbox stall/CC/idle).
          -- DO NOT reset word_in_packet: Aurora 64b/66b resumes the SAME packet
          -- after a stall. Resetting causes 1-beat misalignment: next IQ beat
          -- is treated as header -> metadata-as-data bug.
          -- Resync is handled solely by Aurora_last_in (tlast) below.
          Sample_Fifo_din       <= (others => '0');
          Sample_Fifo_we        <= '0';
          GFP_fifo_source_valid <= '0';
          timestamp_valid_out   <= '0';
          metadata_valid        <= '0';
        end if; -- Aurora_valid_in
      end if;
    end process;
  end generate;

  MBU_FRAMER_GEN : if RFU_MODE = "NO" generate
    DeEmbed_proc : process (Aurora_clk_in)
    begin
      if rising_edge(Aurora_clk_in) then
        if (Aurora_rst_in = '1') then
          word_40              <= 0;
          LOCKEDs              <= '1'; -- RFU never sends dummy frames: lock immediately
          Frame_Length         <= (others => '0');
          packet_counter       <= 0;
          word_in_packet       <= 0;
          first_section        <= '1';
          packet_total_counter <= 0;
          -- rate-matching reset
          meta_counter     <= 0;
          rate_sub         <= 0;
          is_short_pkt     <= '0';
          dummy_frame_done <= '0';
        elsif (Aurora_valid_in = '1') then
          dummy_frame_done <= '0'; -- default: no pulse
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
          -- RFU->MBU: no dummy frames. LOCKEDs='1' from reset -> always normal processing.
          -- LOCKEDs stays '1'; word_in_packet resets naturally at packet boundaries.
          -- LOCKEDs stays '1' once locked; word_in_packet resets naturally.
          -- Removed per-packet LOCKEDs reset: caused ~21MHz CDC toggle -> FIFO gaps.
          case word_in_packet is
            when 0 =>
              word_in_packet <= 1;
              -- FIX: Detect short packet from header nibble (x"8"=short, x"A"=normal)
              if Aurora_data_in(63 downto 60) = x"8" then
                is_short_pkt <= '1';
              else
                is_short_pkt <= '0';
              end if;
              -- Extract metadata from header beat
              first_section   <= '0';
              GFP1            <= Aurora_data_in(55 downto 48);
              GFP2            <= Aurora_data_in(47 downto 40);
              GFP3            <= Aurora_data_in(39 downto 32);
              SA_source_valid <= Aurora_data_in(56);
              SA_source_data  <= Aurora_data_in(31 downto 0);
              -- FIX: header beat must NOT write to IQ FIFO and must NOT
              -- assert GFP_fifo_source_valid (was leaking '1' from prev beat 3).
              Sample_Fifo_we        <= '0';
              Sample_Fifo_din       <= (others => '0');
              GFP_fifo_source_valid <= '0';
              if first_section = '1' then
                case meta_counter is
                  when 0      => Frame_Length <= Aurora_data_in(47 downto 0);
                  when others => null;
                end case;
              end if;
            when 1 =>
              GFP_fifo_source_data  <= GFP1;
              GFP_fifo_source_valid <= '1';
              word_in_packet        <= 2;
              Sample_Fifo_din       <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we        <= not Sample_Fifo_full;
            when 2 =>
              --if(packet_counter /=218) and ((packet_counter /=217)) then
              GFP_fifo_source_data  <= GFP2;
              GFP_fifo_source_valid <= '1';
              -- else
              --GFP_fifo_source_data             <= x"ff";
              --    GFP_fifo_source_valid             <= '0';
              --end if;
              word_in_packet  <= 3;
              Sample_Fifo_din <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we  <= not Sample_Fifo_full;
            when 3 =>
              --if(packet_counter /=218) and ((packet_counter /=217)) then
              GFP_fifo_source_data  <= GFP3;
              GFP_fifo_source_valid <= '1';
              --else
              --GFP_fifo_source_data             <= x"ff";
              --    GFP_fifo_source_valid             <= '0';
              --end if;
              word_in_packet  <= 4;
              Sample_Fifo_din <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we  <= not Sample_Fifo_full;
            when 4 =>
              GFP_fifo_source_valid <= '0';
              -- FIX: is_short_pkt set from header detection in beat 0 (not counter)
              -- Eliminates counter drift between framer and deframer.
              if (is_short_pkt = '1') then
                word_in_packet       <= 0; -- short packet: skip beat 5
                packet_total_counter <= packet_total_counter + 1;
                if meta_counter = 6 then
                  meta_counter <= 0;
                else
                  meta_counter <= meta_counter + 1;
                end if;
              else
                word_in_packet <= 5; -- normal packet: go to beat 5
              end if;

              Sample_Fifo_din <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we  <= not Sample_Fifo_full;
            when 5 =>
              -- Intermediate IQ beat: 7-beat LONG frame -> advance to beat 6
              word_in_packet  <= 6;
              Sample_Fifo_din <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we  <= not Sample_Fifo_full;
            when 6 =>
              -- Intermediate IQ beat: advance to beat 7
              GFP_fifo_source_valid <= '0';
              word_in_packet        <= 7;
              Sample_Fifo_din       <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we        <= not Sample_Fifo_full;
            when 7 =>
              -- Packet end (7 IQ beats total: beats 1-7)
              packet_total_counter <= packet_total_counter + 1;
              word_in_packet       <= 0;
              if meta_counter = 6 then
                meta_counter <= 0;
              else
                meta_counter <= meta_counter + 1;
              end if;
              Sample_Fifo_din <= Aurora_data_in (63 downto 0);
              Sample_Fifo_we  <= not Sample_Fifo_full;
            when others => null;
          end case;
          --TLAST RESYNC
          -- Force word_in_packet=0 at every packet boundary using Aurora_last_in.
          -- Safety net: if is_short_pkt detection is wrong (short->normal),
          -- the next packet's header would be processed at the wrong beat
          -- and written to Sample_Fifo as IQ data (metadata-as-data bug).
          -- tlast guarantees resync without touching Sample_Fifo_we
          -- (the last valid IQ beat write must not be cancelled).
          if (Aurora_last_in = '1') then
            word_in_packet <= 0;
          end if;
        else
          -- Aurora_valid_in = '0' (gearbox stall/CC/idle).
          -- DO NOT reset word_in_packet: Aurora 64b/66b resumes the SAME packet
          -- after a stall. Resetting causes 1-beat misalignment -> metadata-as-data.
          -- Resync handled by Aurora_last_in (tlast resync block below).
          Sample_Fifo_din       <= (others => '0');
          Sample_Fifo_we        <= '0';
          GFP_fifo_source_valid <= '0';
        end if; -- Aurora_valid_in
      end if;
    end process;
  end generate;
  Sample_rst_in_cdc : xpm_cdc_single
  generic map(
    DEST_SYNC_FF   => 4, -- DECIMAL; range: 2-10
    INIT_SYNC_FF   => 1, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    SIM_ASSERT_CHK => 1, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    SRC_INPUT_REG  => 1 -- DECIMAL; 0=do not register input, 1=register input
  )
  port map
  (
    dest_out => Sample_rst_in, -- 1-bit output: src_in synchronized to the destination clock domain. This output
    -- is registered.

    dest_clk => Sample_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
    src_clk  => Aurora_clk_in, -- 1-bit input: optional; required when SRC_INPUT_REG = 1
    src_in   => Aurora_rst_in -- 1-bit input: Input signal to be synchronized to dest_clk domain.
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
  IQ_DEFRAMER_INS : IQ_stream_FIFO
  port map
  (
    s_axis_aresetn => not Aurora_rst_in,
    s_axis_aclk    => Aurora_clk_in,
    s_axis_tvalid  => Sample_Fifo_we,
    s_axis_tready  => open,
    s_axis_tdata   => Sample_Fifo_din,
    m_axis_aclk    => Sample_clk_in,
    m_axis_tvalid  => fifo_valid,
    m_axis_tready  => fifo_ready and (enable_frame or LOCKEDs_dly(JITTER_IGNORE)),
    --m_axis_tready      => '1',
    m_axis_tdata       => Sample_Fifo_dout,
    axis_wr_data_count => wr_data_count,
    axis_rd_data_count => rd_data_count
  );

  -- IQ FIFO read-accept = m_axis_tvalid AND m_axis_tready (exact mirror of the port map above).
  -- The parallel last FIFO is popped on the SAME condition so its head stays word-aligned with
  -- the IQ FIFO head (Sample_Fifo_dout).
  iq_pop_s    <= fifo_valid and fifo_ready and (enable_frame or LOCKEDs_dly(JITTER_IGNORE));
  -- FIX 2026-09-08 (tvsdr_tb_slot_hop: RX frame_start 1 word = 2 samples EARLY on every frame).
  -- Sample_Fifo_we/din are REGISTERED in DeEmbed_proc (they describe the beat that was on the bus
  -- one clock earlier) while the last FIFO was fed Aurora_last_in RAW (the beat on the bus NOW), so
  -- the tlast flag was written next to the word BEFORE the frame's last word and the output demux
  -- closed the frame / pulsed Sample_frame_start one word early. Register tlast by the same clock
  -- (gated with valid) so both FIFOs describe the same beat.
  last_align_proc : process (Aurora_clk_in)
  begin
    if rising_edge(Aurora_clk_in) then
      Aurora_last_d1 <= Aurora_last_in and Aurora_valid_in;
    end if;
  end process;
  last_fifo_din(0) <= Aurora_last_d1;
  fifo_last_s <= last_fifo_dout(0) and (not last_fifo_empty);

  -- 1-bit async FIFO carrying tlast alongside each IQ word. depth 256 = IQ FIFO depth so it never
  -- overflows before the IQ FIFO (writes for both are gated by Sample_Fifo_full at IQ_HIGH_THR=224).
  last_flag_fifo : xpm_fifo_async
    generic map (
      FIFO_MEMORY_TYPE    => "distributed",
      FIFO_WRITE_DEPTH    => 256,
      WRITE_DATA_WIDTH    => 1,
      READ_DATA_WIDTH     => 1,
      READ_MODE           => "fwft",
      FIFO_READ_LATENCY   => 0,
      CDC_SYNC_STAGES     => 2,
      RELATED_CLOCKS      => 0,
      DOUT_RESET_VALUE    => "0",
      ECC_MODE            => "no_ecc",
      USE_ADV_FEATURES    => "0000",
      WAKEUP_TIME         => 0
    )
    port map (
      sleep         => '0',
      rst           => Aurora_rst_in,
      wr_clk        => Aurora_clk_in,
      wr_en         => Sample_Fifo_we,
      din           => last_fifo_din,
      full          => open,
      prog_full     => open,
      wr_data_count => open,
      overflow      => open,
      wr_rst_busy   => open,
      almost_full   => open,
      wr_ack        => open,
      rd_clk        => Sample_clk_in,
      rd_en         => iq_pop_s,
      dout          => last_fifo_dout,
      empty         => last_fifo_empty,
      prog_empty    => open,
      rd_data_count => open,
      underflow     => open,
      rd_rst_busy   => open,
      almost_empty  => open,
      data_valid    => open,
      injectsbiterr => '0',
      injectdbiterr => '0',
      sbiterr       => open,
      dbiterr       => open
    );

  GFP_FIFO_INS : GFP_fifo_0
  port map
  (
    s_axis_aresetn => not Aurora_rst_in,
    s_axis_aclk    => Aurora_clk_in,
    s_axis_tvalid  => GFP_fifo_source_valid,
    s_axis_tready  => open,
    s_axis_tdata   => GFP_fifo_source_data,
    m_axis_aclk    => GFP_clk,
    m_axis_tvalid  => GFP_valid_out,
    m_axis_tready  => GFP_ready_in,
    m_axis_tdata   => GFP_data_out
    --axis_wr_data_count    => GFP_fifo_write_counter,
    --axis_rd_data_count    => GFP_fifo_read_counter
  );
  SA_FIFO : SA_stream_FIFO
  port map
  (
    s_axis_aresetn => not Aurora_rst_in,
    s_axis_aclk    => Aurora_clk_in,
    s_axis_tvalid  => SA_valid_out,
    s_axis_tready  => open,
    s_axis_tdata   => SA_data_out,
    m_axis_aclk    => SA_clk,
    m_axis_tvalid  => SA_valid_out,
    m_axis_tready  => SA_ready_in,
    m_axis_tdata   => SA_data_out
    --axis_wr_data_count => wr_data_count,
    --axis_rd_data_count => rd_data_count
  );
  -- Custom 64->32 demux: eliminates the 1-cycle pipeline bubble of IQ_conver_width.
  -- iq_toggle='0': output lower 32b [31:0], hold FIFO (fifo_ready='0')
  -- iq_toggle='1': output upper 32b [63:32], advance FIFO (fifo_ready='1')
  -- fifo_ready gated by Sample_IQ_valid: only advance when output is enabled.
  -- Sample_IQ_rate_matching = Sample_IQ_valid (registered, enable-gated).
  -- underrun (STUFF condition): hold/repeat ONLY when the IQ FIFO is genuinely EMPTY. NOT gated by
  -- frame_win anymore -- the old "(not frame_win) or ..." asserted hold at frame boundaries while the
  -- FIFO still had data (frame_win closes at tlast then needs FIFO_FILL_THR to re-open), which
  -- repeated a sample and glitched the recovered stream at every frame transition. Now: data
  -- present (fifo_valid='1') -> always read (both 32-bit halves, drain to 0); empty -> hold.
  underrun                <= not fifo_valid;
  fifo_ready              <= iq_toggle and Sample_IQ_valid and (not underrun); -- no pop while stuffing
  -- Overrun drop: when the IQ FIFO reaches IQ_HIGH_THR (RX consumer slower than TX),
  -- assert Sample_Fifo_full to SUPPRESS IQ writes, dropping incoming words and clamping
  -- the FIFO below IQ_HIGH_THR. Drives Sample_Fifo_full (previously undriven), which gates
  -- every 'Sample_Fifo_we <= not Sample_Fifo_full' write in both RFU and MBU blocks.
  Sample_Fifo_full        <= '1' when wr_data_count >= IQ_HIGH_THR else '0';
  Sample_IQ_rate_matching <= Sample_IQ_valid; -- mirror registered valid, NOT raw fifo_valid
  Sample_IQ0              <= Sample_Fifo_dout(31 downto 0) when iq_toggle = '0' else Sample_Fifo_dout(63 downto 32);
  -- ila_deframer_inst2 (Aurora_clk IQ-datapath debug) REPLACED by ila_deframer_meta
  -- below, to capture the RX metadata + absolute timestamp for fixed-offset analysis.
  -- Original IQ-datapath probes (commented out to free its ILA resources on this
  -- near-full device; the IQ path is already characterised by ila_deframer_inst3):
  -- ila_deframer_inst2 : ila_framer
  -- port map (
  --   clk       => Aurora_clk_in,
  --   probe0(0) => Sample_Fifo_we,
  --   probe1    => Aurora_data_in,
  --   probe2(0) => Aurora_valid_in,
  --   probe3    => wrong_sample_sync,
  --   probe4    => Sample_Fifo_din,
  --   probe5(0) => Sample_Fifo_we,
  --   probe6    => std_logic_vector(to_unsigned(word_in_packet, 4)),
  --   probe7(0) => fifo_empty,
  --   probe8    => std_logic_vector(to_unsigned(rate_sub, 5)),
  --   probe9    => wr_data_count
  -- );

  -- NEW: metadata + absolute-timestamp capture (Aurora_clk domain). Trigger on probe0
  -- (timestamp_valid_out): at that exact cycle the {Second_from_2000, Subsecond} pair is
  -- the coherent RX absolute time decoded from the MBU link, so a captured window lets us
  -- read the received time vs the local NCO time and explain the fixed sync offset.
  --   probe0 = timestamp_valid_out (1b, TRIGGER)   probe1 = Second_from_2000 (40b -> 64b)
  --   probe2 = Aurora_valid_in (1b)                probe3 = Aurora_data_in (64b raw beat)
  --   probe4 = Tx_freq (48b -> 64b)                probe5 = LOCKEDs (1b)
  --   probe6 = meta_counter (4b)                   probe7 = metadata_valid (1b)
  --   probe8 = word_in_packet (5b)                 probe9 = Subsecond (27b -> 32b)
  -- 2026-08-07: bo 2 ILA deframer de giam tai dbg_hub (giu ila_fsm + vcsco_spi_ila).
  -- 2026-09-23: BAT LAI 2 ILA nay (ila_deframer_meta + ila_deframer_inst3) de quan sat
  --   metadata va du lieu IQ tu aurora. Chi phi ~14 BRAM tile => ~141/144 tren xcau15p
  --   (tien le build 04-05/08/2026: 140.5/144 van PASS, WNS +0.077). XDC dbg_hub da ghim
  --   clk = init_clk 100 MHz + C_ENABLE_CLK_DIVIDER=false nen cac core moi van enumerate.
  --   ila_deframer_inst2 (khoi tren) GIU NGUYEN trang thai comment.
  -- ------------------------------------------------------------------------
  -- ila_deframer_meta - BAT LAI 29/9/2026 de soi metadata RX ngay tai deframer.
  --
  -- Ly do: fsm_main nhin thay Next_Frame_Transmit_Time = 0 lien tuc (ban bat
  -- ila_fsm_dbg 29/9: NFTT = NFRT = 0 o 320/320 mau). Cau hoi con lai la so 0 do
  -- DEN TU DAU, va chi mot ban bat co CA beat tho LAN thanh ghi da giai ma moi
  -- tra loi duoc:
  --   H1  MBU phat timestamp rong  -> beat tho tai chi so meta 3 cung bang 0
  --   H2  deframer khong giai ma   -> beat tho KHAC 0 ma NFTT van 0
  --                                   (frame_meta_idx / burst_pkt khong bao gio
  --                                    toi 3, hoac in_frame_meta khong len)
  --
  -- NFTT co BA duong giai ma trong khoi nay - phai biet duong nao dang chay:
  --   a) truoc lock, dummy frame        : dummy_pkt_count = 3   (LOCKEDs = '0')
  --   b) burst metadata dinh ky, da lock: burst_pkt       = 3   (meta_burst_active = '1')
  --   c) meta noi tuyen dau frame       : frame_meta_idx  = 3   (in_frame_meta = '1')
  --
  -- STORAGE QUALIFIER dat o probe0 (ila_meta_qual) => 1024 mau = 1024 BEAT HEADER,
  -- phu hang tram frame. Neu qualify theo chu ky thuong thi 1024 mau chua het mot
  -- goi va gan nhu khong bao gio trung khoi metadata.
  --
  -- Ban do probe (khop scripts_ts/prep_ila_deframer_meta.tcl - sua mot ben la lech):
  --   probe0 (1)  ila_meta_qual   <- dat storage qualifier o day
  --   probe1 (64) Aurora_data_in  beat tho tu link, la bang chung goc
  --   probe2 (27) Next_Frame_Transmit_Time
  --   probe3 (27) Next_Frame_Receive_Time
  --   probe4 (4)  frame_meta_idx
  --   probe5 (4)  word_in_packet (0 = beat header)
  --   probe6 (8)  [7:4] dummy_pkt_count   [3:0] burst_pkt
  --   probe7 (8)  [7] LOCKEDs          [6] in_frame_meta      [5] meta_burst_active
  --               [4] first_section    [3] metadata_valid     [2] timestamp_valid_out
  --               [1] Aurora_last_in   [0] Aurora_valid_in
  --
  -- ila_deframer_inst3 (duong IQ) VAN TAT: bat ca hai la tran BRAM.
  -- Bat/tat lai bang: python3 scripts_ts/toggle_deframer_ila.py {off|on|status}
  -- ------------------------------------------------------------------------
  ila_meta_qual <= '1' when (Aurora_valid_in = '1' and word_in_packet = 0) else '0';

  ila_deframer_meta : ila_deframer_meta_ip
  port map
  (
    clk       => Aurora_clk_in,
    probe0(0) => ila_meta_qual,
    probe1    => Aurora_data_in,
    probe2    => Next_Frame_Transmit_Time,
    probe3    => Next_Frame_Receive_Time,
    probe4    => std_logic_vector(to_unsigned(frame_meta_idx, 4)),
    probe5    => std_logic_vector(to_unsigned(word_in_packet, 4)),
    probe6    => std_logic_vector(to_unsigned(dummy_pkt_count, 4)) &
                 std_logic_vector(to_unsigned(burst_pkt, 4)),
    probe7    => LOCKEDs & in_frame_meta & meta_burst_active & first_section &
                 metadata_valid & timestamp_valid_out & Aurora_last_in & Aurora_valid_in,
    probe8    => Tx_freq,
    probe9    => Rx_freq
  );

  --@DBGOFF ila_deframer_inst3 : ila_framer
  --@DBGOFF port map
  --@DBGOFF (
    --@DBGOFF clk       => Sample_clk_in,
    --@DBGOFF probe0(0) => Sample_IQ_valid,
    --@DBGOFF probe1    => Sample_IQ & Sample_IQ_delay,
    --@DBGOFF probe2(0) => miss_order,
    --@DBGOFF probe3    => wrong_sample,
    --@DBGOFF probe4    => Sample_Fifo_dout,
    --@DBGOFF probe5(0) => fifo_valid,
    --@DBGOFF probe6    => frame_win & underrun & hold_active & fifo_valid, -- [3]=frame_win [2]=underrun [1]=hold_active [0]=fifo_valid
    --@DBGOFF probe7(0) => LOCKEDs_dly(JITTER_IGNORE),
    --@DBGOFF probe8    => fifo_ready & enable_frame & enable_frame_dly & iq_toggle & iq_out_tready_sync,
    --@DBGOFF probe9    => rd_data_count
  --@DBGOFF );

  miss_order_ins : fifo_test
  port map
  (
    wr_clk => Sample_clk_in,
    rd_clk => Aurora_clk_in,
    din    => wrong_sample,
    wr_en  => miss_order,
    rd_en  => not fifo_empty,
    dout   => wrong_sample_sync,
    full   => fifo_full,
    empty  => fifo_empty
  );
  -- Elastic-buffer output FSM. Sample_IQ_valid stays '1' once started (DAC needs a
  -- sample every clock). Three states:
  --   STARTUP : output disabled until the IQ FIFO has filled to FIFO_FILL_THR.
  --   NORMAL  : FIFO above IQ_LOW_THR -> emit next sample, walk the 64->32 demux, pop.
  --   STUFF   : FIFO empty or <= IQ_LOW_THR -> HOLD the last sample (clean repeat),
  --             do not toggle, do not pop (fifo_ready gated by 'underrun') -> FIFO refills.
  process (Sample_clk_in)
    -- stall_cnt: consecutive STUFF cycles. Only used to re-align the I/Q demux after a
    -- genuine LONG stall (link loss); brief CC/ppm stuffs keep it small.
    variable stall_cnt : integer range 0 to 31 := 0;
  begin
    if (Sample_clk_in'event and Sample_clk_in = '1') then
      if (Sample_rst_in = '1') then
        Sample_IQ       <= (others => '0');
        Sample_IQ_valid <= '0';
        iq_toggle       <= '0';
        stall_cnt := 0;
        hold_active <= '0';
      elsif (enable_frame_dly = '0') and (LOCKEDs_dly(JITTER_IGNORE + 1) = '0') then
        -- STARTUP: IQ FIFO still filling to FIFO_FILL_THR; hold output off.
        Sample_IQ_valid <= '0';
        iq_toggle       <= '0';
        hold_active     <= '0';
        stall_cnt := 0;
      elsif (underrun = '0') then
        -- NORMAL: FIFO healthy. Emit next sample and advance the demux/FIFO.
        Sample_IQ       <= Sample_IQ0; -- mux: lower(31:0) when toggle=0, upper(63:32) when=1
        Sample_IQ_valid <= '1';
        if (iq_toggle = '1') and (fifo_last_s = '1') then
          -- FRAME BOUNDARY: this cycle pops the frame's LAST IQ word (tlast). Force the demux
          -- back to the lower half so the next frame's first word is decoded I-first. In the
          -- aligned case this equals 'not iq_toggle'; if the phase ever drifted (stuff/CC),
          -- it re-aligns here every frame instead of persisting.
          iq_toggle <= '0';
        else
          iq_toggle <= not iq_toggle;
        end if;
        hold_active     <= '0';
        stall_cnt := 0;
      else
        -- STUFF (underrun): repeat the LAST emitted sample. Sample_IQ and iq_toggle are
        -- HELD (no assignment) -> identical value re-output; valid stays '1' for the DAC;
        -- fifo_ready=0 (gated by underrun) -> no pop, so the FIFO refills.
        Sample_IQ_valid <= '1';
        hold_active     <= '1';
        if stall_cnt < 31 then
          stall_cnt := stall_cnt + 1;
        end if;
        if stall_cnt > 16 then
          -- LONG stall (genuine link loss): re-align demux so resume starts on the I half.
          iq_toggle <= '0';
        end if;
      end if;
    end if;
  end process;


  process (Sample_clk_in)
    constant DROUGHT_REARM_CYC : integer := 256; -- ~1us @250M; CC stall << muc nay
    variable drought_cnt : integer range 0 to DROUGHT_REARM_CYC := 0;
  begin
    if (Sample_clk_in'event and Sample_clk_in = '1') then
      if (Sample_rst_in = '1') then
        enable_frame     <= '0';
        enable_frame_dly <= '0';
        LOCKEDs_dly      <= (others => '0');
        drought_cnt := 0;
      else
        enable_frame_dly <= enable_frame;
        LOCKEDs_dly      <= LOCKEDs_dly(128 downto 0) & enable_frame;
        if (LOCKEDs_sync = '0') then
          enable_frame <= '0';
          drought_cnt := 0;
        else
          if (enable_frame = '0') then
            drought_cnt := 0;
            if (iq_out_tready_sync = '1') then
              enable_frame <= '1';
            end if;
          elsif (hold_active = '1') then
            if drought_cnt = DROUGHT_REARM_CYC then
              enable_frame <= '0';   -- drought re-arm: ve STARTUP tich cushion
              drought_cnt := 0;
            else
              drought_cnt := drought_cnt + 1;
            end if;
          else
            drought_cnt := 0;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Per-frame read window. Frame mode leaves an inter-frame rest gap, so the IQ FIFO drains
  -- between frames. Open the window only once a FIFO_FILL_THR cushion is buffered (iq_out_tready_sync),
  -- read the whole frame until its tlast (fifo_last_s popped via iq_pop_s), then close and wait for
  -- the next fill. Inside the window the demux reads every word (both 32-bit halves) down to empty;
  -- outside it the output holds (underrun) so the DAC never starves and miss_order is not checked.
  frame_win_proc : process (Sample_clk_in)
  begin
    if rising_edge(Sample_clk_in) then
      if (Sample_rst_in = '1') then
        frame_win <= '0';
      elsif (frame_win = '0') then
        if (iq_out_tready_sync = '1') then          -- cushion ready -> begin reading a frame
          frame_win <= '1';
        end if;
      else
        if (iq_pop_s = '1') and (fifo_last_s = '1') then  -- tlast sample read -> frame done
          frame_win <= '0';
        end if;
      end if;
    end if;
  end process;

  test_gfp_process : process (Aurora_clk_in)
  begin
    if (Aurora_clk_in'event and Aurora_clk_in = '1') then
      if (Aurora_rst_in = '1') then
        gfp_miss_order <= '0';
      else
        if (GFP_fifo_source_valid = '1') then
          GFP_fifo_source_data_dly  <= GFP_fifo_source_data;
          GFP_fifo_source_valid_dly <= '1';
          -- Only check ordering when previous beat was also valid
          if (GFP_fifo_source_valid_dly = '1') then
            if (GFP_fifo_source_data /= GFP_fifo_source_data_dly + '1') and
              (GFP_fifo_source_data >= x"01") then
              gfp_miss_order <= '1';
            else
              gfp_miss_order <= '0';
            end if;
          end if;
        else
          GFP_fifo_source_valid_dly <= '0';
          gfp_miss_order            <= '0';
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

  test_process : process (Sample_clk_in)
  begin
    if (Sample_clk_in'event and Sample_clk_in = '1') then
      if (Sample_rst_in = '1') then
        miss_order      <= '0';
        iq_half         <= '0';
        Sample_IQ_delay <= (others => '0');
        chk_started     <= '0';
      else
        -- Track the previous sample on EVERY real read (Sample_IQ_valid AND not a hold). A held
        -- repeat (underrun, FIFO empty) is NOT a transition, so it is skipped and the delay is KEPT
        -- (the ramp is contiguous across a brief hold: ...X, [hold X], X+1 -> X+1 vs X is +1). This
        -- avoids the false miss_order that resetting the delay caused on resume / frame transitions.
        -- miss_order is FLAGGED only inside the frame read window (frame_win) and after the first
        -- sample (chk_started), so the startup/refill is not counted.
        if (Sample_IQ_valid = '1') and (underrun = '0') then
          -- Check on EVERY real read (gated by chk_started, NOT frame_win): frame_win opens only
          -- when the FIFO reaches FIFO_FILL_THR which happens at startup but not at runtime (the
          -- FIFO settles well below FILL_THR), so gating the check on it disabled it entirely.
          if (chk_started = '1') then
            -- Flag ONLY a real disorder = a JUMP: data is neither prev+1 (normal ramp step) nor
            -- prev (a benign 1-sample repeat: elastic-buffer hold or iq_toggle frame-boundary
            -- realign). Repeats are not disorder, so do not flag them.
            if (Sample_IQ /= Sample_IQ_delay + 1) and (Sample_IQ /= Sample_IQ_delay) then
              miss_order   <= '1';
              wrong_sample <= Sample_IQ_delay & Sample_IQ;
            else
              miss_order <= '0';
            end if;
          else
            miss_order <= '0';
          end if;
          Sample_IQ_delay <= Sample_IQ;   -- update on every real read (so resume compares correctly)
          chk_started     <= '1';
          iq_half         <= not iq_half;
        else
          -- Hold (FIFO empty) or startup: NOT a real transition. Keep Sample_IQ_delay & chk_started.
          miss_order <= '0';
        end if;
      end if;
    end if;
  end process;

  -- synthesis translate_off
  ---------------------------------------------------------------------------
  -- SIMULATION-ONLY: dump all internal signals to CSV every clock cycle
  -- after Aurora_rst_in goes low.
  -- Output file: aurora_deframer_dump.txt (written to simulator working dir)
  -- Columns (Aurora_clk_in domain):
  --   clk, Aurora_data_in, valid_in, last_in, word_in_packet,
  --   meta_counter, rate_sub, is_short_pkt, first_section,
  --   LOCKEDs, dummy_pkt_count, dummy_in_pkt, dummy_frame_done,
  --   fifo_we, fifo_din, fifo_full, wr_cnt, rd_cnt,
  --   fifo_valid, fifo_ready, iq_toggle, Sample_IQ0, Sample_IQ_valid,
  --   pkt_total, enable_frame, gfp_valid, gfp_data, iq_out_tready
  ---------------------------------------------------------------------------
  -- -------------------------------------------------------------------------
  -- SIMULATION-ONLY: Sample_clk domain dump (IQ output signals)
  -- Separate from Aurora_clk dump to correctly capture fast Sample_clk domain.
  -- -------------------------------------------------------------------------
  sim_dump_sample : process (Sample_clk_in)
    file sfile      : text;
    variable sline  : line;
    variable s_open : boolean := false;
    variable s_cnt  : integer := 0;
  begin
    if rising_edge(Sample_clk_in) then
      if not s_open then
        file_open(sfile, "aurora_sample_dump.csv", write_mode);
        s_open := true;
        write(sline, string'("sclk,iq_toggle,Sample_IQ0,Sample_IQ_valid,Sample_IQ_rate_matching,fifo_valid,fifo_ready,enable_frame,enable_frame_dly,LOCKEDs_sync,iq_out_tready_sync,wr_data_count,rd_data_count,miss_order,iq_half"));
        writeline(sfile, sline);
      end if;
      -- Write every Sample_clk cycle
      write(sline, s_cnt);
      write(sline, ',');
      write(sline, iq_toggle);
      write(sline, ',');
      write(sline, to_hstring(Sample_IQ0));
      write(sline, ',');
      write(sline, Sample_IQ_valid);
      write(sline, ',');
      write(sline, Sample_IQ_rate_matching);
      write(sline, ',');
      write(sline, fifo_valid);
      write(sline, ',');
      write(sline, fifo_ready);
      write(sline, ',');
      write(sline, enable_frame);
      write(sline, ',');
      write(sline, enable_frame_dly);
      write(sline, ',');
      write(sline, LOCKEDs_sync);
      write(sline, ',');
      write(sline, iq_out_tready_sync);
      write(sline, ',');
      write(sline, to_hstring(wr_data_count));
      write(sline, ',');
      write(sline, to_hstring(rd_data_count));
      write(sline, ',');
      write(sline, miss_order);
      write(sline, ',');
      write(sline, iq_half);
      writeline(sfile, sline);
      s_cnt := s_cnt + 1;
    end if;
  end process;

  sim_dump_deframer : process (Aurora_clk_in)
    file dump_file    : text;
    variable v_line   : line;
    variable v_opened : boolean := false;
  begin
    if rising_edge(Aurora_clk_in) then
      -- Open file and write header on the very first call
      if not v_opened then
        file_open(dump_file, "aurora_deframer_dump.txt", write_mode);
        v_opened := true;
        write(v_line, string'("clk,Aurora_data_in,valid_in,last_in,word_in_packet,meta_counter,rate_sub,is_short_pkt,first_section,LOCKEDs,dummy_pkt_count,dummy_in_pkt,dummy_frame_done,fifo_we,fifo_din,fifo_full,wr_cnt,rd_cnt,fifo_valid,fifo_ready,iq_toggle,Sample_IQ0,Sample_IQ_valid,pkt_total,enable_frame,gfp_valid,gfp_data,iq_out_tready"));
        writeline(dump_file, v_line);
      end if;

      -- Dump only after reset is deasserted
      if Aurora_rst_in = '0' then
        sim_clock_count <= sim_clock_count + 1;

        write(v_line, sim_clock_count);
        write(v_line, string'(","));
        hwrite(v_line, Aurora_data_in);
        write(v_line, string'(","));
        write(v_line, Aurora_valid_in);
        write(v_line, string'(","));
        write(v_line, Aurora_last_in);
        write(v_line, string'(","));
        write(v_line, word_in_packet);
        write(v_line, string'(","));
        write(v_line, meta_counter);
        write(v_line, string'(","));
        write(v_line, rate_sub);
        write(v_line, string'(","));
        write(v_line, is_short_pkt);
        write(v_line, string'(","));
        write(v_line, first_section);
        write(v_line, string'(","));
        write(v_line, LOCKEDs);
        write(v_line, string'(","));
        write(v_line, dummy_pkt_count);
        write(v_line, string'(","));
        write(v_line, dummy_in_pkt);
        write(v_line, string'(","));
        write(v_line, dummy_frame_done);
        write(v_line, string'(","));
        write(v_line, Sample_Fifo_we);
        write(v_line, string'(","));
        hwrite(v_line, Sample_Fifo_din);
        write(v_line, string'(","));
        write(v_line, Sample_Fifo_full);
        write(v_line, string'(","));
        hwrite(v_line, wr_data_count);
        write(v_line, string'(","));
        hwrite(v_line, rd_data_count);
        write(v_line, string'(","));
        write(v_line, fifo_valid);
        write(v_line, string'(","));
        write(v_line, fifo_ready);
        write(v_line, string'(","));
        write(v_line, iq_toggle);
        write(v_line, string'(","));
        hwrite(v_line, Sample_IQ0);
        write(v_line, string'(","));
        write(v_line, Sample_IQ_rate_matching);
        write(v_line, string'(","));
        write(v_line, packet_total_counter);
        write(v_line, string'(","));
        write(v_line, enable_frame);
        write(v_line, string'(","));
        write(v_line, GFP_fifo_source_valid);
        write(v_line, string'(","));
        hwrite(v_line, GFP_fifo_source_data);
        write(v_line, string'(","));
        write(v_line, iq_out_tready);
        writeline(dump_file, v_line);
      end if;
    end if;
  end process sim_dump_deframer;
  -- synthesis translate_on

end Behavioral;

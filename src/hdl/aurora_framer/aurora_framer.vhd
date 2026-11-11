

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
entity aurora_framer is
  generic (
    RFU_MODE : string := "YES"
  );
  port (
    Aurora_data_out  : out std_logic_vector (63 downto 0);
    Aurora_last_out  : out std_logic;
    Aurora_keep_out  : out std_logic_vector(7 downto 0);
    Aurora_valid_out : out std_logic;
    Aurora_rdy_in    : in std_logic;
    Aurora_clk_in    : in std_logic;
    Aurora_rst_in    : in std_logic;

    GFP_data_in     : in std_logic_vector(7 downto 0) := (others => '1');
    GFP_valid_in    : in std_logic                    := '0';
    GFP_ready_out   : out std_logic                   := '0';
    GFP_last_in     : in std_logic                    := '0';
    GFP_clk_in      : in std_logic                    := '0';
    GFP_rst_in      : in std_logic                    := '1';
    
    Sample_IQ       		 : in std_logic_vector (63 downto 0);
    Sample_IQ_valid 		 : in std_logic;
    Sample_IQ_ready 		 : out std_logic;
    Sample_IQin_clk_375M	 : in std_logic:= '0'; 

    Frame_Length             : in std_logic_vector (47 downto 0) := (others => '1');
    Tx_freq                  : in std_logic_vector (47 downto 0) := (others => '0');
    Rx_freq                  : in std_logic_vector (47 downto 0) := (others => '0');
    Next_Frame_Transmit_Time : in std_logic_vector (26 downto 0) := (others => '0');
    Power_Tx                 : in std_logic_vector (7 downto 0)  := (others => '0');
    Rx_bw                    : in std_logic_vector (7 downto 0)  := (others => '0');
    Tx_bw                    : in std_logic_vector (7 downto 0)  := (others => '0');
    Next_Frame_Receive_Time  : in std_logic_vector (26 downto 0) := (others => '0');
    Second_from_2000         : in std_logic_vector (39 downto 0) := (others => '0');
    Subsecond                : in std_logic_vector (26 downto 0) := (others => '0');

    SA_data_in   : in std_logic_vector(31 downto 0) := (others => '1');
    SA_valid_in  : in std_logic                     := '0';
    SA_ready_out : out std_logic;
    SA_last_in   : in std_logic := '0';
    SA_clk_in    : in std_logic := '0';
    SA_rst_in    : in std_logic := '0';

    Sample_clk    : in std_logic;
    Sample_rst_in : in std_logic;

    -- Dummy frame control:
    -- '1' = current frame is dummy: metadata from inputs, IQ data forced to 0
    -- '0' = normal frame
    dummy_frame_in : in std_logic := '0'
  );
end aurora_framer;

architecture Behavioral of aurora_framer is
  --    component fifo_IQ IS
  --      PORT (
  --       -- srst : IN STD_LOGIC;
  --        wr_clk : IN STD_LOGIC;
  --        rd_clk : IN STD_LOGIC;
  --        din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  --        wr_en : IN STD_LOGIC;
  --        rd_en : IN STD_LOGIC;
  --        dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  --        rd_data _count   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
  --        wr_data_count   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
  --        full : OUT STD_LOGIC;
  --        empty : OUT STD_LOGIC
  --        --wr_rst_busy : OUT STD_LOGIC;
  --        --rd_rst_busy : OUT STD_LOGIC
  --      );
  --    END component fifo_IQ;
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
  end component IQ_stream_FIFO;
  component SA_fifo_0 is
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
  end component SA_fifo_0;
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
  signal word_40              : integer;-- range 0 to 39 := 0;
  signal wp                   : std_logic_vector (3 downto 0)  := (others => '0');
  signal GFP_SIGNATURE        : std_logic_vector (7 downto 0)  := x"AA";
  signal Sample_Fifo_din      : std_logic_vector (63 downto 0) := (others => '0');
  signal Sample_Fifo_highword : std_logic_vector (31 downto 0) := (others => '0');
  signal Sample_Fifo_re       : std_logic                      := '0';
  signal Sample_Fifo_re_gated : std_logic                      := '0'; -- re AND Aurora_rdy_in: prevents extra FIFO pop during gearbox stall
  signal Sample_Fifo_re_dly   : std_logic                      := '0';
  signal Sample_Fifo_re_dly1  : std_logic                      := '0';
  signal Sample_Fifo_high     : std_logic;
  signal Sample_Fifo_we       : std_logic                      := '0';
  signal Sample_Fifo_empty    : std_logic                      := '0';
  signal Sample_Fifo_dout     : std_logic_vector (63 downto 0) := (others => '0');
  signal latch_data_en        : std_logic;
  type shift_reg is array (31 downto 0) of std_logic_vector (63 downto 0);
  signal sample_delay                                  : shift_reg;
  signal latch_data_counter                            : integer range 0 to 31;
  signal load_data_counter                             : integer range 0 to 31;
  signal rd_data_count                                 : std_logic_vector(31 downto 0);
  signal wr_data_count                                 : std_logic_vector(31 downto 0);
  signal read_trigger, read_trigger_sync, enable_frame : std_logic;
  signal sample_counter                                : std_logic_vector (47 downto 0) := (others => '0');
  signal iq_sample_inframe                             : std_logic                      := '0';
  -- Finite-Frame_Length end is DEFERRED to the next packet boundary. Since 2026-09-08 the
  -- end is decided in the same cycle the packet's last beat is loaded (see FRAME END below);
  -- this flag only reports "length reached, waiting for the packet boundary" (ILA probe).
  signal frame_end_pending                             : std_logic                      := '0';
  signal packet_counter                                : integer := 0; -- kept for frame-length reset only
  signal packet_total_counter                          : integer := 0;
  signal word_in_packet                                : integer range 0 to 10;
  signal fifo_ready                                    : std_logic;
  signal fifo_valid                                    : std_logic;
  signal first_section                                 : std_logic := '1';
  --signal Sample_IQ_ready                                 : std_logic := '1';
  -- Dummy frame startup signals
  signal dummy_sent      : std_logic            := '0';
  signal dummy_sent_sync : std_logic            := '0'; -- dummy_sent synced Aurora_clk -> Sample_clk
  signal dummy_active    : std_logic            := '0';
  signal dummy_pkt_count : integer range 0 to 6 := 0; -- counts dummy packets sent (0..5 = 6 total)
  signal dummy_in_pkt    : std_logic            := '0'; -- '1' = currently inside a dummy packet beat
  -- dummy_frame_in re-arm (MBU): edge-detect a request to re-send the dummy startup
  -- sequence at the next frame boundary (e.g. new tx_freq for frequency hopping).
  signal dummy_frame_sync   : std_logic := '0'; -- dummy_frame_in synced to Aurora_clk
  signal dummy_frame_sync_d : std_logic := '0'; -- 1-cycle delay for rising-edge detect
  signal dummy_req          : std_logic := '0'; -- latched dummy-frame re-arm request
  -- Rate-matching (DYNAMIC SHORT/LONG): aurora_user_clk=156.25 MHz.
  -- DDS writes the TX FIFO at 125 Mwords/s. Packet read rates:
  --   LONG  (7 IQ / 8 beats) = 7/8 x 156.25 = 136.7 Mwords/s  (> 125 -> TX FIFO drains)
  --   SHORT (4 IQ / 5 beats) = 4/5 x 156.25 = 125.0 Mwords/s  (= 125 -> TX FIFO holds)
  -- Decision is taken at every packet END from the TX FIFO read-side level:
  --   rd_data_count < SHORT_PKT_THR  -> next packet SHORT (header x"8")
  --   else                            -> next packet LONG  (header x"A")
  -- Rationale: ALL-LONG starved the TX FIFO (read 136.7 > write 125), so the
  -- framer stalled on empty and starved the RX deframer FIFO -> Sample_IQ_valid
  -- dropped on HW. The SHORT packets keep the TX FIFO from emptying while LONG
  -- bursts (>125) let the deframer FIFO recover after Aurora CC gaps.
  -- The SHORT machinery (x"8" header, beat-4 terminate, deframer nibble detect)
  -- already exists in both framer and deframer; only this decision was missing.
  constant SHORT_PKT_THR : integer             := 7; -- LONG needs 7 words; below => SHORT
  constant TX_FIFO_LOW   : integer             := 32;
  constant TX_FIFO_HIGH  : integer             := 64;
  signal meta_counter   : integer range 0 to 6 := 0;
  signal rate_sub       : integer range 0 to 3 := 0; -- unused, kept for ILA
  signal is_short_pkt   : std_logic            := '0'; -- dynamic: set at packet end from rd_data_count
  -- EXACT-Frame_Length packet planner (fix 2026-09-08 #2, tvsdr_tb_slot_hop CC-stall findings).
  -- Payloads are fixed: SHORT = 4 IQ beats, LONG = 7. A frame can only close on a packet boundary,
  -- so with the FIFO-level rate-match alone the last packet may straddle Frame_Length and the frame
  -- overshoots by 0..6 beats -- cumulative across back-to-back frames (hop boundaries drift).
  -- rem_after = IQ beats still to send in the current frame AFTER the beat loaded this cycle
  -- (sample_counter = beats loaded before it). plan_short() keeps the remainder representable as
  -- 4a+7b (every n >= 18 is; below that only 4,7,8,11,12,14,15,16 are): for rem >= 25 either size
  -- is safe and the FIFO level decides as before; for smaller remainders the size is forced where
  -- the other one would leave an unreachable remainder {1,2,3,5,6,9,10,13,17}. Unreachable
  -- remainders themselves (only if Frame_Length < 18 is such a value) take the minimum overshoot.
  signal fifo_short_sel : std_logic;                          -- rd_data_count < SHORT_PKT_THR (FIFO says: SHORT)
  signal rem_after      : std_logic_vector(47 downto 0) := (others => '0');
  function plan_short(fifo_low : std_logic; rem_beats : std_logic_vector(47 downto 0)) return std_logic is
    variable r : integer range 0 to 31;
  begin
    if rem_beats(47 downto 5) /= 0 then
      return fifo_low;                                  -- >= 32 beats left: free choice
    end if;
    r := conv_integer(rem_beats(4 downto 0));
    case r is
      when 4 | 8 | 12 | 16 | 20 | 24 => return '1';     -- SHORT forced: LONG would leave 1/5/9/13/17 (or 4->-3)
      when 7 | 14 | 21               => return '0';     -- LONG forced : SHORT would leave 3/10/17
      when 5 | 6 | 13                => return '0';     -- unreachable : LONG gives the smaller overshoot
      when 1 | 2 | 3                 => return '1';     -- unreachable : SHORT gives the smaller overshoot
      when others                    => return fifo_low; -- 9,10,11,15,17,18,19,22,23,25..31 (and 0): free
    end case;
  end function;
  -------------------------GFP Port-------------------------------------------------------------------

  -- signal GFP_fifo_source_data        : std_logic_vector(7 downto 0);
  -- signal GFP_fifo_source_valid       : std_logic;
  -- signal GFP_fifo_source_ready       : std_logic;
  -- signal GFP_fifo_source_last        : std_logic;    

  signal GFP_fifo_sink_data  : std_logic_vector(7 downto 0);
  signal GFP_fifo_sink_valid : std_logic;
  signal GFP_fifo_sink_ready : std_logic;
  --signal GFP_fifo_sink_last        : std_logic;      
  signal GFP_fifo_read_counter  : std_logic_vector(31 downto 0);
  signal GFP_fifo_write_counter : std_logic_vector(31 downto 0);
  signal GFP1                   : std_logic_vector(7 downto 0);
  signal GFP2                   : std_logic_vector(7 downto 0);
  signal GFP3                   : std_logic_vector(7 downto 0);

  -------------------------Spectrum Analyzer Port-------------------------------------------------------------------
  signal SA_source_data  : std_logic_vector(31 downto 0);
  signal SA_source_valid : std_logic;
  signal SA_source_ready : std_logic;
  -- TX FIFO hysteresis gate (Aurora_clk domain)
  signal tx_fifo_ok : std_logic := '0';
  -- synthesis translate_off
  signal sim_clock_count : integer := 0; -- simulation-only cycle counter
  -- synthesis translate_on
  --signal SA_source_last        : std_logic;    
begin
  --Sample_IQ_ready <=  (not Sample_Fifo_full) and Aurora_rdy_in;
  -- Sample_IQ_ready: in MBU mode (dummy_sent gated), in RFU mode (immediate ready).
  -- RFU->MBU: no dummy frame, accept IQ data immediately when FIFO ready.
  -- MBU->RFU: hold until dummy frame sent so Aurora credit loop is active first.
  -----------------------Sample_IQ_ready <= fifo_ready when (RFU_MODE = "YES" or dummy_sent_sync = '1') else  -- Claudio 050726
  -----------------------  '0';
  -- read_trigger: assert when the TX IQ FIFO has data. PURE Sample_clk domain
  -- (wr_data_count is the FIFO write-side count) -> feeds read_trigger_inst (src_clk=Sample_clk).
  -- first_section was REMOVED from this expression: it is an Aurora_clk-domain FF, and mixing
  -- it into this Sample_clk signal created a CDC/timing violation (Aurora_clk FF sampled by
  -- Sample_clk inside the CDC). enable_frame latches once on read_trigger_sync's 0->1 in the
  -- Aurora_clk FSM and first_section is managed there, so gating it here is unnecessary.
  read_trigger <= '1' when wr_data_count >= x"000000010" else
    '0';
  Aurora_keep_out      <= x"ff";
  Sample_Fifo_re_gated <= Sample_Fifo_re and Aurora_rdy_in;
  -- exact-Frame_Length planner inputs (see plan_short): TX FIFO level + beats left after this beat
  fifo_short_sel <= '1' when (rd_data_count < SHORT_PKT_THR) else '0';
  rem_after   <= Frame_Length - sample_counter - '1';
  Sample_Fifo_re_dly1  <= fifo_valid and Sample_Fifo_re_gated;
  Sample_Fifo_empty    <= not fifo_valid;

  -- TX FIFO hysteresis: stop Aurora early (at LOW) to avoid long empty stall.
  -- Hysteresis removed: tx_fifo_ok caused forced 42-cycle TX stop every 62us,
  -- draining RX FIFO 32 words per stop -  >RX FIFO empties after 4 stops.
  -- With (7,1,8): TX drains TX FIFO at 33 Mbps; stall only when truly empty
  -- (1-2 cycles per 4ms) -> negligible RX impact.
  tx_fifo_ok <= not Sample_Fifo_empty; -- direct gate: stop only when TX FIFO truly empty

  -- dummy_frame_in: control request to re-insert a dummy startup frame. It is in the
  -- Sample_clk domain, synchronized to Aurora_clk by dummy_frame_in_cdc (below) and
  -- edge-detected in MBU_FRAMER_GEN. A rising edge latches dummy_req; at the next frame
  -- end (Aurora_last_out='1') dummy_sent is reset to '0', so the next frame re-sends the
  -- zero-IQ dummy startup packets (used by frequency hopping to re-sync RX metadata).
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
  generic map(
    DEST_SYNC_FF   => 4, -- DECIMAL; range: 2-10
    INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    SRC_INPUT_REG  => 1 -- DECIMAL; 0=do not register input, 1=register input
  )
  port map
  (
    dest_out => read_trigger_sync, -- 1-bit output: src_in synchronized to the destination clock domain. This output
    -- is registered.

    dest_clk => Aurora_clk_in, -- 1-bit input: Clock signal for the destination clock domain.
    src_clk  => Sample_clk, -- 1-bit input: optional; required when SRC_INPUT_REG = 1
    src_in   => read_trigger -- 1-bit input: Input signal to be synchronized to dest_clk domain.
  );

  -- CDC: dummy_sent (Aurora_clk) -> Sample_clk. dummy_sent gates Sample_IQ_ready, a
  -- Sample_clk handshake to the IQ source; sampling the Aurora_clk FF directly is a CDC
  -- violation. Level signal (set once at startup, then held) -> 2FF synchronizer is safe.
  dummy_sent_cdc : xpm_cdc_single
  generic map(
    DEST_SYNC_FF   => 4,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 1
  )
  port map
  (
    dest_out => dummy_sent_sync,
    dest_clk => Sample_clk,
    src_clk  => Aurora_clk_in,
    src_in   => dummy_sent
  );

  -- CDC: dummy_frame_in (Sample_clk) -> Aurora_clk, then edge-detected in the MBU FSM.
  -- dummy_frame_in is a control request, so it must be synchronized before the Aurora_clk
  -- FSM samples it (a raw cross-domain edge would be a CDC hazard).
  dummy_frame_in_cdc : xpm_cdc_single
  generic map(
    DEST_SYNC_FF   => 4,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 1
  )
  port map
  (
    dest_out => dummy_frame_sync,
    dest_clk => Aurora_clk_in,
    src_clk  => Sample_clk,
    src_in   => dummy_frame_in
  );

--  process (Sample_clk)
--	  begin
--		if rising_edge(Sample_clk) then
--		  if (Sample_rst_in = '1') then
--			--Sample_Fifo_we   <= '0';
--			Sample_Fifo_high <= '1';
--			--elsif (Sample_IQ_valid = '1') and ( Sample_Fifo_full = '0') then
--		  elsif (Sample_IQ_valid = '1') and (fifo_ready = '1') then
--			if (Sample_Fifo_high = '1') then
--			  Sample_Fifo_highword <= Sample_IQ;
--			  --Sample_Fifo_we       <= '0';
--			else
--			  --Sample_Fifo_we  <= '1';
--			  Sample_Fifo_din <= Sample_IQ & Sample_Fifo_highword;
--			end if;
--			Sample_Fifo_high <= not Sample_Fifo_high;
--		  else
--			--Sample_Fifo_we <= '0';
--		  end if;
--		end if;
--	  end process;


  IQ_FIFO : IQ_stream_FIFO
  port map
  (
    s_axis_aresetn     => not Sample_rst_in,
    s_axis_aclk        => Sample_IQin_clk_375M,
    s_axis_tvalid      => Sample_IQ_valid,--Sample_Fifo_we,
    s_axis_tready      => Sample_IQ_ready,--fifo_ready,
    s_axis_tdata       => Sample_IQ,--Sample_Fifo_din,
    m_axis_aclk        => Aurora_clk_in,
    m_axis_tvalid      => fifo_valid,
    m_axis_tready      => Sample_Fifo_re_gated,
    m_axis_tdata       => Sample_Fifo_dout,
    axis_wr_data_count => wr_data_count,
    axis_rd_data_count => rd_data_count
  );
  GFP_FIFO_INS : GFP_fifo_0
  port map
  (
    s_axis_aresetn => GFP_rst_in,
    s_axis_aclk    => GFP_clk_in,
    s_axis_tvalid  => GFP_valid_in,
    s_axis_tready  => GFP_ready_out,
    s_axis_tdata   => GFP_data_in,
    m_axis_aclk    => Aurora_clk_in,
    m_axis_tvalid  => GFP_fifo_sink_valid,
    m_axis_tready  => GFP_fifo_sink_ready,
    m_axis_tdata   => GFP_fifo_sink_data
    --axis_wr_data_count    => GFP_fifo_write_counter,
    --axis_rd_data_count    => GFP_fifo_read_counter
  );
  SA_FIFO : SA_fifo_0
  port map
  (
    s_axis_aresetn => SA_rst_in,
    s_axis_aclk    => SA_clk_in,
    s_axis_tvalid  => SA_valid_in,
    s_axis_tready  => SA_ready_out,
    s_axis_tdata   => SA_data_in,
    m_axis_aclk    => Aurora_clk_in,
    m_axis_tvalid  => SA_source_valid,
    m_axis_tready  => SA_source_ready,
    m_axis_tdata   => SA_source_data
    --axis_wr_data_count => wr_data_count,
    --axis_rd_data_count => rd_data_count
  );
  --    ASYNC_FIFO: fifo_IQ 
  --      PORT MAP(
  --       -- srst => Aurora_rst_in,
  --        wr_clk => Sample_clk,
  --        rd_clk => Aurora_clk_in,
  --        din => Sample_Fifo_din,
  --        wr_en => Sample_Fifo_we,
  --        rd_en => Sample_Fifo_re, n      
  --        dout => Sample_Fifo_dout,
  --        full => Sample_Fifo_full,
  --        empty => Sample_Fifo_empty,
  --        rd_data_count => rd_data_count,
  --        wr_data_count => wr_data_count
  --        --wr_rst_busy => Sample_Fifo_wr_rst_busy,
  --        --rd_rst_busy => Sample_Fifo_rd_rst_busy
  --      );   
  --fs <= '1' when word_40 = 3 else '0'   ;

  -- ILA: capture same signals as waveform.csv
  -- probe0: fifo_valid         (1b)
  -- probe1: Aurora_data_out    (64b)
  -- probe2: Aurora_valid_out   (1b)
  -- probe3: Aurora_rdy_in      (1b)
  -- probe4: Sample_Fifo_dout   (64b)
  -- probe5: Sample_Fifo_re     (1b)
  -- probe6: word_in_packet     (4b)
  -- probe7: is_short_pkt       (1b)
  -- probe8: rate_sub           (2b,)
  -- probe9: rd_data_count      (32b)
  --
  -- TX FRAME-END VERIFICATION (finite Frame_Length): the upper bits of probe3 carry
  -- the signals needed to confirm, on hardware, that a finite frame ends cleanly on a
  -- packet boundary. Trigger on probe3[34] (Aurora_last_out) rising:
  --   probe3[34]    = Aurora_last_out   (tlast: frame boundary)
  --   probe3[35]    = frame_end_pending (length reached, waiting for packet boundary)
  --   probe3[36]    = enable_frame      (framing active)
  --   probe3[37]    = iq_sample_inframe (IQ counting started)
  --   probe3[63:38] = sample_counter[25:0] (beats counted into the frame)
  -- Combined with probe1=Aurora_data_out, probe2=Aurora_valid_out, probe6=word_in_packet,
  -- probe7=is_short_pkt this fully characterises each transmitted frame.
  -- ila_framer_inst : ila_framer
  -- port map
  -- (
  --   clk                 => Aurora_clk_in,
  --   probe0(0)           => fifo_valid,
  --   probe1              => Aurora_data_out,
  --   probe2(0)           => Aurora_valid_out,
  --   probe3(33 downto 0) => GFP1 & GFP2 & GFP3 & GFP_fifo_sink_data & GFP_fifo_sink_valid & Aurora_rdy_in,
  --   probe3(34)          => Aurora_last_out,
  --   probe3(35)          => frame_end_pending,
  --   probe3(36)          => enable_frame,
  --   probe3(37)          => iq_sample_inframe,
  --   probe3(63 downto 38) => sample_counter(25 downto 0),
  --   probe4              => Sample_Fifo_dout,
  --   probe5(0)           => Sample_Fifo_re,
  --   probe6              => std_logic_vector(to_unsigned(word_in_packet, 4)),
  --   probe7(0)           => is_short_pkt,
  --   probe8              => std_logic_vector(to_unsigned(rate_sub, 5)),
  --   probe9              => rd_data_count
  -- );

  MBU_RFU_MODE : if RFU_MODE = "NO" generate
    -- GFP bytes are read at beats 1,2,3 for ALL packets in new meta_counter scheme.
    -- Old packet_counter /= 216/217 exceptions removed (no longer exist).
    GFP_fifo_sink_ready <= '1' when ((word_in_packet = 1) or (word_in_packet = 2) or (word_in_packet = 3)) and (Sample_Fifo_empty = '0') and (Aurora_rdy_in = '1') else
      '0';
  end generate;
  RFU_RFU_MODE : if RFU_MODE = "YES" generate
    GFP_fifo_sink_ready <= '1' when ((word_in_packet = 1) or (word_in_packet = 2) or (word_in_packet = 3)) and (Sample_Fifo_empty = '0') and (Aurora_rdy_in = '1') else
      '0';
  end generate;
  --GFP_fifo_sink_ready <= '1' when (word_in_packet = 0) or ((word_in_packet = 1) or (word_in_packet = 2)) else '0'; 

  SFP_proc : process (Aurora_clk_in)
  begin
    if rising_edge(Aurora_clk_in) then
      if (Aurora_rst_in = '1') then
        GFP1 <= (others => '0');
        GFP2 <= (others => '0');
        GFP3 <= (others => '0');
      else
        -- Latch GFP bytes at beats 1,2,3 for embedding in metadata word.
        -- Beat 1: always latch GFP1 (present in every packet).
        -- Beats 2,3: latch GFP2/3 only after initial metadata phase
        --   (meta_counter >= 1 means first_section already cleared).
        if (word_in_packet = 1) and (Aurora_rdy_in = '1') then
          if (GFP_fifo_sink_valid) then
            GFP1 <= GFP_fifo_sink_data;
          else
            GFP1 <= x"FF";
          end if;
        elsif (word_in_packet = 2) and (Aurora_rdy_in = '1') then
          if first_section = '0' then -- after initial metadata phase
            if (GFP_fifo_sink_valid) then
              GFP2 <= GFP_fifo_sink_data;
            else
              GFP2 <= x"FF";
            end if;
          end if;
        elsif (word_in_packet = 3) and (Aurora_rdy_in = '1') then
          if first_section = '0' then -- after initial metadata phase
            if (GFP_fifo_sink_valid) then
              GFP3 <= GFP_fifo_sink_data;
            else
              GFP3 <= x"FF";
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
  RFU_FRAMER_GEN : if RFU_MODE = "YES" generate
    process (Aurora_clk_in)
    begin
      if rising_edge(Aurora_clk_in) then
        if (Aurora_rst_in = '1') then
          Aurora_valid_out <= '0';
          word_40          <= 0;
          Sample_Fifo_re   <= '0';
          Aurora_data_out  <= (others => '0');
          wp               <= (others => '0');
          latch_data_en    <= '0';
          --sample_delay    <= (others => (others => '0'));
          latch_data_counter <= 0;
          Sample_Fifo_re_dly <= '0';
          --Sample_Fifo_re_dly1 <= '0';
          load_data_counter <= 0;
          enable_frame      <= '0';
          word_in_packet    <= 0;
          packet_counter    <= 0;
          first_section     <= '1';
          frame_end_pending <= '0';
          -- sample_counter was NOT cleared here, so it survived Aurora_rst_in. After a
          -- protocol restart (slot_hop_gen S_RESET, or any aurora_rst) the first frame of
          -- the new burst closed after only (Frame_Length - stale_count) beats -- measured
          -- 7 beats / 14 samples with a stale 1693 and Frame_Length=1700. Every later frame
          -- was the right length but the whole frame grid stayed shifted by that runt, so
          -- the tlast boundary never lined up with the hop boundary (hop_samples) and the
          -- Frame_Length announced in meta0 no longer described the first frame.
          sample_counter    <= (others => '0');
          iq_sample_inframe <= '0';   -- ILA/debug only since the 2026-09-08 load-time count
          -- ALL-LONG: is_short_pkt always '0', rate_sub unused
          meta_counter <= 0;
          rate_sub     <= 0;
          is_short_pkt <= '0';

        else
          -- Default: Aurora_last_out='0' (AXI-Stream: tlast valid only with tvalid='1').
          -- BUG FIX (AXI-Stream tlast HOLD, mirror of MBU_FRAMER_GEN fix 2026-06-22):
          -- only clear tlast when NO beat is pending acceptance. If Aurora_rdy_in falls
          -- on the cycle the frame-end tlast beat is presented, this unconditional default
          -- used to clear last while valid/data were held -> the last beat was accepted
          -- WITHOUT tlast -> MBU deframer misses its word_in_packet resync. Hold last
          -- asserted until the beat is accepted (tvalid&tready). (Valid/data already hold:
          -- this RFU block has no inter-frame else, so they are not reassigned when idle.)
          if not (Aurora_valid_out = '1' and Aurora_rdy_in = '0') then
            Aurora_last_out <= '0';
          end if;
          -- RFU -> MBU direction: no dummy frame startup (dummy frames only from MBU->RFU).
          -- Enable normal framer as soon as TX FIFO has data.
          if (read_trigger_sync = '1') then
            enable_frame <= '1';
            if (enable_frame = '0') then -- only on initial 0->1 transition
              first_section  <= '1';
              word_in_packet <= 0; -- restart each frame at beat 0 (case skipped this cycle: enable_frame still '0')
            end if;
          end if;
          if (enable_frame = '1') then
            --Sample_Fifo_re_dly <= Sample_Fifo_re;
            --Sample_Fifo_re_dly1 <= Sample_Fifo_re_dly;
            -- Latch FIFO data in 3 cases:
            -- 1. Already in a burst (latch_data_en='1')
            -- 2. Beat 0 pre-fetch (word_in_packet=0)
            -- 3. Gearbox stall mid-packet: Aurora_rdy_in='0' and re was '1' last cycle
            --  FIFO consumed 1 extra word; capture it to prevent data loss
            if (Sample_Fifo_re_dly1 = '1') and
              ((latch_data_en = '1') or (word_in_packet = 0) or
              (Aurora_rdy_in = '0' and word_in_packet /= 0)) then
              latch_data_en                    <= '1';
              sample_delay(latch_data_counter) <= Sample_Fifo_dout;
              latch_data_counter               <= latch_data_counter + 1;
            end if;
            if (Aurora_rdy_in = '1') then
              -- Finite Frame_Length: IQ beats are counted where they are LOADED (after the
              -- case below), never here -- see FRAME END. The old acceptance-time count
              -- (iq_sample_inframe) advanced every cycle while the TX FIFO was empty.
              --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1') or (word_in_packet = 0))) then
              --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1'))) then
              if (tx_fifo_ok = '1') then
                Aurora_valid_out <= '1';
                case word_in_packet is
                  when 0 =>
                    -- Beat 0: output metadata, pre-fetch FIFO word #1
                    Sample_Fifo_re  <= '1';
                    word_in_packet  <= 1;
                    SA_source_ready <= '0';
                    -- Metadata mux uses meta_counter (0..6)
                    if (first_section = '1') then
                      -- FIX: first_section forces x"A" (normal packet).
                      -- MUST also clear is_short_pkt and reset rate_sub here
                      -- so beat 4 does NOT skip beat 5.
                      -- Without this, is_short_pkt='1' from a previous packet
                      -- causes the framer to output x"A" at beat 0 (first_section
                      -- override) but still skip beat 5 at beat 4, misaligning
                      -- the deframer (which saw x"A" and expects 5 IQ beats).
                      Aurora_data_out <= x"A" & "000" & SA_source_valid & GFP1 & GFP2 & GFP3 & SA_source_data;
                      first_section   <= '0';
                      is_short_pkt    <= '0'; -- force normal packet: do not skip beat 5
                      rate_sub        <= 0; -- restart rate counter from 0
                    else
                      -- is_short_pkt='1' => mark short packet with "8" prefix
                      if (is_short_pkt = '1') then
                        Aurora_data_out <= x"8" & "000" & SA_source_valid & GFP1 & GFP2 & GFP3 & SA_source_data;
                      else
                        Aurora_data_out <= x"A" & "000" & SA_source_valid & GFP1 & GFP2 & GFP3 & SA_source_data;
                      end if;
                    end if;
                    iq_sample_inframe <= '0';
                  when 1 =>
                    word_in_packet    <= 2;
                    iq_sample_inframe <= '1';
                    if (load_data_counter < latch_data_counter) then
                      Aurora_data_out   <= sample_delay(load_data_counter);
                      load_data_counter <= load_data_counter + 1;
                    else
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      Aurora_data_out    <= Sample_Fifo_dout;
                      latch_data_en      <= '0';
                    end if;
                    Sample_Fifo_re  <= '1';
                    SA_source_ready <= '0';
                  when 2 =>
                    word_in_packet    <= 3;
                    iq_sample_inframe <= '1';
                    if (load_data_counter < latch_data_counter) then
                      Aurora_data_out   <= sample_delay(load_data_counter);
                      load_data_counter <= load_data_counter + 1;
                    else
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      Aurora_data_out    <= Sample_Fifo_dout;
                      latch_data_en      <= '0';
                    end if;
                    Sample_Fifo_re  <= '1';
                    SA_source_ready <= '0';
                  when 3 =>
                    word_in_packet    <= 4;
                    iq_sample_inframe <= '1';
                    if (load_data_counter < latch_data_counter) then
                      Aurora_data_out   <= sample_delay(load_data_counter);
                      load_data_counter <= load_data_counter + 1;
                    else
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      Aurora_data_out    <= Sample_Fifo_dout;
                      latch_data_en      <= '0';
                    end if;
                    Sample_Fifo_re  <= '1';
                    SA_source_ready <= '0';

                  when 4 =>
                    -- Rate matching: is_short_pkt was decided at the PREVIOUS packet end
                    -- (beat 4/7) from TX rd_data_count. '1' => this is a SHORT packet
                    -- (4 IQ, ends here at beat 4); next type decided below.
                    if (is_short_pkt = '1') then
                      -- -- Short packet: beat 4 is last -> assert tlast (only in framed mode)
                      -- -- BUG FIX: do NOT assert Aurora_last_out in streaming mode
                      -- -- (Frame_Length=0xFFFF...). In streaming mode the framer-level
                      -- -- Aurora_last_out <= '0' guard runs BEFORE this case block but the
                      -- -- assignment here was overriding it (last VHDL assignment wins).
                      -- if Frame_Length /= x"ffffffffffff" then
                      --   Aurora_last_out <= '1';
                      -- end if;
                      word_in_packet       <= 0;
                      Sample_Fifo_re       <= '0';
                      SA_source_ready      <= '1';
                      packet_total_counter <= packet_total_counter + 1;
                      -- Update meta and rate counters
                      if meta_counter = 6 then
                        meta_counter <= 0;
                      else
                        meta_counter <= meta_counter + 1;
                      end if;
                      -- Dynamic rate-match: pick next packet type from TX FIFO level.
                      if (rd_data_count < SHORT_PKT_THR) then
                        is_short_pkt <= '1'; -- TX FIFO low -> next packet SHORT
                      else
                        is_short_pkt <= '0'; -- TX FIFO ok  -> next packet LONG
                      end if;
                    else
                      -- Normal packet: advance to beat 5
                      word_in_packet  <= 5;
                      Sample_Fifo_re  <= '1';
                      SA_source_ready <= '0';
                    end if;
                    -- IQ data output (always at beat 4)
                    iq_sample_inframe <= '1';
                    if (load_data_counter < latch_data_counter) then
                      Aurora_data_out   <= sample_delay(load_data_counter);
                      load_data_counter <= load_data_counter + 1;
                    else
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      Aurora_data_out    <= Sample_Fifo_dout;
                      latch_data_en      <= '0';
                    end if;
                  when 5 =>
                    -- Intermediate IQ beat: 7-beat frame → advance to beat 6
                    -- Beats 5-7 are pure IQ: bypass sample_delay buffer entirely.
                    word_in_packet     <= 6;
                    Sample_Fifo_re     <= '1';
                    iq_sample_inframe  <= '1';
                    load_data_counter  <= 0;
                    latch_data_counter <= 0;
                    latch_data_en      <= '0';
                    Aurora_data_out    <= Sample_Fifo_dout;
                  when 6 =>
                    -- Intermediate IQ beat: advance to beat 7
                    word_in_packet     <= 7;
                    Sample_Fifo_re     <= '1';
                    iq_sample_inframe  <= '1';
                    load_data_counter  <= 0;
                    latch_data_counter <= 0;
                    latch_data_en      <= '0';
                    Aurora_data_out    <= Sample_Fifo_dout;
                  when 7 =>
                    -- -- Packet end: 7 IQ beats + 1 header = 8-beat frame (87.5% IQ)
                    -- -- re='0': beat 0 of next packet already has re='1' (pre-fetch),
                    -- -- which advances FIFO from W6 to W7 for next packet's beat 1.
                    -- -- Adding re='1' here would double-advance and skip one word.
                    -- if Frame_Length /= x"ffffffffffff" then
                    --   Aurora_last_out <= '1';
                    -- end if;
                    word_in_packet       <= 0;
                    SA_source_ready      <= '1';
                    Sample_Fifo_re       <= '0';
                    packet_total_counter <= packet_total_counter + 1;
                    iq_sample_inframe    <= '1';
                    if meta_counter = 6 then
                      meta_counter <= 0;
                    else
                      meta_counter <= meta_counter + 1;
                    end if;
                    -- Dynamic rate-match + exact-Frame_Length planner (fix 2026-09-08 #2, see plan_short):
                    -- the TX FIFO level picks SHORT/LONG unless the beats left in the frame force the size.
                    -- If this beat closes the frame (counter >= FL-1, the FRAME END block below fires) the
                    -- next packet opens a fresh frame of Frame_Length beats.
                    if (Frame_Length = x"ffffffffffff") then
                      is_short_pkt <= fifo_short_sel;                       -- stream mode: FIFO level only
                    elsif (sample_counter >= Frame_Length - '1') then
                      is_short_pkt <= plan_short(fifo_short_sel, Frame_Length);
                    else
                      is_short_pkt <= plan_short(fifo_short_sel, rem_after);
                    end if;
                    load_data_counter  <= 0;
                    latch_data_counter <= 0;
                    latch_data_en      <= '0';
                    Aurora_data_out    <= Sample_Fifo_dout;
                  when others => null;
                end case;
                -- FRAME END (fix 2026-09-08, mirror of MBU_FRAMER_GEN -- see the note there).
                -- word_in_packet still holds the arm that just ran: 1..7 = one IQ beat loaded.
                -- Count it now and end the frame on the packet's last beat (7, or 4 of a
                -- SHORT packet) iff that beat brings the frame to Frame_Length.
                if (word_in_packet /= 0) then
                  if (Frame_Length /= x"ffffffffffff") and
                     ((word_in_packet = 7) or (word_in_packet = 4 and is_short_pkt = '1')) and
                     (sample_counter >= Frame_Length - '1') then
                    Aurora_last_out   <= '1';
                    enable_frame      <= '0';
                    first_section     <= '1';
                    sample_counter    <= (others => '0');
                    packet_counter    <= 0;
                    word_40           <= 0;
                    wp                <= (others => '0');
                    frame_end_pending <= '0';
                  else
                    sample_counter <= sample_counter + '1';
                    if (Frame_Length /= x"ffffffffffff") and (sample_counter >= Frame_Length - '1') then
                      frame_end_pending <= '1'; -- length reached mid-packet (ILA probe only)
                    end if;
                  end if;
                end if;
              else
                -- TX FIFO empty: hold valid='0' but DO NOT clear re.
                -- Keeping re='1' ensures the next word written to FIFO is
                -- consumed at the stall-resume cycle (re_gated fires on arrival),
                -- so beat N+1 sees the correct next word instead of re-reading
                -- the same dout as beat N (which causes the duplicate).
                -- re_gated=Sample_Fifo_re AND Aurora_rdy_in is safe when FIFO
                -- empty: tvalid=0 prevents any AXI-Stream transfer.
                Aurora_valid_out <= '0';
              end if;
              -- re NOT cleared during stall: re_gated combinatorially holds FIFO.
              -- Clearing re here causes duplicate sample on stall resume.

            end if;

          else
            -- at frame end the block above sets enable_frame<='0' with tlast; read_trigger re-arms
            -- it the NEXT cycle, so there is a one-cycle gap where enable_frame='0' and
            -- this datapath block is skipped. Without an else, Aurora_valid_out/data were
            -- HELD -> the last IQ beat was re-presented as a DUPLICATE beat. The MBU
            -- deframer then swallowed it as a header (tlast resync wip=0) and wrote the
            -- real next-frame header into the IQ FIFO as a sample (metadata-as-data).
            -- Clear valid in the idle gap, mirroring MBU_FRAMER_GEN; hold only a beat
            -- still pending acceptance (AXI-Stream tlast HOLD).
            if (Aurora_valid_out = '1') and (Aurora_rdy_in = '0') then
              null;  -- hold pending beat until accepted (tvalid&tready)
            else
              Aurora_valid_out <= '0';
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;
  MBU_FRAMER_GEN : if RFU_MODE = "NO" generate
    process (Aurora_clk_in)
    begin
      if rising_edge(Aurora_clk_in) then
        if (Aurora_rst_in = '1') then
          Aurora_valid_out <= '0';
          word_40          <= 0;
          Sample_Fifo_re   <= '0';
          Aurora_data_out  <= (others => '0');
          wp               <= (others => '0');
          latch_data_en    <= '0';
          --sample_delay    <= (others => (others => '0'));
          latch_data_counter <= 0;
          Sample_Fifo_re_dly <= '0';
          --Sample_Fifo_re_dly1 <= '0';
          load_data_counter <= 0;
          enable_frame      <= '0';
          word_in_packet    <= 0;
          packet_counter    <= 0;
          first_section     <= '1';
          frame_end_pending <= '0';
          -- sample_counter was NOT cleared here, so it survived Aurora_rst_in. After a
          -- protocol restart (slot_hop_gen S_RESET, or any aurora_rst) the first frame of
          -- the new burst closed after only (Frame_Length - stale_count) beats -- measured
          -- 7 beats / 14 samples with a stale 1693 and Frame_Length=1700. Every later frame
          -- was the right length but the whole frame grid stayed shifted by that runt, so
          -- the tlast boundary never lined up with the hop boundary (hop_samples) and the
          -- Frame_Length announced in meta0 no longer described the first frame.
          sample_counter    <= (others => '0');
          iq_sample_inframe <= '0';   -- ILA/debug only since the 2026-09-08 load-time count
          dummy_sent        <= '0';
          dummy_pkt_count   <= 0;
          dummy_in_pkt      <= '0';
          dummy_req          <= '0';
          dummy_frame_sync_d <= '0';
          -- rate-matching reset (N_a=7, N_b=1, Bresenham period=8)
          meta_counter <= 0;
          rate_sub     <= 0;
          is_short_pkt <= '0';
        else
          -- BUG FIX (Bug 1): default Aurora_last_out to '0' every cycle.
          -- Without this, Aurora_last_out stays '1' after dummy frame completion
          -- (set at dummy pkt 5 beat 5, line 911) while Aurora_valid_out='0',
          -- violating AXI-Stream: tlast must only assert when tvalid='1'.
          -- This default is safely overridden by beat-5 / frame-end assignments below.
          -- BUG FIX (Bug 2, AXI-Stream tlast HOLD): only clear tlast when NO beat is
          -- pending acceptance. If Aurora_rdy_in falls on the cycle the frame-end tlast
          -- beat is presented, this unconditional default used to clear last while
          -- valid/data were held -> the beat was later accepted WITHOUT tlast (or dropped
          -- entirely) -> deframer never re-syncs word_in_packet -> metadata-as-data slip.
          -- Hold last asserted until the beat is accepted (tvalid&tready).
          if not (Aurora_valid_out = '1' and Aurora_rdy_in = '0') then
            Aurora_last_out <= '0';
          end if;
          -- dummy_frame_in rising-edge detect (CDC-synced) -> latch dummy_req.
          -- Consumed at frame end (below) to re-arm the dummy startup sequence so the
          -- NEXT frame begins with the zero-IQ dummy packets (RX re-syncs metadata).
          dummy_frame_sync_d <= dummy_frame_sync;
          if (dummy_frame_sync = '1') and (dummy_frame_sync_d = '0') then
            dummy_req <= '1';
          end if;
          -- DUMMY FRAME STARTUP (MBU)
          -- Sends 6 startup packets identical to RFU block so the deframer can
          -- detect and count them before asserting LOCKEDs='1'.
          -- Layout: x"00"(8b) & meta(8b) & payload(48b) = 64b per beat.
          -- dummy_pkt_count: 0..5 (which of the 6 dummy packets)
          -- dummy_in_pkt   : '0'=beat0, '1'=beats1..5
         if dummy_sent = '0' then
            if Aurora_rdy_in = '1' then
              if dummy_in_pkt = '0' then
                -- Beat 0: send metadata header
                Aurora_valid_out <= '1';
                Aurora_last_out  <= '0';
                case meta_counter is
                  when 0 =>
                    Aurora_data_out <= x"00" & x"AA" & Frame_Length;
                  when 1 =>
                    Aurora_data_out <= x"00" & GFP1 & Tx_freq;
                  when 2 =>
                    Aurora_data_out <= x"00" & GFP1 & Rx_freq;
                  when 3 =>
                    Aurora_data_out <= x"00" & GFP1 & Tx_bw & Power_Tx & "00000" & Next_Frame_Transmit_Time;
                  when 4 =>
                    Aurora_data_out <= x"00" & GFP1 & Rx_bw & "0000000000000" & Next_Frame_Receive_Time;
                  when 5 =>
                    Aurora_data_out <= x"00" & GFP1 & x"00" & Second_from_2000;
                  when others =>
                    Aurora_data_out <= x"00" & GFP1 & GFP2 & GFP3 & "00000" & Subsecond;
                end case;
                dummy_in_pkt   <= '1';
                word_in_packet <= 1;
              else
                -- Beats 1..5: IQ data = 0
                Aurora_valid_out <= '1';
                Aurora_data_out  <= (others => '0');
                if word_in_packet < 5 then
                  -- Beats 1..4: not last
                  Aurora_last_out <= '0';
                  word_in_packet  <= word_in_packet + 1;
                else
                  -- Beat 5: end of this dummy packet
                  word_in_packet <= 0;
                  dummy_in_pkt   <= '0';
                  if meta_counter = 6 then
                    meta_counter <= 0;
                  else
                    meta_counter <= meta_counter + 1;
                  end if;
                  if dummy_pkt_count = 5 then
                    -- Last beat of the LAST dummy packet -> assert tlast ONLY HERE.
                    -- Aurora_valid_out stays '1' (set above at beat 1..5 entry, line 908).
                    -- DO NOT set Aurora_valid_out<='0' here: that would override valid='1'
                    -- in the same delta cycle (last-assignment-wins) -> last='1'/valid='0'
                    -- = AXI-Stream violation. valid drops to '0' naturally next cycle
                    -- because dummy_sent='1' prevents the dummy handler from re-entering.
                    Aurora_last_out <= '1';
                    dummy_sent      <= '1';
                    dummy_pkt_count <= 0;
                    meta_counter    <= 0;
                    rate_sub        <= 0;
                    is_short_pkt    <= '0';
                  else
                    -- Packets 0..4: beat 5 is NOT the frame end
                    Aurora_last_out <= '0';
                    dummy_pkt_count <= dummy_pkt_count + 1;
                  end if;
                end if;
              end if;
            end if;
          end if;
          -- Normal framer
          -- CRITICAL FIX: Gate enable_frame and normal-framer block on dummy_sent='1'.
          -- Without this gate, if enable_frame fires while dummy_sent='0', both the
          -- dummy block and normal block run in the same process. The normal block
          -- runs AFTER the dummy block -> its assignments (Aurora_data_out=x"A" header,
          -- Sample_Fifo_re='1') OVERRIDE the dummy block's (x"00" header, re='0').
          -- Result: deframer never sees 6 valid x"00" dummy packets -> premature
          -- LOCKEDs lock via fallback -> IQ FIFO starts at wrong word -> first
          -- Sample_IQ=5 instead of 1, and recurring metadata-as-data at short/normal
          -- packet boundaries.
          if (dummy_sent = '1') then
            if (read_trigger_sync = '1') then
              enable_frame <= '1';
              if (enable_frame = '0') then
                first_section  <= '1';
                word_in_packet <= 0; -- restart each frame at beat 0 (case skipped this cycle: enable_frame still '0')
                meta_counter   <= 0; -- restart metadata burst (meta0..6) at every frame start
              end if;
            end if;
            if (enable_frame = '1') and (dummy_sent = '1') then
              --Sample_Fifo_re_dly <= Sample_Fifo_re;
              --Sample_Fifo_re_dly1 <= Sample_Fifo_re_dly;
              -- Latch FIFO data in 3 cases:
              -- 1. Already in a burst (latch_data_en='1')
              -- 2. Beat 0 pre-fetch (word_in_packet=0)
              -- 3. Gearbox stall mid-packet: Aurora_rdy_in='0' and re was '1' last cycle
              --    FIFO consumed 1 extra word; capture it to prevent data loss
              if (Sample_Fifo_re_dly1 = '1') and
                ((latch_data_en = '1') or (word_in_packet = 0) or
                (Aurora_rdy_in = '0' and word_in_packet /= 0)) then
                latch_data_en                    <= '1';
                sample_delay(latch_data_counter) <= Sample_Fifo_dout;
                latch_data_counter               <= latch_data_counter + 1;
              end if;
              if (Aurora_rdy_in = '1') then
                -- Finite Frame_Length: IQ beats are counted where they are LOADED (after the
                -- case below), never here -- see FRAME END. The old acceptance-time count
                -- (iq_sample_inframe) advanced every cycle while the TX FIFO was empty.
                --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1') or (word_in_packet = 0))) then
                --if(Sample_Fifo_empty = '0') or((Sample_Fifo_empty = '1') and ((latch_data_en = '1') or (Sample_Fifo_re_dly1 = '1'))) then
                if (tx_fifo_ok = '1') then
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
                      -- Beat 0: metadata mux via meta_counter (0..6)
                      -- is_short_pkt='1' => mark super-frame end with "8" prefix
                      if (first_section = '1') then
                        -- FIX: first_section forces x"A" (normal packet).
                        -- MUST also clear is_short_pkt and reset rate_sub
                        -- so beat 4 does NOT skip beat 5 (same fix as RFU_FRAMER_GEN).
                        is_short_pkt  <= '0'; -- force normal: do not skip beat 5
                        rate_sub      <= 0; -- restart rate counter
                        -- METADATA BURST: keep first_section='1' for the first 7 packets so
                        -- beat-0 sends meta0..6 at the start of EVERY frame; clear it after
                        -- meta6 (meta_counter=6) so the rest of the frame sends Subsecond+GFP.
                        -- The RFU deframer mirrors this (re-arms first_section at each tlast).
                        if (meta_counter = 6) then
                          first_section <= '0';
                        end if;
                        case meta_counter is
                          when 0 =>
                            Aurora_data_out           <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP_SIGNATURE & Frame_Length;
                          when 1      => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & Tx_freq;
                          when 2      => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & Rx_freq;
                          when 3      => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & Tx_bw & Power_Tx & "00000" & Next_Frame_Transmit_Time;
                          when 4      => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & Rx_bw & x"00" & "00000" & Next_Frame_Receive_Time;
                          when 5      => Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & x"00" & Second_from_2000;
                          when others =>
                            Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & GFP2 & GFP3 & "00000" & Subsecond;
                        end case;
                      else
                        if (is_short_pkt = '1') then
                          Aurora_data_out <= x"8" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & GFP2 & GFP3 & "00000" & Subsecond;
                        else
                          Aurora_data_out <= x"A" & std_logic_vector(to_unsigned(word_in_packet, 4)) & GFP1 & GFP2 & GFP3 & "00000" & Subsecond;
                        end if;
                      end if;
                      iq_sample_inframe <= '0';
                    when 1 =>
                      word_in_packet    <= 2;
                      iq_sample_inframe <= '1';
                      if (load_data_counter < latch_data_counter) then
                        Aurora_data_out   <= sample_delay(load_data_counter);
                        load_data_counter <= load_data_counter + 1;
                      else
                        load_data_counter  <= 0;
                        latch_data_counter <= 0;
                        Aurora_data_out    <= Sample_Fifo_dout;
                        latch_data_en      <= '0';
                      end if;
                      Sample_Fifo_re <= '1';
                    when 2 =>
                      word_in_packet    <= 3;
                      iq_sample_inframe <= '1';
                      if (load_data_counter < latch_data_counter) then
                        Aurora_data_out   <= sample_delay(load_data_counter);
                        load_data_counter <= load_data_counter + 1;
                      else
                        load_data_counter  <= 0;
                        latch_data_counter <= 0;
                        Aurora_data_out    <= Sample_Fifo_dout;
                        latch_data_en      <= '0';
                      end if;
                      Sample_Fifo_re <= '1';
                    when 3 =>
                      word_in_packet    <= 4;
                      iq_sample_inframe <= '1';
                      if (load_data_counter < latch_data_counter) then
                        Aurora_data_out   <= sample_delay(load_data_counter);
                        load_data_counter <= load_data_counter + 1;
                      else
                        load_data_counter  <= 0;
                        latch_data_counter <= 0;
                        Aurora_data_out    <= Sample_Fifo_dout;
                        latch_data_en      <= '0';
                      end if;
                      Sample_Fifo_re <= '1';
                    when 4 =>
                      -- Rate matching: is_short_pkt was decided at the PREVIOUS packet end
                      -- (beat 4/7) from TX rd_data_count. '1' => SHORT packet (4 IQ, ends
                      -- here at beat 4); next packet type decided below. 
                      if (is_short_pkt = '1') then
                        -- -- Short packet: beat 4 is last -> assert tlast (only in framed mode)
                        -- -- BUG FIX: do NOT assert Aurora_last_out in streaming mode
                        -- -- (Frame_Length=0xFFFF...). In streaming mode the framer-level
                        -- -- Aurora_last_out <= '0' guard runs BEFORE this case block but the
                        -- -- assignment here was overriding it (last VHDL assignment wins).
                        -- if Frame_Length /= x"ffffffffffff" then
                        --   Aurora_last_out <= '1';
                        -- end if;
                        word_in_packet       <= 0;
                        Sample_Fifo_re       <= '0';
                        packet_total_counter <= packet_total_counter + 1;
                        if meta_counter = 6 then
                          meta_counter <= 0;
                        else
                          meta_counter <= meta_counter + 1;
                        end if;
                        -- the TX FIFO level picks SHORT/LONG unless the beats left in the frame force the size.
                        -- If this beat closes the frame (counter >= FL-1, the FRAME END block below fires) the
                        -- next packet opens a fresh frame of Frame_Length beats.
                        if (Frame_Length = x"ffffffffffff") then
                          is_short_pkt <= fifo_short_sel;                       -- stream mode: FIFO level only
                        elsif (sample_counter >= Frame_Length - '1') then
                          is_short_pkt <= plan_short(fifo_short_sel, Frame_Length);
                        else
                          is_short_pkt <= plan_short(fifo_short_sel, rem_after);
                        end if;
                      else
                        -- Normal packet: advance to beat 5
                        word_in_packet <= 5;
                        Sample_Fifo_re <= '1';
                      end if;
                      -- IQ data output (always at beat 4)
                      iq_sample_inframe <= '1';
                      if (load_data_counter < latch_data_counter) then
                        Aurora_data_out   <= sample_delay(load_data_counter);
                        load_data_counter <= load_data_counter + 1;
                      else
                        load_data_counter  <= 0;
                        latch_data_counter <= 0;
                        Aurora_data_out    <= Sample_Fifo_dout;
                        latch_data_en      <= '0';
                      end if;
                    when 5 =>
                      -- Intermediate IQ beat: 7-beat frame → advance to beat 6
                      -- Beats 5-7 are pure IQ: bypass sample_delay buffer entirely.
                      word_in_packet     <= 6;
                      Sample_Fifo_re     <= '1';
                      iq_sample_inframe  <= '1';
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      latch_data_en      <= '0';
                      Aurora_data_out    <= Sample_Fifo_dout;
                    when 6 =>
                      -- Intermediate IQ beat: advance to beat 7
                      word_in_packet     <= 7;
                      Sample_Fifo_re     <= '1';
                      iq_sample_inframe  <= '1';
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      latch_data_en      <= '0';
                      Aurora_data_out    <= Sample_Fifo_dout;
                    when 7 =>
                      -- -- Packet end: 7 IQ beats (beats 1-7) + 1 header = 8-beat frame (87.5% IQ)
                      -- -- re='0': beat 0 already has re='1' (pre-fetch) to advance FIFO.
                      -- if Frame_Length /= x"ffffffffffff" then
                      --   Aurora_last_out <= '1';
                      -- end if;
                      word_in_packet       <= 0;
                      Sample_Fifo_re       <= '0';
                      packet_total_counter <= packet_total_counter + 1;
                      iq_sample_inframe    <= '1';
                      if meta_counter = 6 then
                        meta_counter <= 0;
                      else
                        meta_counter <= meta_counter + 1;
                      end if;
                      -- the TX FIFO level picks SHORT/LONG unless the beats left in the frame force the size.
                      -- If this beat closes the frame (counter >= FL-1, the FRAME END block below fires) the
                      -- next packet opens a fresh frame of Frame_Length beats.
                      if (Frame_Length = x"ffffffffffff") then
                        is_short_pkt <= fifo_short_sel;                       -- stream mode: FIFO level only
                      elsif (sample_counter >= Frame_Length - '1') then
                        is_short_pkt <= plan_short(fifo_short_sel, Frame_Length);
                      else
                        is_short_pkt <= plan_short(fifo_short_sel, rem_after);
                      end if;
                      load_data_counter  <= 0;
                      latch_data_counter <= 0;
                      latch_data_en      <= '0';
                      Aurora_data_out    <= Sample_Fifo_dout;
                    when others => null;
                  end case;
                  -- The case arm that just ran (word_in_packet = pre-update value) loaded
                  -- exactly one beat onto the bus: arm 0 = header, arms 1..7 = one IQ beat.
                  -- Arms only run with Aurora_rdy_in='1' AND tx_fifo_ok='1', and the FSM
                  -- freezes until the beat is accepted, so "arm 1..7 ran" == "one IQ beat
                  -- transferred". Two bugs of the old scheme are fixed here:
                  --  (1) the count advanced at ACCEPTANCE via iq_sample_inframe, which stays
                  --      '1' while the TX FIFO is empty -> a FIFO underrun mid-packet counted
                  --      idle cycles as IQ beats (frame closed early / a stale frame closed at
                  --      the next resume and swallowed the next slot's first samples);
                  --  (2) frame_end_pending became visible 2 beats after the Frame_Length-th
                  --      beat, so when that beat was the packet's last one the end was missed
                  --      and the frame grew by a whole extra packet (+4/+7 beats, cumulative
                  --      +8 samples per hop).
                  -- Now: count at LOAD time and decide in the SAME cycle. tlast goes on the
                  -- packet's last beat (7, or 4 of a SHORT packet) iff that beat brings the
                  -- frame to Frame_Length (sample_counter = beats before it, so >= FL-1).
                  -- tlast still never lands mid-packet. The packet-size planner (plan_short, at the
                  -- packet-end decisions above) steers the last packets so the boundary falls
                  -- exactly on Frame_Length for every FL >= 18 (any 4a+7b).
                  if (word_in_packet /= 0) then
                    if (Frame_Length /= x"ffffffffffff") and
                       ((word_in_packet = 7) or (word_in_packet = 4 and is_short_pkt = '1')) and
                       (sample_counter >= Frame_Length - '1') then
                      Aurora_last_out   <= '1';
                      enable_frame      <= '0';
                      first_section     <= '1';
                      sample_counter    <= (others => '0');
                      packet_counter    <= 0;
                      word_40           <= 0;
                      wp                <= (others => '0');
                      frame_end_pending <= '0';
                      -- re-arm dummy startup on the next frame if a dummy_frame_in was latched
                      if (dummy_req = '1') then
                        dummy_sent      <= '0';
                        dummy_req       <= '0';
                        dummy_pkt_count <= 0;
                        dummy_in_pkt    <= '0';
                        meta_counter    <= 0;
                      end if;
                    else
                      sample_counter <= sample_counter + '1';
                      if (Frame_Length /= x"ffffffffffff") and (sample_counter >= Frame_Length - '1') then
                        frame_end_pending <= '1'; -- length reached mid-packet (ILA probe only)
                      end if;
                    end if;
                  end if;
                else
                  -- TX FIFO empty: hold valid='0' but DO NOT clear re.
                  -- Keeping re='1' lets the next word be consumed at stall-resume
                  -- (re_gated fires on arrival); fifo_valid=0 blocks spurious pops.
                  -- Clearing re here re-reads the same dout next beat => duplicate
                  -- sample on resume (matches the already-fixed RFU_FRAMER_GEN block).
                  Aurora_valid_out <= '0';
                end if;
                -- re NOT cleared during stall: re_gated combinatorially holds FIFO.

                -- Clearing re here causes duplicate sample on stall resume.

              end if;
            else
                -- Inter-frame / dummy-transition idle (enable_frame='0').
                -- BUG FIX (Bug 2, AXI-Stream valid HOLD): if a beat is being offered
                -- (Aurora_valid_out='1') but not yet accepted (Aurora_rdy_in='0') --
                -- e.g. the frame-end tlast beat presented the SAME cycle enable_frame
                -- dropped to '0' (set with tlast at line ~1175) -- HOLD it. Dropping
                -- valid here lost the last IQ beat + tlast when rdy fell on the tlast
                -- cycle -> deframer slip. Data/last are already held (case is gated on
                -- rdy='1'; tlast held by the Bug-2 guard above), so just hold valid too.
                if (Aurora_valid_out = '1') and (Aurora_rdy_in = '0') then
                  null;  -- hold pending beat until accepted (tvalid&tready)
                else
                  Aurora_valid_out <= '0';
                end if;
              end if;
          end if;
        end if;
      end if;
    end process;
  end generate;

  -- synthesis translate_off
  ---------------------------------------------------------------------------
  -- SIMULATION-ONLY: dump all internal signals to CSV every clock cycle
  -- after Aurora_rst_in goes low.
  -- Output file: aurora_framer_dump.txt (written to simulator working dir)
  -- Columns: clk, Aurora_data_out, valid, last, rdy, word_in_packet,
  --          meta_counter, rate_sub, is_short_pkt, first_section,
  --          dummy_sent, dummy_pkt_count, dummy_in_pkt, enable_frame,
  --          fifo_empty, fifo_re, fifo_re_gated, fifo_dout, rd_cnt, wr_cnt,
  --          latch_ctr, load_ctr, latch_en, pkt_total, dummy_frame_in
  ---------------------------------------------------------------------------
  sim_dump_framer : process (Aurora_clk_in)
    file dump_file    : text;
    variable v_line   : line;
    variable v_opened : boolean := false;
  begin
    if rising_edge(Aurora_clk_in) then
      -- Open file and write header on the very first call
      if not v_opened then
        file_open(dump_file, "aurora_framer_dump.txt", write_mode);
        v_opened := true;
        write(v_line, string'("clk,Aurora_data_out,valid,last,rdy,word_in_packet,meta_counter,rate_sub,is_short_pkt,first_section,dummy_sent,dummy_pkt_count,dummy_in_pkt,enable_frame,fifo_empty,fifo_re,fifo_re_gated,fifo_dout,rd_cnt,wr_cnt,latch_ctr,load_ctr,latch_en,pkt_total,dummy_frame_in"));
        writeline(dump_file, v_line);
      end if;

      -- Dump only after reset is deasserted
      if Aurora_rst_in = '0' then
        sim_clock_count <= sim_clock_count + 1;

        write(v_line, sim_clock_count);
        write(v_line, string'(","));
        hwrite(v_line, Aurora_data_out);
        write(v_line, string'(","));
        write(v_line, Aurora_valid_out);
        write(v_line, string'(","));
        write(v_line, Aurora_last_out);
        write(v_line, string'(","));
        write(v_line, Aurora_rdy_in);
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
        write(v_line, dummy_sent);
        write(v_line, string'(","));
        write(v_line, dummy_pkt_count);
        write(v_line, string'(","));
        write(v_line, dummy_in_pkt);
        write(v_line, string'(","));
        write(v_line, enable_frame);
        write(v_line, string'(","));
        write(v_line, Sample_Fifo_empty);
        write(v_line, string'(","));
        write(v_line, Sample_Fifo_re);
        write(v_line, string'(","));
        write(v_line, Sample_Fifo_re_gated);
        write(v_line, string'(","));
        hwrite(v_line, Sample_Fifo_dout);
        write(v_line, string'(","));
        hwrite(v_line, rd_data_count);
        write(v_line, string'(","));
        hwrite(v_line, wr_data_count);
        write(v_line, string'(","));
        write(v_line, latch_data_counter);
        write(v_line, string'(","));
        write(v_line, load_data_counter);
        write(v_line, string'(","));
        write(v_line, latch_data_en);
        write(v_line, string'(","));
        write(v_line, packet_total_counter);
        write(v_line, string'(","));
        write(v_line, dummy_frame_in);
        writeline(dump_file, v_line);
      end if;
    end if;
  end process sim_dump_framer;
  -- synthesis translate_on

end Behavioral;

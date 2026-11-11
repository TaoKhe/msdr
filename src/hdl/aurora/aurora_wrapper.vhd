----------------------------------------------------------------------------------
-- Module Name: aurora_wrapper - Behavioral
-- Description:
--   Wrapper for aurora_64b66b_0 (v12.0, GTHE4, line rate 10.0G, refclk 300 MHz)
--   generated with "Additional transceiver control and status ports" enabled.
--   All GT control inputs are tied to their GTH default (inactive/nominal) values.
--   All GT status outputs are left open except gt_powergood, which is observed
--   via the status register to keep the powergood-delay logic from being trimmed
--   (avoids opt_design [Opt 31-67]).
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
Library xpm;
use xpm.vcomponents.all;

entity aurora_wrapper is
  Port (
     -- System Interface
     rstn_i      : in  std_logic;
     init_clk_i  : in  std_logic;
     -- GT Reference Clock Interface
     gt_refclk1  : in  std_logic;
     -- GT Serial I/O
     rxp : in  std_logic;
     rxn : in  std_logic;
     txp : out std_logic;
     txn : out std_logic;
     -----  control outports ----------------
     aurora_clk_o    : out std_logic;
     aurora_rst_o    : out std_logic;
     aurora_status_o : out std_logic_vector(31 downto 0);
     gt_rxusrclk_o   : out std_logic;
     -- AXI-STREAM interface -------
     s_IQ_tdata_i : in  std_logic_vector(63 downto 0);
     s_IQ_tkeep_i : in  std_logic_vector(7 downto 0);
     s_IQ_tvalid_i: in  std_logic;
     s_IQ_tlast_i : in  std_logic;
     s_IQ_tready_o: out std_logic;

     m_IQ_tdata_o : out std_logic_vector(63 downto 0);
     m_IQ_tkeep_o : out std_logic_vector(7 downto 0);
     m_IQ_tvalid_o: out std_logic;
     m_IQ_tlast_o : out std_logic
  );
end aurora_wrapper;

architecture Behavioral of aurora_wrapper is
    constant PB_RST_CYCLES   : integer := 256;
    constant PMI_INIT_CYCLES : integer := 67108864; -- 2^26
    constant RESET_CYCLES    : integer := PB_RST_CYCLES*2 + PMI_INIT_CYCLES;

    -- Startup delay applied to BOTH reset signals (reset_pb_s and pmi_init_s)
    -- fed to aurora_64b66b_0, relative to the wrapper reset rstn_i.
    -- init_clk_i runs at 100 MHz, so 1 second = 100_000_000 cycles.
    constant INIT_CLK_FREQ_HZ : integer := 100000000;
    constant RST_DELAY_CYCLES : integer := INIT_CLK_FREQ_HZ; -- 1 s @ init_clk_i
    -- NOTE: the RFU uses a single-cycle reset PULSE watchdog (link_wd_rst_s), not a long hold.
    -- The MBU owns the long-reset HOLD; two symmetric 1.5 s holds would livelock the link, so the
    -- RFU only ever pulses a brief GT re-init retry.

    component aurora_64b66b_0
    port(
       -- TX AXI4-S Interface
       s_axi_tx_tdata  : in  std_logic_vector(63 downto 0);
       s_axi_tx_tlast  : in  std_logic;
       s_axi_tx_tkeep  : in  std_logic_vector(7 downto 0);
       s_axi_tx_tvalid : in  std_logic;
       s_axi_tx_tready : out std_logic;
       -- RX AXI4-S Interface
       m_axi_rx_tdata  : out std_logic_vector(63 downto 0);
       m_axi_rx_tlast  : out std_logic;
       m_axi_rx_tkeep  : out std_logic_vector(7 downto 0);
       m_axi_rx_tvalid : out std_logic;
       -- GT Serial I/O
       rxp : in  std_logic;
       rxn : in  std_logic;
       txp : out std_logic;
       txn : out std_logic;
       -- GT Reference Clock Interface
       refclk1_in : in std_logic;
       -- Error Detection
       hard_err : out std_logic;
       soft_err : out std_logic;
       -- Status
       channel_up : out std_logic;
       lane_up    : out std_logic_vector(0 downto 0);
       -- System Interface
       user_clk_out        : out std_logic;
       mmcm_not_locked_out : out std_logic;
       sync_clk_out        : out std_logic;
       reset_pb            : in  std_logic;
       gt_rxcdrovrden_in   : in  std_logic;
       power_down          : in  std_logic;
       loopback            : in  std_logic_vector(2 downto 0);
       pma_init            : in  std_logic;
       gt_pll_lock         : out std_logic;
       -- GT DRP Ports
       gt0_drpaddr : in  std_logic_vector(9 downto 0);
       gt0_drpdi   : in  std_logic_vector(15 downto 0);
       gt0_drpdo   : out std_logic_vector(15 downto 0);
       gt0_drprdy  : out std_logic;
       gt0_drpen   : in  std_logic;
       gt0_drpwe   : in  std_logic;
       init_clk        : in  std_logic;
       link_reset_out  : out std_logic;
       gt_rxusrclk_out : out std_logic;
       -- RX Margin Analysis Ports
       gt_eyescandataerror : out std_logic_vector(0 downto 0);
       gt_eyescanreset     : in  std_logic_vector(0 downto 0);
       gt_eyescantrigger   : in  std_logic_vector(0 downto 0);
       -- RX Equalizer Ports
       gt_rxcdrhold     : in  std_logic_vector(0 downto 0);
       gt_rxdfelpmreset : in  std_logic_vector(0 downto 0);
       gt_rxlpmen       : in  std_logic_vector(0 downto 0);
       gt_rxpmareset    : in  std_logic_vector(0 downto 0);
       gt_rxpcsreset    : in  std_logic_vector(0 downto 0);
       gt_rxrate        : in  std_logic_vector(2 downto 0);
       gt_rxbufreset    : in  std_logic_vector(0 downto 0);
       gt_rxpmaresetdone: out std_logic_vector(0 downto 0);
       gt_rxprbssel     : in  std_logic_vector(3 downto 0);
       gt_rxprbscntreset: in  std_logic_vector(0 downto 0);
       gt_rxprbserr     : out std_logic_vector(0 downto 0);
       gt_rxresetdone   : out std_logic_vector(0 downto 0);
       gt_rxbufstatus   : out std_logic_vector(2 downto 0);
       -- TX Configurable Driver Ports
       gt_txpostcursor  : in  std_logic_vector(4 downto 0);
       gt_txdiffctrl    : in  std_logic_vector(4 downto 0);
       gt_txprecursor   : in  std_logic_vector(4 downto 0);
       -- TX Polarity / Control Ports
       gt_txpolarity    : in  std_logic_vector(0 downto 0);
       gt_txinhibit     : in  std_logic_vector(0 downto 0);
       gt_txpmareset    : in  std_logic_vector(0 downto 0);
       gt_txpcsreset    : in  std_logic_vector(0 downto 0);
       gt_txprbssel     : in  std_logic_vector(3 downto 0);
       gt_txprbsforceerr: in  std_logic_vector(0 downto 0);
       gt_txbufstatus   : out std_logic_vector(1 downto 0);
       gt_txresetdone   : out std_logic_vector(0 downto 0);
       gt_pcsrsvdin     : in  std_logic_vector(15 downto 0);
       gt_dmonitorout   : out std_logic_vector(15 downto 0);
       gt_cplllock      : out std_logic_vector(0 downto 0);
       gt_qplllock      : out std_logic;
       gt_powergood     : out std_logic_vector(0 downto 0);
       -- shared mode 8 series GT quad ports
       gt_qpllclk_quad1_out        : out std_logic;
       gt_qpllrefclk_quad1_out     : out std_logic;
       gt_qplllock_quad1_out       : out std_logic;
       gt_qpllrefclklost_quad1_out : out std_logic;
       sys_reset_out : out std_logic;
       gt_reset_out  : out std_logic;
       tx_out_clk    : out std_logic
    );
    end component;

    -- Debug ILA (reuses existing ila_0 IP: probe widths 1/32/1/1/32/1)
    component ila_0 is
      port (
        clk    : in std_logic;
        probe0 : in std_logic_vector(0 downto 0);
        probe1 : in std_logic_vector(31 downto 0);
        probe2 : in std_logic_vector(0 downto 0);
        probe3 : in std_logic_vector(0 downto 0);
        probe4 : in std_logic_vector(31 downto 0);
        probe5 : in std_logic_vector(0 downto 0);
        probe6 : in std_logic_vector(0 downto 0);
        probe7 : in std_logic_vector(0 downto 0)
      );
    end component;

    signal tx_tdata_s  : std_logic_vector(63 downto 0);
    signal tx_tkeep_s  : std_logic_vector(7 downto 0);
    signal tx_tvalid_s : std_logic;
    signal tx_tlast_s  : std_logic;
    signal tx_tready_s : std_logic;

    signal rx_tdata_s  : std_logic_vector(63 downto 0);
    signal rx_tkeep_s  : std_logic_vector(7 downto 0);
    signal rx_tvalid_s : std_logic;
    signal rx_tlast_s  : std_logic;

    signal user_clk_s   : std_logic;
    signal channel_up_s : std_logic;
    signal lane_up_s    : std_logic_vector(0 downto 0);

    signal hard_err_s, soft_err_s          : std_logic;
    signal pmi_init_s, reset_pb_s          : std_logic;
    signal aurora_system_reset_s           : std_logic;
    signal aurora_tx_out_clk_s             : std_logic;
    signal aurora_link_reset_s             : std_logic;
    signal aurora_pll_notlock_s            : std_logic;
    signal sync_clk_s                      : std_logic;
    signal reset_pb_count_s                : std_logic_vector(31 downto 0);
    signal pmi_init_count_s                : std_logic_vector(31 downto 0);
    signal aurora_status_s                 : std_logic_vector(31 downto 0);
    signal gt_pll_lock                     : std_logic;
    signal gt_rxusrclk_s                   : std_logic;
    signal gt_powergood_s                  : std_logic_vector(0 downto 0);
    -- 1 s startup-delay gate: held '0' for RST_DELAY_CYCLES after rstn_i is
    -- released, then '1'. Both reset sequences below wait for this flag.
    signal startup_dly_done_s              : std_logic := '0';
    signal startup_dly_count_s             : std_logic_vector(31 downto 0) := (others => '0');
    -- Link-up watchdog: after the pma_init pulse, if the link is not up within
    -- 1 s, request an internal reset cycle (reset_pb + pma_init) and retry.
    signal init_done_s                     : std_logic;
    signal link_wd_count_s                 : std_logic_vector(31 downto 0) := (others => '0');
    signal link_wd_rst_s                   : std_logic := '0';
    -- channel_up_s synchronized from the aurora user_clk domain into init_clk_i
    signal channel_up_meta_s               : std_logic := '0';
    signal channel_up_sync_s               : std_logic := '0';
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of channel_up_meta_s : signal is "TRUE";
    attribute ASYNC_REG of channel_up_sync_s : signal is "TRUE";

    signal aurora_status_init_s : std_logic_vector(31 downto 0); -- init_clk copy of aurora_status_s (read via VIO)
    -- VIO (init_clk_i domain, runs even when link/user_clk dead) to read the Aurora
    -- bring-up status word during a stuck link (mirror of the MBU status probe).
    -- Status bits: [0]pmi_init [1]reset_pb [2]hard_err [3]soft_err [4]channel_up
    --   [5]lane_up [6]gt_pll_lock [7]mmcm_notlock [8]link_reset [9]gt_powergood
    component vio_status
      port (
        clk       : in std_logic;
        probe_in0 : in std_logic_vector(31 downto 0)
      );
    end component;
begin

    s_IQ_tready_o <= '1' when tx_tready_s = '1' and channel_up_s = '1' and lane_up_s(0) = '1' else '0';
    tx_tvalid_s <= s_IQ_tvalid_i;
    tx_tdata_s  <= s_IQ_tdata_i;
    tx_tlast_s  <= s_IQ_tlast_i;
    tx_tkeep_s  <= s_IQ_tkeep_i;
    aurora_clk_o  <= user_clk_s;
    aurora_rst_o  <= aurora_system_reset_s or (not channel_up_s);
    m_IQ_tdata_o  <= rx_tdata_s;
    m_IQ_tvalid_o <= rx_tvalid_s;
    m_IQ_tlast_o  <= rx_tlast_s;
    m_IQ_tkeep_o  <= rx_tkeep_s;
    gt_rxusrclk_o <= gt_rxusrclk_s;

    -- 1 s startup delay: count up after rstn_i is released; assert the
    -- startup_dly_done_s flag once RST_DELAY_CYCLES (1 s) have elapsed.
    startup_delay_ins:process(init_clk_i)
    begin
        if(init_clk_i'event and init_clk_i = '1') then
            if(rstn_i = '0') then
               startup_dly_done_s  <= '0';
               startup_dly_count_s <= (others => '0');
            else
                if(startup_dly_count_s >= RST_DELAY_CYCLES) then
                    startup_dly_done_s <= '1';
                else
                    startup_dly_count_s <= startup_dly_count_s + 1;
                end if;
            end if;
        end if;
    end process;

    pb_reset_ins:process(init_clk_i)
    begin
        if(init_clk_i'event and init_clk_i = '1') then
            if(rstn_i = '0' or link_wd_rst_s = '1') then
               -- rstn_i, or a single-cycle watchdog retry pulse, (re)starts the reset_pb sequence
               reset_pb_s <= '1';
               reset_pb_count_s <= (others => '0');
            elsif(startup_dly_done_s = '0') then
               -- hold reset asserted during the 1 s startup delay
               reset_pb_s <= '1';
               reset_pb_count_s <= (others => '0');
            else
                if(reset_pb_count_s > PB_RST_CYCLES * 2 + PMI_INIT_CYCLES) then
                    reset_pb_s <= '0';
                else
                    reset_pb_s <= '1';
                    reset_pb_count_s <= reset_pb_count_s + 1;
                end if;
            end if;
        end if;
    end process;

    pmi_init_ins:process(init_clk_i)
    begin
        if(init_clk_i'event and init_clk_i = '1') then
            if(rstn_i = '0') then
               pmi_init_s <= '0';
               pmi_init_count_s <= (others => '0');
            elsif(link_wd_rst_s = '1') then
               -- single-cycle watchdog retry: restart the pma_init sequence so the GT re-inits
               pmi_init_s <= '0';
               pmi_init_count_s <= (others => '0');
            elsif(startup_dly_done_s = '0') then
               -- hold pma_init inactive during the 1 s startup delay
               pmi_init_s <= '0';
               pmi_init_count_s <= (others => '0');
            else
                if(pmi_init_count_s > PMI_INIT_CYCLES + PB_RST_CYCLES) then
                    pmi_init_s <= '0';
                else
                    if(pmi_init_count_s < PB_RST_CYCLES)then
                        pmi_init_s <= '0';
                    else
                        pmi_init_s <= '1';
                    end if;
                    pmi_init_count_s <= pmi_init_count_s + 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Link-up watchdog (single-cycle reset PULSE on the RFU -- NOT a long hold)
    --   If the link stays down for RST_DELAY_CYCLES (~1 s), pulse link_wd_rst_s for one cycle,
    --   which restarts the reset_pb / pma_init sequence (a brief GT re-init so the RFU re-locks).
    --   This is the original recovery and does NOT deadlock. The MBU keeps the long-reset HOLD;
    --   two symmetric 1.5 s holds would livelock, so the RFU stays a short pulse only.
    ----------------------------------------------------------------------------
    -- Synchronize channel_up (user_clk domain) into the init_clk_i domain.
--    channel_up_cdc_ins:process(init_clk_i)
--    begin
--        if(init_clk_i'event and init_clk_i = '1') then
--            channel_up_meta_s <= channel_up_s;
--            channel_up_sync_s <= channel_up_meta_s;
--        end if;
--    end process;
    
       channel_up_cdc_ins : xpm_cdc_single
   generic map (
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
      INIT_SYNC_FF => 1,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG => 0   -- DECIMAL; 0=do not register input, 1=register input
   )
   port map (
      dest_out => channel_up_sync_s, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

      dest_clk => init_clk_i, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk => '0',   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in => channel_up_s      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
    

    -- High once the startup delay elapsed and the pma_init pulse has completed.
    init_done_s <= '1' when (startup_dly_done_s = '1' and
                             pmi_init_count_s > PMI_INIT_CYCLES + PB_RST_CYCLES)
                       else '0';

    link_watchdog_ins:process(init_clk_i)
    begin
        if(init_clk_i'event and init_clk_i = '1') then
            link_wd_rst_s <= '0';   -- single-cycle reset request (default low)
            if(rstn_i = '0') then
                link_wd_count_s <= (others => '0');
            elsif(init_done_s = '0' or channel_up_sync_s = '1') then
                -- init still running, or link already up: hold watchdog cleared
                link_wd_count_s <= (others => '0');
            else
                -- init done and link still down: time out after 1 s, then pulse a GT re-init retry
                if(link_wd_count_s >= RST_DELAY_CYCLES) then
                    link_wd_rst_s   <= '1';
                    link_wd_count_s <= (others => '0');
                else
                    link_wd_count_s <= link_wd_count_s + 1;
                end if;
            end if;
        end if;
    end process;

   aurora_ins: aurora_64b66b_0
     port map(
        -- TX AXI4-S Interface
         s_axi_tx_tdata  => tx_tdata_s,
         s_axi_tx_tlast  => tx_tlast_s,
         s_axi_tx_tkeep  => tx_tkeep_s,
         s_axi_tx_tvalid => tx_tvalid_s,
         s_axi_tx_tready => tx_tready_s,
        -- RX AXI4-S Interface
         m_axi_rx_tdata  => rx_tdata_s,
         m_axi_rx_tlast  => rx_tlast_s,
         m_axi_rx_tkeep  => rx_tkeep_s,
         m_axi_rx_tvalid => rx_tvalid_s,
        -- GT Serial I/O
         rxp => rxp,
         rxn => rxn,
         txp => txp,
         txn => txn,
        -- GT Reference Clock
         refclk1_in => gt_refclk1,
        -- Error Detection
         hard_err => hard_err_s,
         soft_err => soft_err_s,
        -- Status
         channel_up => channel_up_s,
         lane_up    => lane_up_s,
        -- System Interface
         user_clk_out        => user_clk_s,
         mmcm_not_locked_out => aurora_pll_notlock_s,
         sync_clk_out        => sync_clk_s,
         reset_pb            => reset_pb_s,
         gt_rxcdrovrden_in   => '0',
         power_down          => '0',
         loopback            => "000",
         pma_init            => pmi_init_s,
         gt_pll_lock         => gt_pll_lock,
        -- GT DRP Ports (unused -> tied off, outputs open)
         gt0_drpaddr => (others => '0'),
         gt0_drpdi   => (others => '0'),
         gt0_drpdo   => open,
         gt0_drprdy  => open,
         gt0_drpen   => '0',
         gt0_drpwe   => '0',
         init_clk        => init_clk_i,
         link_reset_out  => aurora_link_reset_s,
         gt_rxusrclk_out => gt_rxusrclk_s,
        ---------------------------------------------------------------------
        -- GT control/status ports : GTH default (inactive / nominal) values
        ---------------------------------------------------------------------
        -- RX Margin Analysis
         gt_eyescandataerror => open,
         gt_eyescanreset     => "0",
         gt_eyescantrigger   => "0",
        -- RX Equalizer
         gt_rxcdrhold     => "0",
         gt_rxdfelpmreset => "0",
         gt_rxlpmen       => "0",        -- 0 = DFE (per IP eq. setting); set to "1" only if IP configured for LPM
         gt_rxpmareset    => "0",
         gt_rxpcsreset    => "0",
         gt_rxrate        => "000",      -- no rate change
         gt_rxbufreset    => "0",
         gt_rxpmaresetdone => open,
         gt_rxprbssel     => "0000",     -- PRBS off / normal data
         gt_rxprbscntreset => "0",
         gt_rxprbserr     => open,
         gt_rxresetdone   => open,
         gt_rxbufstatus   => open,
        -- TX Configurable Driver (SI tuning - confirm against IP/board settings)
         gt_txpostcursor  => "00000",    -- no post-cursor emphasis
         gt_txdiffctrl    => "11000",    -- GTHE4 default diff swing
         gt_txprecursor   => "00000",    -- no pre-cursor emphasis
        -- TX Polarity / Control
         gt_txpolarity    => "0",
         gt_txinhibit     => "0",
         gt_txpmareset    => "0",
         gt_txpcsreset    => "0",
         gt_txprbssel     => "0000",     -- PRBS off / normal data
         gt_txprbsforceerr => "0",
         gt_txbufstatus   => open,
         gt_txresetdone   => open,
         gt_pcsrsvdin     => (others => '0'),
         gt_dmonitorout   => open,
         gt_cplllock      => open,
         gt_qplllock      => open,
        -- powergood : kept observed (folded into status) to avoid Opt 31-67 trim
         gt_powergood     => gt_powergood_s,
        -- shared mode 8 series GT quad ports
         gt_qpllclk_quad1_out        => open,
         gt_qpllrefclk_quad1_out     => open,
         gt_qplllock_quad1_out       => open,
         gt_qpllrefclklost_quad1_out => open,
         sys_reset_out => aurora_system_reset_s,
         gt_reset_out  => open,
         tx_out_clk    => aurora_tx_out_clk_s
     );

    -- Status word (drives aurora_status_o through the CDC below)
    aurora_status_s(0)            <= pmi_init_s;
    aurora_status_s(1)            <= reset_pb_s;
    aurora_status_s(2)            <= hard_err_s;
    aurora_status_s(3)            <= soft_err_s;
    aurora_status_s(4)            <= channel_up_s;
    aurora_status_s(5)            <= lane_up_s(0);
    aurora_status_s(6)            <= gt_pll_lock;
    aurora_status_s(7)            <= aurora_pll_notlock_s;
    aurora_status_s(8)            <= aurora_link_reset_s;
    aurora_status_s(9)            <= gt_powergood_s(0);
    aurora_status_s(31 downto 10) <= (others => '0');

    xpm_cdc_array_single_inst : xpm_cdc_array_single
   generic map (
      DEST_SYNC_FF   => 4,
      INIT_SYNC_FF   => 0,
      SIM_ASSERT_CHK => 0,
      SRC_INPUT_REG  => 0,
      WIDTH          => 32
   )
   port map (
      dest_out => aurora_status_init_s,
      dest_clk => init_clk_i,
      src_clk  => '0',
      src_in   => aurora_status_s
   );
    aurora_status_o <= aurora_status_init_s;

    -- Read the Aurora bring-up status during a stuck link (init_clk_i domain).
    --vio_status_inst : vio_status
    --  port map (
    --   clk       => init_clk_i,
    --    probe_in0 => aurora_status_init_s
    --  );

    -- ----------------------------------------------------------------------
    -- Debug ILA: Aurora link status + reset-delay / link-up watchdog state.
    -- Sampled on init_clk_i (always-on; reset_pb / pma_init / watchdog live in
    -- this domain). channel_up is taken from its init-synced copy; aurora_status_s
    -- carries the user_clk-domain bits (slow status, fine to view cross-domain).
    --   probe0 : channel_up_sync_s  (link up, init-synced)
    --   probe1 : aurora_status_s    (0=pmi_init 1=reset_pb 2=hard_err 3=soft_err
    --            4=channel_up 5=lane_up 6=gt_pll_lock 7=mmcm_notlock
    --            8=link_reset 9=gt_powergood)
    --   probe2 : reset_pb_s         (1 s-delayed reset to the core)
    --   probe3 : pmi_init_s         (pma_init pulse)
    --   probe4 : link_wd_count_s    (link-up watchdog 1 s timer)
    --   probe5 : link_wd_rst_s      (watchdog retry pulse)
    -- aurora_status_ila : ila_0
    -- port map (
    --   clk       => init_clk_i,
    --   probe0(0) => channel_up_sync_s,
    --   probe1    => aurora_status_s,
    --   probe2(0) => reset_pb_s,
    --   probe3(0) => pmi_init_s,
    --   probe4    => link_wd_count_s,
    --   probe5(0) => link_wd_rst_s,
    --   probe6    => (others => '0'),
    --   probe7    => (others => '0')
    -- );

end Behavioral;
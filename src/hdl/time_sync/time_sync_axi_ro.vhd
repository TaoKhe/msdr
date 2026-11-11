library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_sync_axi_ro is
  generic (
    SECOND_WIDTH        : integer := 40;
    USEC_WIDTH          : integer := 27;
    ERR_WIDTH           : integer := 32;
    INC_WIDTH           : integer := 32;
    C_S_AXI_ADDR_WIDTH  : integer := 6;   -- 64 bytes
    C_S_AXI_DATA_WIDTH  : integer := 32
  );
  port (
    -------------------------------------------------------------------------
    -- AXI4-Lite slave interface
    -------------------------------------------------------------------------
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    -------------------------------------------------------------------------
    -- Inputs from time_sync_top (or any time sync core)
    -------------------------------------------------------------------------
    sec_loc_i       : in unsigned(SECOND_WIDTH-1 downto 0);
    usec_loc_i      : in unsigned(USEC_WIDTH-1 downto 0);
    offset_us_i     : in signed(ERR_WIDTH-1 downto 0);
    pps_error_us_i  : in signed(ERR_WIDTH-1 downto 0);
    error_us_i      : in signed(ERR_WIDTH-1 downto 0);
    inc_i           : in unsigned(INC_WIDTH-1 downto 0);
    tick_us_i       : in std_logic
  );
end entity;

architecture rtl of time_sync_axi_ro is

  ---------------------------------------------------------------------------
  -- AXI address decode helpers
  ---------------------------------------------------------------------------
  constant ADDR_LSB          : integer := 2; -- 4-byte alignment
  constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH - ADDR_LSB;

  -- Register word indices
  constant REG_CTRL      : integer := 0;  -- 0x00
  constant REG_SEC_LO    : integer := 1;  -- 0x04
  constant REG_SEC_HI    : integer := 2;  -- 0x08
  constant REG_USEC      : integer := 3;  -- 0x0C
  constant REG_OFFSET    : integer := 4;  -- 0x10
  constant REG_PPS_ERR   : integer := 5;  -- 0x14
  constant REG_ERROR     : integer := 6;  -- 0x18
  constant REG_INC_OUT   : integer := 7;  -- 0x1C
  constant REG_STATUS    : integer := 8;  -- 0x20

  ---------------------------------------------------------------------------
  -- AXI4-Lite internal signals
  ---------------------------------------------------------------------------
  signal axi_awready   : std_logic := '0';
  signal axi_wready    : std_logic := '0';
  signal axi_bvalid    : std_logic := '0';
  signal axi_bresp     : std_logic_vector(1 downto 0) := (others => '0');
  signal axi_arready   : std_logic := '0';
  signal axi_rvalid    : std_logic := '0';
  signal axi_rresp     : std_logic_vector(1 downto 0) := (others => '0');
  signal axi_rdata     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

  signal awaddr_reg    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal araddr_reg    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');

  signal slv_reg_wren  : std_logic := '0';
  signal slv_reg_rden  : std_logic := '0';

  ---------------------------------------------------------------------------
  -- Snapshot registers (latched when CAPTURE_REQ is asserted)
  ---------------------------------------------------------------------------
  signal sec_loc_snap        : unsigned(SECOND_WIDTH-1 downto 0) := (others => '0');
  signal usec_loc_snap       : unsigned(USEC_WIDTH-1 downto 0)   := (others => '0');
  signal offset_us_snap      : signed(ERR_WIDTH-1 downto 0)      := (others => '0');
  signal pps_error_us_snap   : signed(ERR_WIDTH-1 downto 0)      := (others => '0');
  signal error_us_snap       : signed(ERR_WIDTH-1 downto 0)      := (others => '0');
  signal inc_out_snap        : unsigned(INC_WIDTH-1 downto 0)    := (others => '0');
  signal tick_us_snap        : std_logic                         := '0';

  -- control flags
  signal capture_req_pulse   : std_logic := '0';
  signal capture_done        : std_logic := '0';

begin

  ---------------------------------------------------------------------------
  -- Map AXI internal signals to top-level ports
  ---------------------------------------------------------------------------
  s_axi_awready <= axi_awready;
  s_axi_wready  <= axi_wready;
  s_axi_bvalid  <= axi_bvalid;
  s_axi_bresp   <= axi_bresp;
  s_axi_arready <= axi_arready;
  s_axi_rvalid  <= axi_rvalid;
  s_axi_rresp   <= axi_rresp;
  s_axi_rdata   <= axi_rdata;

  ---------------------------------------------------------------------------
  -- AXI write address channel
  ---------------------------------------------------------------------------
  axi_write_addr_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        axi_awready <= '0';
        awaddr_reg  <= (others => '0');
      else
        if (axi_awready = '0') and (s_axi_awvalid = '1') and (s_axi_wvalid = '1') then
          axi_awready <= '1';
          awaddr_reg  <= s_axi_awaddr;
        elsif (s_axi_awvalid = '0') or (s_axi_wvalid = '0') then
          axi_awready <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- AXI write data channel
  ---------------------------------------------------------------------------
  axi_write_data_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        axi_wready <= '0';
      else
        if (axi_wready = '0') and (s_axi_wvalid = '1') and (s_axi_awvalid = '1') then
          axi_wready <= '1';
        elsif (s_axi_wvalid = '0') or (s_axi_awvalid = '0') then
          axi_wready <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Write response channel
  ---------------------------------------------------------------------------
  axi_write_resp_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        axi_bvalid <= '0';
        axi_bresp  <= "00";
      else
        if (axi_awready = '1') and (s_axi_awvalid = '1') and
           (axi_wready = '1')  and (s_axi_wvalid = '1') and
           (axi_bvalid = '0') then
          axi_bvalid <= '1';
          axi_bresp  <= "00"; -- OKAY
        elsif (axi_bvalid = '1') and (s_axi_bready = '1') then
          axi_bvalid <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Generate write enable (std_logic, no boolean mixing)
  ---------------------------------------------------------------------------
  slv_reg_wren <= '1' when (axi_awready = '1' and s_axi_awvalid = '1' and
                            axi_wready  = '1' and s_axi_wvalid  = '1' and
                            axi_bvalid  = '0')
                  else '0';

  ---------------------------------------------------------------------------
  -- CTRL register write (CAPTURE_REQ, clear CAPTURE_DONE) + snapshot
  ---------------------------------------------------------------------------
  write_regs_proc : process(s_axi_aclk)
    variable addr_index : integer;
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        capture_req_pulse <= '0';
        capture_done      <= '0';
        sec_loc_snap      <= (others => '0');
        usec_loc_snap     <= (others => '0');
        offset_us_snap    <= (others => '0');
        pps_error_us_snap <= (others => '0');
        error_us_snap     <= (others => '0');
        inc_out_snap      <= (others => '0');
        tick_us_snap      <= '0';
      else
        -- default: clear request pulse
        capture_req_pulse <= '0';

        if slv_reg_wren = '1' then
          addr_index := to_integer(unsigned(awaddr_reg(C_S_AXI_ADDR_WIDTH-1 downto ADDR_LSB)));

          case addr_index is
            when REG_CTRL =>
              -- bit0: CAPTURE_REQ (write 1 to trigger)
              if s_axi_wdata(0) = '1' then
                capture_req_pulse <= '1';
              end if;
              -- bit1: CAPTURE_DONE clear (W1C)
              if s_axi_wdata(1) = '1' then
                capture_done <= '0';
              end if;

            when others =>
              null;
          end case;
        end if;

        -- Snapshot when requested
        if capture_req_pulse = '1' then
          sec_loc_snap      <= sec_loc_i;
          usec_loc_snap     <= usec_loc_i;
          offset_us_snap    <= offset_us_i;
          pps_error_us_snap <= pps_error_us_i;
          error_us_snap     <= error_us_i;
          inc_out_snap      <= inc_i;
          tick_us_snap      <= tick_us_i;
          capture_done      <= '1';
        end if;

      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- AXI read address channel
  ---------------------------------------------------------------------------
  axi_read_addr_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        axi_arready <= '0';
        araddr_reg  <= (others => '0');
      else
        if (axi_arready = '0') and (s_axi_arvalid = '1') then
          axi_arready <= '1';
          araddr_reg  <= s_axi_araddr;
        elsif (s_axi_arvalid = '0') then
          axi_arready <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Generate read enable (std_logic)
  ---------------------------------------------------------------------------
  slv_reg_rden <= '1' when (axi_arready = '1' and s_axi_arvalid = '1' and axi_rvalid = '0')
                  else '0';

  ---------------------------------------------------------------------------
  -- Read data mux (pure combinational)
  ---------------------------------------------------------------------------
  read_data_proc : process(araddr_reg,
                           capture_done,
                           sec_loc_snap,
                           usec_loc_snap,
                           offset_us_snap,
                           pps_error_us_snap,
                           error_us_snap,
                           inc_out_snap,
                           tick_us_snap)
    variable rdata_v    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    variable addr_index : integer;
    variable sec_hi     : std_logic_vector(31 downto 0);
  begin
    rdata_v := (others => '0');
    sec_hi  := (others => '0');

    addr_index := to_integer(unsigned(araddr_reg(C_S_AXI_ADDR_WIDTH-1 downto ADDR_LSB)));

    case addr_index is
      when REG_CTRL =>
        -- bit1: CAPTURE_DONE (RO)
        rdata_v(1) := capture_done;

      when REG_SEC_LO =>
        if SECOND_WIDTH >= 32 then
          rdata_v := std_logic_vector(sec_loc_snap(31 downto 0));
        else
          rdata_v(SECOND_WIDTH-1 downto 0) := std_logic_vector(sec_loc_snap);
        end if;

      when REG_SEC_HI =>
        -- Upper bits of sec_loc_snap above bit 31
        if SECOND_WIDTH > 32 then
          -- copy bits [SECOND_WIDTH-1 .. 32] into sec_hi[SECOND_WIDTH-33 .. 0]
          sec_hi(SECOND_WIDTH-33 downto 0) :=
            std_logic_vector(sec_loc_snap(SECOND_WIDTH-1 downto 32));
        end if;
        rdata_v := sec_hi;

      when REG_USEC =>
        rdata_v(USEC_WIDTH-1 downto 0) := std_logic_vector(usec_loc_snap);

      when REG_OFFSET =>
        rdata_v := std_logic_vector(offset_us_snap);

      when REG_PPS_ERR =>
        rdata_v := std_logic_vector(pps_error_us_snap);

      when REG_ERROR =>
        rdata_v := std_logic_vector(error_us_snap);

      when REG_INC_OUT =>
        if INC_WIDTH >= 32 then
          rdata_v := std_logic_vector(inc_out_snap(31 downto 0));
        else
          rdata_v(INC_WIDTH-1 downto 0) := std_logic_vector(inc_out_snap);
        end if;

      when REG_STATUS =>
        rdata_v(0) := tick_us_snap;

      when others =>
        rdata_v := (others => '0');
    end case;

    axi_rdata <= rdata_v;
  end process;

  ---------------------------------------------------------------------------
  -- Read data channel handshake
  ---------------------------------------------------------------------------
  axi_read_data_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        axi_rvalid <= '0';
        axi_rresp  <= "00";
      else
        if slv_reg_rden = '1' then
          axi_rvalid <= '1';
          axi_rresp  <= "00"; -- OKAY
        elsif (axi_rvalid = '1') and (s_axi_rready = '1') then
          axi_rvalid <= '0';
        end if;
      end if;
    end if;
  end process;

end architecture;

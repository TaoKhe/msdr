-- tb_pps_jam: tai hien ca GPS 19/10/2026 o thang thu nho va kiem guard jam PPS.
--
-- Thang: USEC_PER_SEC=1000 tick/giay, inc_nominal=0x66666666 (1 tick / 2.5 clk)
-- -> mot "giay" = 2500 clk. OUTLIER = 1000/5 = 200 tick; STEP_THRESH = 1000 tick.
-- PPS vao co pha tre 350 tick (0.35 "giay"): nam dung VUNG CHET 0.2..0.5 s --
-- cong loc outlier chan, hard-step cua servo khong toi duoc nguong.
--
-- DUT A (vcxo_ctrl_en='0', che do so):  truoc jam inc phai dung o nominal;
--   dung canh PPS thu 16 guard phai jam; sau jam |pps_err| < 2 tick va servo
--   bat dau keo (inc roi nominal).
-- DUT B (vcxo_ctrl_en='1', che do analog): jam van phai ap vao bo dem NCO
--   (mux che do ep step_req_s='0' nhung jam di duong rieng); sau jam
--   |pps_err| < 2 tick va dac_update bat dau chay.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pps_jam is
end entity;

architecture sim of tb_pps_jam is
  constant CLK_PERIOD : time    := 4 ns;
  constant UPS        : integer := 1000;   -- tick / "giay"
  -- 2501 clk/giay = 1000.4 tick/giay: lech tan +0.4 tick/s de sau jam servo
  -- PHAI keo inc khoi nominal (PPS dung 2500 thi sai so sau jam = 0 va inc
  -- dung nominal la hanh vi dung -- khong kiem duoc).
  constant SEC_CLK    : integer := 2501;
  constant PPS_OFF    : integer := 875;    -- clk: 875/2.5 = 350 tick = 0.35 "giay"

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal pps_in : std_logic := '0';

  -- "dong ho MBU": chay dung nominal (0x66666666/2^32 tick/clk), phat timestamp
  -- moi 250 clk (0.1 "giay"). Local khoi dau trung MBU (ca hai ve 0 sau reset)
  -- nen truoc jam offset ~ 0; sau jam ve GPS thi offset = -350 tick = -0.35 s
  -- >= OUTLIER 0.2 s -> neu guard TS khong bi gate theo use_offset_s thi no se
  -- nap lai thoi gian MBU va pha GPS mat sau 16 mau TS (loi thay tren HW 19/10).
  signal rx_ts_valid : std_logic := '0';
  signal mbu_sec  : unsigned(39 downto 0) := (others => '0');
  signal mbu_usec : unsigned(26 downto 0) := (others => '0');

  type duts_t is record
    pps_err  : signed(31 downto 0);
    inc_out  : unsigned(31 downto 0);
    run_st   : std_logic_vector(2 downto 0);
    pps_ok   : std_logic;
    dac_upd  : std_logic;
  end record;
  signal a, b : duts_t;

  signal sim_done : boolean := false;
  constant INC_NOM : unsigned(31 downto 0) := x"66666666";
begin
  clk_proc : process
  begin
    while not sim_done loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  -- 1PPS: chu ky SEC_CLK, mo dau lech PPS_OFF so voi ranh gioi giay cuc bo
  -- (local bat dau tu 0 sau reset). Cao 25 clk (du 5 tap debounce).
  pps_proc : process
  begin
    wait until rst = '0';
    wait for PPS_OFF * CLK_PERIOD;
    while not sim_done loop
      pps_in <= '1';
      wait for 25 * CLK_PERIOD;
      pps_in <= '0';
      wait for (SEC_CLK - 25) * CLK_PERIOD;
    end loop;
    wait;
  end process;

  mbu_clk_proc : process(clk)
    variable acc : unsigned(31 downto 0) := (others => '0');
    variable sum : unsigned(32 downto 0);
    variable cnt : integer := 0;
  begin
    if rising_edge(clk) then
      rx_ts_valid <= '0';
      if rst = '0' then
        sum := ('0' & acc) + unsigned'('0' & INC_NOM);
        acc := sum(31 downto 0);
        if sum(32) = '1' then                      -- tick MBU
          if mbu_usec = to_unsigned(UPS-1, 27) then
            mbu_usec <= (others => '0');
            mbu_sec  <= mbu_sec + 1;
          else
            mbu_usec <= mbu_usec + 1;
          end if;
        end if;
        cnt := cnt + 1;
        if cnt = 250 then cnt := 0; rx_ts_valid <= '1'; end if;
      end if;
    end if;
  end process;

  dut_a : entity work.time_sync_top
    generic map (
      USEC_PER_SEC => UPS, NCO_PHASE_WIDTH => 32, FRAC_BITS => 1,
      KP_SHIFT => -2, KI_SHIFT => 2, I_FRAC => 8,
      INC_TRIM_MAX => 10_000_000, FILT_SHIFT => 1,
      PPS_TIMEOUT_CYCLES => 3*SEC_CLK, TS_TIMEOUT_CYCLES => 3*SEC_CLK,
      HOLDOVER_TIMEOUT_CYCLES => 100*SEC_CLK, AD_UPDATE_MIN_CYCLES => 50)
    port map (
      clk => clk, rst => rst, cfg_mode => "010",   -- FORCE_PPS_ONLY
      pps_in => pps_in, rx_ts_valid => rx_ts_valid,
      rx_sec => mbu_sec, rx_usec => mbu_usec,
      inc_nominal => INC_NOM, vcxo_ctrl_en => '0', vcxo_ref_10m => '0',
      dac_fb_code => (17 downto 0 => '0'), dac_fb_valid => '0',
      ts_delay_cyc => (15 downto 0 => '0'),
      pps_error_us_out => a.pps_err, inc_out => a.inc_out,
      run_state_out => a.run_st, pps_ok_out => a.pps_ok,
      dac_update_pulse => a.dac_upd);

  dut_b : entity work.time_sync_top
    generic map (
      USEC_PER_SEC => UPS, NCO_PHASE_WIDTH => 32, FRAC_BITS => 1,
      KP_SHIFT => -2, KI_SHIFT => 2, I_FRAC => 8,
      INC_TRIM_MAX => 10_000_000, FILT_SHIFT => 1, DAC_GAIN_SHIFT => 2,
      PPS_TIMEOUT_CYCLES => 3*SEC_CLK, TS_TIMEOUT_CYCLES => 3*SEC_CLK,
      HOLDOVER_TIMEOUT_CYCLES => 100*SEC_CLK, AD_UPDATE_MIN_CYCLES => 50)
    port map (
      clk => clk, rst => rst, cfg_mode => "010",
      pps_in => pps_in, rx_ts_valid => rx_ts_valid,
      rx_sec => mbu_sec, rx_usec => mbu_usec,
      inc_nominal => INC_NOM, vcxo_ctrl_en => '1', vcxo_ref_10m => '0',
      dac_fb_code => (17 downto 0 => '0'), dac_fb_valid => '0',
      ts_delay_cyc => (15 downto 0 => '0'),
      pps_error_us_out => b.pps_err, inc_out => b.inc_out,
      run_state_out => b.run_st, pps_ok_out => b.pps_ok,
      dac_update_pulse => b.dac_upd);

  mon : process(clk)
    variable sec : integer := 0;
  begin
    if rising_edge(clk) then
      if pps_in = '1' and pps_in'last_value = '0' then
        sec := sec + 1;
        report "MON canh " & integer'image(sec) &
               ": A err=" & integer'image(to_integer(a.pps_err)) &
               " inc-nom=" & integer'image(to_integer(signed(a.inc_out)) - to_integer(signed(INC_NOM))) &
               " st=" & integer'image(to_integer(unsigned(a.run_st))) &
               " | B err=" & integer'image(to_integer(b.pps_err));
      end if;
    end if;
  end process;

  check : process
    variable n_upd_pre, n_upd_post : integer := 0;
    variable errs : integer := 0;
    procedure chk(cond : boolean; msg : string) is
    begin
      if not cond then
        report "FAIL: " & msg severity error;
        errs := errs + 1;
      else
        report "PASS: " & msg;
      end if;
    end procedure;
  begin
    rst <= '1';
    wait for 20 * CLK_PERIOD;
    rst <= '0';

    -- dem dac_update cua DUT B trong giai doan truoc jam (giay 2..14):
    wait for 2 * SEC_CLK * CLK_PERIOD;
    for i in 1 to 12 * SEC_CLK loop
      wait until rising_edge(clk);
      if b.dac_upd = '1' then n_upd_pre := n_upd_pre + 1; end if;
    end loop;

    -- t ~ giay 14: truoc canh thu 16. Kiem tra he dang nam im dung kieu HW:
    chk(a.pps_ok = '1', "A: pps_ok=1 du mau bi chan");
    chk(a.run_st = "001", "A: run_state = PPS_ONLY");
    chk(a.inc_out = INC_NOM, "A: inc dung nominal (vung chet) truoc jam");
    chk(abs(a.pps_err) >= 2*200, "A: |pps_err| >= OUTLIER (sub-tick) truoc jam");
    chk(n_upd_pre <= 1, "B: khong co dac_update truoc jam (tru echo boot)");

    -- doi qua canh 16 + 2 giay cho servo nhan mau dau
    wait for 5 * SEC_CLK * CLK_PERIOD;
    chk(abs(a.pps_err) < 2*2, "A: |pps_err| < 2 tick sau jam");
    chk(abs(b.pps_err) < 2*2, "B: |pps_err| < 2 tick sau jam (vcxo mode)");

    -- them 4 giay: servo da keo -> inc A roi nominal; B co dac_update
    for i in 1 to 4 * SEC_CLK loop
      wait until rising_edge(clk);
      if b.dac_upd = '1' then n_upd_post := n_upd_post + 1; end if;
    end loop;
    chk(a.inc_out /= INC_NOM, "A: inc roi nominal sau jam (servo chay)");
    chk(n_upd_post >= 3, "B: dac_update chay sau jam");

    -- TS van song suot bai test; neu guard TS khong bi gate theo use_offset_s
    -- thi den day local da bi nap lai thoi gian MBU va |pps_err| quay ve
    -- ~350 tick (700 sub). Kiem lai lan nua sau them 4 giay:
    wait for 4 * SEC_CLK * CLK_PERIOD;
    chk(abs(a.pps_err) < 2*20, "A: pha GPS GIU sau 8 giay du TS MBU van chay");
    chk(abs(b.pps_err) < 2*20, "B: pha GPS GIU sau 8 giay (vcxo mode)");

    if errs = 0 then report "==== tb_pps_jam: PASS ===="; 
    else report "==== tb_pps_jam: " & integer'image(errs) & " FAIL ====" severity error;
    end if;
    sim_done <= true;
    wait;
  end process;
end architecture;

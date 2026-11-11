# MSDR FPGA sources

## Current TX path and project flows

The source-based `make msdr` flow builds the current design from
`scripts/msdr/` and `src/`, including the Xilinx FIR Compiler TX path and DAC1
DMA removal. The separate v4 recreation flow is retained to reproduce its
exported project snapshot.

Use Vivado 2024.1:

```sh
make project-msdr-v4  # new project + HDL/IP generation, no synth/implementation
# OR, with the output directory absent:
make build-msdr-v4    # new project + synthesis/implementation/bitstream
```

Both use `scripts/msdr/build_recreated_v4.tcl` and write
`msdr_recreated_v4_gen/msdr.xpr` by default. They refuse to overwrite an
existing output directory. To preserve an existing generated project and make
a fresh one in a separate directory, run:

```sh
MSDR_CREATE_ONLY=1 vivado -mode batch -nojournal -nolog \
  -source scripts/msdr/build_recreated_v4.tcl \
  -tclargs --output_dir msdr_recreated_v4_16bit_gen
vivado msdr_recreated_v4_16bit_gen/msdr.xpr
```

After project-only creation, open that project and run synthesis and
implementation in Vivado to continue; do not rerun the creation command.

Imported IP configuration, wrapper and SYSID ROM data are retained in
`scripts/msdr/assets_v4/`. HDL/XDC are read from `src/`. Old generated
projects, their checkpoints and the v3 directory are not required to run the
new scripts. The old `build_repair_v3.tcl` is historical and requires the
now-retired v2 project.

The Aurora IQ TX path is documented in
[`docs/Aurora_IQ_250_to_50_v3.md`](docs/Aurora_IQ_250_to_50_v3.md). A prior
source build exposed unsynchronized status crossings from the ADRV RX clocks
into the AXI register clock. The current source transfers RX overflow events
through per-clock XPM pulse/level synchronizers and synchronizes the time-sync
lock status before the AXI register block. The latest `make msdr` build in
`msdr_v3_16bit_cdcfix_gen/` passed implementation and generated a bitstream.
Post-route timing is WNS +0.142 ns, TNS 0, WHS +0.010 ns and WPWS +0.039 ns,
with zero failing endpoints. The former RX-to-AXI violations are gone; the
worst remaining path is a recovery check in ADRV `clk_pl_2`, with +0.142 ns
slack. External I/O delays are not fully constrained, so this is not complete
board-level timing certification.

Generated Vivado projects are outputs, not sources. The older `msdr_gen/`,
`msdr_v3_16bit_gen/` and v4 recreation directories are retained as versioned
references; `make msdr` builds the current source tree into
`msdr_v3_16bit_cdcfix_gen/`. `make clean` removes the current MSDR and ZCU102
build outputs but leaves those retained project versions, HDL, IP sources and
documentation untouched. The AXI FIFO example project is retained because it
contains example sources rather than only disposable build output.

One design, two hardware targets. The repository follows the t7_fpga layout:
design sources under `src/`, Vivado Tcl entrypoints under `scripts/`, and one
generated Vivado project per variant in `<variant>_gen/`.

| Variant | FPGA | Carrier |
|---|---|---|
| `msdr` | `xczu15eg-ffvb1156-2-i` | T12 custom board |
| `adrv9001_zcu102` | `xczu9eg-ffvb1156-2-e` | ZCU102 |

Both are LVDS-only and share the ADI framework, the IP library set and the
Makefile front end; every design file is per-variant.

```
Makefile                      build entrypoint (see `make help`)
scripts/
  adi_env.tcl                 convenience loader for the vendored ADI environment
  msdr/
    system_project.tcl        project entrypoint (part given explicitly)
    system_bd.tcl             block-design entrypoint (fixed name, see below)
    msdr_bd.tcl               the block design itself
  adrv9001_zcu102/
    system_project.tcl        project entrypoint (part derived from the name)
    system_bd.tcl             block-design entrypoint (fixed name, see below)
    adrv9001_bd.tcl           the block design itself
src/
  hdl/                        design HDL and the vendored ADI HDL framework
    top/                      board top levels; both keep module name `system_top`
      msdr_top.v
      adrv9001_zcu102_top.v
    msdr_trx/                 MSDR TRX integration layer (see "TRX chain" below)
      msdr_trx_core.vhd       Aurora + GFP + time sync, tapped onto the ADRV9002
      msdr_rf_ctrl.vhd        fsm_main adapted to the T12 RF control surface
      msdr_trx_regs.vhd       single AXI4-Lite window the PS drives both from
    aurora/ aurora_framer/ aurora_deframer/ gfp_module/
                              Aurora link and frame protocol, from tvsdr_rfu_trx
    time_sync_v2/             1PPS + timestamp servo, from tvsdr_rfu_trx
    time_sync/                only time_sync_axi_ro.vhd (v2 has no AXI wrapper)
    fsm/                      TDD frame state machine and its SPI/GPIO plumbing
    *_Driver/                 RF part drivers fsm_main instantiates
    library/                  ADI IP sources; Vivado reads this as its IP repository
    projects/scripts/         ADI project Tcl (adi_project_xilinx, adi_board, adi_pd)
    projects/common/zcu102/   ZCU102 carrier block design and constraints
    scripts/adi_env.tcl       ADI environment setup
    quiet.mk, ipcache/
  ip/
    adi_library/              separate copy of the ADI custom IP repository
    <core>/                   the TRX IP, all retargeted to xczu15eg-ffvb1156-2-i
  xdc/                        board constraints, one pair per variant
    msdr.xdc, msdr_lvds.xdc
    adrv9001_zcu102.xdc, adrv9001_zcu102_lvds.xdc
  attic_tvsdr/                retired with the tvsdr_rfu_trx migration, see below
docs/                         architecture drawings and datasheets
msdr_v3_16bit_cdcfix_gen/      current source-based MSDR build output
msdr_v3_16bit_gen/             retained prior source-based project
msdr_gen/                      retained earlier generated project
adrv9001_zcu102_gen/
```


## Building

```
make msdr               # create and implement current MSDR    -> msdr_v3_16bit_cdcfix_gen/
make project-msdr       # create current project only          -> msdr_v3_16bit_cdcfix_gen/
make adrv9001_zcu102    # create and implement ADRV9001/ZCU102 -> adrv9001_zcu102_gen/
make all                # both variants, one after the other
make lib                # only (re)build the ADI IP libraries
make gui-<variant>      # open a generated project in the Vivado GUI
make clean              # remove current build outputs (versioned archives are kept)
make help               # list every target
```

### Opening the project

`msdr_v3_16bit_cdcfix_gen/` is **generated output, not a source**. Never open a stale
one and never edit the block design expecting the change to survive: the next
build recreates the project from `scripts/msdr/`, and anything done in the GUI
is lost. The sources are `scripts/msdr/msdr_bd.tcl` (the block design),
`scripts/msdr/file_list.tcl` (what goes into the project) and `src/`. The
project top is `msdr_fpga` (VHDL), set at the end of
`scripts/msdr/system_project.tcl` — `adi_project_files` sets it to `system_top`
first, which does not exist here, so the override is required.

To look at or work on the design:

```
make project-msdr       # project + block design, no synth/impl
make gui-msdr           # open msdr_v3_16bit_cdcfix_gen/msdr.xpr
```

To build a bitstream, `make msdr` instead; it does the same thing and then runs
synthesis and implementation. Both targets refuse to overwrite an existing
`msdr_v3_16bit_cdcfix_gen/`; preserve that version and choose a new output directory
with `MSDR_PROJECT_DIR=<new-directory>` when generating another copy.

### Temporary v3 board profile

Source builds now use `src/hdl/top/msdr_fpga_v3.vhd`. The original
`msdr_fpga.vhd` and `msdr_repair_v2_gen/msdr.xpr` are retained for v2.
At the user's request, v3 temporarily removes `mcs_out`, `tdd_sync_cntr`,
`onepps_in` and `uart_txd` from the external FPGA interface. The BD's MCS/TDD
outputs are left open, the unused UART TX port is removed, and the internal
1PPS input is held low. **External 1PPS synchronization is disabled**:
this profile must not be used to validate external PPS lock. Existing BBU
GPIO ownership and all assigned board pins are unchanged. No DRC severity
is relaxed and no ADI IP core is edited.

Run `scripts/msdr/build_repair_v3.tcl` in Vivado batch mode to clone the
existing v2 project into `msdr_repair_v3_gen/`, select the v3 top-level,
and rebuild through bitstream generation. This does not import GUI-only
changes from other generated projects. Open `msdr_repair_v3_gen/msdr.xpr`
for this profile, not the retained v2 project.

Verified v3 build (Vivado 2024.1): generated
`msdr_repair_v3_gen/msdr.runs/impl_1/msdr_fpga.bit` (28,700,859 bytes).
The routed checkpoint exports none of the four disabled ports. Targeted
`MDRV-1`, `NSTD-1`, `UCIO-1`, `AVAL-326` and `RTSTAT-1` DRC reports zero
violations; all 73,159 routable nets are fully routed with zero routing errors.
Specified timing constraints pass: WNS +0.033 ns, WHS +0.010 ns, worst
pulse-width slack +0.036 ns. Existing methodology/CDC and missing external
I/O delay warnings remain; this is not full board-level timing certification
or hardware validation. Reports are saved in `msdr_repair_v3_gen/`.

To restore the external ports after their hardware mapping is confirmed,
select the original top-level in the project and source file list, implement
the required board connections/constraints, then rerun synthesis and implementation.

### Historical v2 pin blockers

**In v2, `write_bitstream` is not ready.** `src/xdc/msdr.xdc` now constrains the
T12 GPIO, DSA, DCXO and filter-SPI ports using the supplied pin map, but the
Aurora L1 and its 156.25 MHz reference are now constrained from schematic
sheet 24 (bank 230). The separate 1PPS/10 MHz, UART and MCS top-level ports
still need an unambiguous mapping; the BBU GPIO pads already have PS owners.
Linked synthesis DRC now reports four unassigned ports: `mcs_out`, `onepps_in`,
`tdd_sync_cntr` and `uart_txd`; these remain bitstream blockers, not waived.
`NSTD-1`/`UCIO-1` can therefore still block bitstream generation. Synthesis
and implementation remain the useful checks until the full top-level pin map
is available.

If you changed the block design in the GUI and want to keep it, write it back
to the script with `write_bd_tcl` and merge that into `scripts/msdr/msdr_bd.tcl`
by hand — the file carries hand-written sections that a regenerated dump would
otherwise drop.

### GFP AXI-Stream clock mismatch in a GUI-edited design

If `generate_target` reports `BD 41-237` for `GFP_UB_IN` or `GFP_UB_OUT`
(100000000 Hz versus 99999992 Hz), open `system.bd` and run in the Vivado
Tcl console:

```tcl
source /home/taokhe/Projects/in/msdr_2_2/scripts/msdr/fix_gfp_clock_v2.tcl
generate_target {synthesis implementation} [get_files */system.bd]
```

Version 2 reads the actual `sys_ps8/pl_clk0` frequency and associates the AXI
and optional GFP interfaces with the existing `init_clk` output. This also
fixes `BD 41-2559`; setting only `FREQ_HZ` is insufficient. It assigns the
existing TRX windows at 0x81210000/0x81220000/0x81230000/0x81250000 and repairs
an unreadable relocated SYSID ROM path before validating and saving the design.
It does not change the clock generator, FIFO/converter configuration or
interface wiring. Version 1 is retained for reference. Source builds now select
RPLL for PL0/1/2 (100/250/500 MHz).
Preserve GUI changes with `write_bd_tcl` before rebuilding from source.
The separate HPC0 `AWUSER_WIDTH`/`ARUSER_WIDTH` warnings are not fixed by this
clock metadata repair.

The separately generated `msdr_repair_v2_gen/msdr.xpr` is a source-based
project; it does not overwrite `msdr_gen/` or incorporate the GUI-only GFP
FIFO/converter edits. Do not mix its generated wrapper with the GUI-edited
block design. Source edits require fresh synthesis and implementation: old
09-Nov checkpoints and their `/home/user5/...` log paths do not reflect them.
No ADI IP core source is changed by these repairs.
The RFE MISO feedback uses the existing GPIO IOBUF's `O` signal rather than
reading its `IO` pad again in fabric; the latter inferred an extra input path
and left `trx_spi_miso_iobuf/IO` unrouted.

Final v2 verification (Vivado 2024.1): HDL generation and linked synthesis
passed; placement/routing completed with all 73,162 routable nets fully routed
and zero routing errors. Routed timing meets the specified constraints:
WNS +0.023 ns, WHS +0.011 ns, worst pulse-width slack +0.039 ns, no failing
setup/hold endpoints and no bus-skew violations. Timing margin is small and
does not validate unconstrained external board interfaces. The final targeted
DRC has no `MDRV-1`, `AVAL-326` or `RTSTAT-1`; only `NSTD-1`/`UCIO-1` for the
four unassigned ports listed above remain. No bitstream was generated.
Reports are `msdr_repair_v2_gen/repair_timing_final_v2.rpt`,
`repair_drc_final_v2.rpt` and `repair_route_status_v2.rpt` in that directory.

`make` with no target builds `msdr` only. Each variant target depends on `lib`,
so the ADI IP libraries are brought up to date first; the two variants share the
same `LIB_DEPS`, so this is built once.

Vivado runs with its working directory set to `scripts/<variant>/`, because
`adi_project_create` sources `system_bd.tcl` by that fixed name relative to the
working directory. `ADI_PROJECT_DIR` redirects all generated output into
`<variant>_gen/`.

## TRX chain (migrated from `tvsdr_rfu_trx`)

The FPGA design from `/home/user5/Projects/v0.6.3/RFU/FPGA` was moved onto
MSDR. The source is `src/hdl/top/tvsdr_fpga.vhd` over there — the top that
`scripts/project_top.tcl` actually loads and names in `set_property top`. The
sibling `tvsdr_rfu_trx.vhd` in the same directory is **not** part of that
project and is stale; do not use it as a reference. Two things about the hardware differ, and they decide everything below:
MSDR is a Zynq UltraScale+ MPSoC (`xczu15eg`) so there is a PS where TVSDR had
a MicroBlaze, and the converters are one ADRV9002 where TVSDR had an AD9652 ADC
and an AD9164 DAC behind JESD204.

### What the data does now

```
           ADRV9002                      PL                          BBU (J2)
  RX1 ---> adc_1 i0/q0 --+
                         +--> framer -> GFP -> Aurora ------------> GTH lane 1
  RX2 ---> adc_2 i0/q0 --+   (64-bit word = I_A Q_A I_B Q_B)             |
                                                                         |
  TX1 <--- dac_1 i0/q0 <-- async FIFO <-- FIR Compiler x2 (5:1) <-- [tx_iq_source mux] <- deframer <- Aurora
                                               ^          ^
                                               |          +- DDS, CW, GMSK
                                               |          +- RF off

  TX2 <--- dac_2 <---- util_upack2 <- axi_dmac <- PS DDR       (unchanged)
```

**Receive has no DMA.** Both RX channels go only to Aurora, the way the AD9652's
two channels did on TVSDR. `axi_adrv9001_rx1_dma`, `axi_adrv9001_rx2_dma` and
both `util_cpack2` instances are gone from the block design. Nothing on the PS
side can read raw RX samples any more; the ADI IIO receive device no longer
exists for this design.

The 64-bit framer word keeps TVSDR's layout from `rx_system_wrap.vhd:395`,
`I_A & Q_A & I_B & Q_B`, with channel A = RX1 and channel B = RX2. I is the
high half of each channel.

**`adc_1` and `dac_1` carry two channels, not two time samples.** In
`axi_adrv9001_core.v`, `i_rx1` takes channel A from `rx1_data_*` and channel B
from `rx2_data_*`, so `adc_1_data_i1/q1` is RX2 — and only when the ADRV9002
profile routes RX2 over RX1's interface. T12 wires both RX LVDS interfaces
separately (`msdr_top.v` has separate `rx1_*` and `rx2_*` pin groups), so this
design assumes **separate interfaces** and takes RX2 from `adc_2` on its own
clock. `adc_1_clk` and `adc_2_clk` come from the same ADRV9002 device clock, so
they are mesochronous; RX2 crosses into `adc_1_clk` through a 16-deep
`xpm_fifo_async`. If the profile turns out to use one interleaved interface
instead, drop that FIFO and read `adc_1_data_i1/q1` directly.

The same applies on transmit: `dac_1_data_i0/q0` is TX1 and `i1/q1` is TX2.
Only TX1 is driven here; `i1/q1` are tied to zero and TX2 keeps its own DMA
path through `dac_2`.

### Transmit source selection

`tx_iq_source` (CTRL[10:8]) is carried over from the `case` block at
`tvsdr_fpga.vhd:947`:

| Code | Source |
|---|---|
| `000` | DDS two-tone, 500 kHz apart — IMD3 measurement |
| `001` | DDS single carrier shifted 250 kHz |
| `010` | IQ from the BBU over Aurora — the operational path |
| `011` | CW at 1/2 power |
| `100` | CW at 1/8 power |
| `101` | GMSK 2 Mb/s from `Waveform_streamer` |
| `110` | Reserved/off; DAC1 has no DMA source |
| `111` | RF off |

Every source passes through TVSDR's 6 dB backoff (sign-extend twice, keep the
top 14 bits), so CW, GMSK and DDS levels match measurements taken on the old
board. CTRL resets to `0x0000_0700`, i.e. **RF off**, so nothing transmits
before software asks for it.

### Clock domains

| Clock | Source | Used by |
|---|---|---|
| `init_clk`, 100 MHz | PS `pl_clk0` | AXI, GFP, time sync, Aurora init/DRP |
| `aurora_clk` | `aurora_64b66b_0` user clock | framer/deframer protocol layer |
| `adc_clk` | `axi_adrv9001/adc_1_clk` | framer sample side, RX1 |
| `adc2_clk` | `axi_adrv9001/adc_2_clk` | RX2, mesochronous with `adc_clk` |
| `PL1`, 250 MHz | PS `pl_clk1` | Aurora deframer sample output, TX mux, DDS/GMSK, FIR input |
| `dac_clk` | `axi_adrv9001/dac_1_clk` | async FIFO read and DAC input; request rate comes from `dac_1_rd_en` |

### Blocks and their fate

| TVSDR block | On MSDR |
|---|---|
| `aurora_wrapper`, `aurora_protocol`, framer/deframer, GFP | kept as-is |
| `tx_IQ_source` mux, DDS, GMSK `Waveform_streamer` | kept, from `tvsdr_fpga.vhd` |
| `vcsco_wrapper` wrapping `time_sync_top` | kept at the same level as the original |
| `fsm_main`, `tx_ctrl`, `spi_master`, `GPIO_Mux` | kept, instance name `i_fsm_main` unchanged |
| `rx_system_wrap` (AD9652 LVDS + DDC) | dropped, replaced by `adc_1` |
| `tx_sys` (JESD204 + AD9164) | dropped, replaced by `dac_1` |
| `mb_bd_wrapper` (MicroBlaze + ELF) | dropped, replaced by the PS |
| `clk_wiz_0`, `INIT_CLK` IBUFDS | dropped, `pl_clk0` instead |
| Two Xilinx FIR Compiler IPs + XPM async FIFO | 24-bit COE low-pass, I/Q decimation by 5, then CDC from PL1 to `dac_1_clk` |
| `vio_0`, `vio_ts` | kept — `vio_0` is how `tx_IQ_source` is driven during bring-up |
| `ila_0`, `ila_1`, `ila_12` at top level | removed |
| KCU116 / ALINX / MBU top levels | not carried over |

### Control from the PS

The PS reaches the design the same way the MicroBlaze did, through buses that
kept their `mb_bd` names so the top reads the same:

- `gpio_1_tri` — the command word `i_fsm_main` reads, from an `axi_gpio`
- `CFG_LUT` — the frequency lookup BRAM `fsm_main` reads
- `GFP_UB_IN` / `GFP_UB_OUT` — the GFP message channel, which on TVSDR went
  straight to the MicroBlaze and here goes to the PS through an
  `axi_fifo_mm_s`
- `SYS_INTERFACE` — `system_info_wrapper`, unchanged

`u_msdr_trx_regs` is the one block with no counterpart in TVSDR. It carries
only what MSDR adds: the per-bit masks deciding whether the PS or `fsm_main`
owns each RF control bit, and a software-readable copy of the transmit source
select. Its map is documented at the top of
`src/hdl/msdr_trx/msdr_trx_regs.vhd`.

Masks reset to all-ones, i.e. the PS owns every RF control bit and the FSM
drives nothing until software hands bits over. They are as wide as the
`axi_t12_gpio` channels actually are: 32 bits for channel 1 and 27 for channel
2. Only the low 24 and low 26 bits drive pads; the rest are sense inputs, where
the mask value does not matter.

### Open points

These are migration decisions that still need hardware facts:

- **Pin constraints remain incomplete.** `src/xdc/msdr.xdc` now constrains the
  T12 GPIO, DSA, DCXO and filter-SPI pins using the supplied pin map. The
  Aurora L1 and its reference use the bank-230 pins from schematic sheet 24.
  Separate 1PPS/10 MHz, UART and MCS ports still need confirmed ownership/pins.
- **The frequency band table is still TVSDR's.** `gpio_BRAM`/`gpio.coe` and the
  `gpio_outs` decode inside `fsm_main` were written for the TVSDR RF board. The
  first 13 bits are mapped onto T12's `rfsw_ctrl`/`lbf_ctrl`/LNA-bypass/TRX
  control by function; the rest is left to the PS. The table has to be redone
  against the T12 RF chain for the FSM to be useful.
- **Drivers for parts T12 does not have are still compiled in.** `fsm_main`
  instantiates the AD9164, AD9914, ADF41510, MAAD-011045, LB TBPF and PLL
  drivers directly, exactly as on TVSDR. Their outputs go nowhere on T12, so
  synthesis removes the logic, but the files must stay for `fsm_main` to
  elaborate. Deleting them means editing `fsm_main`, which is the same job as
  redoing the band table.
- **T12 peripheral ownership is now with the PS.** `axi_t12_aux_gpio` drives
  the DSA, BBU GPIO and RFE SPI pins; the low/high-band AXI Quad SPI blocks
  drive the filter buses; PS SPI1 drives the DCXO. The legacy VHDL drivers
  remain compiled for the FSM but are no longer routed to those board pins.
  The AXI GPIO defaults to high-Z at reset. Verify the wiring against the T12
  schematic before enabling output directions in software.
- **Upstream frame metadata has no source.** The `*_in` metadata ports of
  `i_aurora_protocol` (what the RFU reports back to the BBU) come from
  `i_fsm_main` as on TVSDR, but nothing yet sets the PS-side values.
- **The time-sync tick unit needs confirming against the MBU.**
  `time_sync_v2` documents the protocol Subsecond unit as 10 ns, but its NCO
  cannot generate 10 ns ticks at any practical clock (the increment is 32 bits
  into a 36-bit accumulator, so ticks cap at clk/16). It runs at the 1 us
  default here. If the MBU really sends 10 ns units, the `rx_usec` path needs a
  conversion. See the generic comment in `msdr_trx_core.vhd`.
- **The BBU GFP message channel is not connected.** `GFPin_*`/`GFPout_*` are
  tied off; wire them to a FIFO the PS can reach when that channel is needed.
- **The BBU UART (J2 GPIO_2/3) is not brought up.** It would need an EMIO UART
  enabled in the PS configuration.

### The Aurora core is configured to match `aurora_wrapper.vhd`

`src/ip/aurora_64b66b_0/aurora_64b66b_0.xci` is not freely configurable. The
hand-written `src/hdl/aurora/aurora_wrapper.vhd` carried over from TVSDR
declares the core's full 75-port interface, and four options decide whether
those ports exist at all:

| Option | Must be | Why |
|---|---|---|
| `SupportLevel` | `1` | shared logic inside the core: `user_clk_out`, `sync_clk_out`, `mmcm_not_locked_out`, `gt_qpll*_quad1_out`, `tx_out_clk` |
| `TransceiverControl` | `true` | exposes the `gt_eyescan*` / `gt_rx*` / `gt_tx*` control and debug group |
| `drp_mode` | `Native` | gives `gt0_drpaddr/di/do/rdy/en/we`; `AXI4_LITE` replaces them with a bus the wrapper does not drive |
| `SINGLEEND_GTREFCLK` | `true` | the core takes an already-buffered clock, because `msdr_top.v` owns the `IBUFDS_GTE4` |

`C_INIT_CLK` must also stay at `100`, matching `pl_clk0` and the hard-coded
`INIT_CLK_FREQ_HZ` inside `aurora_wrapper.vhd`.

Everything else is T12 hardware: GTH, one lane, 10.3125 Gbps, a 156.25 MHz
reference, lane `X1Y4` in `Quad_X1Y1`. Those placements are provisional until
the constraints are written.

If any of the four options above is changed, synthesis fails with a wall of
`[Synth 8-485] no port '<name>' on instance` against `aurora_wrapper.vhd`.
Either change it back, or rewrite the wrapper's component declaration and
instantiation to match.

### One block design, as in the original

The original project `tvsdr_rfu_trx_gen` has exactly one block design,
`mb_bd` (MicroBlaze), and its top `tvsdr_fpga.vhd` is plain VHDL that
instantiates that wrapper alongside every other RTL module and IP core
directly. MSDR keeps that shape:

```
msdr_fpga.vhd                     top, plain VHDL, project top
├── sys_wrapper_ins               system.bd — Xilinx and ADI IP
│     sys_ps8, axi_adrv9001, tx1/tx2 DMA, util_upack2 x2, axi_sysid,
│     axi_t12_gpio, interconnects, axi_trx_crossbar, the configuration-LUT
│     BRAM, the GFP message FIFO, the command GPIO
├── Aurora_ins, i_aurora_protocol, i_fsm_main, u_vcsco_wrapper,
│   dac_data_cdc_fifo, dds_instan, Waveform_streamer_inst, vio_0_inst,
│   vio_timesync, spi_3wire_ins, tx_spi_ctrl, sys_infor_ins, ...
└── u_msdr_trx_regs               MSDR-only control bits
```

`system.bd` plays exactly the role `mb_bd` played: it is the processor plus
the things the processor served to the fabric. Everything else is instantiated
in VHDL, with the same instance names as `tvsdr_fpga.vhd`.

### Reading `msdr_fpga.vhd` against `tvsdr_fpga.vhd`

`src/hdl/top/msdr_fpga.vhd` is a copy of `tvsdr_fpga.vhd` with edits, not a
rewrite, so `diff` between the two is meaningful. Every change carries an
`-- [MSDR]` comment. The substitutions:

| `tvsdr_fpga.vhd` | `msdr_fpga.vhd` |
|---|---|
| `rx_wrap : rx_system_wrap` | tap on `axi_adrv9001` `adc_1`/`adc_2` |
| `tx_wrap : tx_sys` | drives `dac_1` |
| `tx_sync_inst : IBUFDS` | removed, JESD SYNC does not exist |
| `mb_wrapper_ins : mb_bd_wrapper` | `sys_wrapper_ins : system_wrapper` |
| `Aurora_samp_out_ila : ila_1` | removed |
| `vcsco_spi_ila : ila_0` | removed |
| `ila_Aurora_link_inst : ila_12` | removed |

Everything else keeps its original instance name, including `Aurora_ins`,
`i_aurora_protocol`, `i_fsm_main`, `u_vcsco_wrapper`, `dac_data_cdc_fifo`,
`dds_instan`, `Waveform_streamer_inst`, `NB6L295_Driver_inst`, `spi_3wire_ins`,
`tx_spi_ctrl`, `sys_infor_ins`, `tx_ref_ins`, `vio_0_inst` and `vio_timesync`.
The ILAs that live *inside* the migrated modules (`ila_framer`,
`ila_deframer_meta_ip`, `ila_fsm_dbg`) are left alone — removing them would
mean editing the tvsdr sources themselves.

`tx_ref_ins : IBUFDS_GTE4` is unchanged in function: it was already the buffer
feeding `Aurora_ins/gt_refclk1`, only its pins move from `tx_ref_0_p/n` to
`Aurora_refclk_p/n`.

**The 145 board pins of `tvsdr_fpga` become internal signals**, keeping their
names, so the body — above all the `i_fsm_main` port map — needed no edits. A
single mapping block at the end of the architecture is the only place that
knows about T12 hardware; skip from there to the end of the file when diffing.

### Clock mapping

`mb_bd` was both the CPU and the clock generator. On MSDR the clocks come from
the PS and the ADRV9002:

| `tvsdr_fpga` signal | MSDR source |
|---|---|
| `init_clk_s`, `system_clk_s` | PS `pl_clk0` |
| `sample_clk_s`, `clk_375M` | `axi_adrv9001/adc_1_clk` |
| `clk_250m_aurora_s` | PS `pl_clk1`, configured to 250 MHz |
| `tx_core_clk` | `axi_adrv9001/dac_1_clk` |

### Address map

`axi_trx_crossbar` in `system.bd` decodes four apertures; the bases are
parameters on the crossbar, not `assign_bd_address` targets, so changing one
means editing `msdr_bd.tcl`:

| Master | Base | Size | Slave |
|---|---|---|---|
| `M00_AXI` | `0x8121_0000` | 4 kB | `sys_infor_ins` (`SYS_INTERFACE`) |
| `M01_AXI` | `0x8122_0000` | 4 kB | GFP message FIFO |
| `M02_AXI` | `0x8123_0000` | 8 kB | configuration-LUT BRAM (`CFG_LUT`) |
| `M03_AXI` | `0x8125_0000` | 4 kB | `u_msdr_trx_regs` |

`axi_t12_gpio` sits at `0x8120_0000` and the command GPIO at `0x8124_0000`.
The T12 board peripherals added from the current `msdr` design are:

| Base | Size | Controller |
|---|---:|---|
| `0x8126_0000` | 4 kB | `axi_t12_aux_gpio` (17 bits) |
| `0x8127_0000` | 4 kB | Low-band `axi_quad_spi_lb` |
| `0x8128_0000` | 4 kB | High-band `axi_quad_spi_hb` |

The auxiliary GPIO bit order is DSA bits 0-8, BBU GPIO bits 9-11, RFE SPI
bits 12-14, and LB/HB TFT SFL bits 15-16. The main GPIO keeps its existing
per-bit PS/FSM mask arbitration. These pages are kept clear of the existing
TRX crossbar windows at `0x8121_0000`-`0x8125_0000`.

### Things that bite when moving tvsdr IP into this project

**`.coe` paths break on import.** `gpio_BRAM` and `Wavefor_storer_4k` load
their contents from a `.coe` by a path relative to the original `.xci`.
`file_list.tcl` uses `import_ip`, which copies the `.xci` into the project and
breaks that path, so both are re-pointed with `set_property CONFIG.Coe_File`
after import. Any further IP with a `.coe` needs the same treatment.

**Retarget the part in the `.xci`.** Most tvsdr IP was built for
`xcau15p-sbvb484`. The ones this design uses have had `ARCHITECTURE`,
`DEVICE`, `PACKAGE` and `C_XDEVICEFAMILY` rewritten to the ZU15EG values.

### Two traps when editing the block design

**Never leave a cell input unconnected.** `validate_bd_design` only warns, but
the BD-to-Verilog writer then emits a reference to an undeclared `GND_<n>` net
and synthesis dies with `[Synth 8-36] 'GND_2' is not declared` against the
generated `system.v`, followed by a misleading
`[Synth 8-439] module 'system_top' not found`. That second error is only a
knock-on: `system.v` failed to elaborate, so `system` did not exist. This bit
this design once, when removing the RX DMAs orphaned
`sys_concat_intc_1/In4` and `In5`; both are now tied to `GND_1`.

**Declare `FREQ_HZ` on clock ports and AXI interface ports.**
`create_bd_port -type clk` with no frequency silently defaults to 100 MHz, and
an AXI interface port defaults the same way. `pl_clk0` is actually 99,999,992 Hz,
not a round 100 MHz, and `validate_bd_design` rejects the mismatch with
`[BD 41-237]`.

**`ilconstant` must be created with `-type inline_hdl`,** not `-type ip`.
With `-type ip` the cell exists but `generate_target` emits no HDL for it and
synthesis fails with `[Synth 8-439] module ... not found`.

Worth knowing when deleting cells from `msdr_bd.tcl` with a script: the shared
`sys_cpu_clk` and `sys_cpu_resetn` nets list every peripheral's pins on one
line, so a naive "drop every line mentioning cell X" also deletes the clock and
reset for the whole design. Strip the individual `[get_bd_pins X/...]` entries
instead of the line, and never insert text by byte offset into a string you are
also mutating in the same pass — both mistakes were made here and both produced
designs that built but were silently wrong.

### Aurora TX sample path

`clk_250m_aurora_s` is PS `pl_clk1`, configured to 250 MHz. Aurora IQ,
DDS, CW and GMSK are selected in that clock domain. The Aurora deframer
produces a valid output each sample-clock cycle after startup; when its IQ FIFO
is empty it holds/repeats the last sample, and when its FIFO reaches the high
watermark it suppresses incoming writes. Therefore a continuous 250-MSPS
valid stream at the FIR input does not by itself prove that every item is a
new Aurora sample.

Two Xilinx FIR Compiler cores use `simulink/ddc/ddc.coe`, are configured for
signed 16-bit outputs with LSB truncation, and decimate by five. With one
valid input per 250-MHz PL1 cycle, their nominal output is one I/Q pair per
five cycles (50 MSPS). The 32-bit pair crosses to `dac_1_clk` through an
asynchronous FIFO. `dac_1_data_i0/q0` carry I/Q; `dac_1_data_i1/q1` are tied
low. DAC1 has no DMA path and the FIR path has no NCO/mixer.

The 50-MSPS output rate is conditional on continuous FIR input-valid and on
the ADRV9002 TX configuration requesting/consuming samples at 50 MSPS.
`dac_1_rd_en` comes from the ADRV9001/9002 interface's DAC rate logic and is
the FIFO read request; it can also be gated by TX/TDD operation. The radio
profile is not included/verified here, so neither the actual DAC sample rate
nor sustained 50-MSPS operation is certified by the RTL settings alone.
Verify the configured TX rate and measure `dac_1_rd_en` while TX is enabled.
Sticky status bits report FIR backpressure/IQ mismatch (Aurora status bit 12),
FIFO overflow (bit 11), and post-start underflow (bit 10); check these during
hardware validation. See
[`docs/Aurora_IQ_250_to_50_v3.md`](docs/Aurora_IQ_250_to_50_v3.md).

The unused legacy ADC/TX three-wire SPI instances are removed from the T12
top; the board SPI controllers remain PS-owned. `impl_pre.tcl` now restores
default severity for `MDRV-1`, `NSTD-1` and `UCIO-1`, rather than suppressing
multiple-driver failures.

### Local time crossing into the 100 MHz FSM

The servo's `{sec, subsecond}` pair previously crossed directly from the ADC
sample clock into the FSM and AXI registers. It now crosses as a held 67-bit
snapshot through `xpm_cdc_handshake` (two synchronizer stages each direction).
Both consumers use a destination-clock register, updated only on `dest_req`.
This deliberately adds snapshot latency and age: acquisition takes several
destination cycles and each refresh waits for a complete request/acknowledge
round trip in both clock domains. FSM time is therefore delayed, not a
cycle-exact copy of servo time. This behavior change was approved; any strict
RF trigger deadline must budget for it using the actual sample-clock rate.
No false-path exception is added to hide the original direct CDC.
XSim tests using the actual top-level CDC block passed at 250 MHz and
125 MHz against the 100 MHz destination, including timestamp rollovers and
reset/restart (249 and 187 snapshots). Maximum observed acquisition age was
104 ns and 96 ns respectively; this excludes time held until the next refresh
and is not a hardware worst-case bound.

### Retired sources

Everything the migration dropped was moved to `src/attic_tvsdr/`, not deleted,
because this directory is not a git repository. It holds the JESD204 and
AD9652/AD9164 interfaces, the MBU-side duplicates, `fsm/fsm_bk`, the superseded
`time_sync` v1 files, the unreferenced `timestamp_timer` ORAN sources, the
`exp1_*` block-design experiments, and 40 IP cores that no longer have a user.
Delete it with `rm -rf src/attic_tvsdr` once you are satisfied nothing there is
wanted.

## Notes

- Both variants are locked to LVDS: each `system_project.tcl` rejects any
  `CMOS_LVDS_N` other than `0`, and only the LVDS constraints are carried.
- `msdr` names its part explicitly (`adi_project_create ... xczu15eg-...`),
  while `adrv9001_zcu102` lets `adi_project` derive `xczu9eg-...` from the
  `_zcu102` suffix in the project name.
- `src/hdl/scripts/adi_env.tcl` pins `required_vivado_version` to the
  locally installed toolchain; upstream ADI HDL asks for a newer one.
- `src/hdl/` is kept identical to the copy in
  `/home/user5/Projects/adrv9001_zcu102`, which holds the same design as a
  standalone project. When the two diverge, the newer framework wins. Check
  with `diff -rq --exclude ipcache` between the two `src/hdl` trees.
- Build metadata reaches software through the ADI system ID ROM (`axi_sysid` +
  `rom_sys` in the block design), which records the build timestamp plus the
  project and board names. The git SHA and branch fields are empty because this
  directory is not a git repository.
- Vivado reads `src/hdl/library` as its IP repository.
  `src/ip/adi_library` is a second physical copy that is not on that path, so
  changes meant to affect the build belong in `src/hdl/library`.
- `src/ip/quiet.mk` and `src/ip/scripts` are compatibility links into
  `src/hdl/`, required by `src/ip/adi_library/Makefile`.

# Aurora IQ TX path: 250 to 50 MSPS

The MSDR TX source mux now runs from PS `PL1` at 250 MHz, matching the
TVSDR sample-clock arrangement. Aurora deframed IQ, DDS, GMSK and CW samples
enter as one 32-bit complex sample per valid clock: signed I in bits 31:16,
signed Q in bits 15:0. The I/Q FIR decimator accepts valid samples and emits
one output for every five inputs.

The decimated 32-bit `{I,Q}` stream crosses from `PL1` to `dac_1_clk` through
an asynchronous FIFO. DAC requests select one I/Q pair and connect it directly
to `dac_1_data_i0` and `dac_1_data_q0`. The unused `dac_1_data_i1` and
`dac_1_data_q1` inputs are tied low. The PS DMA test source remains a direct
DAC-clock-domain bypass of the FIR.

Sticky TX FIFO overflow and post-start underflow events are reported in the
existing Aurora status word to the PS: bit 11 is overflow, bit 10 is underflow.

`iq_fir_decimator.vhd` contains a 32-tap, signed Q1.15 FIR with a unity-impulse
placeholder coefficient table. This placeholder lets the 5:1 rate conversion
be exercised, but it does **not** provide anti-alias filtering. Replace
`FIR_COEFFICIENTS` with the designed low-pass coefficients before transmitting
signals that require spectral rejection. The accumulator saturates to signed
16-bit output. No NCO/mixer is included because a frequency offset was not
specified; this block performs filtering and decimation only.

The source build exports PS `PL1` as `aurora_sample_clk` from `msdr_bd.tcl`;
the reproducible v4 project script and its checked-in `system_wrapper` asset
carry the same clock port. `PL1` is configured to 250 MHz. The decimator
therefore produces a 50-MSPS stream when the ADRV9002 DAC consumes one sample
per 50 MHz-equivalent valid event. Confirm the ADRV9002 TX clock/profile and
`dac_1_rd_en` rate are set for 50 MSPS; changing the FPGA data path alone does
not configure the radio profile.

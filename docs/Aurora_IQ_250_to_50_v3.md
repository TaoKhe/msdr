# Aurora IQ TX path: 250 to 50 MSPS

The TX source mux runs from PS `PL1` at 250 MHz. Aurora IQ, DDS, CW and GMSK
are selected before two Xilinx FIR Compiler 7.2 instances, one for I and one
for Q. Each core uses the 272 signed 24-bit coefficients in
`simulink/ddc/ddc.coe`, runs at 250 MHz, and decimates by five.

Each FIR core is configured for a signed 16-bit output with LSB truncation.
The top-level connects those I and Q outputs directly and packs one 32-bit
complex sample into the asynchronous FIFO. FIFO output is connected to
`dac_1_data_i0` and `dac_1_data_q0`; `i1/q1` are tied low. The ADRV9002 TX
profile and `dac_1_rd_en` must consume one sample per five PL1 clocks to
achieve 50 MSPS.

DAC1 has no DMA path. Source selection code `110` is reserved/off and produces
zeros; code `111` remains RF off. TX2's independent DMA path is unchanged.

FIR input is presented only when both cores assert `s_axis_data_tready`, keeping
I/Q aligned. A sticky FIR status is reported in Aurora status bit 12 if either
core backpressures a valid sample or the I/Q ready/valid signals disagree.
FIFO overflow and post-start underflow remain sticky in bits 11 and 10.

This block filters and decimates but does not include an NCO/mixer. The
coefficient file is the current low-pass response from `simulink/ddc`; future
coefficient updates should preserve the COE's signed 24-bit format and update
both FIR cores through the shared project-generation script.

Both project-generation flows create the same FIR cores:

- `scripts/msdr/file_list.tcl` creates them for the source build.
- `scripts/msdr/recreate_v4.tcl` creates them for the reproducible v4 project.

The PL1 clock is configured to 250 MHz. Changing this data path does not
configure the ADRV9002 radio profile; verify its TX sample rate and the actual
`dac_1_rd_en` rate in the selected profile.

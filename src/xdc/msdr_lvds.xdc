###############################################################################
## Copyright (C) 2020-2023, 2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# T12_DSP_v01.pdf, sheet 23. HDL directions are relative to the FPGA:
# tx*_dclk_in receives ADRV_TX*_DCLK_OUT; tx*_dclk_out drives ADRV_TX*_DCLK_IN.
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_dclk_in_n]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_dclk_in_p]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_idata_in_n]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_idata_in_p]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_qdata_in_n]
set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_qdata_in_p]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_strobe_in_n]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_strobe_in_p]

set_property -dict {PACKAGE_PIN Y3  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_dclk_in_n]
set_property -dict {PACKAGE_PIN Y4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_dclk_in_p]
set_property -dict {PACKAGE_PIN V1  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_idata_in_n]
set_property -dict {PACKAGE_PIN V2  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_idata_in_p]
set_property -dict {PACKAGE_PIN Y1  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_qdata_in_n]
set_property -dict {PACKAGE_PIN Y2  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_qdata_in_p]
set_property -dict {PACKAGE_PIN W1  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_strobe_in_n]
set_property -dict {PACKAGE_PIN W2  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_strobe_in_p]

set_property -dict {PACKAGE_PIN R9  IOSTANDARD LVDS} [get_ports tx1_dclk_out_n]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVDS} [get_ports tx1_dclk_out_p]
set_property -dict {PACKAGE_PIN R8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports tx1_dclk_in_n]
set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports tx1_dclk_in_p]
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVDS} [get_ports tx1_idata_out_n]
set_property -dict {PACKAGE_PIN L12 IOSTANDARD LVDS} [get_ports tx1_idata_out_p]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVDS} [get_ports tx1_qdata_out_n]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVDS} [get_ports tx1_qdata_out_p]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVDS} [get_ports tx1_strobe_out_n]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVDS} [get_ports tx1_strobe_out_p]

set_property -dict {PACKAGE_PIN Y7  IOSTANDARD LVDS} [get_ports tx2_dclk_out_n]
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVDS} [get_ports tx2_dclk_out_p]
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports tx2_dclk_in_n]
set_property -dict {PACKAGE_PIN Y5  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports tx2_dclk_in_p]
set_property -dict {PACKAGE_PIN U4  IOSTANDARD LVDS} [get_ports tx2_idata_out_n]
set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVDS} [get_ports tx2_idata_out_p]
set_property -dict {PACKAGE_PIN AC3 IOSTANDARD LVDS} [get_ports tx2_qdata_out_n]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD LVDS} [get_ports tx2_qdata_out_p]
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVDS} [get_ports tx2_strobe_out_n]
set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVDS} [get_ports tx2_strobe_out_p]

# Keep the ZCU102 LVDS timing profile, as requested.
create_clock -name ref_clk      -period 8.00 [get_ports fpga_ref_clk]
create_clock -name rx1_dclk_out -period 2.0 -waveform {0.0 1.0} [get_ports rx1_dclk_in_p]
create_clock -name rx2_dclk_out -period 2.0 -waveform {0.0 1.0} [get_ports rx2_dclk_in_p]
create_clock -name tx1_dclk_out -period 2.0 -waveform {0.0 1.0} [get_ports tx1_dclk_in_p]
create_clock -name tx2_dclk_out -period 2.0 -waveform {0.0 1.0} [get_ports tx2_dclk_in_p]

# Allow max skew of 0.2 ns between input clocks.
set_clock_latency -source -early -0.1 [get_clocks rx1_dclk_out]
set_clock_latency -source -early -0.1 [get_clocks rx2_dclk_out]
set_clock_latency -source -late   0.1 [get_clocks rx1_dclk_out]
set_clock_latency -source -late   0.1 [get_clocks rx2_dclk_out]

set_property CLOCK_DELAY_GROUP BALANCE_CLOCKS_1 \
  [list [get_nets -of [get_pins sys_wrapper_ins/system_i/axi_adrv9001/inst/i_if/i_rx_1_phy/i_div_clk_buf/O]] \
        [get_nets -of [get_pins sys_wrapper_ins/system_i/axi_adrv9001/inst/i_if/i_rx_1_phy/i_clk_buf_fast/O]] \
  ]

set_property CLOCK_DELAY_GROUP BALANCE_CLOCKS_2 \
  [list [get_nets -of [get_pins sys_wrapper_ins/system_i/axi_adrv9001/inst/i_if/i_rx_2_phy/i_div_clk_buf/O]] \
        [get_nets -of [get_pins sys_wrapper_ins/system_i/axi_adrv9001/inst/i_if/i_rx_2_phy/i_clk_buf_fast/O]] \
  ]

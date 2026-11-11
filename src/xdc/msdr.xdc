###############################################################################
## Copyright (C) 2020-2023, 2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# T12_DSP_v01.pdf, sheet 23 (5.6 BANK_66_67), XCZU15EG-2FFVB1156I.
# FPGA_SYSCLK is single-ended; the PDF does not route MCS or ZCU102 board GPIO.
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS18} [get_ports fpga_ref_clk]

# T12_DSP_v01.pdf, sheet 24: Y6 156.25 MHz, Aurora lane L1, bank 230.
# Dedicated GTH pins do not use a SelectIO IOSTANDARD.
set_property PACKAGE_PIN C8 [get_ports Aurora_refclk_p]
set_property PACKAGE_PIN C7 [get_ports Aurora_refclk_n]
set_property PACKAGE_PIN E4 [get_ports {Aurora_Txp[0]}]
set_property PACKAGE_PIN E3 [get_ports {Aurora_Txn[0]}]
set_property PACKAGE_PIN D2 [get_ports {Aurora_Rxp[0]}]
set_property PACKAGE_PIN D1 [get_ports {Aurora_Rxn[0]}]
create_clock -name aurora_refclk -period 6.400 [get_ports Aurora_refclk_p]

set_property -dict {PACKAGE_PIN U10  IOSTANDARD LVCMOS18} [get_ports {dgpio[0]}]
set_property -dict {PACKAGE_PIN AB8  IOSTANDARD LVCMOS18} [get_ports {dgpio[1]}]
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS18} [get_ports {dgpio[2]}]
set_property -dict {PACKAGE_PIN AC9  IOSTANDARD LVCMOS18} [get_ports {dgpio[3]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS18} [get_ports {dgpio[4]}]
set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS18} [get_ports {dgpio[5]}]
set_property -dict {PACKAGE_PIN AC8  IOSTANDARD LVCMOS18} [get_ports {dgpio[6]}]
set_property -dict {PACKAGE_PIN AC7  IOSTANDARD LVCMOS18} [get_ports {dgpio[7]}]
set_property -dict {PACKAGE_PIN AC6  IOSTANDARD LVCMOS18} [get_ports {dgpio[8]}]
set_property -dict {PACKAGE_PIN AB6  IOSTANDARD LVCMOS18} [get_ports {dgpio[9]}]
set_property -dict {PACKAGE_PIN AB1  IOSTANDARD LVCMOS18} [get_ports {dgpio[10]}]
set_property -dict {PACKAGE_PIN AB5  IOSTANDARD LVCMOS18} [get_ports {dgpio[11]}]

# MODE is the same ADRV9002 pin as DGPIO_11, not a second FPGA port.
set_property -dict {PACKAGE_PIN AC11 IOSTANDARD LVCMOS18} [get_ports gp_int]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS18} [get_ports reset_trx]

set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS18} [get_ports rx1_enable]
set_property -dict {PACKAGE_PIN T10  IOSTANDARD LVCMOS18} [get_ports rx2_enable]
set_property -dict {PACKAGE_PIN AA2  IOSTANDARD LVCMOS18} [get_ports tx1_enable]
set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVCMOS18} [get_ports tx2_enable]

set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS18} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN Y9   IOSTANDARD LVCMOS18} [get_ports spi_dio]
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS18} [get_ports spi_do]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS18} [get_ports spi_en]

create_clock -name spi0_clk -period 40 [get_pins -hier */EMIOSPI0SCLKO]
create_clock -name spi1_clk -period 40 [get_pins -hier */EMIOSPI1SCLKO]

# PS SPI1 drives the T12 DCXO.
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS18} [get_ports dcosc_spi_sclk]
set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS18} [get_ports dcosc_spi_mosi]
set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVCMOS18} [get_ports dcosc_spi_miso]
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS18} [get_ports dcosc_spi_csn]

# T12 main GPIO channel 1: bit order is the physical order in msdr_fpga.vhd.
# All board control outputs are high-Z at AXI GPIO reset.
set_property -dict {PACKAGE_PIN AG13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[0]}]
set_property -dict {PACKAGE_PIN AL12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[1]}]
set_property -dict {PACKAGE_PIN AN12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[2]}]
set_property -dict {PACKAGE_PIN AJ15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[3]}]
set_property -dict {PACKAGE_PIN AK13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[4]}]
set_property -dict {PACKAGE_PIN AP12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[5]}]
set_property -dict {PACKAGE_PIN AN14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[6]}]
set_property -dict {PACKAGE_PIN AL13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[7]}]
set_property -dict {PACKAGE_PIN AM14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[8]}]
set_property -dict {PACKAGE_PIN AM13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[9]}]
set_property -dict {PACKAGE_PIN AK15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[10]}]
set_property -dict {PACKAGE_PIN AN13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[11]}]
set_property -dict {PACKAGE_PIN AP14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[12]}]
set_property -dict {PACKAGE_PIN L20  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[13]}]
set_property -dict {PACKAGE_PIN G21  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[14]}]
set_property -dict {PACKAGE_PIN H17  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[15]}]
set_property -dict {PACKAGE_PIN H14  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[16]}]
set_property -dict {PACKAGE_PIN E18  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[17]}]
set_property -dict {PACKAGE_PIN E19  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[18]}]
set_property -dict {PACKAGE_PIN F17  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[19]}]
set_property -dict {PACKAGE_PIN K17  IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[20]}]
set_property -dict {PACKAGE_PIN AE15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[21]}]
set_property -dict {PACKAGE_PIN AE14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[22]}]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio0_pad[23]}]

# These additional FPGA pads are tied to the same RF nets on the PCB.
set_property -dict {PACKAGE_PIN H10 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {rfsw_ctrl_sense[0]}]
set_property -dict {PACKAGE_PIN E10 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {rfsw_ctrl_sense[1]}]
set_property -dict {PACKAGE_PIN F10 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {rfsw_ctrl_sense[2]}]
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {rfsw_ctrl_sense[3]}]
set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lbf_ctrl_sense[0]}]
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lbf_ctrl_sense[1]}]
set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lbf_ctrl_sense[2]}]
set_property -dict {PACKAGE_PIN F11 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lbf_ctrl_sense[3]}]
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lbf_ctrl_sense[4]}]

# T12 main GPIO channel 2: TFT controls, switches, then reset pins.
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[0]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[1]}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[2]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[3]}]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[4]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[5]}]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[6]}]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[7]}]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[8]}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[9]}]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[10]}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[11]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[12]}]
set_property -dict {PACKAGE_PIN K20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[13]}]
set_property -dict {PACKAGE_PIN H21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[14]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[15]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[16]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[17]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[18]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[19]}]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[20]}]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[21]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[22]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[23]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[24]}]
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {t12_gpio1_pad[25]}]

# Auxiliary AXI GPIO bits 0..16: DSA, BBU, RFE SPI and TFT SFL.
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports tx_dsa_si]
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports tx_dsa_clk]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports tx_dsa_le]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports rx_dsa_si]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports rx_dsa_clk]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports rx_dsa_le]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports orx_dsa_si]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports orx_dsa_clk]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports orx_dsa_le]
set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports bbu_gpio_1]
set_property -dict {PACKAGE_PIN AF15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports bbu_gpio_2]
set_property -dict {PACKAGE_PIN AG15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports bbu_gpio_3]
set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports trx_spi_sclk]
set_property -dict {PACKAGE_PIN AK14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports trx_spi_mosi]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports trx_spi_miso]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports lb_tft_sfl]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports hb_tft_sfl]

# AXI Quad SPI low-band filter pins.
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports lb_tft_sclk]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports lb_tft_sdi]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports lb_tft_sdo]
set_property -dict {PACKAGE_PIN J12 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lb_tft_csn[0]}]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {lb_tft_csn[1]}]

# AXI Quad SPI high-band filter pins.
set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports hb_tft_sclk]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports hb_tft_sdi]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports hb_tft_sdo]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {hb_tft_csn[0]}]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {hb_tft_csn[1]}]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {hb_tft_csn[2]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33 PULLTYPE NONE} [get_ports {hb_tft_csn[3]}]

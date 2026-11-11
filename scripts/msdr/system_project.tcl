###############################################################################
## Copyright (C) 2020-2023, 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

set msdr_root [file normalize [file join [file dirname [info script]] ../..]]
source [file join $msdr_root src hdl scripts adi_env.tcl]
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# The get_env_param procedure retrieves parameter value from the environment if
# exists, other case returns the default value specified in its second parameter.
#
# Parameter description:
#   CMOS_LVDS_N - type of interface
#         0 - LVDS
#         1 - CMOS

set CMOS_LVDS_N [get_env_param CMOS_LVDS_N 0]
if {$CMOS_LVDS_N != 0} {
  error "T12 XCZU15EG supports only LVDS. Use CMOS_LVDS_N=0."
}

adi_project_create msdr 0 {} xczu15eg-ffvb1156-2-i

## Top la msdr_fpga (VHDL), dung nhu tvsdr_rfu_trx_gen dat top la tvsdr_fpga.
## Khong co system_top.v cua ADI nua: msdr_fpga.vhd instantiate thang
## system_wrapper, y nhu tvsdr_fpga.vhd instantiate mb_bd_wrapper.
adi_project_files {} [list \
  [file join $msdr_root src xdc msdr.xdc] \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  [file join $msdr_root src xdc msdr_lvds.xdc] ]

## adi_project_files vua dat top thanh system_top; MSDR khong co file do nen
## phai dat lai. tvsdr_rfu_trx_gen cung lam dung vay voi tvsdr_fpga.
## Restore default DRC severities before opt_design.
add_files -fileset utils_1 -norecurse [file join $msdr_root scripts msdr impl_pre.tcl]
set_property STEPS.OPT_DESIGN.TCL.PRE \
  [get_files -of_objects [get_fileset utils_1] impl_pre.tcl] [get_runs impl_1]

set_property top msdr_fpga [current_fileset]
update_compile_order -fileset sources_1

## ADI_CREATE_ONLY=1: chi tao project va block design roi dung, khong chay
## synth/impl. Dung khi muon mo project trong GUI de xem hoac sua block design
## (make project-msdr). Bo bien nay di thi chay day du (make msdr).
if {[get_env_param ADI_CREATE_ONLY 0] == 1} {
  puts "system_project.tcl: ADI_CREATE_ONLY=1, bo qua adi_project_run"
} else {
  adi_project_run msdr
}

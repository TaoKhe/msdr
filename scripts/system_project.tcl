###############################################################################
## Copyright (C) 2020-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

set t12_root [file normalize [file join [file dirname [info script]] ..]]
source [file join $t12_root src ip adi_hdl scripts adi_env.tcl]
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# The get_env_param procedure retrieves parameter value from the environment if exists,
# other case returns the default value specified in its second parameter field.
#
#   How to use over-writable parameters from the environment:
#
#    e.g.
#      make CMOS_LVDS_N=0
#     or
#      make CMOS_LVDS_N=1
#
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

adi_project_files {} [list \
  [file join $t12_root src hdl top system_top.v] \
  [file join $t12_root src xdc system_constr.xdc] \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  [file join $t12_root src xdc lvds_constr.xdc] ]

adi_project_run msdr

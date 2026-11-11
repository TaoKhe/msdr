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
#
# This variant is locked to LVDS; cmos_constr.xdc is not carried here.

set CMOS_LVDS_N [get_env_param CMOS_LVDS_N 0]
if {$CMOS_LVDS_N != 0} {
  error "adrv9001_zcu102 supports only LVDS. Use CMOS_LVDS_N=0."
}

# adi_project derives the device from the _zcu102 suffix: xczu9eg-ffvb1156-2-e
adi_project adrv9001_zcu102 0 [list \
  CMOS_LVDS_N $CMOS_LVDS_N \
]

adi_project_files {} [list \
  [file join $msdr_root src hdl top adrv9001_zcu102_top.v] \
  [file join $msdr_root src xdc adrv9001_zcu102.xdc] \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zcu102/zcu102_system_constr.xdc" \
  [file join $msdr_root src xdc adrv9001_zcu102_lvds.xdc] ]

adi_project_run adrv9001_zcu102

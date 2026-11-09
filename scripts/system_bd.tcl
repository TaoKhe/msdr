###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source $ad_hdl_dir/projects/scripts/adi_pd.tcl
sysid_gen_sys_init_file LVDS

set t12_root [file normalize [file join [file dirname [info script]] ..]]
set result [source [file join $t12_root scripts msdr_bd.tcl]]
if {$result ne "" && $result != 0} {
  error "MSDR block design creation failed (status $result)"
}

set_property strategy Flow_RunPostRoutePhysOpt [get_runs impl_1]

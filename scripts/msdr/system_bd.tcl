###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
##
## adi_project_create sources this file by its fixed name from the working
## directory, which is this variant's scripts directory.
###############################################################################

source $ad_hdl_dir/projects/scripts/adi_pd.tcl
sysid_gen_sys_init_file LVDS

set bd_dir [file normalize [file dirname [info script]]]

## Nguon TRX phai vao project TRUOC khi dung msdr_bd.tcl: block design tham
## chieu msdr_trx_core / msdr_rf_ctrl / msdr_trx_regs duoi dang RTL module
## reference, nen Vivado can doc duoc cac entity do ngay luc tao cell.
## adi_project_create goi file nay ben trong mot proc, vi vay msdr_root duoc
## tinh lai tai day thay vi dua vao bien toan cuc.
set msdr_root [file normalize [file join $bd_dir ../..]]
source [file join $bd_dir file_list.tcl]

set result [source [file join $bd_dir msdr_bd.tcl]]
if {$result ne "" && $result != 0} {
  error "MSDR block design creation failed (status $result)"
}

set_property strategy Flow_RunPostRoutePhysOpt [get_runs impl_1]

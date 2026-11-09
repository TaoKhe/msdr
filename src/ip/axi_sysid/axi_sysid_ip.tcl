###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# ip
source [file normalize [file join [file dirname [info script]] ../../../scripts/adi_env.tcl]]
source $ad_script_dir/adi_ip_xilinx.tcl

adi_ip_create axi_sysid
adi_ip_files axi_sysid [list \
  "$ad_library_dir/common/up_axi.v" \
  "axi_sysid.v"]

adi_ip_properties axi_sysid

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_sysid} [ipx::current_core]

set cc [ipx::current_core]

ipx::save_core $cc

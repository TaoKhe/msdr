set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir adi_env.tcl]

set expected_repo [file join $msdr_root msdr_gen ip]
if {$ad_library_dir ne $expected_repo} {
  error "IP build output must be $expected_repo, got $ad_library_dir"
}
if {[llength $argv] == 0} {
  error "No IP names provided"
}
foreach ip $argv {
  if {![file isdirectory [file join $msdr_root src ip $ip]] ||
      ![file isfile [file join $msdr_root src ip $ip ${ip}_ip.tcl]]} {
    error "Missing source or packaging script for IP: $ip"
  }
}

file delete -force $ad_library_dir
file mkdir $ad_library_dir
foreach source_dir [glob -directory [file join $msdr_root src ip] -types d *] {
  file copy $source_dir $ad_library_dir
}

file mkdir [file join $ad_library_dir scripts]
file copy [file join $ad_script_dir adi_xilinx_device_info_enc.tcl] \
  [file join $ad_library_dir scripts]

foreach ip {interfaces axi_dmac/interfaces} {
  file mkdir [file join $ad_library_dir $ip]
  cd [file join $ad_library_dir $ip]
  source [file join $msdr_root src ip $ip interfaces_ip.tcl]
}
foreach ip $argv {
  puts "Packaging MSDR IP: $ip"
  cd [file join $ad_library_dir $ip]
  source [file join $msdr_root src ip $ip ${ip}_ip.tcl]
  ipx::check_integrity [ipx::current_core]
  close_project
}
cd $msdr_root

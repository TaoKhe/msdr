set msdr_root [file normalize [file join [file dirname [info script]] ..]]
source [file join $msdr_root scripts adi adi_env.tcl]

set ad_script_dir [file join $msdr_root scripts adi]
set ad_library_dir [file join $msdr_root msdr_gen ip]
if {[info exists ::env(ADI_IP_REPO)]} {
  set ad_library_dir [file normalize $::env(ADI_IP_REPO)]
}

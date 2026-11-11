set script_dir [file dirname [info script]]
source [file join $script_dir recreate_v4.tcl]
set_param general.maxThreads 2
set bd [get_files */system.bd]
set_property synth_checkpoint_mode None $bd
foreach {ip coe} [list \
  gpio_BRAM [file join $origin_dir src hdl fsm gpio.coe] \
  Wavefor_storer_4k [file join $origin_dir src hdl Waveform_streamer GMSK_2Mbps_BT_0p3_250Msps_rand_data_4k_HEX.coe]] {
  set_property CONFIG.Coe_File $coe [get_ips $ip]
}
generate_target all $bd
foreach ip [get_ips] {
  if {![string match "system_*" [get_property NAME $ip]]} {
    generate_target all $ip
    create_ip_run [get_files [get_property IP_FILE $ip]]
  }
}
update_compile_order -fileset sources_1
if {[info exists ::env(MSDR_CREATE_ONLY)] && $::env(MSDR_CREATE_ONLY) eq "1"} {
  puts "RECREATE_V4_GENERATION_PASS"
} else {
  launch_runs synth_1 -jobs 2
  wait_on_run synth_1
  if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis failed: [get_property STATUS [get_runs synth_1]]"
  }
  launch_runs impl_1 -to_step write_bitstream -jobs 2
  wait_on_run impl_1
  set bit [file join $output_dir msdr.runs impl_1 msdr_fpga.bit]
  if {![file exists $bit] || [file size $bit] == 0} {
    error "Bitstream failed: [get_property STATUS [get_runs impl_1]]"
  }
  puts "RECREATE_V4_BITSTREAM_PASS $bit"
}
close_project

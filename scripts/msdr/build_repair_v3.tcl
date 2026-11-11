set root [file normalize [file join [file dirname [info script]] ../..]]
set out $root/msdr_repair_v3_gen
if {[file exists $out]} {
  error "Refusing to overwrite existing v3 output: $out"
}
set_param general.maxThreads 2
open_project $root/msdr_repair_v2_gen/msdr.xpr
save_project_as msdr $out
remove_files [get_files */top/msdr_fpga.vhd]
add_files -norecurse $root/src/hdl/top/msdr_fpga_v3.vhd
set_property FILE_TYPE {VHDL 2008} [get_files */top/msdr_fpga_v3.vhd]
set_property top msdr_fpga [get_filesets sources_1]
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
  error "Synthesis failed: [get_property STATUS [get_runs synth_1]]"
}
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
set bit $out/msdr.runs/impl_1/msdr_fpga.bit
if {![file exists $bit] || [file size $bit] == 0} {
  error "Bitstream not generated: [get_property STATUS [get_runs impl_1]]"
}
close_project
open_checkpoint $out/msdr.runs/impl_1/msdr_fpga_routed.dcp
foreach port {mcs_out tdd_sync_cntr onepps_in uart_txd} {
  if {[llength [get_ports -quiet $port]]} {
    error "Temporarily disabled port still exported: $port"
  }
}
report_drc -checks {MDRV-1 NSTD-1 UCIO-1 AVAL-326 RTSTAT-1} \
  -file $out/repair_drc_final_v3.rpt
foreach rule {MDRV-1 NSTD-1 UCIO-1 AVAL-326 RTSTAT-1} {
  if {[llength [get_drc_violations -quiet ${rule}*]]} {
    error "Remaining DRC violation: $rule"
  }
}
report_timing_summary -file $out/repair_timing_final_v3.rpt
report_route_status -file $out/repair_route_status_v3.rpt
puts "V3_BITSTREAM_PASS $bit"
close_design

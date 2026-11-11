# Run in the Vivado Tcl console with the edited system block design open.
if {[current_bd_design -quiet] eq ""} {
  error "Open the system block design before sourcing fix_gfp_clock_v1.tcl."
}

set gfp_clock_hz [get_property CONFIG.FREQ_HZ [get_bd_pins /sys_ps8/pl_clk0]]
if {![string is integer -strict $gfp_clock_hz] || $gfp_clock_hz <= 0} {
  error "Cannot determine the PS pl_clk0 frequency: '$gfp_clock_hz'."
}

set gfp_clock_ports [get_bd_intf_ports -quiet {GFP_UB_IN GFP_UB_OUT}]
if {[llength $gfp_clock_ports] != 2} {
  error "Expected both GFP_UB_IN and GFP_UB_OUT AXI-Stream interface ports."
}
set_property CONFIG.FREQ_HZ $gfp_clock_hz $gfp_clock_ports

validate_bd_design
save_bd_design
puts "GFP_UB_IN and GFP_UB_OUT FREQ_HZ set to $gfp_clock_hz; block design validated and saved."

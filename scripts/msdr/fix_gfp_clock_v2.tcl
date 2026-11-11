# Also used by msdr_bd.tcl; keep GUI-edited FIFO/converter wiring unchanged.
if {[current_bd_design -quiet] eq ""} {
  error "Open the system block design before sourcing fix_gfp_clock_v2.tcl."
}

set cpu_clock [get_bd_pins /sys_ps8/pl_clk0]
set cpu_clock_hz [get_property CONFIG.FREQ_HZ $cpu_clock]
if {![string is integer -strict $cpu_clock_hz] || $cpu_clock_hz <= 0} {
  error "Cannot determine the PS pl_clk0 frequency: '$cpu_clock_hz'."
}

set clock_port [get_bd_ports init_clk]
set clock_net [get_bd_nets -of_objects $clock_port]
if {$clock_net ne [get_bd_nets -of_objects $cpu_clock]} {
  error "init_clk must be connected to sys_ps8/pl_clk0."
}
if {[get_property TYPE $clock_port] ne "clk"} {
  delete_bd_objs $clock_port
  set clock_port [create_bd_port -dir O -type clk init_clk]
  connect_bd_net -net $clock_net $clock_port
}
set_property CONFIG.FREQ_HZ $cpu_clock_hz $clock_port

set clock_interfaces [split [get_property CONFIG.ASSOCIATED_BUSIF $clock_port] :]
foreach name {M_AXI_SYS M_AXI_REGS GFP_UB_IN GFP_UB_OUT} {
  set intf [get_bd_intf_ports -quiet $name]
  if {[llength $intf]} {
    if {[lsearch -exact $clock_interfaces $name] < 0} {
      lappend clock_interfaces $name
    }
  }
}
set_property CONFIG.ASSOCIATED_BUSIF \
  [join [lsearch -all -inline -not -exact $clock_interfaces ""] :] $clock_port

# These are the existing four crossbar windows, not new address allocations.
foreach {segment offset range} {
  M_AXI_SYS/Reg                 0x81210000 0x1000
  trx_cfg_lut_ctrl/S_AXI/Mem0    0x81220000 0x1000
  trx_gfp_fifo/S_AXI/Mem0        0x81230000 0x2000
  M_AXI_REGS/Reg                0x81250000 0x1000
} {
  assign_bd_address -offset $offset -range $range \
    -target_address_space [get_bd_addr_spaces sys_ps8/Data] \
    [get_bd_addr_segs $segment] -force
}

set repair_root [file normalize [file join [file dirname [info script]] ../..]]
set rom_path [get_property CONFIG.PATH_TO_FILE [get_bd_cells rom_sys_0]]
if {![file readable $rom_path]} {
  set rom_path [file join $repair_root scripts msdr assets_v4 mem_init_sys.txt]
  if {![file readable $rom_path]} {
    error "SYSID ROM initialization file is missing: $rom_path. Create the project to regenerate it."
  }
  set_property CONFIG.PATH_TO_FILE $rom_path [get_bd_cells rom_sys_0]
}

validate_bd_design
foreach name {M_AXI_SYS M_AXI_REGS GFP_UB_IN GFP_UB_OUT} {
  set intf [get_bd_intf_ports -quiet $name]
  if {[llength $intf] && [get_property CONFIG.FREQ_HZ $intf] != $cpu_clock_hz} {
    error "$name did not inherit the $cpu_clock_hz Hz init_clk frequency."
  }
}
save_bd_design
puts "Clock/address repair v2: interfaces associated with init_clk ($cpu_clock_hz Hz); AXI windows assigned; SYSID ROM readable."

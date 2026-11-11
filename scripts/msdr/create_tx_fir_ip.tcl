if {![info exists msdr_root]} {
  set msdr_root [file normalize [file join [file dirname [info script]] ../..]]
}

set tx_fir_coe [file normalize [file join $msdr_root simulink ddc ddc.coe]]
if {![file exists $tx_fir_coe]} {
  error "TX FIR coefficient file not found: $tx_fir_coe"
}

foreach name {fir_i_decimator fir_q_decimator} {
  if {[get_ips -quiet $name] eq ""} {
    create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 \
      -module_name $name
  }

  set fir [get_ips $name]
  set_property -dict [list \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Rate_Change_Type {Integer} \
    CONFIG.Decimation_Rate {5} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File $tx_fir_coe \
    CONFIG.Coefficient_Width {24} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Data_Width {16} \
    CONFIG.Data_Sign {Signed} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {16} \
    CONFIG.Sample_Frequency {250} \
    CONFIG.Clock_Frequency {250} \
    CONFIG.M_DATA_Has_TREADY {false} \
    CONFIG.S_DATA_Has_FIFO {false} \
    CONFIG.Has_ARESETn {true} \
  ] $fir

  generate_target all $fir
}

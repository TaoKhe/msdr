# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CUSTOM_ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROM_ADDR_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROM_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.CUSTOM_ID { PARAM_VALUE.CUSTOM_ID } {
	# Procedure called to update CUSTOM_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CUSTOM_ID { PARAM_VALUE.CUSTOM_ID } {
	# Procedure called to validate CUSTOM_ID
	return true
}

proc update_PARAM_VALUE.ROM_ADDR_BITS { PARAM_VALUE.ROM_ADDR_BITS } {
	# Procedure called to update ROM_ADDR_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROM_ADDR_BITS { PARAM_VALUE.ROM_ADDR_BITS } {
	# Procedure called to validate ROM_ADDR_BITS
	return true
}

proc update_PARAM_VALUE.ROM_WIDTH { PARAM_VALUE.ROM_WIDTH } {
	# Procedure called to update ROM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROM_WIDTH { PARAM_VALUE.ROM_WIDTH } {
	# Procedure called to validate ROM_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.ROM_WIDTH { MODELPARAM_VALUE.ROM_WIDTH PARAM_VALUE.ROM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROM_WIDTH}] ${MODELPARAM_VALUE.ROM_WIDTH}
}

proc update_MODELPARAM_VALUE.ROM_ADDR_BITS { MODELPARAM_VALUE.ROM_ADDR_BITS PARAM_VALUE.ROM_ADDR_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROM_ADDR_BITS}] ${MODELPARAM_VALUE.ROM_ADDR_BITS}
}

proc update_MODELPARAM_VALUE.CUSTOM_ID { MODELPARAM_VALUE.CUSTOM_ID PARAM_VALUE.CUSTOM_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CUSTOM_ID}] ${MODELPARAM_VALUE.CUSTOM_ID}
}


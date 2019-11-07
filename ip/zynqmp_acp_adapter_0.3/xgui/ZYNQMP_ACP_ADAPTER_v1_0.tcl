# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_RESP_QUEUE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_DATA_QUEUE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_MAX_LENGTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_RESP_QUEUE" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to update AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to validate AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to update AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to validate AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to update AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to validate AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.READ_ENABLE { PARAM_VALUE.READ_ENABLE } {
	# Procedure called to update READ_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_ENABLE { PARAM_VALUE.READ_ENABLE } {
	# Procedure called to validate READ_ENABLE
	return true
}

proc update_PARAM_VALUE.READ_RESP_QUEUE { PARAM_VALUE.READ_RESP_QUEUE } {
	# Procedure called to update READ_RESP_QUEUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_RESP_QUEUE { PARAM_VALUE.READ_RESP_QUEUE } {
	# Procedure called to validate READ_RESP_QUEUE
	return true
}

proc update_PARAM_VALUE.WRITE_DATA_QUEUE { PARAM_VALUE.WRITE_DATA_QUEUE } {
	# Procedure called to update WRITE_DATA_QUEUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_DATA_QUEUE { PARAM_VALUE.WRITE_DATA_QUEUE } {
	# Procedure called to validate WRITE_DATA_QUEUE
	return true
}

proc update_PARAM_VALUE.WRITE_ENABLE { PARAM_VALUE.WRITE_ENABLE } {
	# Procedure called to update WRITE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_ENABLE { PARAM_VALUE.WRITE_ENABLE } {
	# Procedure called to validate WRITE_ENABLE
	return true
}

proc update_PARAM_VALUE.WRITE_MAX_LENGTH { PARAM_VALUE.WRITE_MAX_LENGTH } {
	# Procedure called to update WRITE_MAX_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_MAX_LENGTH { PARAM_VALUE.WRITE_MAX_LENGTH } {
	# Procedure called to validate WRITE_MAX_LENGTH
	return true
}

proc update_PARAM_VALUE.WRITE_RESP_QUEUE { PARAM_VALUE.WRITE_RESP_QUEUE } {
	# Procedure called to update WRITE_RESP_QUEUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_RESP_QUEUE { PARAM_VALUE.WRITE_RESP_QUEUE } {
	# Procedure called to validate WRITE_RESP_QUEUE
	return true
}


proc update_MODELPARAM_VALUE.READ_ENABLE { MODELPARAM_VALUE.READ_ENABLE PARAM_VALUE.READ_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_ENABLE}] ${MODELPARAM_VALUE.READ_ENABLE}
}

proc update_MODELPARAM_VALUE.WRITE_ENABLE { MODELPARAM_VALUE.WRITE_ENABLE PARAM_VALUE.WRITE_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_ENABLE}] ${MODELPARAM_VALUE.WRITE_ENABLE}
}

proc update_MODELPARAM_VALUE.AXI_ADDR_WIDTH { MODELPARAM_VALUE.AXI_ADDR_WIDTH PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_DATA_WIDTH { MODELPARAM_VALUE.AXI_DATA_WIDTH PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_ID_WIDTH { MODELPARAM_VALUE.AXI_ID_WIDTH PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ID_WIDTH}] ${MODELPARAM_VALUE.AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.READ_RESP_QUEUE { MODELPARAM_VALUE.READ_RESP_QUEUE PARAM_VALUE.READ_RESP_QUEUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_RESP_QUEUE}] ${MODELPARAM_VALUE.READ_RESP_QUEUE}
}

proc update_MODELPARAM_VALUE.WRITE_DATA_QUEUE { MODELPARAM_VALUE.WRITE_DATA_QUEUE PARAM_VALUE.WRITE_DATA_QUEUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_DATA_QUEUE}] ${MODELPARAM_VALUE.WRITE_DATA_QUEUE}
}

proc update_MODELPARAM_VALUE.WRITE_MAX_LENGTH { MODELPARAM_VALUE.WRITE_MAX_LENGTH PARAM_VALUE.WRITE_MAX_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_MAX_LENGTH}] ${MODELPARAM_VALUE.WRITE_MAX_LENGTH}
}

proc update_MODELPARAM_VALUE.WRITE_RESP_QUEUE { MODELPARAM_VALUE.WRITE_RESP_QUEUE PARAM_VALUE.WRITE_RESP_QUEUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_RESP_QUEUE}] ${MODELPARAM_VALUE.WRITE_RESP_QUEUE}
}


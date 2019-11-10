# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set WIDTH [ipgui::add_group $IPINST -name "WIDTH" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent ${WIDTH}
  ipgui::add_param $IPINST -name "AXI_DATA_WIDTH" -parent ${WIDTH}
  ipgui::add_param $IPINST -name "AXI_ADDR_WIDTH" -parent ${WIDTH}

  #Adding Group
  set READ [ipgui::add_group $IPINST -name "READ" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "READ_ENABLE" -parent ${READ}
  ipgui::add_param $IPINST -name "RRESP_QUEUE_SIZE" -parent ${READ}
  ipgui::add_param $IPINST -name "RDATA_QUEUE_SIZE" -parent ${READ}
  ipgui::add_param $IPINST -name "RDATA_INTAKE_REGS" -parent ${READ}

  #Adding Group
  set WRITE [ipgui::add_group $IPINST -name "WRITE" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "WRITE_ENABLE" -parent ${WRITE}
  ipgui::add_param $IPINST -name "WRESP_QUEUE_SIZE" -parent ${WRITE}
  ipgui::add_param $IPINST -name "WDATA_QUEUE_SIZE" -parent ${WRITE}
  ipgui::add_param $IPINST -name "WDATA_OUTLET_REGS" -parent ${WRITE}
  ipgui::add_param $IPINST -name "WDATA_INTAKE_REGS" -parent ${WRITE}



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

proc update_PARAM_VALUE.RDATA_INTAKE_REGS { PARAM_VALUE.RDATA_INTAKE_REGS } {
	# Procedure called to update RDATA_INTAKE_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDATA_INTAKE_REGS { PARAM_VALUE.RDATA_INTAKE_REGS } {
	# Procedure called to validate RDATA_INTAKE_REGS
	return true
}

proc update_PARAM_VALUE.RDATA_QUEUE_SIZE { PARAM_VALUE.RDATA_QUEUE_SIZE } {
	# Procedure called to update RDATA_QUEUE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RDATA_QUEUE_SIZE { PARAM_VALUE.RDATA_QUEUE_SIZE } {
	# Procedure called to validate RDATA_QUEUE_SIZE
	return true
}

proc update_PARAM_VALUE.READ_ENABLE { PARAM_VALUE.READ_ENABLE } {
	# Procedure called to update READ_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_ENABLE { PARAM_VALUE.READ_ENABLE } {
	# Procedure called to validate READ_ENABLE
	return true
}

proc update_PARAM_VALUE.RRESP_QUEUE_SIZE { PARAM_VALUE.RRESP_QUEUE_SIZE } {
	# Procedure called to update RRESP_QUEUE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RRESP_QUEUE_SIZE { PARAM_VALUE.RRESP_QUEUE_SIZE } {
	# Procedure called to validate RRESP_QUEUE_SIZE
	return true
}

proc update_PARAM_VALUE.WDATA_INTAKE_REGS { PARAM_VALUE.WDATA_INTAKE_REGS } {
	# Procedure called to update WDATA_INTAKE_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WDATA_INTAKE_REGS { PARAM_VALUE.WDATA_INTAKE_REGS } {
	# Procedure called to validate WDATA_INTAKE_REGS
	return true
}

proc update_PARAM_VALUE.WDATA_OUTLET_REGS { PARAM_VALUE.WDATA_OUTLET_REGS } {
	# Procedure called to update WDATA_OUTLET_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WDATA_OUTLET_REGS { PARAM_VALUE.WDATA_OUTLET_REGS } {
	# Procedure called to validate WDATA_OUTLET_REGS
	return true
}

proc update_PARAM_VALUE.WDATA_QUEUE_SIZE { PARAM_VALUE.WDATA_QUEUE_SIZE } {
	# Procedure called to update WDATA_QUEUE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WDATA_QUEUE_SIZE { PARAM_VALUE.WDATA_QUEUE_SIZE } {
	# Procedure called to validate WDATA_QUEUE_SIZE
	return true
}

proc update_PARAM_VALUE.WRESP_QUEUE_SIZE { PARAM_VALUE.WRESP_QUEUE_SIZE } {
	# Procedure called to update WRESP_QUEUE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRESP_QUEUE_SIZE { PARAM_VALUE.WRESP_QUEUE_SIZE } {
	# Procedure called to validate WRESP_QUEUE_SIZE
	return true
}

proc update_PARAM_VALUE.WRITE_ENABLE { PARAM_VALUE.WRITE_ENABLE } {
	# Procedure called to update WRITE_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_ENABLE { PARAM_VALUE.WRITE_ENABLE } {
	# Procedure called to validate WRITE_ENABLE
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

proc update_MODELPARAM_VALUE.RRESP_QUEUE_SIZE { MODELPARAM_VALUE.RRESP_QUEUE_SIZE PARAM_VALUE.RRESP_QUEUE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RRESP_QUEUE_SIZE}] ${MODELPARAM_VALUE.RRESP_QUEUE_SIZE}
}

proc update_MODELPARAM_VALUE.RDATA_QUEUE_SIZE { MODELPARAM_VALUE.RDATA_QUEUE_SIZE PARAM_VALUE.RDATA_QUEUE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDATA_QUEUE_SIZE}] ${MODELPARAM_VALUE.RDATA_QUEUE_SIZE}
}

proc update_MODELPARAM_VALUE.RDATA_INTAKE_REGS { MODELPARAM_VALUE.RDATA_INTAKE_REGS PARAM_VALUE.RDATA_INTAKE_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RDATA_INTAKE_REGS}] ${MODELPARAM_VALUE.RDATA_INTAKE_REGS}
}

proc update_MODELPARAM_VALUE.WRESP_QUEUE_SIZE { MODELPARAM_VALUE.WRESP_QUEUE_SIZE PARAM_VALUE.WRESP_QUEUE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRESP_QUEUE_SIZE}] ${MODELPARAM_VALUE.WRESP_QUEUE_SIZE}
}

proc update_MODELPARAM_VALUE.WDATA_QUEUE_SIZE { MODELPARAM_VALUE.WDATA_QUEUE_SIZE PARAM_VALUE.WDATA_QUEUE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WDATA_QUEUE_SIZE}] ${MODELPARAM_VALUE.WDATA_QUEUE_SIZE}
}

proc update_MODELPARAM_VALUE.WDATA_OUTLET_REGS { MODELPARAM_VALUE.WDATA_OUTLET_REGS PARAM_VALUE.WDATA_OUTLET_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WDATA_OUTLET_REGS}] ${MODELPARAM_VALUE.WDATA_OUTLET_REGS}
}

proc update_MODELPARAM_VALUE.WDATA_INTAKE_REGS { MODELPARAM_VALUE.WDATA_INTAKE_REGS PARAM_VALUE.WDATA_INTAKE_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WDATA_INTAKE_REGS}] ${MODELPARAM_VALUE.WDATA_INTAKE_REGS}
}


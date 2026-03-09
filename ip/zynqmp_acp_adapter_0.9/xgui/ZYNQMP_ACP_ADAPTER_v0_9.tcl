# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set CORE [ipgui::add_page $IPINST -name "CORE"]
  #Adding Group
  set AXI_WIDTH [ipgui::add_group $IPINST -name "AXI_WIDTH" -parent ${CORE}]
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent ${AXI_WIDTH}
  ipgui::add_param $IPINST -name "AXI_DATA_WIDTH" -parent ${AXI_WIDTH}
  ipgui::add_param $IPINST -name "AXI_ADDR_WIDTH" -parent ${AXI_WIDTH}
  ipgui::add_param $IPINST -name "AXI_AUSER_WIDTH" -parent ${AXI_WIDTH}

  #Adding Group
  set READ [ipgui::add_group $IPINST -name "READ" -parent ${CORE}]
  ipgui::add_param $IPINST -name "READ_ENABLE" -parent ${READ}

  #Adding Group
  set WRITE [ipgui::add_group $IPINST -name "WRITE" -parent ${CORE}]
  ipgui::add_param $IPINST -name "WRITE_ENABLE" -parent ${WRITE}


  #Adding Page
  set READ [ipgui::add_page $IPINST -name "READ"]
  #Adding Group
  set READ_CACHE [ipgui::add_group $IPINST -name "READ_CACHE" -parent ${READ}]
  ipgui::add_param $IPINST -name "ARCACHE_OVERLAY" -parent ${READ_CACHE}
  ipgui::add_param $IPINST -name "ARCACHE_VALUE" -parent ${READ_CACHE}

  #Adding Group
  set READ_PROT [ipgui::add_group $IPINST -name "READ_PROT" -parent ${READ}]
  ipgui::add_param $IPINST -name "ARPROT_OVERLAY" -parent ${READ_PROT}
  ipgui::add_param $IPINST -name "ARPROT_VALUE" -parent ${READ_PROT}

  #Adding Group
  set READ_SHARE [ipgui::add_group $IPINST -name "READ_SHARE" -parent ${READ}]
  ipgui::add_param $IPINST -name "ARSHARE_TYPE" -parent ${READ_SHARE}

  #Adding Group
  set READ_REGS [ipgui::add_group $IPINST -name "READ_REGS" -parent ${READ}]
  ipgui::add_param $IPINST -name "RRESP_QUEUE_SIZE" -parent ${READ_REGS}
  ipgui::add_param $IPINST -name "RDATA_QUEUE_SIZE" -parent ${READ_REGS}
  ipgui::add_param $IPINST -name "RDATA_INTAKE_REGS" -parent ${READ_REGS}


  #Adding Page
  set WRITE [ipgui::add_page $IPINST -name "WRITE"]
  #Adding Group
  set WRITE_CACHE [ipgui::add_group $IPINST -name "WRITE_CACHE" -parent ${WRITE}]
  ipgui::add_param $IPINST -name "AWCACHE_OVERLAY" -parent ${WRITE_CACHE}
  ipgui::add_param $IPINST -name "AWCACHE_VALUE" -parent ${WRITE_CACHE}

  #Adding Group
  set WRITE_PROT [ipgui::add_group $IPINST -name "WRITE_PROT" -parent ${WRITE}]
  ipgui::add_param $IPINST -name "AWPROT_OVERLAY" -parent ${WRITE_PROT}
  ipgui::add_param $IPINST -name "AWPROT_VALUE" -parent ${WRITE_PROT}

  #Adding Group
  set WRITE_SHARE [ipgui::add_group $IPINST -name "WRITE_SHARE" -parent ${WRITE}]
  ipgui::add_param $IPINST -name "AWSHARE_TYPE" -parent ${WRITE_SHARE}

  #Adding Group
  set WRITE_REGS [ipgui::add_group $IPINST -name "WRITE_REGS" -parent ${WRITE}]
  ipgui::add_param $IPINST -name "WRESP_QUEUE_SIZE" -parent ${WRITE_REGS}
  ipgui::add_param $IPINST -name "WDATA_QUEUE_SIZE" -parent ${WRITE_REGS}
  ipgui::add_param $IPINST -name "WDATA_OUTLET_REGS" -parent ${WRITE_REGS}
  ipgui::add_param $IPINST -name "WDATA_INTAKE_REGS" -parent ${WRITE_REGS}



}

proc update_PARAM_VALUE.ACP_ADDR_WIDTH { PARAM_VALUE.ACP_ADDR_WIDTH } {
	# Procedure called to update ACP_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACP_ADDR_WIDTH { PARAM_VALUE.ACP_ADDR_WIDTH } {
	# Procedure called to validate ACP_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.ACP_AUSER_WIDTH { PARAM_VALUE.ACP_AUSER_WIDTH } {
	# Procedure called to update ACP_AUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACP_AUSER_WIDTH { PARAM_VALUE.ACP_AUSER_WIDTH } {
	# Procedure called to validate ACP_AUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.ACP_DATA_WIDTH { PARAM_VALUE.ACP_DATA_WIDTH } {
	# Procedure called to update ACP_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACP_DATA_WIDTH { PARAM_VALUE.ACP_DATA_WIDTH } {
	# Procedure called to validate ACP_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.ACP_ID_WIDTH { PARAM_VALUE.ACP_ID_WIDTH } {
	# Procedure called to update ACP_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACP_ID_WIDTH { PARAM_VALUE.ACP_ID_WIDTH } {
	# Procedure called to validate ACP_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.ARCACHE_OVERLAY { PARAM_VALUE.ARCACHE_OVERLAY } {
	# Procedure called to update ARCACHE_OVERLAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARCACHE_OVERLAY { PARAM_VALUE.ARCACHE_OVERLAY } {
	# Procedure called to validate ARCACHE_OVERLAY
	return true
}

proc update_PARAM_VALUE.ARCACHE_VALUE { PARAM_VALUE.ARCACHE_VALUE } {
	# Procedure called to update ARCACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARCACHE_VALUE { PARAM_VALUE.ARCACHE_VALUE } {
	# Procedure called to validate ARCACHE_VALUE
	return true
}

proc update_PARAM_VALUE.ARPROT_OVERLAY { PARAM_VALUE.ARPROT_OVERLAY } {
	# Procedure called to update ARPROT_OVERLAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARPROT_OVERLAY { PARAM_VALUE.ARPROT_OVERLAY } {
	# Procedure called to validate ARPROT_OVERLAY
	return true
}

proc update_PARAM_VALUE.ARPROT_VALUE { PARAM_VALUE.ARPROT_VALUE } {
	# Procedure called to update ARPROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARPROT_VALUE { PARAM_VALUE.ARPROT_VALUE } {
	# Procedure called to validate ARPROT_VALUE
	return true
}

proc update_PARAM_VALUE.ARSHARE_TYPE { PARAM_VALUE.ARSHARE_TYPE } {
	# Procedure called to update ARSHARE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARSHARE_TYPE { PARAM_VALUE.ARSHARE_TYPE } {
	# Procedure called to validate ARSHARE_TYPE
	return true
}

proc update_PARAM_VALUE.AWCACHE_OVERLAY { PARAM_VALUE.AWCACHE_OVERLAY } {
	# Procedure called to update AWCACHE_OVERLAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWCACHE_OVERLAY { PARAM_VALUE.AWCACHE_OVERLAY } {
	# Procedure called to validate AWCACHE_OVERLAY
	return true
}

proc update_PARAM_VALUE.AWCACHE_VALUE { PARAM_VALUE.AWCACHE_VALUE } {
	# Procedure called to update AWCACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWCACHE_VALUE { PARAM_VALUE.AWCACHE_VALUE } {
	# Procedure called to validate AWCACHE_VALUE
	return true
}

proc update_PARAM_VALUE.AWPROT_OVERLAY { PARAM_VALUE.AWPROT_OVERLAY } {
	# Procedure called to update AWPROT_OVERLAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWPROT_OVERLAY { PARAM_VALUE.AWPROT_OVERLAY } {
	# Procedure called to validate AWPROT_OVERLAY
	return true
}

proc update_PARAM_VALUE.AWPROT_VALUE { PARAM_VALUE.AWPROT_VALUE } {
	# Procedure called to update AWPROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWPROT_VALUE { PARAM_VALUE.AWPROT_VALUE } {
	# Procedure called to validate AWPROT_VALUE
	return true
}

proc update_PARAM_VALUE.AWSHARE_TYPE { PARAM_VALUE.AWSHARE_TYPE } {
	# Procedure called to update AWSHARE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWSHARE_TYPE { PARAM_VALUE.AWSHARE_TYPE } {
	# Procedure called to validate AWSHARE_TYPE
	return true
}

proc update_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to update AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to validate AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_AUSER_BIT0_POS { PARAM_VALUE.AXI_AUSER_BIT0_POS } {
	# Procedure called to update AXI_AUSER_BIT0_POS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_AUSER_BIT0_POS { PARAM_VALUE.AXI_AUSER_BIT0_POS } {
	# Procedure called to validate AXI_AUSER_BIT0_POS
	return true
}

proc update_PARAM_VALUE.AXI_AUSER_BIT1_POS { PARAM_VALUE.AXI_AUSER_BIT1_POS } {
	# Procedure called to update AXI_AUSER_BIT1_POS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_AUSER_BIT1_POS { PARAM_VALUE.AXI_AUSER_BIT1_POS } {
	# Procedure called to validate AXI_AUSER_BIT1_POS
	return true
}

proc update_PARAM_VALUE.AXI_AUSER_WIDTH { PARAM_VALUE.AXI_AUSER_WIDTH } {
	# Procedure called to update AXI_AUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_AUSER_WIDTH { PARAM_VALUE.AXI_AUSER_WIDTH } {
	# Procedure called to validate AXI_AUSER_WIDTH
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

proc update_MODELPARAM_VALUE.AXI_AUSER_WIDTH { MODELPARAM_VALUE.AXI_AUSER_WIDTH PARAM_VALUE.AXI_AUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_AUSER_WIDTH}] ${MODELPARAM_VALUE.AXI_AUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_AUSER_BIT0_POS { MODELPARAM_VALUE.AXI_AUSER_BIT0_POS PARAM_VALUE.AXI_AUSER_BIT0_POS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_AUSER_BIT0_POS}] ${MODELPARAM_VALUE.AXI_AUSER_BIT0_POS}
}

proc update_MODELPARAM_VALUE.AXI_AUSER_BIT1_POS { MODELPARAM_VALUE.AXI_AUSER_BIT1_POS PARAM_VALUE.AXI_AUSER_BIT1_POS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_AUSER_BIT1_POS}] ${MODELPARAM_VALUE.AXI_AUSER_BIT1_POS}
}

proc update_MODELPARAM_VALUE.ACP_ADDR_WIDTH { MODELPARAM_VALUE.ACP_ADDR_WIDTH PARAM_VALUE.ACP_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACP_ADDR_WIDTH}] ${MODELPARAM_VALUE.ACP_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.ACP_DATA_WIDTH { MODELPARAM_VALUE.ACP_DATA_WIDTH PARAM_VALUE.ACP_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACP_DATA_WIDTH}] ${MODELPARAM_VALUE.ACP_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ACP_ID_WIDTH { MODELPARAM_VALUE.ACP_ID_WIDTH PARAM_VALUE.ACP_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACP_ID_WIDTH}] ${MODELPARAM_VALUE.ACP_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.ACP_AUSER_WIDTH { MODELPARAM_VALUE.ACP_AUSER_WIDTH PARAM_VALUE.ACP_AUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACP_AUSER_WIDTH}] ${MODELPARAM_VALUE.ACP_AUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.ARCACHE_OVERLAY { MODELPARAM_VALUE.ARCACHE_OVERLAY PARAM_VALUE.ARCACHE_OVERLAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARCACHE_OVERLAY}] ${MODELPARAM_VALUE.ARCACHE_OVERLAY}
}

proc update_MODELPARAM_VALUE.ARCACHE_VALUE { MODELPARAM_VALUE.ARCACHE_VALUE PARAM_VALUE.ARCACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARCACHE_VALUE}] ${MODELPARAM_VALUE.ARCACHE_VALUE}
}

proc update_MODELPARAM_VALUE.ARPROT_OVERLAY { MODELPARAM_VALUE.ARPROT_OVERLAY PARAM_VALUE.ARPROT_OVERLAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARPROT_OVERLAY}] ${MODELPARAM_VALUE.ARPROT_OVERLAY}
}

proc update_MODELPARAM_VALUE.ARPROT_VALUE { MODELPARAM_VALUE.ARPROT_VALUE PARAM_VALUE.ARPROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARPROT_VALUE}] ${MODELPARAM_VALUE.ARPROT_VALUE}
}

proc update_MODELPARAM_VALUE.ARSHARE_TYPE { MODELPARAM_VALUE.ARSHARE_TYPE PARAM_VALUE.ARSHARE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARSHARE_TYPE}] ${MODELPARAM_VALUE.ARSHARE_TYPE}
}

proc update_MODELPARAM_VALUE.AWCACHE_OVERLAY { MODELPARAM_VALUE.AWCACHE_OVERLAY PARAM_VALUE.AWCACHE_OVERLAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWCACHE_OVERLAY}] ${MODELPARAM_VALUE.AWCACHE_OVERLAY}
}

proc update_MODELPARAM_VALUE.AWCACHE_VALUE { MODELPARAM_VALUE.AWCACHE_VALUE PARAM_VALUE.AWCACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWCACHE_VALUE}] ${MODELPARAM_VALUE.AWCACHE_VALUE}
}

proc update_MODELPARAM_VALUE.AWPROT_OVERLAY { MODELPARAM_VALUE.AWPROT_OVERLAY PARAM_VALUE.AWPROT_OVERLAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWPROT_OVERLAY}] ${MODELPARAM_VALUE.AWPROT_OVERLAY}
}

proc update_MODELPARAM_VALUE.AWPROT_VALUE { MODELPARAM_VALUE.AWPROT_VALUE PARAM_VALUE.AWPROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWPROT_VALUE}] ${MODELPARAM_VALUE.AWPROT_VALUE}
}

proc update_MODELPARAM_VALUE.AWSHARE_TYPE { MODELPARAM_VALUE.AWSHARE_TYPE PARAM_VALUE.AWSHARE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWSHARE_TYPE}] ${MODELPARAM_VALUE.AWSHARE_TYPE}
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


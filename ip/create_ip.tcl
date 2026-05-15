#
# create_ip.tcl  Tcl script for generate IP
#
set ip_name                 "ZYNQMP_ACP_ADAPTER"
set ip_version              "1.1"
set ip_core_revision        1
set ip_description          "ZynqMP-ACP-AXI Adapter"
set ip_vendor_name          "ikwzm"
set ip_library_name         "PIPEWORK"
set ip_root_directory       [file join [file dirname [info script]] "zynqmp_acp_adapter_$ip_version"]
#
# Open project
#
set project_directory       [file join [file dirname [info script]] "work"]
set project_name            "zynqmp_acp_adapter"
open_project [file join $project_directory $project_name]
#
# Create IP-Package project
#
ipx::package_project -root_dir $ip_root_directory -vendor $ip_vendor_name -library $ip_library_name -taxonomy /UserIP -generated_files -import_files -force
#
# Infer Bus Interfaces
#
ipx::infer_bus_interfaces xilinx.com:interface:aximm_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interfaces xilinx.com:interface:axis_rtl:1.0  [ipx::current_core]
#
# Associate Clock
#
ipx::associate_bus_interfaces -busif ACP -clock ACLK [ipx::current_core]
ipx::associate_bus_interfaces -busif AXI -clock ACLK [ipx::current_core]
#
# Set Supported Families
#
set_property supported_families {zynq Production virtex7 Production qvirtex7 Production kintex7 Production kintex7l Production qkintex7 Production qkintex7l Production artix7 Production artix7l Production aartix7 Production qartix7 Production zynq Production qzynq Production azynq Production zynquplus Production} [ipx::current_core]
#
# Set Core Version
#
set_property version         "$ip_version"         [ipx::current_core]
set_property core_revision   "$ip_core_revision"   [ipx::current_core]
set_property name            "$ip_name"            [ipx::current_core]
set_property display_name    "$ip_name"            [ipx::current_core]
set_property description     "$ip_description"     [ipx::current_core]
#
# Generate files
#
ipx::create_xgui_files       [ipx::current_core]
ipx::update_checksums        [ipx::current_core]
ipx::save_core               [ipx::current_core]
#
# Close and Done.
#
close_project

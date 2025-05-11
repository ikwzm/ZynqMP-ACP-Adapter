#
# update_xgui.tcl  Tcl script for Update XGUI
#
set project_name            "zynqmp_acp_adapter"
set ip_name                 "ZYNQMP_ACP_ADAPTER"
set ip_version              "0.8"

set ip_root_directory       [file join [file dirname [info script]] "zynqmp_acp_adapter_$ip_version"]
set project_directory       [file join [file dirname [info script]] "work"]
set ip_version_             [string map {. _} $ip_version]
set xgui_tcl_file           "${ip_name}_v${ip_version_}.tcl"
set need_merge_project      0

#
# Copy GUI Tcl file to IP
#
file copy -force [file join "xgui" $xgui_tcl_file] [file join $ip_root_directory "xgui"]
#
# Open project
#
open_project [file join $project_directory $project_name]
#
# Open IP-XACT file
# 
ipx::open_ipxact_file [file join $ip_root_directory "component.xml"]
#
# Save already existing files of a file group to existing_files
#
if {$need_merge_project} {
    set existing_files [dict create]
    proc add_existing_files { fileset } {
        global existing_files
        set file_group [ipx::get_file_groups $fileset -of_objects [ipx::current_core]]
        set file_list  [ipx::get_files -of_objects $file_group]
        dict set existing_files $fileset $file_list
    }
    add_existing_files xilinx_anylanguagesynthesis
    add_existing_files xilinx_anylanguagebehavioralsimulation
}
#
# merge_project
# 
if {$need_merge_project} {
    ipx::merge_project_changes port           [ipx::current_core]
    ipx::merge_project_changes hdl_paramegers [ipx::current_core]
 ## When Vivado 2021.1, Abnormal program termination (11)
 ## ipx::merge_project_changes files          [ipx::current_core]
}
#
# Update GUI Tcl file
#
ipx::create_xgui_files          [ipx::current_core]
#
# Set Display Name same as Name
#
proc set_user_parameter_display_name_same_as_name { user_parameter } {
    set name         [get_property name $user_parameter]
    set display_name $name
    puts "## change_display_name $name -> $display_name"
    set_property display_name $display_name $user_parameter
}
proc set_user_parameter_all_display_name_same_as_name {} {
    set user_parameter_list [ipx::get_user_parameters -of_objects [ipx::current_core]]
    foreach user_parameter $user_parameter_list {
        set_user_parameter_display_name_same_as_name $user_parameter
    }
}
set_user_parameter_all_display_name_same_as_name
#
# Remove newly added files by mistake
#
if {$need_merge_project} {
    proc remove_mistake_file_from_fileset { fileset } {
        global existing_files
        set old_file_list  [dict get $existing_files $fileset]
        set file_group     [ipx::get_file_groups $fileset -of_objects [ipx::current_core]]
        set new_file_list  [ipx::get_files -of_objects $file_group]
        foreach file $new_file_list {
            if {[lsearch -exact $old_file_list $file] != -1} {
                # puts "+ : $fileset : $file"
            } else {
                # puts "- : $fileset : $file"
                puts "## remove_file $file from $file_group"
                ipx::remove_file $file $file_group
            }
        }
    }
    remove_mistake_file_from_fileset xilinx_anylanguagesynthesis
    remove_mistake_file_from_fileset xilinx_anylanguagebehavioralsimulation
}
#
# Generate files
#
# ipx::merge_project_changes port [ipx::current_core]
# ipx::create_xgui_files          [ipx::current_core]
ipx::update_checksums           [ipx::current_core]
ipx::check_integrity            [ipx::current_core]
ipx::save_core                  [ipx::current_core]
#
# Close and Done.
#
close_project


all: add_sources.tcl add_sim.tcl

add_sources.tcl : add_sources.yml
	../../../PipeWork/tools/vhdl-archiver.rb -v --config add_sources.yml > add_sources.tcl


add_sim.tcl     : add_sim.yml
	../../../PipeWork/tools/vhdl-archiver.rb -v --config add_sim.yml     > add_sim.tcl



all: add_sources.tcl

clean:
	rm add_sources.tcl

add_sources.tcl     : add_sources.yml
	../PipeWork/tools/vhdl-archiver.rb -v --config add_sources.yml > add_sources.tcl



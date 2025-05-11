VIVADO       ?= vivado
IP_NAME      ?= zynqmp_acp_adapter
IP_VERSION   ?= 0.8
IP_VERSION_  := $(subst .,_,$(IP_VERSION))
IP_ROOT_DIR  := $(IP_NAME)_$(IP_VERSION)
XGUI_FILE    := ./xgui/ZYNQMP_ACP_ADAPTER_v$(IP_VERSION_).tcl
VIVADO_FILES := create_ip.tcl add_sources.tcl update_xgui.tcl $(XGUI_FILE)

all: ip

ip:  $(IP_ROOT_DIR)/component.xml

clean:
	rm add_sources.tcl
	rm -rf $(IP_ROOT_DIR)

add_sources.tcl     : add_sources.yml
	../PipeWork/tools/vhdl-archiver.rb -v --config add_sources.yml > add_sources.tcl

$(IP_ROOT_DIR)/component.xml : $(VIVADO_FILES)
	$(VIVADO) -mode batch -source create_ip.tcl
	$(VIVADO) -mode batch -source update_xgui.tcl


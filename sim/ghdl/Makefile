
DUMMY_PLUG_PATH      = ../../Dummy_Plug
DUMMY_PLUG_SRC_PATH  = $(DUMMY_PLUG_PATH)/src/main/vhdl
DUMMY_PLUG_WORK_PATH = $(DUMMY_PLUG_PATH)/sim/ghdl-0.35/dummy_plug
DUMMY_PLUG_TOOL_PATH = $(DUMMY_PLUG_PATH)/tools
PIPEWORK_PATH        = ../../PipeWork
PIPEWORK_WORK_PATH   = $(PIPEWORK_PATH)/sim/ghdl-0.35
PIPEWORK_SRC_PATH    = $(PIPEWORK_PATH)/src
PIPEWORK_TOOL_PATH   = $(PIPEWORK_PATH)/tools
SRC_PATH             = ../../src
SRC_TEST_PATH        = $(SRC_PATH)/test/vhdl/
SRC_SCENARIOS_PATH   = $(SRC_PATH)/test/scenarios/

COPY       = cp
GHDL       = ghdl
GHDLFLAGS  = --mb-comments -P$(DUMMY_PLUG_WORK_PATH)

TEST_BENCH = zynqmp_acp_adapter_test_bench  \
             zynqmp_acp_adapter_read_test   \
             zynqmp_acp_adapter_write_test  \
             $(END_LIST)

all: zynqmp_acp_adapter_library-obj93.cf $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

zynqmp_acp_adapter_test_bench : zynqmp_acp_adapter_test_bench.o zynqmp_acp_adapter_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_read_test  : zynqmp_acp_adapter_test_bench.o zynqmp_acp_adapter_read_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_write_test : zynqmp_acp_adapter_test_bench.o zynqmp_acp_adapter_write_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_library-obj93.cf: add_sources.yml
	$(PIPEWORK_TOOL_PATH)/vhdl-archiver.rb --config add_sources.yml

zynqmp_acp_adapter_test_bench.o         : $(SRC_TEST_PATH)/zynqmp_acp_adapter_test_bench.vhd 
	$(GHDL) -a $(GHDLFLAGS) --work=WORK $<

zynqmp_acp_adapter_test.snr	 :
	$(SRC_SCENARIOS_PATH)/make_scenario.rb

zynqmp_acp_adapter_read_test.snr  : $(SRC_SCENARIOS_PATH)/zynqmp_acp_adapter_read_test.snr
	$(COPY) $< $@

zynqmp_acp_adapter_write_test.snr : $(SRC_SCENARIOS_PATH)/zynqmp_acp_adapter_write_test.snr
	$(COPY) $< $@

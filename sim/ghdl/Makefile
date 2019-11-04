
PIPEWORK_TOOL_PATH = ../../PipeWork/tools/
SCENARIOS_PATH     = ../../src/test/scenarios/

COPY       = cp
GHDL       = ghdl
GHDLFLAGS  = --mb-comments

TEST_BENCH = zynqmp_acp_adapter_test_bench  \
             zynqmp_acp_adapter_read_test   \
             zynqmp_acp_adapter_write_test  \
             $(END_LIST)

all: work-obj93.cf $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

analyze: work-obj93.cf

work-obj93.cf: analyze.yml
	$(PIPEWORK_TOOL_PATH)/vhdl-archiver.rb -v --config $<

zynqmp_acp_adapter_test_bench : work-obj93.cf zynqmp_acp_adapter_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_read_test  : work-obj93.cf zynqmp_acp_adapter_read_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_write_test : work-obj93.cf zynqmp_acp_adapter_write_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_test.snr	 :
	$(SCENARIOS_PATH)/make_scenario.rb

zynqmp_acp_adapter_read_test.snr  : $(SCENARIOS_PATH)/zynqmp_acp_adapter_read_test.snr
	$(COPY) $< $@

zynqmp_acp_adapter_write_test.snr : $(SCENARIOS_PATH)/zynqmp_acp_adapter_write_test.snr
	$(COPY) $< $@


PIPEWORK_TOOL_PATH = ../../PipeWork/tools/
SCENARIOS_PATH     = ../../src/test/scenarios/

COPY      = cp
GHDL      = ghdl
GHDLFLAGS = --mb-comments

TEST_BENCH_0 = zynqmp_acp_adapter_test_bench

TEST_BENCH_1 = zynqmp_acp_adapter_read_test          \
               zynqmp_acp_adapter_write_test         \
               zynqmp_acp_adapter_cache_overlay_test \
               zynqmp_acp_adapter_prot_overlay_test  \
               zynqmp_acp_adapter_share_0_test       \
               zynqmp_acp_adapter_share_1_test       \
               zynqmp_acp_adapter_share_2_test       \
               zynqmp_acp_adapter_share_4_test       \
               zynqmp_acp_adapter_share_5_test       \
               zynqmp_acp_adapter_share_6_test       \
               $(END_LIST)

TEST_BENCH   = $(TEST_BENCH_0) $(TEST_BENCH_1)

all: work-obj93.cf $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

analyze: work-obj93.cf

work-obj93.cf: analyze.yml
	$(PIPEWORK_TOOL_PATH)/vhdl-archiver.rb -v --config $<

zynqmp_acp_adapter_test_bench : work-obj93.cf zynqmp_acp_adapter_test.snr
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

zynqmp_acp_adapter_test.snr	 :
	$(SCENARIOS_PATH)/make_scenario.rb

define DEF_TEST_BENCH_1
$(1): work-obj93.cf $(2)
	$(GHDL) -e $(GHDLFLAGS) --work=WORK $(1)
	$(GHDL) -r $(GHDLFLAGS) --work=WORK $(1)
$(2):  $(SCENARIOS_PATH)/$(2)
	$(COPY) $(SCENARIOS_PATH)/$(2) $(2)
endef

$(foreach TB, $(TEST_BENCH_1), $(eval $(call DEF_TEST_BENCH_1,$(TB),$(addsuffix .snr,$(TB)))))


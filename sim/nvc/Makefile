PIPEWORK_PATH = ../../PipeWork
SRC_TEST_PATH = ../../src/test/vhdl
SCENARIO_PATH = ../../src/test/scenarios

COPY          = cp
NVC           = nvc
NVCFLAGS      = -L ./ -M 32M

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

all: $(TEST_BENCH)

clean:
	rm -rf *.o WORK DUMMY_PLUG PIPEWORK ZYNQMP_ACP_ADAPTER_LIBRARY analyze_libs.sh

analyze_libs.sh: libs.yml
	$(PIPEWORK_PATH)/tools/vhdl-archiver.rb -v --config libs.yml > analyze_libs.sh

define NVC_ANALIZE_FILE
$(addprefix WORK/WORK.,$(shell echo $(1) | tr a-z A-Z))
endef

define NVC_EXECUTE_FILE
$(addsuffix .elab.so,$(addprefix WORK/_WORK.,$(shell echo $(1) | tr a-z A-Z)))
endef

define NVC_RUN_0
$(1): $(call NVC_EXECUTE_FILE,$(1)) $(2)
	$(NVC) $(NVCFLAGS) --work=WORK -r $(1)
endef

define NVC_RUN_1
$(1): $(call NVC_EXECUTE_FILE,$(1)) $(2)
	$(NVC) $(NVCFLAGS) --work=WORK -r $(1)
$(2):  $(SCENARIO_PATH)/$(2)
	$(COPY) $(SCENARIO_PATH)/$(2) $(2)
endef

define NVC_ELAB
$(call NVC_EXECUTE_FILE,$(1)): $(call NVC_ANALIZE_FILE,$(1))
	$(NVC) $(NVCFLAGS) --work=WORK -e $(1)
endef

$(call NVC_ANALIZE_FILE, $(TEST_BENCH)) : analyze_libs.sh
	sh analyze_libs.sh

analyze_libs : $(call NVC_ANALIZE_FILE, $(TEST_BENCH))

$(foreach TB, $(TEST_BENCH)  , $(eval $(call NVC_ELAB , $(TB))))
$(foreach TB, $(TEST_BENCH_0), $(eval $(call NVC_RUN_0, $(TB),zynqmp_acp_adapter_test.snr)))
$(foreach TB, $(TEST_BENCH_1), $(eval $(call NVC_RUN_1, $(TB),$(addsuffix .snr,$(TB)))))

zynqmp_acp_adapter_test.snr : $(SCENARIO_PATH)/make_scenario.rb
	$(SCENARIO_PATH)/make_scenario.rb

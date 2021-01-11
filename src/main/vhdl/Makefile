ENTITY_FILES = ../../../PipeWork/src/components/reducer.vhd         \
               ../../../PipeWork/src/components/queue_register.vhd  \
               ../../../PipeWork/src/components/queue_receiver.vhd  \
               ../../../PipeWork/src/components/sdpram.vhd          \
               zynqmp_acp_adapter.vhd                               \
               zynqmp_acp_read_adapter.vhd                          \
               zynqmp_acp_response_queue.vhd                        \
               zynqmp_acp_write_adapter.vhd                         \
               ${ENDLIST}

components.vhd : ${ENTITY_FILES}
	../../../PipeWork/tools/MakeComponentPackage.rb --verbose \
            --brief   'ZynqMP ACP Adapter Component Library Description' \
            --version 0.5.1 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library ZYNQMP_ACP_ADAPTER_LIBRARY \
            --package COMPONENTS \
            --output  components.vhd \
            ${ENTITY_FILES}

clean:
	-rm components.vhd

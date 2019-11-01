create_clock -period 10 -name CLK -waveform {0.000 5.000} [get_ports CLK]
# set_input_delay  -clock [get_clocks *] 2.0 [get_ports I_DATA[*] I_STRB[*] I_VALID I_LAST O_READY]
# set_output_delay -clock [get_clocks *] 2.0 [get_ports O_DATA[*] O_STRB[*] O_VALID O_LAST I_READY]

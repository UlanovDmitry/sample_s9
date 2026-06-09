## 4 LED: leds[0..3]
## ВНИМАНИЕ: порядок индексов astranome отличается от trebisky!
##   astranome leds[0]=D6(M17), [1]=D5(M19), [2]=D8(L19), [3]=D7(F16)
## Источник: astranome/Astra_S9_FPGA_Base — HDMI18.3.srcs/constrs_1/new/system.xdc

set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN M17 [get_ports {leds[0]}]
set_property PACKAGE_PIN M19 [get_ports {leds[1]}]
set_property PACKAGE_PIN L19 [get_ports {leds[2]}]
set_property PACKAGE_PIN F16 [get_ports {leds[3]}]

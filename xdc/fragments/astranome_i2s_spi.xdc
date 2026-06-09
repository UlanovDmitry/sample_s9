## I2S, SPI, PWM, MIDI-UART — daughter board Astra_S9_FPGA_Base
## Источник: astranome/Astra_S9_FPGA_Base — HDMI18.3.srcs/constrs_1/new/system.xdc

set_property IOSTANDARD LVCMOS33 [get_ports lrclk_out_0]
set_property IOSTANDARD LVCMOS33 [get_ports lrclk_out_1]
set_property IOSTANDARD LVCMOS33 [get_ports sclk_out_0]
set_property IOSTANDARD LVCMOS33 [get_ports sclk_out_1]
set_property IOSTANDARD LVCMOS33 [get_ports sdata_0_in_0]
set_property IOSTANDARD LVCMOS33 [get_ports sdata_0_out_0]
set_property PACKAGE_PIN H20 [get_ports lrclk_out_0]
set_property PACKAGE_PIN G17 [get_ports lrclk_out_1]
set_property PACKAGE_PIN J20 [get_ports sclk_out_0]
set_property PACKAGE_PIN G18 [get_ports sclk_out_1]
set_property PACKAGE_PIN F19 [get_ports sdata_0_in_0]
set_property PACKAGE_PIN F20 [get_ports sdata_0_out_0]

set_property IOSTANDARD LVCMOS33 [get_ports SPI0_MISO_I_0]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_MOSI_O_0]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SCLK_O_0]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SS_O_0]
set_property PACKAGE_PIN R14 [get_ports SPI0_MISO_I_0]
set_property PACKAGE_PIN T14 [get_ports SPI0_MOSI_O_0]
set_property PACKAGE_PIN T15 [get_ports SPI0_SCLK_O_0]
set_property PACKAGE_PIN P14 [get_ports SPI0_SS_O_0]

#set_property IOSTANDARD LVCMOS33 [get_ports UART_0_0_rxd]
#set_property IOSTANDARD LVCMOS33 [get_ports UART_0_0_txd]
#set_property PACKAGE_PIN W16 [get_ports UART_0_0_rxd]
#set_property PACKAGE_PIN V16 [get_ports UART_0_0_txd]

set_property IOSTANDARD LVCMOS33 [get_ports pwm_l_out_0]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_r_out_0]
set_property PACKAGE_PIN Y19 [get_ports pwm_l_out_0]
set_property PACKAGE_PIN Y18 [get_ports pwm_r_out_0]

set_property IOSTANDARD LVCMOS33 [get_ports uart_midi_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_midi_txd]
set_property PACKAGE_PIN W16 [get_ports uart_midi_rxd]
set_property PACKAGE_PIN V16 [get_ports uart_midi_txd]

set_property IOSTANDARD LVCMOS33 [get_ports MClk18]
set_property PACKAGE_PIN J18 [get_ports MClk18]

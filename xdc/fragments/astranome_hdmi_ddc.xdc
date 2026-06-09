## HDMI DDC (I2C) на daughter board Astra_S9_FPGA_Base
## Источник: astranome/Astra_S9_FPGA_Base — HDMI18.3.srcs/constrs_1/new/system.xdc

set_property IOSTANDARD LVCMOS33 [get_ports HDMI_DDC_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports HDMI_DDC_sda_io]
set_property PACKAGE_PIN W18 [get_ports HDMI_DDC_scl_io]
set_property PACKAGE_PIN W19 [get_ports HDMI_DDC_sda_io]

# IIC на S9 (закомментировано в оригинале):
#set_property IOSTANDARD LVCMOS33 [get_ports IIC_0_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports IIC_0_sda_io]
#set_property PACKAGE_PIN N17 [get_ports IIC_0_scl_io]
#set_property PACKAGE_PIN P18 [get_ports IIC_0_sda_io]

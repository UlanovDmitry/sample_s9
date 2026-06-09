## HDMI TMDS (требует соответствующего IP/RTL в PL)
## IOSTANDARD TMDS_33 — не LVCMOS33!
## Источник: astranome/Astra_S9_FPGA_Base — HDMI18.3.srcs/constrs_1/new/system.xdc

set_property PACKAGE_PIN U18 [get_ports {TMDS_data_p[0]}]
set_property PACKAGE_PIN V20 [get_ports {TMDS_data_p[2]}]

set_property IOSTANDARD TMDS_33 [get_ports TMDS_clk_n]
set_property PACKAGE_PIN U14 [get_ports TMDS_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports TMDS_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[1]}]
set_property PACKAGE_PIN T20 [get_ports {TMDS_data_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[2]}]

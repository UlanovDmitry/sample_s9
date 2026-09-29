# Antminer S9 — PS7-only Block Design (Vivado 2024.2)
#
# Creates xc7z010clg400-1 project with processing_system7_0 configured for:
#   NAND MIO 0–14, GEM0 RGMII MIO 16–27 + MDIO 52–53,
#   SDIO0 MIO 40–46, UART1 MIO 48–49, MIO GPIO, DDR MT41K128M16 (1 GiB default).
#
# Usage (Vivado Tcl console or batch):
#   cd sample_s9/vivado
#   source s9_ps7.tcl
#
# After changes to MIO/DDR: regenerate ps7_init and run sync_ps7_init.sh

set scripts_vivado_version 2024.2
set current_vivado_version [version -short]
if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
    puts "WARNING: script targets Vivado $scripts_vivado_version, running $current_vivado_version"
}

set script_dir [file normalize [file dirname [info script]]]
set proj_name antminer_s9_ps7
set design_name zynq_antminer_s9
set part xc7z010clg400-1

set proj_dir [file join $script_dir proj]
set export_dir [file join $script_dir export]

file mkdir $proj_dir
file mkdir $export_dir

if { [llength [get_projects -quiet]] == 0 } {
    create_project $proj_name $proj_dir -part $part
} else {
    set proj_name [lindex [get_projects] 0]
    puts "Using open project: $proj_name"
}

set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set bd_file [get_files -quiet ${design_name}.bd]
if { $bd_file eq "" } {
    create_bd_design $design_name
} else {
    current_bd_design $design_name
}

set ps7 [get_bd_cells -quiet processing_system7_0]
if { $ps7 eq "" } {
    set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
}

set_property -dict [list \
    CONFIG.PCW_PRESET {None} \
    CONFIG.PCW_FPGA0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_FPGA1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_FPGA2_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_FPGA3_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USE_M_AXI_GP0 {0} \
    CONFIG.PCW_USE_M_AXI_GP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {0} \
    CONFIG.PCW_EN_CLK0_PORT {0} \
    CONFIG.PCW_EN_RST0_PORT {0} \
    CONFIG.PCW_EN_EMIO_ENET0 {0} \
    CONFIG.PCW_EN_EMIO_ENET1 {0} \
    CONFIG.PCW_EN_EMIO_GPIO {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
    CONFIG.PCW_EN_SMC {1} \
    CONFIG.PCW_EN_ENET0 {1} \
    CONFIG.PCW_EN_ENET1 {0} \
    CONFIG.PCW_EN_GPIO {1} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_NAND_NAND_IO {MIO 0 2.. 14} \
    CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
    CONFIG.PCW_NAND_CYCLES_T_AR {15} \
    CONFIG.PCW_NAND_CYCLES_T_CLR {15} \
    CONFIG.PCW_NAND_CYCLES_T_RC {30} \
    CONFIG.PCW_NAND_CYCLES_T_REA {5} \
    CONFIG.PCW_NAND_CYCLES_T_RR {25} \
    CONFIG.PCW_NAND_CYCLES_T_WC {30} \
    CONFIG.PCW_NAND_CYCLES_T_WP {15} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {100 Mbps} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_ENET0_RESET_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_ENABLE {0} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {0} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_I2C_RESET_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K128M16 JT-125} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
    CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
    CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {2048 MBits} \
    CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
    CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
] $ps7

if { [get_bd_intf_ports -quiet DDR] eq "" } {
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
}
if { [get_bd_intf_ports -quiet FIXED_IO] eq "" } {
    create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
}

connect_bd_intf_net [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
connect_bd_intf_net [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

validate_bd_design
save_bd_design

set wrapper [make_wrapper -files [get_files ${design_name}.bd] -top]
add_files -norecurse $wrapper
set wrapper_file [get_files -quiet *${design_name}_wrapper.v]
if { $wrapper_file ne "" } {
    set_property top ${design_name}_wrapper [current_fileset]
}

update_compile_order -fileset sources_1

set bd_path [get_files ${design_name}.bd]
generate_target all $bd_path

set ip_dir [file join $proj_dir ${proj_name}.srcs sources_1 bd $design_name ip processing_system7_0_0]
puts ""
puts "PS7 Block Design ready: $design_name"
puts "  ps7_init_gpl.c/h -> $ip_dir"
puts "  Sync to Buildroot: ./sync_ps7_init.sh"
puts ""
puts "512 MiB boards: set PCW_DDR_RAM_HIGHADDR to 0x1FFFFFFF in this script,"
puts "  update memory@0 in zynq-antminer-s9.dts, regenerate ps7_init."

if { [catch {write_hw_platform -fixed -force [file join $export_dir ${proj_name}.xsa]} err] } {
    puts "NOTE: write_hw_platform skipped ($err). Export manually if needed."
}

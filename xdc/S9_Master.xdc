## S9_Master.xdc
## Эталон привязки пинов Antminer S9 control board (XC7Z010 CLG400).
## Источник: trebisky/Antminer — board_files/S9_Master.xdc
## https://github.com/trebisky/Antminer
##
## Использование:
##   - раскомментируйте строки для нужных пинов;
##   - имена портов должны совпадать с top-модулем / Block Design wrapper.
##
## Bank 34/35: VCCO = 3.3 V (джамперов нет).

## Четыре зелёных LED на плате (только через PL/EMIO).
## Слева направо на плате: D7, D8, D5, D6.

# Имена по шелкографии / схеме:
#set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { d7_led }];
#set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports { d8_led }];
#set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports { d5_led }];
#set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { d6_led }];

# Те же LED, нейтральные имена:
#set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { led_A }];
#set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports { led_B }];
#set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports { led_C }];
#set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { led_D }];

# Имена, которые Vivado генерирует для EMIO GPIO (PS7 → EMIO → PL pin):
#set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { GPIO_0_tri_io[0] }];
#set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports { GPIO_0_tri_io[1] }];
#set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports { GPIO_0_tri_io[2] }];
#set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { GPIO_0_tri_io[3] }];

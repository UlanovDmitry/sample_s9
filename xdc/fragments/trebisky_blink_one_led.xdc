## Один LED (D7) через PL-порт led
## Источник: trebisky/Antminer — koala/blink-led/constraints.xdc

set_property IOSTANDARD LVCMOS33 [get_ports {led}]
set_property SLEW SLOW [get_ports {led}]
set_property DRIVE 8 [get_ports {led}]

set_property PACKAGE_PIN F16 [get_ports {led}]

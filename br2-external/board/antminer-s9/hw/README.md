# Vivado 2024.2 hardware artifacts for Buildroot



## Два режима загрузки



| Режим | defconfig | Откуда `boot.bin` |

|-------|-----------|-------------------|

| **FSBL (Vitis)** | `antminer_s9_defconfig` | Vitis → `board/antminer-s9/boot.bin` |

| **U-Boot SPL** | `antminer_s9_spl_defconfig` | U-Boot `spl/boot.bin` + `ps7_init_gpl.c` |



## ps7_init_gpl.c / ps7_init_gpl.h



Файлы в `board/antminer-s9/` инициализируют PS7 (DDR, MIO, периферия) в **U-Boot SPL**.



**Текущая копия:** astranome `Astra_S9_FPGA` / `SD_BOOT` (GEM MIO 16–27, UART1 48–49, SDIO, NAND, DDR MT41K128M16, **512 MiB** адресное пространство).



После правки Block Design:



1. `sample_s9/vivado/s9_ps7.tcl` → `sync_ps7_init.sh`

2. `make antminer_s9_spl_defconfig && make`



Подробнее: `sample_s9/vivado/README.md`.



## Minimal PS7 Block Design (S9)



Согласовать MIO с `sample_s9/boot/uboot_bitmain-antminer-s9.dts`:



- UART1 MIO 48–49 (`ttyPS0`, 115200)

- SDIO0 MIO 40–46

- GEM0 RGMII MIO 16–27, MDIO 52–53

- NAND MIO 0–14 (опционально для SD-only)

- DDR: 512 MiB (`0x1FFFFFFF`) или 1 GiB (`0x3FFFFFFF`) — см. `zynq-antminer-s9.dts` `memory@0`



## BOOT.BIN для FSBL-режима (blkf2016-style)



1. **FAT (p1):** `boot.bin` (FSBL), `u-boot.bin`, `boot.scr`

2. **ext4 (p2):** rootfs с `/boot/uImage` и `/boot/zynq-antminer-s9.dtb`



FSBL и `ps7_init` должны описывать **одну и ту же** конфигурацию PS7.



## U-Boot SPL (без Vitis boot.bin)



```bash

export BR2_EXTERNAL=/path/to/sample_s9/br2-external

cd buildroot-2025.02.1

make antminer_s9_spl_defconfig

make

```



Buildroot копирует `ps7_init_gpl.c` в дерево U-Boot (`external.mk`) и задаёт путь через `board/antminer-s9/uboot-spl.config`. `post-build.sh` переименует `spl/boot.bin` → `output/images/boot.bin` для genimage.


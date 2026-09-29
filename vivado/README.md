# Vivado 2024.2 — PS7 Block Design for Antminer S9



Минимальный **PS-only** проект для платы управления S9 (`xc7z010clg400-1`).



Связанный BSP: [`../br2-external/`](../br2-external/README.md) (Buildroot, два режима загрузки).



---



## Дерево файлов



```

vivado/

├── s9_ps7.tcl          # создаёт BD и ps7_init_gpl.c/h

├── sync_ps7_init.sh    # копирует ps7_init в br2-external

├── README.md           # этот файл

├── proj/               # (после запуска) проект Vivado

└── export/             # (опционально) antminer_s9_ps7.xsa

```



---



## `s9_ps7.tcl`



| | |

|---|---|

| **Что это** | Tcl-скрипт Vivado — Block Design **только PS7**, без PL-логики. |

| **Зачем** | Воспроизводимая конфигурация MIO/DDR под S9; генерация `ps7_init_gpl.c/h` для U-Boot SPL. |



**Содержит (MIO):**



| Периферия | MIO | Примечание |

|-----------|-----|------------|

| NAND | 0, 2–14 | как штатная прошивка / KarolNi |

| GEM0 RGMII | 16–27 | PHY в Linux DTS `@1`, `rgmii-id` |

| MDIO | 52–53 | |

| SDIO0 | 40–45, CD 46 | SD-boot |

| UART1 | 48–49 | консоль `ttyPS0`, 115200 |

| MIO GPIO | 37/38/47/51… | LED/кнопки в Linux DTS |

| DDR3 | MT41K128M16 JT-125 | **1 GiB** (`PCW_DDR_RAM_HIGHADDR=0x3FFFFFFF`) |



**Откуда:** KarolNi `P04_SD_BOOT`, astranome `SD_BOOT` (Debian/Ubuntu), `../boot/uboot_bitmain-antminer-s9.dts`.



**Запуск:**



```bash

cd sample_s9/vivado

vivado -mode batch -source s9_ps7.tcl

# или в Tcl-консоли Vivado: source s9_ps7.tcl

```



После выполнения: `proj/antminer_s9_ps7.srcs/.../processing_system7_0_0/ps7_init_gpl.{c,h}`.



---



## `sync_ps7_init.sh`



| | |

|---|---|

| **Что это** | Bash-скрипт — копирует `ps7_init_gpl.c/h` в Buildroot BSP. |

| **Содержит** | Путь по умолчанию к IP-каталогу BD; опциональный аргумент `$1` — другой каталог. |

| **Зачем** | Связка Vivado → `br2-external/board/antminer-s9/` без ручного `cp`. |

| **Откуда** | Написан под `sample_s9`; вызывается после каждой пересборки BD. |



```bash

./sync_ps7_init.sh

# или явно:

./sync_ps7_init.sh proj/antminer_s9_ps7.srcs/sources_1/bd/zynq_antminer_s9/ip/processing_system7_0_0

```



Назначение: `../br2-external/board/antminer-s9/ps7_init_gpl.{c,h}`.



Далее в Buildroot:



```bash

make antminer_s9_spl_defconfig && make

```



---



## `README.md`



| | |

|---|---|

| **Что это** | Документация каталога `sample_s9/vivado/`. |

| **Зачем** | Точка входа для настройки PS7 вне Buildroot; перекрёстные ссылки на defconfig и `hw/README.md`. |



---



## 512 MiB DDR



На многих S9 — 512 MiB (см. `../boot/bootlog_notes.txt`):



1. В `s9_ps7.tcl`: `PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF}`

2. В `../br2-external/board/antminer-s9/zynq-antminer-s9.dts`: `reg = <0x0 0x20000000>`

3. `source s9_ps7.tcl` → `./sync_ps7_init.sh` → `make` с **`antminer_s9_spl_defconfig`**



Текущая bootstrap-копия `ps7_init` в репозитории — под **512 MiB** (astranome SD_BOOT). После первого прогона `s9_ps7.tcl` с 1 GiB обязательно выполните `sync_ps7_init.sh`.



---



## Два режима BSP



| Режим | defconfig | `boot.bin` на FAT |

|-------|-----------|-------------------|

| FSBL из Vivado | `antminer_s9_defconfig` | Vitis FSBL → `board/antminer-s9/boot.bin` |

| U-Boot SPL | `antminer_s9_spl_defconfig` | `spl/boot.bin` из сборки U-Boot + `ps7_init_gpl.c` |



Подробное описание всех файлов BSP: [`../br2-external/README.md`](../br2-external/README.md).


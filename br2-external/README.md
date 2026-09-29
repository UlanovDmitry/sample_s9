# Antminer S9 — Buildroot external tree (BR2_EXTERNAL)

BSP для **Bitmain Antminer S9** (XC7Z010) на стеке **Vivado 2024.2 + Buildroot 2025.02.x**.

| Компонент | Версия |
|-----------|--------|
| Vivado / Vitis | **2024.2** |
| Buildroot | **2025.02.x LTS** |
| Linux | `linux-xlnx` → `xlnx_rebase_v6.6_LTS_merge_6.6.70` |
| U-Boot | `u-boot-xlnx` → `xlnx_rebase_v2024.01_2024.2` |

## Откуда взялся этот каталог

Дерево собрано по образцу [blkf2016/ebaz4205](https://github.com/blkf2016/ebaz4205) (тот же **XC7Z010**, Buildroot + SD boot), но:

- версии toolchain приведены к **Xilinx 2024.2** (как в upstream Buildroot `zynq_zc702_defconfig` 2025.02);
- device tree — из **Antminer S9**, а не EBAZ4205;
- U-Boot DTS — из `sample_s9/boot/uboot_bitmain-antminer-s9.dts` (копия [Xilinx u-boot-xlnx / polprog](https://github.com/Xilinx/u-boot-xlnx/blob/master/arch/arm/dts/bitmain-antminer-s9.dts));
- Linux DTS — расширение U-Boot DTS (GPIO, отключение NAND для SD-only);
- `defconfig` — адаптация blkf2016 + Buildroot 2025.02 Zynq-шаблона.

Buildroot **не знает** плату S9 «из коробки» (есть только ZC702, ZedBoard, MicroZed). Поэтому BSP вынесен в **BR2_EXTERNAL** — отдельное дерево рядом с Buildroot, без правок внутри `buildroot/`.

---

## Дерево файлов

```
br2-external/
├── external.desc              # паспорт BR2_EXTERNAL для Buildroot
├── Config.in                  # заглушка меню Kconfig
├── external.mk                # hook: ps7_init → дерево U-Boot
├── README.md                  # этот файл
├── build.sh                   # обёртка: defconfig + make
├── configs/
│   ├── antminer_s9_defconfig      # FSBL boot.bin из Vivado
│   └── antminer_s9_spl_defconfig  # U-Boot SPL + ps7_init (без Vitis)
└── board/antminer-s9/
    ├── zynq-antminer-s9.dts   # Device Tree для Linux
    ├── ps7_init_gpl.c         # PS7 init для U-Boot SPL
    ├── ps7_init_gpl.h
    ├── ps7_init_gpl.SOURCE    # откуда взята копия / как обновить
    ├── uboot-spl.config       # Kconfig-фрагмент: CONFIG_XILINX_PS_INIT_FILE
    ├── uboot.patch            # патч U-Boot: добавить DTS платы
    ├── uboot-boot-script.txt  # сценарий загрузки → boot.scr
    ├── genimage.cfg           # разметка SD → sdcard.img
    ├── post-build.sh          # после rootfs: boot.bin, /boot/*
    ├── post-image.sh          # вызов genimage
    ├── .gitignore             # не коммитить boot.bin / bitstream
    ├── boot.bin               # (вы добавляете) FSBL из Vivado
    ├── hw/
    │   └── README.md          # как получить boot.bin / ps7_init
    └── rootfs_overlay/
        └── etc/network/
            └── interfaces     # DHCP на eth0

sample_s9/vivado/              # вне BR2_EXTERNAL, рядом с br2-external
├── s9_ps7.tcl                 # TCL Block Design PS7 (Vivado 2024.2)
├── sync_ps7_init.sh           # ps7_init → board/antminer-s9/
└── README.md                  # инструкция Vivado / DDR / SPL
```

---

## Файлы корня `br2-external/`

### `external.desc`

| | |
|---|---|
| **Что это** | Обязательный «паспорт» внешнего дерева Buildroot. |
| **Содержит** | Две строки: `name: ANTMINER_S9` и краткое описание. |
| **Зачем** | При `export BR2_EXTERNAL=...` Buildroot регистрирует дерево, создаёт переменную `BR2_EXTERNAL_ANTMINER_S9_PATH` и подхватывает `configs/*_defconfig` и `board/`. |
| **Откуда** | Стандарт [Buildroot BR2_EXTERNAL](https://buildroot.org/downloads/manual/manual.html#outside-br-custom). Имя `ANTMINER_S9` выбрано явно под плату. |

### `Config.in`

| | |
|---|---|
| **Что это** | Корень меню Kconfig для внешнего дерева (может быть пустым). |
| **Содержит** | Комментарии-указатели на `board/antminer-s9/` и defconfig. |
| **Зачем** | Buildroot требует файл; здесь нет своих опций `menuconfig` — вся конфигурация в `antminer_s9_defconfig`. |
| **Откуда** | Минимальный шаблон из документации Buildroot; расширять при добавлении пакетов через `BR2_EXTERNAL`. |

### `external.mk`

| | |
|---|---|
| **Что это** | Makefile-фрагмент для hook'ов сборки. |
| **Содержит** | `UBOOT_POST_PATCH_HOOKS`: копирует `ps7_init_gpl.c/h` в `u-boot/.../board/xilinx/zynq/antminer_s9/` перед сборкой SPL. |
| **Зачем** | U-Boot SPL требует `ps7_init` внутри дерева исходников; путь задаёт `uboot-spl.config`. |
| **Откуда** | Аналог `BR2_TARGET_UBOOT_ZYNQ_PS7_INIT_FILE` (Buildroot master); работает на 2025.02.1 без патча Buildroot. |

### `build.sh`

| | |
|---|---|
| **Что это** | Bash-обёртка для быстрой сборки. |
| **Содержит** | `export BR2_EXTERNAL`, `make $DEFCONFIG`, `make -j$(nproc)`. По умолчанию `antminer_s9_defconfig`; SPL: `DEFCONFIG=antminer_s9_spl_defconfig ./build.sh`. |
| **Зачем** | Не обязателен для Buildroot; удобство: одна команда вместо ручного export. |
| **Откуда** | Написан под этот репозиторий; путь к Buildroot переопределяется `BUILDROOT_DIR=...`. |

### `README.md`

| | |
|---|---|
| **Что это** | Документация BSP (этот файл). |
| **Зачем** | Описание файлов, сборки, boot chain, связи с `sample_s9/`. |

---

## `configs/antminer_s9_defconfig`

| | |
|---|---|
| **Что это** | Главный **манифест сборки** — снимок `make menuconfig` для платы S9. |
| **Зачем** | Одна команда `make antminer_s9_defconfig` воспроизводит всю конфигурацию: архитектура, ядро, U-Boot, пакеты, скрипты. |

**Содержит (группы опций):**

| Группа | Ключевые строки | Назначение |
|--------|-----------------|------------|
| CPU | `BR2_arm`, `BR2_cortex_a9`, NEON/VFP | Zynq-7010 — dual Cortex-A9 |
| Заголовки ядра | `BR2_PACKAGE_HOST_LINUX_HEADERS_CUSTOM_6_6` | Согласование с Linux 6.6 |
| Патчи Xilinx | `BR2_GLOBAL_PATCH_DIR="board/xilinx/patches"` | Патчи из **основного** Buildroot для Zynq |
| Система | hostname `antminer-s9`, пароль `root`, DHCP `eth0` | Базовая идентификация и сеть |
| Overlay / скрипты | `BR2_ROOTFS_OVERLAY`, `POST_BUILD`, `POST_IMAGE` | Файлы rootfs и hook'и |
| **Linux** | tarball `linux-xlnx` 6.6, `defconfig xilinx_zynq`, `CUSTOM_DTS_PATH` → `zynq-antminer-s9.dts`, `UIMAGE` | Сборка `uImage` + DTB платы |
| **Пакеты** | openssh, bash, dhcpcd, ethtool, htop, e2fsprogs… | Минимальный рабочий rootfs |
| **Rootfs** | ext4 128M | Второй раздел SD |
| **U-Boot** | tarball `u-boot-xlnx` 2024.2, patch, `DEVICE_TREE=zynq-antminer-s9`, `boot.scr` | Загрузчик под S9 |
| **Host** | genimage, dosfstools, mtools | Сборка `sdcard.img` |

**Откуда:**

1. Каркас Zynq — из `buildroot-2025.02/configs/zynq_zc702_defconfig` (версии linux/u-boot 2024.2).
2. Пути `board/antminer-s9/*`, overlay, post-скрипты — по аналогии с `blkf2016/.../zynq-ebaz4205_defconfig`.
3. Список пакетов — упрощённый blkf2016 (без dnsmasq/genimage-специфики EBAZ).

После `make menuconfig` сохранять изменения:

```bash
make savedefconfig BR2_DEFCONFIG=$BR2_EXTERNAL/configs/antminer_s9_defconfig
```

---

## `configs/antminer_s9_spl_defconfig`

| | |
|---|---|
| **Что это** | Вариант манифеста сборки **без Vitis FSBL** — первая стадия загрузки из **U-Boot SPL**. |
| **Зачем** | Не нужен Vitis/`boot.bin` на хосте: `boot.bin` на FAT собирает Buildroot из `ps7_init_gpl.c` + SPL. |

**Отличия от `antminer_s9_defconfig`:**

| Группа | Ключевые строки | Назначение |
|--------|-----------------|------------|
| U-Boot SPL | `BR2_TARGET_UBOOT_SPL=y` | Включить сборку SPL |
| Имя SPL | `BR2_TARGET_UBOOT_SPL_NAME="spl/boot.bin"` | Артефакт в `output/images/spl/` |
| ps7_init | `BR2_TARGET_UBOOT_CONFIG_FRAGMENT_FILES` → `uboot-spl.config` | Путь к `ps7_init_gpl.c` в Kconfig U-Boot |
| Issue | `Antminer S9 Buildroot (sample_s9, SPL boot)` | Метка в `/etc/issue` |

Linux, rootfs, пакеты, `genimage`, `post-build.sh` — **идентичны** `antminer_s9_defconfig`.

**Откуда:** копия `antminer_s9_defconfig` + опции SPL из `buildroot/configs/zynq_zc702_defconfig` и `zynq_zed_defconfig`; ps7_init — по схеме [board/zynq/readme.txt](https://github.com/buildroot/buildroot/tree/master/board/zynq) (Buildroot master).

Сохранение после `menuconfig`:

```bash
make savedefconfig BR2_DEFCONFIG=$BR2_EXTERNAL/configs/antminer_s9_spl_defconfig
```

Сборка:

```bash
make antminer_s9_spl_defconfig && make
# или: DEFCONFIG=antminer_s9_spl_defconfig ./build.sh
```

---

## `sample_s9/vivado/` — Block Design и ps7_init

Каталог **вне** BR2_EXTERNAL; пути в defconfig на него не ссылаются — только человекочитаемая связка Vivado ↔ BSP.

### `sample_s9/vivado/s9_ps7.tcl`

| | |
|---|---|
| **Что это** | Vivado **Tcl-скрипт** — создаёт PS-only Block Design под Antminer S9. |
| **Зачем** | Воспроизводимая настройка PS7 (MIO, DDR, периферия); источник истины для `ps7_init_gpl.c/h`. |

**Содержит:**

- проверку версии Vivado **2024.2** (предупреждение при другой версии);
- проект `antminer_s9_ps7`, part **`xc7z010clg400-1`**;
- BD `zynq_antminer_s9` с `processing_system7_0` и портами DDR / FIXED_IO;
- `CONFIG.PCW_*`: NAND 0–14, GEM0 MIO 16–27, MDIO 52–53, SD 40–46, UART1 48–49, MIO GPIO, DDR **MT41K128M16 JT-125**, `PCW_DDR_RAM_HIGHADDR=0x3FFFFFFF` (1 GiB);
- `generate_target all` → `ps7_init_gpl.c/h` в `proj/.../processing_system7_0_0/`;
- опционально `write_hw_platform` → `export/antminer_s9_ps7.xsa`.

**Откуда:** MIO/NAND/SD/UART — KarolNi `P04_SD_BOOT`; GEM — astranome `SD_BOOT` (Debian/Ubuntu); сверка с `sample_s9/boot/uboot_bitmain-antminer-s9.dts`.

**Запуск:**

```bash
cd sample_s9/vivado
vivado -mode batch -source s9_ps7.tcl
```

### `sample_s9/vivado/sync_ps7_init.sh`

| | |
|---|---|
| **Что это** | Bash-скрипт копирования `ps7_init_gpl.c/h` из выхода Vivado в BSP. |
| **Содержит** | Путь по умолчанию `proj/.../zynq_antminer_s9/ip/processing_system7_0_0/`; аргумент `$1` — другой каталог IP. |
| **Зачем** | После правки `s9_ps7.tcl` или DDR — одна команда обновляет файлы для `antminer_s9_spl_defconfig`. |
| **Откуда** | Написан под этот репозиторий; аналог ручного копирования из PetaLinux/Vitis flow. |

```bash
./sync_ps7_init.sh
# затем в Buildroot:
make antminer_s9_spl_defconfig && make
```

### `sample_s9/vivado/README.md`

| | |
|---|---|
| **Что это** | Краткая инструкция по Vivado-части (MIO-таблица, 512 MiB vs 1 GiB, два режима BSP). |
| **Зачем** | Точка входа для инженера, который не читает весь `br2-external/README.md`. |
| **Откуда** | Дополнение к этому файлу; перекрёстные ссылки на defconfig и `hw/README.md`. |

---

## `board/antminer-s9/` — платформенные файлы

Все пути в defconfig (`board/antminer-s9/...`) резолвятся **от корня BR2_EXTERNAL**, не от Buildroot.

### `zynq-antminer-s9.dts`

| | |
|---|---|
| **Что это** | **Device Tree Source** для **ядра Linux** — описание железа для драйверов. |
| **Зачем** | Buildroot компилирует его в `zynq-antminer-s9.dtb`; ядро узнаёт UART, Ethernet, SD, RAM, GPIO. |

**Содержит:**

- `compatible = "bitmain,antminer-s9"` — идентификатор платы;
- `memory@0` — **1 GiB** (`0x40000000`); для 512 MiB → `0x20000000`;
- `reserved-memory` — области bootcount и fpga (как в U-Boot DTS);
- `&gem0` — Ethernet **RGMII** + PHY @1;
- `&sdhci0`, `&uart1` — SD и консоль **115200**;
- `gpio-leds` / `gpio-keys` — LED и кнопки S1/S2 (MIO из KarolNi P02);
- `&nfc0`, `&smcc` — **disabled** (SD-boot без NAND).

**Откуда:**

- Основа — `sample_s9/boot/uboot_bitmain-antminer-s9.dts` (Xilinx / polprog);
- Добавлены GPIO и отключение NAND;
- `#include <dt-bindings/gpio/gpio.h>` — для `GPIO_ACTIVE_*` в Linux 6.x.

U-Boot и Linux **разделяют** смысл DTS, но файлы разные: U-Boot — в `uboot.patch`, Linux — здесь.

### `uboot.patch`

| | |
|---|---|
| **Что это** | Git-патч, накладываемый на исходники **U-Boot** при сборке. |
| **Зачем** | В upstream U-Boot **нет** `zynq-antminer-s9.dts`; патч добавляет файл и строку в `arch/arm/dts/Makefile`. |

**Содержит:**

1. Правку `Makefile` — сборка `zynq-antminer-s9.dtb`;
2. Новый файл `arch/arm/dts/zynq-antminer-s9.dts` — U-Boot-вариант (с `u-boot,dm-pre-reloc`, NAND enabled, без gpio-leds).

**Откуда:** структура как `blkf2016/.../uboot.patch`; содержимое DTS — копия `sample_s9/boot/uboot_bitmain-antminer-s9.dts` с переименованием в `zynq-antminer-s9.dts`.

> Если `patch` не применится (изменился Makefile в новой версии U-Boot), обновите контекст diff вручную.

### `uboot-spl.config`

| | |
|---|---|
| **Что это** | **Kconfig-фрагмент** U-Boot — дополнение к `xilinx_zynq_virt_defconfig`. |
| **Содержит** | Одну строку: `CONFIG_XILINX_PS_INIT_FILE="board/xilinx/zynq/antminer_s9/ps7_init_gpl.c"`. |
| **Зачем** | U-Boot SPL компилирует и линкует указанный `ps7_init_gpl.c` вместо встроенного ps7 для ZC702/ZedBoard. |
| **Откуда** | Опция `XILINX_PS_INIT_FILE` в `u-boot-xlnx` `board/xilinx/Kconfig`; путь совпадает с каталогом, куда `external.mk` копирует файлы. |

Подключается только в **`antminer_s9_spl_defconfig`** через `BR2_TARGET_UBOOT_CONFIG_FRAGMENT_FILES`. В режиме FSBL (`antminer_s9_defconfig`) не используется — ps7_init выполняет FSBL из Vitis `boot.bin`.

### `ps7_init_gpl.c` / `ps7_init_gpl.h`

| | |
|---|---|
| **Что это** | **GPL-версия ps7_init** — C-код инициализации PS7 (DDR, PLL, MIO, включение периферии). |
| **Зачем** | Без корректного ps7_init SPL **не поднимет DDR** и загрузка с SD оборвётся сразу после Boot ROM. |

**Содержит:**

- `ps7_init()` / `ps7_post_config()` — таблицы записей в регистры PS7;
- тайминги и training **DDR3** под конкретный Block Design;
- настройку MIO под NAND, Ethernet, SD, UART (как в BD-источнике).

**Откуда (текущая копия в репозитории):**

- bootstrap: astranome `Astra_S9_FPGA` / `Examples/Debian_Ubuntu/Simple_Project/SD_BOOT` → `zynq_processing_system7_0_0/ps7_init_gpl.{c,h}`;
- BD источника: GEM MIO 16–27, UART1 48–49, SDIO, NAND, **512 MiB** (`PCW_DDR_RAM_HIGHADDR=0x1FFFFFFF`).

**Обновление:** после `s9_ps7.tcl` → `./sync_ps7_init.sh`. Подробности — `ps7_init_gpl.SOURCE`.

> Файлы **коммитятся** в Git (в отличие от `boot.bin`): без них SPL-сборка не воспроизводится «из коробки».

### `ps7_init_gpl.SOURCE`

| | |
|---|---|
| **Что это** | Текстовая **метка происхождения** `ps7_init_gpl.c/h` (не участвует в сборке). |
| **Содержит** | Путь к astranome SD_BOOT; команды Vivado/sync; предупреждение 512 MiB vs 1 GiB. |
| **Зачем** | Не забыть перегенерировать ps7_init после смены MIO/DDR; не путать bootstrap-копию с выходом `s9_ps7.tcl`. |
| **Откуда** | Добавлен при появлении SPL-пути в BSP. |

### `uboot-boot-script.txt`

| | |
|---|---|
| **Что это** | Текст **U-Boot boot script** (формат `mkimage -T script`). |
| **Зачем** | Buildroot превращает его в `boot.scr`; U-Boot выполняет после `u-boot.bin`. |

**Содержит:**

```
ext4load mmc 0:2 0x2000000 /boot/uImage
ext4load mmc 0:2 0x1f00000 /boot/zynq-antminer-s9.dtb
setenv bootargs "console=ttyPS0,115200 root=/dev/mmcblk0p2 rootwait"
bootm 0x2000000 - 0x1f00000
```

Ядро и DTB лежат на **ext4**, раздел 2, каталог `/boot/` (копирует `post-build.sh`).

**Откуда:** схема **blkf2016** (`ext4load` + `root=/dev/mmcblk0p2`); имена файлов заменены на `uImage` / `zynq-antminer-s9.dtb`.

### `genimage.cfg`

| | |
|---|---|
| **Что это** | Конфиг утилиты **genimage** — собирает образ всей SD-карты. |
| **Зачем** | На выходе один файл `output/images/sdcard.img` для записи через `dd` / Win32 Disk Imager. |

**Содержит:**

| Образ | Содержимое |
|-------|------------|
| `boot.vfat` (16 MiB) | `boot.bin`, `u-boot.bin`, `boot.scr` |
| `rootfs.ext4` | rootfs из Buildroot |
| `sdcard.img` | раздел 1 = FAT (bootable), раздел 2 = ext4 |

**Откуда:** `blkf2016/.../genimage.cfg`; размер FAT увеличен до 16M; убраны лишние файлы с FAT (ядро на ext4, не на FAT).

### `post-build.sh`

| | |
|---|---|
| **Что это** | Hook Buildroot: выполняется **после** сборки rootfs, **до** `post-image`. |
| **Зачем** | Подготовить файлы для SD и каталог `/boot` внутри rootfs. |

**Делает:**

1. **`boot.bin` для genimage** (приоритет):
   - **`output/images/spl/boot.bin`** — режим SPL (`antminer_s9_spl_defconfig`);
   - иначе **`board/antminer-s9/boot.bin`** — FSBL из Vitis;
   - иначе **WARNING** (образ SD соберётся без рабочей первой стадии);
2. копирует выбранный `boot.bin` → **`output/images/boot.bin`** (имя ожидает `genimage.cfg`);
3. создаёт **`target/boot/`**;
4. копирует в rootfs: `boot.scr`, `uImage`, `zynq-antminer-s9.dtb`.

**Откуда:** упрощённый `blkf2016/.../post-build.sh`; ветка SPL добавлена под `antminer_s9_spl_defconfig`.

### `post-image.sh`

| | |
|---|---|
| **Что это** | Hook после всех образов; вызывает **genimage**. |
| **Зачем** | Собрать `sdcard.img` из `boot.bin`, `u-boot.bin`, `boot.scr`, `rootfs.ext4`. |

**Содержит:** вызов `genimage --rootpath ... --inputpath ... --config genimage.cfg`.

**Откуда:** один в один по структуре blkf2016.

### `.gitignore`

| | |
|---|---|
| **Что это** | Исключения для Git в каталоге платы. |
| **Содержит** | `boot.bin`, `*.bit` |
| **Зачем** | Бинарники из Vivado не коммитят (размер, лицензия, у каждого своя прошивка). |

### `boot.bin` *(файл добавляете вы)*

| | |
|---|---|
| **Что это** | **BOOT.BIN** — образ для Boot ROM Zynq (первая стадия загрузки). |
| **Содержит** | Обычно **FSBL** (+ опционально bitstream PL); в схеме blkf2016 U-Boot грузится с FAT отдельно. |
| **Зачем** | Без него Boot ROM не стартует; на FAT первого раздела обязателен. |
| **Откуда** | **Vitis 2024.2** → Create Boot Image из FSBL вашего Block Design. Не собирается Buildroot. См. `hw/README.md`. |

---

## `board/antminer-s9/hw/README.md`

| | |
|---|---|
| **Что это** | Инструкция по **аппаратным артефактам** вне Buildroot. |
| **Содержит** | Таблицу двух режимов (FSBL vs SPL); откуда брать `boot.bin` / `ps7_init`; MIO PS7; команды `antminer_s9_spl_defconfig`. |
| **Зачем** | Краткая шпаргалка «что положить в `board/antminer-s9/`»; ссылки на `sample_s9/vivado/`. |
| **Откуда** | blkf2016 + `fpga_docs` (MIO S9, KarolNi BD) + SPL-путь из этого BSP. |

---

## `board/antminer-s9/rootfs_overlay/etc/network/interfaces`

| | |
|---|---|
| **Что это** | Файл **overlay** — накладывается на rootfs при сборке. |
| **Содержит** | `lo` loopback; `eth0` **DHCP** (согласовано с `BR2_SYSTEM_DHCP="eth0"` в defconfig). |
| **Зачем** | Ethernet поднимается после загрузки без ручной настройки. |
| **Откуда** | Упрощённый вариант `blkf2016/.../rootfs_overlay/etc/network/interfaces` (там был статический IP + dnsmasq). |

---

## Что Buildroot производит (не в репозитории)

После `make` в `buildroot/output/images/`:

| Артефакт | FSBL (`antminer_s9_defconfig`) | SPL (`antminer_s9_spl_defconfig`) |
|----------|--------------------------------|-----------------------------------|
| `uImage` | Linux 6.6 + `zynq-antminer-s9.dts` | то же |
| `zynq-antminer-s9.dtb` | компиляция DTS | то же |
| `u-boot.bin` | U-Boot 2024.2 + `uboot.patch` | то же |
| `boot.scr` | `uboot-boot-script.txt` | то же |
| `rootfs.ext4` | rootfs + overlay | то же |
| `spl/boot.bin` | — | U-Boot SPL + `ps7_init_gpl.c` |
| `boot.bin` | Vitis FSBL → `post-build.sh` | копия `spl/boot.bin` → `post-build.sh` |
| **`sdcard.img`** | genimage | genimage |

---

## Сборка

**Вариант A — FSBL из Vivado (как blkf2016):**

```bash
export BR2_EXTERNAL=/path/to/sample_s9/br2-external
cd buildroot-2025.02.1
make antminer_s9_defconfig && make
# + положить board/antminer-s9/boot.bin из Vitis, снова make
```

**Вариант B — U-Boot SPL (без Vitis boot.bin):**

```bash
make antminer_s9_spl_defconfig && make
```

Или: `cd br2-external && ./build.sh` / `DEFCONFIG=antminer_s9_spl_defconfig ./build.sh`.

### Перед первой прошивкой SD

1. **A:** `boot.bin` из Vitis в `board/antminer-s9/`. **B:** достаточно `ps7_init_gpl.c` (уже в репозитории; обновить из Vivado при смене MIO/DDR).
2. Boot jumpers → **SD** (`sample_s9/boot_mode/boot_jumpers.txt`).
3. UART **115200 8N1**, `ttyPS0`.
4. При **512 MB DDR** — правка `memory@0` в `zynq-antminer-s9.dts` и `s9_ps7.tcl` (`PCW_DDR_RAM_HIGHADDR`).

---

## Цепочка загрузки

**FSBL (antminer_s9_defconfig):**

```
Boot ROM → boot.bin (Vitis FSBL) → u-boot.bin → boot.scr → uImage + .dtb → Linux
```

**SPL (antminer_s9_spl_defconfig):**

```
Boot ROM → boot.bin (U-Boot SPL + ps7_init) → u-boot.bin → boot.scr → uImage + .dtb → Linux
```

---

## Связь с остальным `sample_s9/`

| Файл в sample_s9 | Роль для br2-external |
|------------------|------------------------|
| `boot/uboot_bitmain-antminer-s9.dts` | **Первоисточник** U-Boot/Linux периферии PS |
| `boot/bootlog_stock_nand.log` | Эталон RAM, UART, Ethernet штатной прошивки |
| `boot/bootlog_notes.txt` | Выжимка для сверки DTS |
| `vivado/s9_ps7.tcl` | TCL Block Design PS7; генерирует ps7_init |
| `vivado/sync_ps7_init.sh` | Копирует ps7_init в `br2-external/board/antminer-s9/` |
| `vivado/README.md` | Инструкция Vivado (MIO, DDR, SPL) |
| `pinout/`, `xdc/` | Vivado stage 1 (не входят в Buildroot) |
| `tools/versions.txt` | Зафиксирован стек 2024.2 / 2025.02 |
| `STAGE0.txt` | Указатель на этот каталог |

---

## Настройка

```bash
make menuconfig
make linux-menuconfig
make uboot-menuconfig
make savedefconfig BR2_DEFCONFIG=$BR2_EXTERNAL/configs/antminer_s9_defconfig
# для SPL-варианта:
make savedefconfig BR2_DEFCONFIG=$BR2_EXTERNAL/configs/antminer_s9_spl_defconfig
```

Дополнительно: [fpga_docs/tutor/BSP - Buildroot.md](../../../fpga_docs/tutor/BSP%20-%20Buildroot.md), [blkf2016/ebaz4205](https://github.com/blkf2016/ebaz4205).

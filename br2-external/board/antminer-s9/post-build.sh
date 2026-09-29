#!/bin/sh
#
# Post-build: stage boot.bin for genimage and copy boot artifacts into rootfs /boot.
#
# boot.bin sources (first match wins):
#   1. U-Boot SPL  -> output/images/spl/boot.bin  (antminer_s9_spl_defconfig)
#   2. Vitis FSBL  -> board/antminer-s9/boot.bin    (antminer_s9_defconfig)
#

set -e

BOARD_DIR="$(dirname "$0")"
BOOT_BIN=""

if [ -f "${BINARIES_DIR}/spl/boot.bin" ]; then
	cp -fv "${BINARIES_DIR}/spl/boot.bin" "${BINARIES_DIR}/boot.bin"
	echo "Using U-Boot SPL boot.bin from spl/boot.bin"
elif [ -f "${BOARD_DIR}/boot.bin" ]; then
	cp -fv "${BOARD_DIR}/boot.bin" "${BINARIES_DIR}/boot.bin"
	echo "Using external FSBL boot.bin from board/antminer-s9/"
else
	echo ""
	echo "WARNING: no boot.bin for SD partition 1."
	echo "  SPL path: make antminer_s9_spl_defconfig (needs ps7_init_gpl.c in board/antminer-s9/)"
	echo "  FSBL path: copy Vitis boot.bin to board/antminer-s9/boot.bin"
	echo "  See br2-external/README.md and sample_s9/vivado/README.md"
	echo ""
fi

mkdir -p "${TARGET_DIR}/boot"

if [ -e "${BINARIES_DIR}/boot.scr" ]; then
	cp -fv "${BINARIES_DIR}/boot.scr" "${TARGET_DIR}/boot/boot.scr"
fi

if [ -e "${BINARIES_DIR}/uImage" ]; then
	cp -fv "${BINARIES_DIR}/uImage" "${TARGET_DIR}/boot/uImage"
fi

if [ -e "${BINARIES_DIR}/zynq-antminer-s9.dtb" ]; then
	cp -fv "${BINARIES_DIR}/zynq-antminer-s9.dtb" "${TARGET_DIR}/boot/zynq-antminer-s9.dtb"
fi

exit 0

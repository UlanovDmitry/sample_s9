#!/usr/bin/env bash
# Build Antminer S9 image using Buildroot 2025.02.1 + this BR2_EXTERNAL tree.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BR2_EXTERNAL="${SCRIPT_DIR}"
BUILDROOT_DIR="${BUILDROOT_DIR:-${SCRIPT_DIR}/../buildroot-2025.02.1}"
DEFCONFIG="${DEFCONFIG:-antminer_s9_defconfig}"

if [ ! -f "${BUILDROOT_DIR}/Makefile" ]; then
	echo "Buildroot not found at: ${BUILDROOT_DIR}" >&2
	echo "Download buildroot-2025.02.1.tar.xz from https://buildroot.org/download.html" >&2
	echo "Extract to: ${BUILDROOT_DIR}" >&2
	exit 1
fi

export BR2_EXTERNAL

cd "${BUILDROOT_DIR}"
make "${DEFCONFIG}"
make -j"$(nproc)"

echo ""
echo "Done. Image: ${BUILDROOT_DIR}/output/images/sdcard.img"
case "${DEFCONFIG}" in
	*_spl_defconfig)
		if [ ! -f "${BUILDROOT_DIR}/output/images/spl/boot.bin" ]; then
			echo "WARNING: spl/boot.bin missing — check U-Boot build / ps7_init_gpl.c" >&2
		fi
		;;
	*)
		if [ ! -f "${BR2_EXTERNAL}/board/antminer-s9/boot.bin" ] && \
		   [ ! -f "${BUILDROOT_DIR}/output/images/boot.bin" ]; then
			echo "WARNING: boot.bin missing — add FSBL or use DEFCONFIG=antminer_s9_spl_defconfig" >&2
		fi
		;;
esac

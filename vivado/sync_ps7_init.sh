#!/usr/bin/env bash
# Copy ps7_init_gpl.c/h from Vivado PS7 IP output into br2-external.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SRC="${SCRIPT_DIR}/proj/antminer_s9_ps7.srcs/sources_1/bd/zynq_antminer_s9/ip/processing_system7_0_0"
SRC="${1:-${DEFAULT_SRC}}"
DST="${SCRIPT_DIR}/../br2-external/board/antminer-s9"

for f in ps7_init_gpl.c ps7_init_gpl.h; do
	if [ ! -f "${SRC}/${f}" ]; then
		echo "Missing ${SRC}/${f}" >&2
		echo "Run Vivado first: cd sample_s9/vivado && vivado -mode batch -source s9_ps7.tcl" >&2
		exit 1
	fi
done

cp -fv "${SRC}/ps7_init_gpl.c" "${SRC}/ps7_init_gpl.h" "${DST}/"
echo "Updated ${DST}/ps7_init_gpl.{c,h}"

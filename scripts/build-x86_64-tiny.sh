#!/bin/sh
set -eu
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BR_DIR="$ROOT_DIR/buildroot"
OUT_DIR="$ROOT_DIR/out/x86_64-tiny"
[ -d "$BR_DIR" ] || { echo "Run bootstrap first"; exit 1; }
make -C "$BR_DIR" O="$OUT_DIR" BR2_DEFCONFIG="$ROOT_DIR/configs/roro_defconfig" defconfig
make -C "$BR_DIR" O="$OUT_DIR" -j"$(nproc)"

# sanity: ensure target arch resolved to x86_64
if ! grep -q '^BR2_x86_64=y' "$OUT_DIR/.config"; then
  echo "ERROR: Buildroot .config did not resolve to x86_64 target"
  grep '^BR2_x86' "$OUT_DIR/.config" || true
  exit 1
fi
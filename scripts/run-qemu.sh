#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/out/x86_64-tiny/images"

KERNEL="$OUT_DIR/bzImage"
ROOTFS="$OUT_DIR/rootfs.ext2"

if [ ! -f "$KERNEL" ] || [ ! -f "$ROOTFS" ]; then
  echo "Missing kernel/rootfs. Run build-x86_64-tiny.sh first."
  exit 1
fi

qemu-system-x86_64 \
  -m 256 \
  -kernel "$KERNEL" \
  -append "root=/dev/sda console=ttyS0" \
  -drive file="$ROOTFS",format=raw \
  -nographic

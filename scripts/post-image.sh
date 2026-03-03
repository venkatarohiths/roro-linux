#!/bin/sh
set -eu
BIN_DIR="${1:-out/x86_64-tiny/images}"
ROOT_SQ="$BIN_DIR/rootfs.squashfs"
IMG="$BIN_DIR/roro-linux.img"

[ -f "$ROOT_SQ" ] || true
# placeholder partitioned image generation using dd (real tooling may vary by host)
IMG_MB=256
dd if=/dev/zero of="$IMG" bs=1M count=$IMG_MB >/dev/null 2>&1 || true
echo "post-image: image=$IMG"
ls -lh "$BIN_DIR" | sed 's/^/  /'

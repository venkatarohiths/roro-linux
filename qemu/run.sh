#!/usr/bin/env bash
set -euo pipefail
IMG_DIR="${1:-out/x86_64-tiny/images}"
KERNEL="$IMG_DIR/bzImage"
INITRD="$IMG_DIR/rootfs.cpio"
[ -f "$INITRD" ] || INITRD="$IMG_DIR/rootfs.cpio.gz"
qemu-system-x86_64 -m 512 -kernel "$KERNEL" -initrd "$INITRD" -append "console=ttyS0" -nographic

#!/usr/bin/env bash
set -euo pipefail

IMG_DIR="${1:-out/x86_64-tiny/images}"
OUT_ISO="${2:-out/x86_64-tiny/images/roro-linux-live.iso}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

KERNEL="$IMG_DIR/bzImage"
if [[ -f "$IMG_DIR/rootfs.cpio" ]]; then
  INITRD="$IMG_DIR/rootfs.cpio"
elif [[ -f "$IMG_DIR/rootfs.cpio.gz" ]]; then
  INITRD="$IMG_DIR/rootfs.cpio.gz"
else
  echo "FAIL: rootfs.cpio or rootfs.cpio.gz not found in $IMG_DIR"
  exit 1
fi

[[ -f "$KERNEL" ]] || { echo "FAIL: bzImage not found in $IMG_DIR"; exit 1; }

mkdir -p "$WORK/iso/boot/grub"
cp "$KERNEL" "$WORK/iso/boot/bzImage"
cp "$INITRD" "$WORK/iso/boot/$(basename "$INITRD")"

cat > "$WORK/iso/boot/grub/grub.cfg" <<EOF
set timeout=3
set default=0
menuentry "Roro Linux Live" {
  linux /boot/bzImage root=/dev/ram0 rw console=ttyS0 console=tty0
  initrd /boot/$(basename "$INITRD")
}
EOF

mkdir -p "$(dirname "$OUT_ISO")"
grub-mkrescue -o "$OUT_ISO" "$WORK/iso" >/dev/null 2>&1

echo "Created ISO: $OUT_ISO"

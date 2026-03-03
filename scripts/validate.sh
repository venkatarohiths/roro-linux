#!/bin/sh
set -eu
req_files="configs/roro_defconfig configs/linux.config configs/busybox.config overlay/etc/fstab overlay/etc/inittab scripts/post-build.sh scripts/post-image.sh"
for f in $req_files; do
  [ -f "$f" ] || { echo "ERROR: missing $f"; exit 1; }
done
if find overlay -type f -perm -0002 | grep -q .; then
  echo "ERROR: world-writable file in overlay"; exit 1
fi
for s in scripts/*.sh qemu/*.sh; do
  [ -f "$s" ] && sh -n "$s"
done
echo "validate: OK"

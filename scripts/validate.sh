#!/bin/sh
set -eu

req_files="configs/roro_defconfig configs/linux.config configs/busybox.config overlay/etc/fstab overlay/etc/inittab scripts/post-build.sh scripts/post-image.sh build.sh"
for f in $req_files; do
  [ -f "$f" ] || { echo "ERROR: missing $f"; exit 1; }
  [ -s "$f" ] || { echo "ERROR: empty file $f"; exit 1; }
done

if find overlay -type f -perm -0002 | grep -q .; then
  echo "ERROR: world-writable file in overlay"
  exit 1
fi

for s in scripts/*.sh qemu/*.sh build.sh; do
  [ -f "$s" ] && sh -n "$s"
done

# Guard against CRLF in shell scripts (can break shebang/portable tooling in Linux builds)
crlf_count=0
for s in scripts/*.sh qemu/*.sh build.sh; do
  [ -f "$s" ] || continue
  if LC_ALL=C grep -q "$(printf '\r')" "$s"; then
    echo "ERROR: CRLF detected in $s (convert to LF)"
    crlf_count=$((crlf_count + 1))
  fi
done

if [ "$crlf_count" -gt 0 ]; then
  exit 1
fi

echo "validate: OK"
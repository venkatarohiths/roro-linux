#!/usr/bin/env bash
set -euo pipefail
required=(
  "configs/roro_x86_64_tiny_defconfig"
  "scripts/build-x86_64-tiny.sh"
  "overlay/etc/motd"
)
for f in "${required[@]}"; do
  [ -e "$f" ] || { echo "Missing: $f"; exit 1; }
done
echo "validate.sh: OK"

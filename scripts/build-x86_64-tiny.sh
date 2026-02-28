#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BR_DIR="$ROOT_DIR/buildroot"
OUT_DIR="$ROOT_DIR/out/x86_64-tiny"

if [ ! -d "$BR_DIR" ]; then
  echo "Buildroot missing. Run scripts/bootstrap-buildroot.sh first."
  exit 1
fi

mkdir -p "$OUT_DIR"

cd "$BR_DIR"
make O="$OUT_DIR" qemu_x86_64_defconfig

# Minimal footprint tweaks
cat >> "$OUT_DIR/.config" <<'EOF'
BR2_PACKAGE_BUSYBOX_SHOW_OTHERS=y
# Keep toolchain/userland minimal
BR2_INIT_BUSYBOX=y
BR2_ROOTFS_OVERLAY="../overlay"
BR2_TARGET_GENERIC_HOSTNAME="pothuri"
BR2_TARGET_GENERIC_ISSUE="Pothuri Linux"
EOF

make O="$OUT_DIR" olddefconfig
make O="$OUT_DIR" -j"$(nproc)"

echo "Build complete. Artifacts under: $OUT_DIR/images"

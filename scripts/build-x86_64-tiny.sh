#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BR_DIR="$ROOT_DIR/buildroot"
OUT_DIR="$ROOT_DIR/out/x86_64-tiny"
CONFIG_FILE="$OUT_DIR/.config"

ensure_config() {
  local key="$1"
  local value="$2"

  if grep -qE "^${key}=" "$CONFIG_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
  else
    echo "${key}=${value}" >> "$CONFIG_FILE"
  fi
}

ensure_flag() {
  local flag="$1"

  if ! grep -qE "^${flag}$" "$CONFIG_FILE"; then
    echo "$flag" >> "$CONFIG_FILE"
  fi
}

if [ ! -d "$BR_DIR" ]; then
  echo "Buildroot missing. Run scripts/bootstrap-buildroot.sh first."
  exit 1
fi

mkdir -p "$OUT_DIR"

cd "$BR_DIR"
make O="$OUT_DIR" qemu_x86_64_defconfig

# Minimal footprint tweaks (idempotent)
ensure_flag "BR2_PACKAGE_BUSYBOX_SHOW_OTHERS=y"
ensure_flag "BR2_INIT_BUSYBOX=y"
ensure_config "BR2_ROOTFS_OVERLAY" '"../overlay"'
ensure_config "BR2_TARGET_GENERIC_HOSTNAME" '"roro"'
ensure_config "BR2_TARGET_GENERIC_ISSUE" '"Roro Linux"'

make O="$OUT_DIR" olddefconfig
make O="$OUT_DIR" -j"$(nproc)"

echo "Build complete. Artifacts under: $OUT_DIR/images"

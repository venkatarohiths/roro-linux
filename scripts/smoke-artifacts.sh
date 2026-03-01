#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR_DEFAULT="$ROOT_DIR/out/x86_64-tiny"
OUT_DIR="$OUT_DIR_DEFAULT"
IMG_DIR=""

# Optional size gates (MiB). Set to 0 to disable a gate.
MAX_BZIMAGE_MB="${MAX_BZIMAGE_MB:-20}"
MAX_ROOTFS_MB="${MAX_ROOTFS_MB:-64}"
MAX_ISO_MB="${MAX_ISO_MB:-0}"

# Require ISO artifact presence? 1=yes, 0=no
REQUIRE_ISO="${REQUIRE_ISO:-0}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OUT_DIR] [options]

Validate build artifacts under OUT_DIR/images.

Arguments:
  OUT_DIR                   Artifact output directory (default: $OUT_DIR_DEFAULT)

Options:
  --out-dir <dir>           Same as OUT_DIR positional argument
  --max-bzimage-mb <int>    Max kernel size in MiB (default: $MAX_BZIMAGE_MB)
  --max-rootfs-mb <int>     Max rootfs size in MiB (default: $MAX_ROOTFS_MB)
  --max-iso-mb <int>        Max ISO size in MiB; 0 disables (default: $MAX_ISO_MB)
  --require-iso <0|1>       Require at least one ISO artifact (default: $REQUIRE_ISO)
  -h, --help                Show this help and exit

Environment fallback:
  MAX_BZIMAGE_MB, MAX_ROOTFS_MB, MAX_ISO_MB, REQUIRE_ISO
EOF
}

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

pass() {
  echo "[OK] $1"
}

require_non_negative_int() {
  local value="$1"
  local label="$2"

  if [[ ! "$value" =~ ^[0-9]+$ ]]; then
    fail "$label must be a non-negative integer (got: $value)"
  fi
}

bytes_to_mib() {
  awk -v bytes="$1" 'BEGIN { printf "%.2f", bytes / (1024 * 1024) }'
}

file_size_bytes() {
  local file="$1"

  if stat -c%s "$file" >/dev/null 2>&1; then
    stat -c%s "$file"
  elif stat -f%z "$file" >/dev/null 2>&1; then
    stat -f%z "$file"
  else
    fail "Unable to determine file size for $file (unsupported stat implementation)"
  fi
}

validate_max_size() {
  local file="$1"
  local gate_mb="$2"
  local label="$3"

  if [ "$gate_mb" -eq 0 ]; then
    echo "[WARN] Size gate disabled for $label"
    return
  fi

  local bytes
  bytes=$(file_size_bytes "$file")
  local actual_mib
  actual_mib=$(bytes_to_mib "$bytes")

  if [ "$bytes" -le $((gate_mb * 1024 * 1024)) ]; then
    pass "$label size ${actual_mib} MiB <= ${gate_mb} MiB"
  else
    fail "$label size ${actual_mib} MiB exceeds ${gate_mb} MiB"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --out-dir)
      [ "$#" -ge 2 ] || fail "--out-dir requires a value"
      OUT_DIR="$2"
      shift 2
      ;;
    --max-bzimage-mb)
      [ "$#" -ge 2 ] || fail "--max-bzimage-mb requires a value"
      MAX_BZIMAGE_MB="$2"
      shift 2
      ;;
    --max-rootfs-mb)
      [ "$#" -ge 2 ] || fail "--max-rootfs-mb requires a value"
      MAX_ROOTFS_MB="$2"
      shift 2
      ;;
    --max-iso-mb)
      [ "$#" -ge 2 ] || fail "--max-iso-mb requires a value"
      MAX_ISO_MB="$2"
      shift 2
      ;;
    --require-iso)
      [ "$#" -ge 2 ] || fail "--require-iso requires a value"
      REQUIRE_ISO="$2"
      shift 2
      ;;
    --*)
      fail "Unknown option: $1"
      ;;
    *)
      if [ "$OUT_DIR" != "$OUT_DIR_DEFAULT" ]; then
        fail "Multiple OUT_DIR values provided: '$OUT_DIR' and '$1'"
      fi
      OUT_DIR="$1"
      shift
      ;;
  esac
done

IMG_DIR="$OUT_DIR/images"

require_non_negative_int "$MAX_BZIMAGE_MB" "MAX_BZIMAGE_MB"
require_non_negative_int "$MAX_ROOTFS_MB" "MAX_ROOTFS_MB"
require_non_negative_int "$MAX_ISO_MB" "MAX_ISO_MB"
require_non_negative_int "$REQUIRE_ISO" "REQUIRE_ISO"

if [ "$REQUIRE_ISO" -gt 1 ]; then
  fail "REQUIRE_ISO must be 0 or 1 (got: $REQUIRE_ISO)"
fi

[ -d "$IMG_DIR" ] || fail "Images directory not found: $IMG_DIR"

KERNEL_FILE="$IMG_DIR/bzImage"
[ -f "$KERNEL_FILE" ] || fail "Kernel image missing (expected: bzImage)"
pass "Kernel image present (bzImage)"
validate_max_size "$KERNEL_FILE" "$MAX_BZIMAGE_MB" "Kernel (bzImage)"

ROOTFS_FILE=""
for candidate in rootfs.ext2 rootfs.ext4 rootfs.ext4.gz rootfs.cpio rootfs.cpio.gz rootfs.tar rootfs.tar.gz rootfs.squashfs; do
  if [ -f "$IMG_DIR/$candidate" ]; then
    ROOTFS_FILE="$IMG_DIR/$candidate"
    pass "Rootfs present ($candidate)"
    break
  fi
done

[ -n "$ROOTFS_FILE" ] || fail "No expected rootfs artifact found in $IMG_DIR"
validate_max_size "$ROOTFS_FILE" "$MAX_ROOTFS_MB" "Rootfs ($(basename "$ROOTFS_FILE"))"

shopt -s nullglob
iso_files=("$IMG_DIR"/*.iso)
shopt -u nullglob

if [ "${#iso_files[@]}" -gt 0 ]; then
  pass "ISO artifact present (${#iso_files[@]})"
  if [ "$MAX_ISO_MB" -gt 0 ]; then
    for iso in "${iso_files[@]}"; do
      validate_max_size "$iso" "$MAX_ISO_MB" "ISO ($(basename "$iso"))"
    done
  fi
else
  if [ "$REQUIRE_ISO" -eq 1 ]; then
    fail "ISO required but none found in $IMG_DIR"
  fi
  echo "[WARN] No ISO found (this may be expected depending on Buildroot config)"
fi

echo "Smoke artifact check passed for: $OUT_DIR"

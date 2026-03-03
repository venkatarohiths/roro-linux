#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out/x86_64-tiny/images}"
MAX_BZIMAGE_MB="${MAX_BZIMAGE_MB:-0}"
MAX_ROOTFS_MB="${MAX_ROOTFS_MB:-0}"
MAX_ISO_MB="${MAX_ISO_MB:-0}"
REQUIRE_ISO="${REQUIRE_ISO:-0}"

usage() {
  cat <<EOF
Usage: $0 [--out-dir <dir>] [--max-bzimage-mb <n>] [--max-rootfs-mb <n>] [--max-iso-mb <n>] [--require-iso <0|1>]
EOF
}

require_non_negative_int() {
  local name="$1" val="$2"
  [[ "$val" =~ ^[0-9]+$ ]] || { echo "FAIL: $name must be a non-negative integer"; exit 1; }
}

file_size_bytes() {
  local f="$1"
  stat -c%s "$f" 2>/dev/null || stat -f%z "$f"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir) OUT_DIR="$2"; shift 2;;
    --max-bzimage-mb) MAX_BZIMAGE_MB="$2"; shift 2;;
    --max-rootfs-mb) MAX_ROOTFS_MB="$2"; shift 2;;
    --max-iso-mb) MAX_ISO_MB="$2"; shift 2;;
    --require-iso) REQUIRE_ISO="$2"; shift 2;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

require_non_negative_int MAX_BZIMAGE_MB "$MAX_BZIMAGE_MB"
require_non_negative_int MAX_ROOTFS_MB "$MAX_ROOTFS_MB"
require_non_negative_int MAX_ISO_MB "$MAX_ISO_MB"
require_non_negative_int REQUIRE_ISO "$REQUIRE_ISO"
[[ "$REQUIRE_ISO" == "0" || "$REQUIRE_ISO" == "1" ]] || { echo "FAIL: REQUIRE_ISO must be 0 or 1"; exit 1; }

echo "Smoke check: $OUT_DIR"
[[ -d "$OUT_DIR" ]] || { echo "FAIL: out dir missing"; exit 1; }

bz=("$OUT_DIR"/bzImage)
root_candidates=("$OUT_DIR"/rootfs.ext2 "$OUT_DIR"/rootfs.ext4 "$OUT_DIR"/rootfs.squashfs "$OUT_DIR"/rootfs.cpio "$OUT_DIR"/rootfs.ext4.gz "$OUT_DIR"/rootfs.cpio.gz "$OUT_DIR"/rootfs.tar.gz)
iso=("$OUT_DIR"/*.iso)

[[ -f "${bz[0]}" ]] || { echo "FAIL: bzImage missing"; exit 1; }

root_found=""
for f in "${root_candidates[@]}"; do
  [[ -f "$f" ]] && root_found="$f" && break
done
[[ -n "$root_found" ]] || { echo "FAIL: no rootfs artifact found"; exit 1; }

if [[ "$REQUIRE_ISO" == "1" ]]; then
  ls "$OUT_DIR"/*.iso >/dev/null 2>&1 || { echo "FAIL: REQUIRE_ISO=1 but no ISO found"; exit 1; }
fi

check_max_mb() {
  local file="$1" max_mb="$2" label="$3"
  [[ "$max_mb" == "0" ]] && return 0
  local bytes
  bytes=$(file_size_bytes "$file")
  local max_bytes=$((max_mb*1024*1024))
  [[ "$bytes" -le "$max_bytes" ]] || { echo "FAIL: $label exceeds ${max_mb}MB"; exit 1; }
}

check_max_mb "${bz[0]}" "$MAX_BZIMAGE_MB" "bzImage"
check_max_mb "$root_found" "$MAX_ROOTFS_MB" "rootfs"
if [[ "$MAX_ISO_MB" != "0" ]]; then
  for f in "$OUT_DIR"/*.iso; do
    [[ -f "$f" ]] && check_max_mb "$f" "$MAX_ISO_MB" "ISO $(basename "$f")"
  done
fi

echo "PASS: smoke checks complete"

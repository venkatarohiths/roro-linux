#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${1:-$ROOT_DIR/out/x86_64-tiny}"
IMG_DIR="$OUT_DIR/images"
MANIFEST_FILE="${2:-$OUT_DIR/SHA256SUMS.txt}"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

resolve_hasher() {
  if command -v sha256sum >/dev/null 2>&1; then
    printf 'sha256sum'
  elif command -v shasum >/dev/null 2>&1; then
    printf 'shasum -a 256'
  else
    fail "Neither sha256sum nor shasum is available on PATH"
  fi
}

[ -d "$IMG_DIR" ] || fail "Images directory not found: $IMG_DIR"

# Collect artifacts deterministically and safely (handles spaces/newlines in names).
files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find "$IMG_DIR" -maxdepth 1 -type f -print0 | LC_ALL=C sort -z)

[ "${#files[@]}" -gt 0 ] || fail "No artifact files found in $IMG_DIR"

mkdir -p "$(dirname "$MANIFEST_FILE")"
HASHER="$(resolve_hasher)"

# Write checksums with paths relative to OUT_DIR for portability.
(
  cd "$OUT_DIR"
  rel_files=()
  for f in "${files[@]}"; do
    rel_files+=("${f#"$OUT_DIR"/}")
  done

  # shellcheck disable=SC2086
  $HASHER -- "${rel_files[@]}"
) > "$MANIFEST_FILE"

echo "[OK] Wrote checksum manifest: $MANIFEST_FILE"
echo "[OK] Entries: ${#files[@]}"
echo "[OK] Hasher: $HASHER"

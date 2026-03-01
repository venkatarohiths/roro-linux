#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out/x86_64-tiny/images}"
OUT_MD="docs/ARTIFACT_MANIFEST.md"
SUMS="SHA256SUMS.txt"

resolve_hasher() {
  if command -v sha256sum >/dev/null 2>&1; then
    echo "sha256sum"
  elif command -v shasum >/dev/null 2>&1; then
    echo "shasum -a 256"
  else
    echo ""
  fi
}

HASHER="$(resolve_hasher)"
[[ -n "$HASHER" ]] || { echo "FAIL: no sha256 hasher found (need sha256sum or shasum)"; exit 1; }

echo "Hasher: $HASHER"
mkdir -p docs

{
  echo "# Roro Linux Artifact Manifest"
  echo "Generated (UTC): $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  echo
  echo "| File | Bytes | MB | SHA256 |"
  echo "|---|---:|---:|---|"

  if [[ ! -d "$OUT_DIR" ]]; then
    echo "| out/ not present | 0 | 0.00 | n/a |"
  else
    mapfile -t files < <(find "$OUT_DIR" -type f | sort)
    if [[ ${#files[@]} -eq 0 ]]; then
      echo "| out/ empty | 0 | 0.00 | n/a |"
    else
      : > "$SUMS"
      for f in "${files[@]}"; do
        b=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
        mb=$(awk "BEGIN {printf \"%.2f\", $b/1048576}")
        if [[ "$HASHER" == "sha256sum" ]]; then
          h=$(sha256sum "$f" | awk '{print $1}')
          sha256sum "$f" >> "$SUMS"
        else
          h=$(shasum -a 256 "$f" | awk '{print $1}')
          shasum -a 256 "$f" >> "$SUMS"
        fi
        rel="${f#./}"
        echo "| $rel | $b | $mb | \\`$h\\` |"
      done
    fi
  fi
} > "$OUT_MD"

echo "Wrote: $OUT_MD"
[[ -s "$SUMS" ]] && echo "Wrote: $SUMS"

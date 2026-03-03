#!/bin/sh
set -eu
TARGET_DIR="${1:-target}"
find "$TARGET_DIR" -type f -executable -exec strip --strip-unneeded {} + 2>/dev/null || true
rm -rf "$TARGET_DIR"/usr/share/man "$TARGET_DIR"/usr/share/doc "$TARGET_DIR"/usr/share/locale || true
find "$TARGET_DIR" -type f -name '*.a' -delete || true
find "$TARGET_DIR" -type f -name '*.pyc' -delete || true
DU=$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}')
echo "post-build: target size=$DU"

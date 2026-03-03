#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="$1"
echo "Roro Linux post-build hook" > "$TARGET_DIR/etc/roro-build-info"

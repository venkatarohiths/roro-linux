#!/usr/bin/env bash
set -euo pipefail
BINARIES_DIR="$1"
echo "post-image hook complete" > "$BINARIES_DIR/roro-post-image.txt"

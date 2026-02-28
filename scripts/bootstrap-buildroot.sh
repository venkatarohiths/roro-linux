#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d buildroot ]; then
  git clone --depth=1 https://github.com/buildroot/buildroot.git
fi

echo "Buildroot ready at: $ROOT_DIR/buildroot"

#!/bin/sh
set -eu
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"
[ -d buildroot ] || git clone --depth=1 https://github.com/buildroot/buildroot.git
echo "Buildroot ready"

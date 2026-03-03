#!/usr/bin/env bash
set -euo pipefail
bash scripts/bootstrap-buildroot.sh
bash scripts/build-x86_64-tiny.sh

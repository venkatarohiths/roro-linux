# Roro Linux

A lightweight, customizable Linux distribution project for tiny hardware and embedded use-cases.

## Vision
- Minimal footprint
- Fast boot
- Easy to customize and rebuild
- Works on small devices and in virtual machines

## Approach (v1)
Built with **Buildroot** to produce tiny Linux images quickly.

## Targets
1. QEMU VM (for rapid testing)
2. Small x86_64 hardware
3. Optional ARM SBC profile (later phase)

## Quick Start
### Linux/macOS
```bash
# 1) Bootstrap buildroot
bash scripts/bootstrap-buildroot.sh

# 2) Build image
bash scripts/build-x86_64-tiny.sh

# 3) Run in QEMU
bash scripts/run-qemu.sh
```

### Windows (WSL path)
```powershell
powershell -ExecutionPolicy Bypass -File scripts/precheck-host.ps1
powershell -ExecutionPolicy Bypass -File scripts/build-wsl.ps1
```

## Repo Layout
- `configs/` buildroot configs
- `overlay/` rootfs overrides
- `scripts/` build/run automation
- `docs/` architecture and roadmap

## Current Status
Phase 0 complete: foundation, build scripts, tiny profile, VM flow.

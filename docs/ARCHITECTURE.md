# Architecture (Pothuri Linux)

## Base stack
- Linux kernel (Buildroot managed)
- BusyBox userland
- musl libc
- Dropbear SSH (optional profile)

## Design principles
1. **Small first**: keep base image minimal
2. **Composable profiles**: add features by profile, not in core
3. **Deterministic builds**: scripted, repeatable
4. **VM-first testing**: validate in QEMU before hardware

## Planned profiles
- `tiny-core`: shell, networking, init, package-free base
- `tiny-net`: core + SSH + basic diagnostics
- `tiny-media`: core + lightweight media stack (future)

## Boot model
- ext4 rootfs image
- GRUB/syslinux via Buildroot image generation
- QEMU boot for smoke tests

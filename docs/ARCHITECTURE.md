# Architecture (Roro Linux)

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

## Implemented profiles
- `roro_x86_64_tiny_defconfig`: tiny but practical x86_64 profile (musl + busybox + ext4 + dropbear)
- `roro_i386_micro_defconfig`: ultra-small i386 profile for constrained VMs/devices

## Planned profiles
- `tiny-media`: core + lightweight media stack (future)

## Boot model
- ext4 rootfs image
- GRUB/syslinux via Buildroot image generation
- QEMU boot for smoke tests

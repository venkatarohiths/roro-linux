# Architecture

Build pipeline: Buildroot -> rootfs (musl+busybox) -> post-build trim -> post-image pack -> VM/hardware image.

Design choices:
- musl over glibc for smaller/faster footprint
- BusyBox init (no systemd) for lean boot
- read-only root with overlay/tmpfs for durability and speed

Boot target: <3s to login (QEMU virtio baseline).

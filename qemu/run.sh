#!/bin/sh
set -eu
MEM=512
CPUS=1
IMG="out/x86_64-tiny/images/roro-linux.img"
while [ $# -gt 0 ]; do
  case "$1" in
    --memory) MEM="$2"; shift 2;;
    --cpus) CPUS="$2"; shift 2;;
    *) shift;;
  esac
done
KVM=""
[ -e /dev/kvm ] && KVM="-enable-kvm"
qemu-system-x86_64 $KVM -m "$MEM" -smp "$CPUS" -drive file="$IMG",if=virtio,format=raw -nic user,model=virtio-net-pci -serial mon:stdio

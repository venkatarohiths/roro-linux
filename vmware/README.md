# VMware Test Pack — Roro Linux

This guide prepares Roro Linux artifacts for VMware testing.

## Goal
Boot Roro Linux in VMware Workstation/Player using a raw disk image converted to VMDK.

## Prerequisites
- VMware Workstation or VMware Player
- qemu-img (from QEMU tools)
- WSL + Buildroot build completion

## 1) Build artifacts
From repo root (WSL path):
```bash
bash scripts/bootstrap-buildroot.sh
bash scripts/build-x86_64-tiny.sh
```
Expected artifacts under:
`out/x86_64-tiny/images/`

## 2) Convert rootfs image to VMDK
On Windows PowerShell:
```powershell
qemu-img convert -f raw -O vmdk .\out\x86_64-tiny\images\rootfs.ext2 .\vmware\roro-linux-disk.vmdk
```

## 3) Create VMware VM
- Guest OS type: Linux (Other Linux 5.x/6.x kernel 64-bit)
- CPU: 1-2 vCPU
- RAM: 256MB-512MB
- Disk: use existing `vmware/roro-linux-disk.vmdk`
- Firmware: BIOS first (UEFI optional)

## 4) Optional kernel attach (if needed)
If VMware cannot boot rootfs disk directly, use an installer helper ISO or create a bootloader disk in next phase.

## 5) Validation checklist
- [ ] VM boots to shell/login prompt
- [ ] Hostname shows `roro`
- [ ] BusyBox commands available
- [ ] Networking up (if profile enables)

## Notes
Current fastest validation path is QEMU; VMware test path is prepared and will be finalized with bootloader image packaging in next iteration.

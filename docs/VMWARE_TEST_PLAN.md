# VM Test Readiness

## Ready now
- Buildroot tiny profile + build scripts
- Artifact smoke/manifest scripts
- VMware conversion script: `scripts/export-vmware.ps1`
- VMware setup guide: `vmware/README.md`

## Pending host dependencies
- WSL initialized (`wsl --install` + distro setup)
- QEMU tools installed (`qemu-img` required)

## One-command prep checks
```powershell
powershell -ExecutionPolicy Bypass -File scripts/precheck-host.ps1
```

## VMware flow
1. Build image
2. Convert raw rootfs to VMDK
3. Attach VMDK in VMware
4. Boot and validate

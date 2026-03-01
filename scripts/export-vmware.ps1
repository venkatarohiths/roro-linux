param(
  [string]$InputRaw = "out/x86_64-tiny/images/rootfs.ext2",
  [string]$OutputVmdk = "vmware/roro-linux-disk.vmdk"
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command qemu-img -ErrorAction SilentlyContinue)) {
  throw 'qemu-img not found. Install QEMU tools and ensure qemu-img is on PATH.'
}

if (-not (Test-Path $InputRaw)) {
  throw "Input raw image not found: $InputRaw"
}

$dir = Split-Path -Parent $OutputVmdk
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

qemu-img convert -f raw -O vmdk $InputRaw $OutputVmdk
Write-Output "Created VMDK: $OutputVmdk"

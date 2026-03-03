param(
  [string]$InputRaw = "out/x86_64-tiny/images/rootfs.ext2",
  [string]$OutputVmdk = "vmware/roro-linux-disk.vmdk"
)

$ErrorActionPreference = 'Stop'
$qemuImg = Get-Command qemu-img -ErrorAction SilentlyContinue; if(-not $qemuImg -and (Test-Path 'C:\\Program Files\\qemu\\qemu-img.exe')){ $qemuImg = @{ Source='C:\\Program Files\\qemu\\qemu-img.exe' } }
if (-not $qemuImg) { throw 'qemu-img not found. Install QEMU tools.' }

if (-not (Test-Path $InputRaw)) {
  throw "Input raw image not found: $InputRaw"
}

$dir = Split-Path -Parent $OutputVmdk
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

& $qemuImg.Source convert -f raw -O vmdk $InputRaw $OutputVmdk
Write-Output "Created VMDK: $OutputVmdk"


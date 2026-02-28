$ErrorActionPreference = 'Stop'
Write-Host "[Roro Linux] Host precheck starting..."

$checks = @()
$checks += [pscustomobject]@{ Name='Git';       Ok= [bool](Get-Command git -ErrorAction SilentlyContinue) }
$checks += [pscustomobject]@{ Name='WSL';       Ok= [bool](Get-Command wsl -ErrorAction SilentlyContinue) }
$checks += [pscustomobject]@{ Name='QEMU';      Ok= [bool](Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue) }
$checks += [pscustomobject]@{ Name='7zip(opt)'; Ok= [bool](Get-Command 7z -ErrorAction SilentlyContinue) }

$checks | Format-Table -AutoSize

if (-not ($checks | Where-Object Name -eq 'Git').Ok) { throw 'Git missing. Install Git first.' }
if (-not ($checks | Where-Object Name -eq 'WSL').Ok) { Write-Warning 'WSL missing. Build scripts require bash via WSL.' }
if (-not ($checks | Where-Object Name -eq 'QEMU').Ok) { Write-Warning 'QEMU missing. VM run script will not work until installed.' }

Write-Host "[Roro Linux] Precheck complete."
param(
  [string]$VmName = 'RoroLinux-Tiny',
  [string]$IsoPath = 'out/ci-artifacts/out/x86_64-tiny/images/rootfs.iso'
)

$ErrorActionPreference='Stop'
$vbox='C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
if(-not (Test-Path $vbox)){ throw 'VBoxManage not found.' }

$resolvedIso = (Resolve-Path -LiteralPath $IsoPath -ErrorAction Stop).Path

$existing = & $vbox list vms
if($existing -match ('"' + [regex]::Escape($VmName) + '"')){
  $running = & $vbox list runningvms
  if($running -match ('"' + [regex]::Escape($VmName) + '"')){
    & $vbox controlvm $VmName poweroff | Out-Null
    Start-Sleep -Seconds 1
  }
  & $vbox unregistervm $VmName --delete | Out-Null
}

& $vbox createvm --name $VmName --ostype Linux_64 --register | Out-Null
& $vbox modifyvm $VmName --memory 512 --cpus 1 --ioapic on --boot1 dvd --boot2 disk --boot3 none --boot4 none | Out-Null
& $vbox storagectl $VmName --name 'IDE' --add ide | Out-Null
& $vbox storageattach $VmName --storagectl 'IDE' --port 1 --device 0 --type dvddrive --medium $resolvedIso | Out-Null

Write-Output "VM ready: $VmName"
Write-Output "ISO attached: $resolvedIso"

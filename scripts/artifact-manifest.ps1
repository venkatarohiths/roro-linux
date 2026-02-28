$ErrorActionPreference='Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'out'
$manifest = Join-Path $root 'docs\ARTIFACT_MANIFEST.md'
$lines=@('# Roro Linux Artifact Manifest',"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",'')
if(Test-Path $out){
  Get-ChildItem $out -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $rel=$_.FullName.Replace($root+'\\','')
    $mb=[Math]::Round($_.Length/1MB,2)
    $lines += "- $rel | ${mb} MB"
  }
}else{
  $lines += '- out/ not present yet'
}
Set-Content -Path $manifest -Value ($lines -join "`r`n") -Encoding UTF8
Write-Output "Wrote: $manifest"

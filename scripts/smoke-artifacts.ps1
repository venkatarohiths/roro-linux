$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$outRoot = Join-Path $root 'out'
$report = Join-Path $root 'docs\SMOKE_REPORT.md'

$lines = @()
$lines += '# Roro Linux Smoke Artifact Report'
$lines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
$lines += ''

if (-not (Test-Path $outRoot)) {
  $lines += 'No build artifacts found yet (`out/` missing).'
} else {
  $lines += '## Artifacts'
  $files = Get-ChildItem -Path $outRoot -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, LastWriteTime

  if (-not $files) {
    $lines += '- No files found under out/'
  } else {
    foreach ($f in $files) {
      $sizeMB = [Math]::Round($f.Length / 1MB, 2)
      $rel = $f.FullName.Replace($root + '\\', '')
      $lines += "- $rel | ${sizeMB} MB | $($f.LastWriteTime)"
    }
  }
}

$lines += ''
$lines += '## Host checks'
$hasWsl = [bool](Get-Command wsl -ErrorAction SilentlyContinue)
$hasQemu = [bool](Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue)
$lines += "- WSL available: $hasWsl"
$lines += "- QEMU available: $hasQemu"

Set-Content -Path $report -Value ($lines -join "`r`n") -Encoding UTF8
Write-Output "Smoke report written: $report"

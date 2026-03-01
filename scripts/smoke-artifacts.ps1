param(
  [string]$OutDir = 'out'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$outRoot = if ([System.IO.Path]::IsPathRooted($OutDir)) { $OutDir } else { Join-Path $root $OutDir }
$report = Join-Path $root 'docs\SMOKE_REPORT.md'

$lines = @()
$lines += '# Roro Linux Smoke Artifact Report'
$lines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
$lines += "Artifact root: $outRoot"
$lines += ''

if (-not (Test-Path $outRoot)) {
  $lines += "No build artifacts found yet (`"$OutDir/`" missing)."
} else {
  $lines += '## Artifacts'
  $files = Get-ChildItem -Path $outRoot -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object FullName, Length, LastWriteTime

  if (-not $files) {
    $lines += '- No files found under artifact root'
  } else {
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    $totalMB = [Math]::Round(($totalBytes / 1MB), 2)
    $lines += "- Total files: $($files.Count)"
    $lines += "- Total size: ${totalMB} MB"
    $lines += ''

    foreach ($f in $files) {
      $sizeMB = [Math]::Round($f.Length / 1MB, 2)
      $rel = [System.IO.Path]::GetRelativePath($root, $f.FullName)
      $lines += "- $rel | ${sizeMB} MB | $($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
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

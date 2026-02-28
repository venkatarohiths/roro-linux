$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

& "$PSScriptRoot\precheck-host.ps1"

if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
  throw 'WSL is required for Buildroot builds on Windows.'
}

$cmd = "cd '$root' && bash scripts/bootstrap-buildroot.sh && bash scripts/build-x86_64-tiny.sh"
Write-Host "Running in WSL: $cmd"
wsl -e bash -lc $cmd

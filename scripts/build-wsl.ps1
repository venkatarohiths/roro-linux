[CmdletBinding()]
param(
  [switch]$DryRun,
  [string]$Distro
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

& "$PSScriptRoot\precheck-host.ps1"

if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
  throw 'WSL is required for Buildroot builds on Windows.'
}

# Verify that WSL is actually installed/configured, not just that wsl.exe exists.
$stderrFile = [System.IO.Path]::GetTempFileName()
$stdoutFile = [System.IO.Path]::GetTempFileName()
try {
  $probe = Start-Process -FilePath 'wsl.exe' -ArgumentList '-l','-q' -NoNewWindow -PassThru -Wait -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
  $probeOut = (Get-Content -Path $stdoutFile -Raw -ErrorAction SilentlyContinue)
  $probeErr = (Get-Content -Path $stderrFile -Raw -ErrorAction SilentlyContinue).Trim()

  if ($probe.ExitCode -ne 0) {
    if ([string]::IsNullOrWhiteSpace($probeErr)) {
      $probeErr = 'Unknown WSL initialization error.'
    }
    throw "WSL is present but not configured. Install/initialize it with 'wsl --install', then re-run this script. Details: $probeErr"
  }

  $distros = @($probeOut -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  if ($distros.Count -eq 0) {
    throw "WSL is installed, but no Linux distributions are available. Install one with 'wsl --install -d Ubuntu' (or another distro), then re-run this script."
  }

  if (-not [string]::IsNullOrWhiteSpace($Distro) -and -not ($distros -contains $Distro)) {
    $available = ($distros -join ', ')
    throw "Requested distro '$Distro' was not found. Available distros: $available"
  }
}
finally {
  Remove-Item -Path $stderrFile,$stdoutFile -ErrorAction SilentlyContinue
}

$rootWsl = (& wsl -e wslpath -a "$root" 2>$null)
$rootWsl = $rootWsl.Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($rootWsl)) {
  # Fallback for environments where wslpath is unavailable
  if ($root -match '^[A-Za-z]:\\') {
    $drive = $root.Substring(0,1).ToLower()
    $rest = $root.Substring(2).Replace('\\','/')
    $rootWsl = "/mnt/$drive$rest"
  } else {
    throw "Unable to convert Windows path to WSL path: $root"
  }
}

# Validate required build scripts before invoking WSL to fail fast with clear errors.
$requiredScripts = @('scripts/bootstrap-buildroot.sh', 'scripts/build-x86_64-tiny.sh')
foreach ($scriptRel in $requiredScripts) {
  $scriptPath = Join-Path $root $scriptRel
  if (-not (Test-Path -Path $scriptPath -PathType Leaf)) {
    throw "Required build script not found: $scriptRel"
  }
}

# Escape single quotes for safe embedding in bash single-quoted context.
$rootWslEscaped = $rootWsl.Replace("'", "'""'""'")
$cmd = "cd '$rootWslEscaped' && bash scripts/bootstrap-buildroot.sh && bash scripts/build-x86_64-tiny.sh"
Write-Host "Running in WSL: $cmd"
if (-not [string]::IsNullOrWhiteSpace($Distro)) {
  Write-Host "Using WSL distro: $Distro"
}

if ($DryRun) {
  Write-Host 'DryRun enabled: not executing WSL build command.'
  exit 0
}

if ([string]::IsNullOrWhiteSpace($Distro)) {
  wsl -e bash -lc $cmd
} else {
  wsl -d $Distro -e bash -lc $cmd
}

if ($LASTEXITCODE -ne 0) {
  throw "WSL build command failed with exit code $LASTEXITCODE."
}


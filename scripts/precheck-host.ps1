[CmdletBinding()]
param(
  [switch]$Json,
  [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
if (-not $Quiet) {
  Write-Host "[Roro Linux] Host precheck starting..."
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$checks = @()

function Add-Check {
  param(
    [string]$Name,
    [bool]$Ok,
    [string]$Details = ''
  )

  $script:checks += [pscustomobject]@{
    Name = $Name
    Ok = $Ok
    Details = $Details
  }
}

Add-Check -Name 'Git'       -Ok ([bool](Get-Command git -ErrorAction SilentlyContinue))
Add-Check -Name 'WSL'       -Ok ([bool](Get-Command wsl -ErrorAction SilentlyContinue))
Add-Check -Name 'QEMU'      -Ok ([bool](Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue))
Add-Check -Name '7zip(opt)' -Ok ([bool](Get-Command 7z -ErrorAction SilentlyContinue)) -Details 'Optional'

$requiredPaths = @(
  'configs\\roro_x86_64_tiny_defconfig',
  'scripts\\build-x86_64-tiny.sh',
  'overlay\\etc\\motd'
)
foreach ($required in $requiredPaths) {
  Add-Check -Name "Repo:$required" -Ok (Test-Path (Join-Path $repoRoot $required)) -Details 'Required repo file'
}

$wslCheck = ($checks | Where-Object Name -eq 'WSL' | Select-Object -First 1).Ok
if ($wslCheck) {
  $wslBashOk = $false
  $previousNativePref = $PSNativeCommandUseErrorActionPreference
  try {
    $PSNativeCommandUseErrorActionPreference = $false
    $bashProbe = & wsl -e bash -lc 'echo wsl-ok' 2>$null
    $wslBashOk = ($LASTEXITCODE -eq 0 -and "$bashProbe".Trim() -eq 'wsl-ok')
  } catch {
    $wslBashOk = $false
  } finally {
    $PSNativeCommandUseErrorActionPreference = $previousNativePref
  }
  Add-Check -Name 'WSL bash' -Ok $wslBashOk -Details ($(if ($wslBashOk) { 'bash executable via WSL' } else { 'wsl exists but bash launch failed' }))
}

$gitOk = ($checks | Where-Object Name -eq 'Git' | Select-Object -First 1).Ok
$wslOk = ($checks | Where-Object Name -eq 'WSL' | Select-Object -First 1).Ok
$qemuOk = ($checks | Where-Object Name -eq 'QEMU' | Select-Object -First 1).Ok
$missingRepo = $checks | Where-Object { $_.Name -like 'Repo:*' -and -not $_.Ok }
$wslBash = $checks | Where-Object Name -eq 'WSL bash' | Select-Object -First 1

$warnings = @()
$errors = @()

if (-not $gitOk) { $errors += 'Git missing. Install Git first.' }
if (-not $wslOk) { $warnings += 'WSL missing. Build scripts require bash via WSL.' }
if (-not $qemuOk) { $warnings += 'QEMU missing. VM run script will not work until installed.' }
if ($missingRepo) {
  $missingList = ($missingRepo | ForEach-Object { $_.Name.Replace('Repo:', '') }) -join ', '
  $errors += "Repository layout check failed. Missing required paths: $missingList"
}
if ($wslBash -and -not $wslBash.Ok) {
  $warnings += 'WSL command exists, but bash could not be launched. Check WSL distro initialization.'
}

$summary = [pscustomobject]@{
  repoRoot = $repoRoot
  ok = ($errors.Count -eq 0)
  checks = @($checks)
  warnings = @($warnings)
  errors = @($errors)
}

if ($Json) {
  $summary | ConvertTo-Json -Depth 5
} elseif (-not $Quiet) {
  $checks | Format-Table -AutoSize
  foreach ($warning in $warnings) { Write-Warning $warning }
  if ($errors.Count -eq 0) {
    Write-Host "[Roro Linux] Precheck complete."
  }
}

if ($errors.Count -gt 0) {
  throw ($errors -join ' | ')
}


param(
  [string]$ManifestPath = "docs/ARTIFACT_MANIFEST.md"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$content = Get-Content -Raw $ManifestPath
$lines = $content -split "`r?`n"
$tableLines = $lines | Where-Object { $_ -match '^\| .* \|$' }

if (-not $tableLines) {
  throw 'No markdown table rows found in manifest.'
}

$bad = @()
foreach ($line in $tableLines) {
  if ($line -match "\|[^|]*`n") { $bad += $line; continue }
  # each row should have at least 5 cells for current schema
  $pipes = ($line.ToCharArray() | Where-Object { $_ -eq '|' }).Count
  if ($pipes -lt 6) { $bad += $line }
}

if ($bad.Count -gt 0) {
  Write-Output 'Manifest markdown validation failed on lines:'
  $bad | ForEach-Object { Write-Output $_ }
  exit 1
}

Write-Output 'Manifest markdown validation passed.'

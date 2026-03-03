param(
  [string]$ManifestPath = "docs/ARTIFACT_MANIFEST.md"
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedManifestPath = if ([System.IO.Path]::IsPathRooted($ManifestPath)) {
  $ManifestPath
} else {
  Join-Path $repoRoot $ManifestPath
}

if (-not (Test-Path $resolvedManifestPath)) {
  throw "Manifest not found: $resolvedManifestPath"
}

$content = Get-Content -Raw $resolvedManifestPath
$lines = $content -split "`r?`n"

$bad = [System.Collections.Generic.List[string]]::new()

if ($lines.Count -lt 5) {
  $bad.Add('Manifest is too short to contain required header/table structure.')
}

if ($lines[0] -ne '# Roro Linux Artifact Manifest') {
  $bad.Add('Line 1 must be exactly: # Roro Linux Artifact Manifest')
}

if ($lines.Count -gt 1) {
  if ($lines[1] -notmatch '^Generated \(UTC\): \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
    $bad.Add('Line 2 must match: Generated (UTC): YYYY-MM-DDTHH:MM:SSZ')
  }
}

$tableHeader = '| Artifact | Modified (UTC) | Size (bytes) | Size (MB) | SHA256 |'
$tableSeparator = '| --- | --- | ---: | ---: | --- |'

if ($lines -notcontains $tableHeader) {
  $bad.Add('Missing required table header row.')
}

if ($lines -notcontains $tableSeparator) {
  $bad.Add('Missing required table separator row.')
}

$tableLines = $lines | Where-Object { $_ -match '^\| .* \|$' }
$dataLines = $tableLines | Where-Object { $_ -ne $tableHeader -and $_ -ne $tableSeparator }

if (-not $dataLines) {
  $bad.Add('No data rows found in artifact table.')
}

foreach ($line in $dataLines) {
  $pipes = ($line.ToCharArray() | Where-Object { $_ -eq '|' }).Count
  if ($pipes -lt 6) {
    $bad.Add("Malformed row (wrong cell count): $line")
    continue
  }

  $cells = $line.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
  if ($cells.Count -lt 5) {
    $bad.Add("Malformed row (unable to parse cells): $line")
    continue
  }

  $artifact = $cells[0]
  $modifiedUtc = $cells[1]
  $sizeBytes = $cells[2]
  $sizeMb = $cells[3]
  $sha256 = $cells[4]

  if ([string]::IsNullOrWhiteSpace($artifact)) {
    $bad.Add("Artifact path is empty in row: $line")
  }

  if ($modifiedUtc -ne 'n/a' -and $modifiedUtc -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
    $bad.Add("Invalid modified timestamp '$modifiedUtc' in row: $line")
  }

  if ($sizeBytes -ne '0' -and $sizeBytes -notmatch '^\d+$') {
    $bad.Add("Invalid size-bytes value '$sizeBytes' in row: $line")
  }

  if ($sizeMb -ne '0.00' -and $sizeMb -notmatch '^\d+\.\d{2}$') {
    $bad.Add("Invalid size-MB value '$sizeMb' in row: $line")
  }

  if ($sha256 -ne 'n/a' -and $sha256 -notmatch '^[a-fA-F0-9]{64}$') {
    $bad.Add("Invalid SHA256 value '$sha256' in row: $line")
  }
}

if ($bad.Count -gt 0) {
  Write-Output 'Manifest validation failed:'
  $bad | ForEach-Object { Write-Output "- $_" }
  exit 1
}

Write-Output 'Manifest validation passed.'

param(
  [string]$OutDir = 'out',
  [string]$ManifestPath = 'docs/ARTIFACT_MANIFEST.md',
  [switch]$FailOnHashError
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root $OutDir
$manifest = Join-Path $root $ManifestPath

function Format-Megabytes([long]$bytes) {
  return ([Math]::Round($bytes / 1MB, 2)).ToString('0.00', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Escape-MarkdownCell([string]$value) {
  if ($null -eq $value) {
    return ''
  }

  return $value.Replace('\\', '\\\\').Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
}

$manifestDir = Split-Path -Parent $manifest
if (-not [string]::IsNullOrWhiteSpace($manifestDir) -and -not (Test-Path $manifestDir)) {
  New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
}

$generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$lines = @(
  '# Roro Linux Artifact Manifest'
  "Generated (UTC): $generatedAt"
  ''
  '| Artifact | Modified (UTC) | Size (bytes) | Size (MB) | SHA256 |'
  '| --- | --- | ---: | ---: | --- |'
)

if (Test-Path $out) {
  $artifacts = Get-ChildItem $out -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object FullName

  if ($artifacts.Count -gt 0) {
    $totalBytes = 0L

    foreach ($item in $artifacts) {
      $rel = [System.IO.Path]::GetRelativePath($root, $item.FullName).Replace('\\', '/')
      $relMd = Escape-MarkdownCell $rel
      $modifiedUtc = $item.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
      $mb = Format-Megabytes $item.Length

      $hash = 'error'
      try {
        $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
      }
      catch {
        if ($FailOnHashError) {
          throw
        }
        $hash = Escape-MarkdownCell ("error: $($_.Exception.Message)")
      }

      $totalBytes += $item.Length
      $lines += "| $relMd | $modifiedUtc | $($item.Length) | $mb | $hash |"
    }

    $totalMb = Format-Megabytes $totalBytes
    $lines += ''
    $lines += "Total artifacts: $($artifacts.Count)"
    $lines += "Total size (bytes): $totalBytes"
    $lines += "Total size (MB): $totalMb"
  } else {
    $lines += '| out/ (empty) | n/a | 0 | 0.00 | n/a |'
  }
} else {
  $lines += '| out/ not present yet | n/a | 0 | 0.00 | n/a |'
}

Set-Content -Path $manifest -Value ($lines -join "`r`n") -Encoding UTF8
Write-Output "Wrote: $manifest"


$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'out'
$manifest = Join-Path $root 'docs\ARTIFACT_MANIFEST.md'
$generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$lines = @(
  '# Roro Linux Artifact Manifest'
  "Generated (UTC): $generatedAt"
  ''
  '| Artifact | Size (bytes) | Size (MB) | SHA256 |'
  '| --- | ---: | ---: | --- |'
)

if (Test-Path $out) {
  $artifacts = Get-ChildItem $out -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object FullName

  if ($artifacts.Count -gt 0) {
    foreach ($item in $artifacts) {
      $rel = $item.FullName.Replace($root + '\\', '')
      $mb = [Math]::Round($item.Length / 1MB, 2)
      $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
      $lines += "| $rel | $($item.Length) | $mb | $hash |"
    }
  } else {
    $lines += '| out/ (empty) | 0 | 0 | n/a |'
  }
} else {
  $lines += '| out/ not present yet | 0 | 0 | n/a |'
}

Set-Content -Path $manifest -Value ($lines -join "`r`n") -Encoding UTF8
Write-Output "Wrote: $manifest"

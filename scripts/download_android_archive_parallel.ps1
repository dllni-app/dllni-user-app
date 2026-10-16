param(
    [Parameter(Mandatory)][string]$Url,
    [Parameter(Mandatory)][string]$File,
    [Parameter(Mandatory)][long]$ExpectedSize,
    [int]$Parallel = 8,
    [int]$ChunkMB = 8
)
$ErrorActionPreference = 'Stop'
$chunkSize = [long]$ChunkMB * 1024 * 1024
$partsDir = "$File.parts"
New-Item -ItemType Directory -Path $partsDir -Force | Out-Null
$prefix = if (Test-Path $File) { (Get-Item $File).Length } else { 0 }
if ($prefix -gt $ExpectedSize) { throw "Oversized archive: $File" }
if ($prefix -eq $ExpectedSize) { Write-Host "Already downloaded $File"; exit 0 }

$blocks = [collections.generic.list[object]]::new()
for ([long]$start = $prefix; $start -lt $ExpectedSize; $start += $chunkSize) {
    [long]$end = [math]::Min($ExpectedSize - 1, $start + $chunkSize - 1)
    $part = Join-Path $partsDir ("$start-$end.bin")
    $blocks.Add([pscustomobject]@{ Start=$start; End=$end; Part=$part; Size=($end-$start+1) })
}
Write-Host "Downloading $($blocks.Count) ranges with $Parallel connections; resuming from $prefix bytes."

for ($base = 0; $base -lt $blocks.Count; $base += $Parallel) {
    $started = @()
    $batch = @($blocks | Select-Object -Skip $base -First $Parallel)
    foreach ($block in $batch) {
        if ((Test-Path $block.Part) -and (Get-Item $block.Part).Length -eq $block.Size) { continue }
        if (Test-Path $block.Part) { Remove-Item $block.Part -Force }
        $range = "$($block.Start)-$($block.End)"
        $args = @('-f','-s','-S','-L','--retry','3','--retry-delay','2','--range',$range,'--output',$block.Part,$Url)
        $proc = Start-Process -FilePath 'curl.exe' -ArgumentList $args -PassThru -NoNewWindow
        $started += $proc
    }
    if ($started.Count -gt 0) { $started | Wait-Process }
    foreach ($block in $batch) {
        if (-not (Test-Path $block.Part)) { throw "Missing downloaded range: $($block.Start)" }
        if ((Get-Item $block.Part).Length -ne $block.Size) {
            throw "Incomplete downloaded range $($block.Start): $((Get-Item $block.Part).Length) instead of $($block.Size)"
        }
    }
    Write-Host ("Verified ranges {0}/{1} ({2}%)" -f ([math]::Min($blocks.Count,$base+$Parallel)), $blocks.Count, [math]::Round(100*[math]::Min($blocks.Count,$base+$Parallel)/$blocks.Count))
}

$merged = "$File.merged"
if (Test-Path $merged) { Remove-Item $merged -Force }
$out = [IO.File]::Open($merged, [IO.FileMode]::Create, [IO.FileAccess]::Write)
try {
    if ($prefix -gt 0) {
        $inputStream = [IO.File]::OpenRead($File)
        try { $inputStream.CopyTo($out) } finally { $inputStream.Dispose() }
    }
    foreach ($block in $blocks) {
        $inputStream = [IO.File]::OpenRead($block.Part)
        try { $inputStream.CopyTo($out) } finally { $inputStream.Dispose() }
    }
} finally { $out.Dispose() }
if ((Get-Item $merged).Length -ne $ExpectedSize) { throw "Merged archive size mismatch: $merged" }
Move-Item -Force $merged $File
Remove-Item -Force -Recurse $partsDir
Write-Host "Assembled $File ($ExpectedSize bytes)."

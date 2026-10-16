# Official Google CDN fallback when dl.google.com returns HTTP 404.
# Versions and SHA-1 values are from Android SDK repository manifests (2026-10).
$ErrorActionPreference = 'Stop'
$sdk = 'C:\laragon\www\Dllni\.tools\android-sdk'
$cache = Join-Path $sdk '.temp'
New-Item -ItemType Directory -Force -Path $cache | Out-Null
$base = 'https://redirector.gvt1.com/edgedl/android/repository'

function Install-Zip {
    param(
        [string] $Url,
        [string] $Filename,
        [long] $ExpectedSize,
        [string] $ExpectedSha1,
        [string] $ExtractInto,
        [string] $InstalledCheck
    )
    if (Test-Path $InstalledCheck) {
        Write-Host "Already installed: $InstalledCheck"
        return
    }
    $archive = Join-Path $cache $Filename
    $isValid = $false
    if (Test-Path $archive) {
        $item = Get-Item $archive
        if ($item.Length -eq $ExpectedSize) {
            $hash = (Get-FileHash $archive -Algorithm SHA1).Hash
            $isValid = ($hash -ieq $ExpectedSha1)
        }
        if ($item.Length -gt $ExpectedSize -or ($item.Length -eq $ExpectedSize -and -not $isValid)) {
            Remove-Item $archive -Force
        }
    }
    if (-not $isValid) {
        Write-Host "Downloading $Filename from Google's official CDN..."
        & (Join-Path $PSScriptRoot 'download_android_archive_parallel.ps1') -Url $Url -File $archive -ExpectedSize $ExpectedSize
        # The helper throws on failure; PowerShell script calls do not set LASTEXITCODE.
        $actualSize = (Get-Item $archive).Length
        if ($actualSize -ne $ExpectedSize) { throw "Incomplete download: $Filename ($actualSize / $ExpectedSize bytes)" }
        $actualSha1 = (Get-FileHash $archive -Algorithm SHA1).Hash
        if ($actualSha1 -ine $ExpectedSha1) { throw "Integrity verification failed for $Filename" }
    }
    New-Item -ItemType Directory -Force -Path $ExtractInto | Out-Null
    Write-Host "Extracting $Filename..."
    & tar.exe -xf $archive -C $ExtractInto
    if ($LASTEXITCODE -ne 0) { throw "Extraction failed: $Filename" }
    if (-not (Test-Path $InstalledCheck)) { throw "Installed file not found: $InstalledCheck" }
    Write-Host "Installed $Filename successfully."
}

Install-Zip -Url "$base/emulator-windows_x64-16489710.zip" `
    -Filename 'emulator-windows_x64-16489710.zip' -ExpectedSize 459469167 `
    -ExpectedSha1 '4a0780da28b6e80783baf2505cab21f35b8bee56' `
    -ExtractInto $sdk -InstalledCheck (Join-Path $sdk 'emulator\emulator.exe')
Install-Zip -Url "$base/sys-img/google_atd/x86_64-35_r01.zip" `
    -Filename 'google_atd_x86_64-35_r01.zip' -ExpectedSize 813411228 `
    -ExpectedSha1 'e7fb65c5bc6c6fc81487be0834345b276d7b6951' `
    -ExtractInto (Join-Path $sdk 'system-images\android-35\google_atd') `
    -InstalledCheck (Join-Path $sdk 'system-images\android-35\google_atd\x86_64\system.img')
Write-Host 'Official Android Emulator and API 35 Google ATD image installed.'

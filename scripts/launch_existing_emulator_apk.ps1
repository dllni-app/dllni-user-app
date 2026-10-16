# Start the configured Android emulator and launch the prepared x86_64 Debug APK.
# This runs the last-built application; new source edits require a normal rebuild.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sdk = 'C:\laragon\www\Dllni\.tools\android-sdk'
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$apk = Join-Path $root 'build\app\outputs\flutter-apk\app-emulator-x64-debug.apk'
& (Join-Path $PSScriptRoot 'run_android_emulator.ps1') -BootOnly
if (-not (Test-Path $apk)) {
    throw 'Prepared emulator APK missing. Run scripts\prepare_emulator_debug_apk.ps1 first.'
}
$device = @(& $adb devices | Select-String '^(emulator-\d+)\s+device' |
    ForEach-Object { $_.Matches[0].Groups[1].Value } | Select-Object -First 1)
if (-not $device) { throw 'No booted Android emulator available.' }
& $adb -s $device install -r -t --no-incremental $apk
if ($LASTEXITCODE -ne 0) { throw 'APK installation failed.' }
& $adb -s $device shell am start -n 'com.alnadha.app/com.ahmadAlbetar.dllni_user_app.MainActivity'
if ($LASTEXITCODE -ne 0) { throw 'App launch failed.' }
Write-Host "User app launched on $device (existing Debug APK; no Gradle rebuild)."

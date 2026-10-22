param([string]$AvdName = 'Dllni_User_API35', [switch]$BootOnly)
$ErrorActionPreference = 'Stop'
$sdk = 'C:\laragon\www\Dllni\.tools\android-sdk'
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
$env:Path = "$env:JAVA_HOME\bin;$sdk\platform-tools;$sdk\emulator;$env:Path"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..'))
$emulatorExe = Join-Path $sdk 'emulator\emulator.exe'
if (-not (Test-Path $emulatorExe)) { throw 'Emulator is missing. Run .\scripts\setup_android_emulator.ps1 first.' }
$avds = @(& $emulatorExe -list-avds)
if ($avds -notcontains $AvdName) { throw "AVD $AvdName is missing. Run setup_android_emulator.ps1 first." }
$running = @(& adb devices | Select-String '^emulator-\d+\s+device')
if (-not $running) { Start-Process -FilePath $emulatorExe -ArgumentList @('-avd',$AvdName,'-memory','1536','-cores','2','-no-snapshot-load','-no-boot-anim','-gpu','host') | Out-Null }
& adb wait-for-device
$booted = $false
for ($i = 0; $i -lt 120; $i++) {
  $status = (& adb shell getprop sys.boot_completed 2>$null | Out-String).Trim()
  if ($status -eq '1') { $booted = $true; break }
  Start-Sleep -Seconds 2
}
if (-not $booted) { throw 'Android emulator did not finish booting.' }
$device = @(& adb devices | Select-String '^(emulator-\d+)\s+device' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Select-Object -First 1)
if (-not $device) { throw 'Cannot detect emulator device.' }
if ($BootOnly) { Write-Host "Android emulator $device is ready for VS Code debugging."; exit 0 }
& flutter run -d $device

# Connect an Android emulator to the Laravel service running on this computer.
# It is safe to call after every emulator restart.
param([string]$DeviceId = 'emulator-5554', [int]$Port = 8000)
$ErrorActionPreference = 'Stop'
$adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adb) {
  $adbPath = 'C:\laragon\www\Dllni\.tools\android-sdk\platform-tools\adb.exe'
  if (-not (Test-Path $adbPath)) { throw 'Android SDK adb.exe was not found' }
  $adbExe = $adbPath
} else { $adbExe = $adb.Source }
$running = (& $adbExe devices | Select-String "^$([regex]::Escape($DeviceId))\s+device")
if (-not $running) { throw "Android device $DeviceId is not connected." }
$listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if (-not $listener) { throw "Laravel is not listening on this computer at port $Port." }
& $adbExe -s $DeviceId reverse "tcp:$Port" "tcp:$Port"
if ($LASTEXITCODE -ne 0) { throw 'adb reverse failed' }
& $adbExe -s $DeviceId reverse --list
Write-Output "The emulator can now access http://127.0.0.1:$Port through your local Laravel server."

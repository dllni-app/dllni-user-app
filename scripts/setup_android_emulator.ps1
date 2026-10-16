param([string]$AvdName = 'Dllni_User_API35')
$ErrorActionPreference = 'Stop'
$sdk = 'C:\laragon\www\Dllni\.tools\android-sdk'
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
$env:Path = "$env:JAVA_HOME\bin;$sdk\platform-tools;$sdk\emulator;$env:Path"
$manager = Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
$avdManager = Join-Path $sdk 'cmdline-tools\latest\bin\avdmanager.bat'
& $manager --sdk_root=$sdk 'emulator' 'system-images;android-35;google_atd;x86_64'
if ($LASTEXITCODE -ne 0) {
  Write-Warning 'SDK Manager source unavailable. Trying verified Google CDN archives.'
  & (Join-Path $PSScriptRoot 'install_android_emulator_google_mirror.ps1')
}
$avds = @(& $avdManager list avd)
if (-not ($avds -match [regex]::Escape($AvdName))) {
  'no' | & $avdManager create avd --name $AvdName --package 'system-images;android-35;google_atd;x86_64' --force
  if ($LASTEXITCODE -ne 0) { throw 'Failed to create Android virtual device.' }
}
Write-Host "Created $AvdName. Run .\scripts\run_android_emulator.ps1"

# Emulator-only workaround when Google Maven cannot complete a full x86_64 Gradle build.
# Reuses the existing Flutter debug APK, adds the matching local x86_64 Flutter engine
# and signs a separate debug APK. Never use this APK for production release.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sdk = 'C:\laragon\www\Dllni\.tools\android-sdk'
$tools = Join-Path $sdk 'build-tools\35.0.0'
$source = Join-Path $root 'build\app\outputs\flutter-apk\app-debug.apk'
$unsigned = Join-Path $root 'build\app\outputs\flutter-apk\app-emulator-x64-unsigned.apk'
$aligned = Join-Path $root 'build\app\outputs\flutter-apk\app-emulator-x64-aligned.apk'
$output = Join-Path $root 'build\app\outputs\flutter-apk\app-emulator-x64-debug.apk'
$engine = Join-Path $sdk '.temp\libflutter-x86_64.so'
$store = Join-Path $env:USERPROFILE '.android\debug.keystore'
if (-not (Test-Path $source)) { throw 'Existing Debug APK missing. Build the user app first.' }
if (-not (Test-Path $engine)) { throw 'Extract Flutter x64 engine from C:\flutter\bin\cache\artifacts\engine\android-x64\flutter.jar first.' }
if (-not (Test-Path $store)) { throw 'Local Android debug keystore not found.' }
Copy-Item -Path $source -Destination $unsigned -Force
$python = 'C:\laragon\bin\python\python-3.13\python.exe'
& $python (Join-Path $PSScriptRoot 'inject_flutter_x64_engine.py') $unsigned $engine
if ($LASTEXITCODE -ne 0) { throw 'Failed to inject native engine' }
Write-Host 'Native x86_64 Flutter engine added uncompressed to emulator-only Debug APK.'
& (Join-Path $tools 'zipalign.exe') -P 16 -f 4 $unsigned $aligned
if ($LASTEXITCODE -ne 0) { throw 'zipalign failed' }
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
& (Join-Path $tools 'apksigner.bat') sign --ks $store --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out $output $aligned
if ($LASTEXITCODE -ne 0) { throw 'apksigner failed' }
& (Join-Path $tools 'apksigner.bat') verify --verbose $output
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
Write-Host "Emulator Debug APK ready: $output"

# Device QA Phase 4 — 2026-10-10

Branch: `dev` — project: `dllni-user-app`.

## Build artifact verified
- `build/app/outputs/apk/debug/app-debug.apk`, generated 2026-10-10 17:57:50.
- Size: 196,955,681 bytes.
- Package: `com.alnadha.app`, versionCode 23, versionName 1.0.0.
- Application label: `ع الندهة`.
- minSdk 24, targetSdk 36, compileSdk 36.
- `apksigner verify --print-certs`: signer Android Debug.
- APK certificate SHA-256: `204b18d6598344fc790ca28c3d0aac21effd9ac3b093ecfb07a08f91e874173c`.
- APK file SHA-256: `B0FEEEA3150F852975367F4C58BA3B2CCC64D1425D05BE68AED45B7A31F1E27A`.

## Automated regression results
- Cleaning / orders: **29/29 passed**, exit 0. Log: `docs/device-smoke/cleaning-regression-20261010.log`, completed at 18:05:10 local.
- Shared UI / auth / home / profile / notifications / restaurant / supermarket / session: **40/40 passed**, exit 0. Log: `docs/device-smoke/shared-ui-regression-20261010.log`, completed at 18:17:46 local.
- Combined: **69 tests passed, 0 failed**. These are local Flutter unit/widget tests, not physical-device E2E tests.

## Hardware blocker
- The phone was not detected by either `adb devices -l` or Windows present USB PnP queries during this phase.
- **No APK installation, no app uninstall, and no data reset performed**.
- Safe signing-aware installer prepared in `scripts/qa_redmi_safe_install_and_launch.ps1`. It refuses installation when USB is absent or the installed app signing certificate differs, and uses `adb install -r` only on a verified match.
- When Redmi is plugged in and authorized, run the signing comparison first; then execute the installer to update/launch/capture screenshot and relevant Android logs.
- Inspect screenshot / runtime logs and perform manual guided E2E for cleaning booking steps, RTL, cancellation, worker selection, session booking, active order tracking, and cross-section navigation.

## Preservation
- No tracked Android Gradle sources modified during this phase.
- No commit or push performed.
- Existing user data remains untouched.

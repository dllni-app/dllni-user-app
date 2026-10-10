# Android Debug Build — Dependency Resolution Blocker
Date: 2026-10-10
Project: dllni-user-app
Branch: dev
Device: Redmi Note 13 Pro (Android 16), ADB serial wgkjbm795pzpvovw

## Confirmed
- ADB detects the Redmi as device.
- No new Android debug APK was produced. Latest APK dates from 2026-07-12 and must not be used to validate October UI changes.
- Android SDK platform 36, build tools 36 and NDK 27 are installed in the workspace.
- Source Gradle files have no tracked differences after temporary QA build attempts.
- Approximately 5.5 GB of disk space remained after the last attempt.
- Existing 29 cleaning + order widget regression tests passed in earlier QA run. These are not device E2E tests.
- Gradle 8.12, AGP 8.9.1, Kotlin plugin 2.1.0 produce forward-compatibility warnings; upgrading without a successful dependency resolution baseline is not safe.

## Primary build blocker
An offline run of :app:assembleDebug on 2026-10-10 exited 1 within 21 seconds. The log shows 30 required JARs not cached locally (examples):
- org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0 (Gradle 8.5 variant)
- org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.0
- org.jetbrains.kotlinx:kotlinx-serialization-json-jvm:1.4.0
- com.android.tools.build:transform-api:2.0.0-deprecated-use-gradle-api
- org.ow2.asm:asm:9.7
- com.google.guava:guava:32.0.1-jre

Log: docs/device-smoke/build_20261010_161823/gradle-build.log

Online attempts via Maven mirrors intermittently stall inside Gradle's HTTPS dependency resolution despite individual URL HEAD probes succeeding. The final low-parallelism Java/DNS attempt was stopped after no log progress. It exited 1 and left original Gradle files restored.

Log: docs/device-smoke/build_20261010_162450/gradle-build.log

## Next safe route
1. Connect Windows to a stable network that can access dl.google.com, repo.maven.apache.org, and plugins.gradle.org (or a properly configured trusted Maven mirror).
2. Ensure at least 5 GB of additional free working disk space before downloading remaining artifacts and producing new Android build intermediates.
3. Run a limited build once; do not run several Gradle jobs in parallel. If network is stable, use the existing temporary QA build script in scripts/, not permanent Gradle repository changes.
4. If possible, install the project-required NDK 28.2.13676358 when disk capacity allows, replacing the temporary NDK 27 override.
5. Only when a new APK is built, validate its package/signature against the installed application before considering an install; never uninstall or clear data automatically.
6. Perform on-device visual regression testing of RTL booking, recurring sessions, worker selection, order tracking and login.

## Scope/safety
No changes to backend endpoints, app business logic, production dependencies, or release signing.
No changes pushed or committed; branch remains dev.

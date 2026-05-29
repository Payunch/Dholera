# AdMob Setup (dev / staging / prod)

This file explains how the project manages AdMob App IDs per build flavor/configuration and how to run the app locally for debugging.

Files you may have already seen
- `android/gradle.properties.sample` — sample per-flavor properties (copy to `android/gradle.properties` and edit; do NOT commit real keys).
- `ios/Runner/AppIDs.xcconfig` — sample Xcode config mapping build configurations to `GADApplicationIdentifier`.
- `android/app/src/main/AndroidManifest.xml` — contains a manifest placeholder for the App ID:
  - `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="${com.google.android.gms.ads.APPLICATION_ID}"/>`
- `android/app/build.gradle.kts` — defines `dev`, `staging`, and `prod` flavors and sets `manifestPlaceholders` from Gradle properties.

Quick setup (Android)
1. Copy the sample properties and edit locally:

   - Linux/macOS/Windows (PowerShell):

     Copy `android/gradle.properties.sample` to `android/gradle.properties`.

   - Edit `android/gradle.properties` and set `ADMOB_APP_ID_PROD` to your production App ID.

2. Build / run the `dev` flavor locally (the `dev` flavor falls back to the AdMob test ID):

   flutter run --flavor dev -t lib/main.dart

3. To explicitly pass a production App ID at build time:

   cd android
   ./gradlew assembleProdRelease -PADMOB_APP_ID_PROD=ca-app-pub-XXXXXXXX~YYYYYYYY

Notes about Android emulators
- If you don't have an emulator, use Android Studio AVD Manager to create one, or follow the command-line steps described in the developer docs.
- First-time emulator boot can take several minutes.

Quick setup (iOS)
1. Add `ios/Runner/AppIDs.xcconfig` to your Xcode project and assign it to your Debug/Release configurations.
2. In Xcode, set each configuration's `GADApplicationIdentifier` build setting to the corresponding variable (for example, `$(GADApplicationIdentifier_debug)` for Debug).

Debugging tips for MobileAds startup crash
- If you see an IllegalStateException complaining "Invalid application ID", the merged manifest likely doesn't contain a valid App ID. Confirm:
  - The merged manifest (under `android/app/build/intermediates/merged_manifests/<flavor>/<buildType>/AndroidManifest.xml`) contains the App ID value (not the literal placeholder string).
  - The Gradle property for the flavor is set (e.g., `ADMOB_APP_ID_DEV`).
- For quick debugging, temporarily set the test App ID directly in `AndroidManifest.xml` (replace meta-data value with `ca-app-pub-3940256099942544~3347511713`) — rebuild, verify, then revert before production.

Security and best practices
- Never commit production AdMob App IDs or keys to the repository. Use `android/gradle.properties` (local) or CI secrets to inject production values.
- Use the official AdMob test App ID for local development and testing.

If you'd like, I can add a small `docs/` README or example CI snippet that shows how to inject `ADMOB_APP_ID_PROD` during a GitHub Actions build.

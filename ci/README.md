# CI Integration Notes

This document explains the CI workflows added to this repository and the secrets they require.

Workflows

- `.github/workflows/android-ci.yml`
  - Purpose: builds the Android production APK (`assembleProdRelease`) and uploads the APK as an artifact.
  - Injects `ADMOB_APP_ID_PROD` into `android/gradle.properties` at runtime so the manifest placeholder is substituted with your real AdMob App ID.

- `.github/workflows/ios-ci.yml`
  - Purpose: builds an unsigned iOS app for validation (`flutter build ios --no-codesign`) and uploads the unsigned `Runner.app` as an artifact.
  - Injects `GAD_APP_ID_IOS` into `ios/Runner/AppIDs.xcconfig` at runtime so `GADApplicationIdentifier` resolves in the Info.plist.

Required repository secrets

- `ADMOB_APP_ID_PROD` — your production AdMob App ID (format: `ca-app-pub-...~...`). Used by `android-ci.yml`.
- `GAD_APP_ID_IOS` — your iOS AdMob App ID (format: `ca-app-pub-...~...`). Used by `ios-ci.yml`.

How the secret is used

- The Android workflow appends a line to `android/gradle.properties` during the job containing `ADMOB_APP_ID_PROD` and then runs Gradle. The workflow removes the line after the build.
- The iOS workflow overwrites `ios/Runner/AppIDs.xcconfig` during the job so Xcode/Flutter picks up the `GADApplicationIdentifier` value.

Security guidance

- Do not commit production App IDs to the repository. Keep them in GitHub Actions secrets or a secure secrets manager.
- The workflows attempt to remove the injected secret from workspace files after the job, but secrets may still appear in logs if printed — avoid echoing secrets.

Troubleshooting

- If the Android build fails with `Invalid application ID` at runtime, ensure `ADMOB_APP_ID_PROD` is set in repository secrets and the workflow run shows the property being written (the job includes a step that writes to `android/gradle.properties`).
- For iOS, ensure `GAD_APP_ID_IOS` is set and that Info.plist uses `$(GADApplicationIdentifier)`.

If you want, I can add an example GitHub Actions secret setup guide (screenshots or CLI commands) or extend the Android workflow to also run unit tests.

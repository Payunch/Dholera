Analytics integration notes — Flutter app (Dholera)

1) Firebase (mobile) setup
- Android: place `google-services.json` into `android/app/`.
- iOS: place `GoogleService-Info.plist` into `ios/Runner/` and add to Xcode bundle resources.
- Web: use `FirebaseOptions` or add config object in `web/index.html` and initialize `Firebase.initializeApp(options)`.

After adding platform files, run:
```bash
cd Dholera
flutter pub get
flutter run -d <device>
```

2) GTM for Flutter Web
- A GTM script snippet was added to `web/index.html` with placeholder container `GTM-WM9HRJVV`.
- Replace `GTM-WM9HRJVV` with your container ID or inject dynamically during CI/CD.

6) AdMob (mobile) integration
- Add the `google_mobile_ads` package to `pubspec.yaml` (done).
- Initialize the SDK by calling `MobileAds.instance.initialize()` in `main()` (done).
- Add your AdMob app IDs:
  - Android: set `com.google.android.gms.ads.APPLICATION_ID` in `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:
    ```xml
    <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-xxxxxxxx~yyyyyyyy"/>
    ```
  - Place `google-services.json` in `android/app/` (Firebase Android config). Do NOT commit this file to source control.
  - Ensure `com.google.gms:google-services` Gradle plugin is available; the project `android/build.gradle.kts` was updated to include the Google services classpath and `android/app/build.gradle.kts` applies the plugin.

  7) Consent handling
  - A simple in-app consent dialog was added (`lib/widgets/consent_dialog.dart`) and persisted via `lib/consent.dart` using SharedPreferences.
  - Analytics collection is toggled via `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(...)` based on consent during startup.
  - Ad requests will use non-personalized ads if the user rejects personalized ads (AdMob request uses `nonPersonalizedAds`).
  - iOS: add `GADApplicationIdentifier` key in `ios/Runner/Info.plist`.
- Replace test ad unit IDs in `lib/admob.dart` with your real ad unit IDs when ready.
- A sample `AdBanner` widget and interstitial helper were added to the codebase.

3) Testing & smoke checks
- Open app (web): check browser devtools Network for `gtm.js?id=GTM-XXXXX` and `collect` calls to Google Analytics.
- For Firebase Analytics (mobile), use `adb logcat` on Android to view analytics events or use the DebugView in Firebase Console:
  - Enable analytics debug on Android: `adb shell setprop debug.firebase.analytics.app <your.app.package>` then run app.
  - For iOS, use Xcode console and follow Firebase DebugView docs.

4) Consent & privacy
- Ensure you comply with regional consent laws (EEA/UK). For web, implement a consent banner that calls `dataLayer.push({'event':'consent_update', 'analytics': true})` and configure GTM to respect consent.

5) Next actions I can do for you
- Add dynamic replacement of GTM id via build-time env var for web.
- Add a lightweight consent banner in the Flutter web UI that toggles `dataLayer` consent.
- Run `flutter build web` and simulate network checks locally.

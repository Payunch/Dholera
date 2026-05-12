# Dholera Admin APK Release Guide

This guide provides step-by-step instructions for building and deploying the Dholera Admin Flutter APK.

## Prerequisites

✅ Flutter SDK installed  
✅ Android SDK with NDK (v28.2 or higher)  
✅ Gradle installed  
✅ Java 17+ configured  

## Building the Release APK

### Step 1: Accept Android SDK Licenses

The build system requires Android SDK license acceptance. On your local machine with Android Studio:

```bash
# Option A: Using Android Studio (Recommended)
# Open Android Studio → Tools → SDK Manager → Appearance & Behavior → System Settings → Android SDK
# Click "SDK Tools" tab and accept licenses for:
# - Android SDK Command-line Tools
# - Android NDK (Side by side) 28.2.x

# Option B: Using command line
cd ~/android-sdk-path
./bin/sdkmanager --licenses
# Type 'y' and press Enter to accept all licenses
```

### Step 2: Configure Backend URL

Before building, update the backend API endpoint:

```bash
cd dholera_admin_flutter
```

Edit `lib/config/api_config.dart`:

```dart
// Update this line with your deployed backend URL:
static const String API_BASE_URL = 'https://your-api-server.com/api';
```

**Important:** Use HTTPS for production. For local testing on Android, use your machine's IP instead of `localhost`.

### Step 3: Get Dependencies

```bash
flutter pub get
```

### Step 4: Build Release APK

```bash
flutter build apk --release

# Output location:
# build/app/release/app-release.apk
```

Or build for specific architecture:

```bash
# ARM64 (most common for modern devices)
flutter build apk --release --target-platform android-arm64

# ARM (older devices)
flutter build apk --release --target-platform android-arm

# x86 (emulators)
flutter build apk --release --target-platform android-x86-64

# All architectures in one APK (app bundle)
flutter build appbundle --release
```

### Step 5: Install on Device/Emulator

#### On Physical Device:

```bash
# Ensure device is connected via USB with USB debugging enabled
flutter install --release

# Or manually:
adb install build/app/release/app-release.apk
```

#### On Android Emulator:

```bash
# Start emulator first
emulator -avd <emulator_name> &

# Install APK
flutter run --release
```

## Production Release Signing

For Google Play Store distribution, sign the APK with your production keystore:

### Create Keystore (One-time)

```bash
keytool -genkey -v -keystore ~/dholera-admin-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias dholera-admin \
  -storepass your_storepass \
  -keypass your_keypass

# When prompted, fill in your details:
# First and last name: Dholera Admin
# Organizational unit: Admin App
# Organization: Dholera Growth
# City: Gandhinagar
# State/Province: Gujarat
# Country code: IN
```

### Create Signing Configuration

Create `android/key.properties`:

```properties
storeFile=/path/to/dholera-admin-key.jks
storePassword=your_storepass
keyPassword=your_keypass
keyAlias=dholera-admin
```

### Build Signed APK

```bash
flutter build apk --release --verbose

# APK will be automatically signed with the keystore from key.properties
```

## Debugging Build Issues

### License Error

If you get: `Failed to install the following Android SDK packages as some licences have not been accepted`

**Solution:**
```bash
# On Linux with system Android SDK:
sudo echo -e "\n8933bad161af4d5e80854a3d99a2f18c8abf1456\nd56f5187479451eabf01fb78af6dfcb131b33968" \
  > /usr/lib/android-sdk/licenses/android-sdk-license

sudo echo -e "\n79120722343a6f314e0719f863036319f60439a5" \
  > /usr/lib/android-sdk/licenses/ndk-license
```

### Build Cache Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

### NDK Not Found

```bash
# Check Flutter's Android SDK configuration
flutter doctor -v

# Ensure ANDROID_SDK_ROOT is set correctly
export ANDROID_SDK_ROOT=/path/to/android-sdk
flutter build apk --release
```

## Testing the APK

### On Device

```bash
# Install
adb install build/app/release/app-release.apk

# View app logs
adb logcat

# Uninstall
adb uninstall com.dholera.admin
```

### Network Testing

The app connects to the configured backend API. Verify:

- Backend is running and accessible
- API endpoint is correct in `api_config.dart`
- Backend returns valid tokens on `/auth/login`
- Device can reach the backend URL

```bash
# Test from device
adb shell ping your-api-server.com
adb shell curl -I https://your-api-server.com/api/auth/me
```

## Uploading to Google Play Store

1. Sign up for [Google Play Developer Console](https://play.google.com/console)
2. Create new app: "Dholera Admin"
3. Fill in app details (description, screenshots, etc.)
4. Build signed APK (see above)
5. Upload signed APK/AAB to Play Store
6. Set up store listing, pricing, and distribution
7. Submit for review

## Distribution Alternatives

If not using Play Store:

### Direct APK Distribution
```bash
# Share app-release.apk directly
# Users can install via:
adb install app-release.apk
# Or email/download + manual installation
```

### Internal App Sharing (Google Play)
```bash
# Upload to internal testing track first
# Share link with testers without Store listing
# Faster review than production release
```

## Troubleshooting Deployment

### "App not installed"
- Check device Android version compatibility (Flutter standard is Android 5.0+)
- Try debug APK first: `flutter build apk --debug`

### "Signature mismatch"
- Ensure same keystore used for all releases
- Keep keystore file safe and backed up

### "Certificate expired"
- Check keystore expiration: `keytool -list -v -keystore ~/dholera-admin-key.jks`
- Create new keystore if expired (upload new App certificate to Play Store)

### Connection refused to backend
- Verify backend URL in `api_config.dart`
- Test network connectivity from device
- Check backend CORS settings for Android app domain

## Next Steps

After successful APK build and testing:

1. ✅ Build release APK
2. ✅ Test on multiple Android devices
3. ✅ Configure production backend URL
4. ✅ Create signed keystore
5. ✅ Build signed release APK
6. ✅ Upload to Google Play Store or distribute directly

---

**For more Flutter build help:** https://flutter.dev/docs/deployment/android  
**Google Play Store guidelines:** https://play.google.com/console/about/guides/

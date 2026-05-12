# Dholera Admin Flutter APK - Complete Quick Start

This guide provides everything you need to build and deploy the Dholera Admin app as an Android APK.

## 📋 Quick Summary

| Task | Command |
|------|---------|
| **Setup** | `./setup-build.sh` |
| **Build APK** | `./build-apk.sh` |
| **Install** | `flutter install` |
| **Test API Config** | Edit `lib/config/api_config.dart` |
| **License Help** | Read `ANDROID_LICENSE_FIX.md` |

## 🚀 Getting Started (5 minutes)

### Step 1: Automatic Setup

```bash
cd dholera_admin_flutter
./setup-build.sh
```

This script will:
- ✅ Check Flutter installation
- ✅ Find your Android SDK
- ✅ Accept required licenses
- ✅ Verify build environment

### Step 2: Configure Backend URL

Edit `lib/config/api_config.dart`:

```dart
// Change this to your backend server
static const String API_BASE_URL = 'https://your-api.com/api';
```

### Step 3: Build the APK

```bash
./build-apk.sh
```

Or use Flutter directly:

```bash
flutter build apk --release
```

**Output:** `build/app/release/app-release.apk`

### Step 4: Install on Device

```bash
# Connect Android device via USB (enable USB debugging)
flutter install

# Or install directly
adb install build/app/release/app-release.apk
```

## 🔧 Common Issues

### ❌ "License not accepted" Error

**Solution:** Run `./setup-build.sh` or see [ANDROID_LICENSE_FIX.md](ANDROID_LICENSE_FIX.md)

### ❌ "Android SDK not found"

**Solution:** Set ANDROID_SDK_ROOT environment variable:

```bash
export ANDROID_SDK_ROOT=/path/to/your/android-sdk
./setup-build.sh
```

### ❌ "Flutter not found"

**Solution:** Install Flutter from https://flutter.dev/docs/get-started/install

## 📖 Available Documentation

| File | Purpose |
|------|---------|
| `README.md` | Main project overview |
| `APK_BUILD_GUIDE.md` | Complete build & deploy instructions |
| `ANDROID_LICENSE_FIX.md` | License error solutions |
| `setup-build.sh` | Automated environment setup |
| `build-apk.sh` | Build script with logging |

## 🏗️ Build Variants

### Debug APK (for testing)

```bash
flutter build apk --debug
# Output: build/app/debug/app-debug.apk
```

### Release APK (for production)

```bash
flutter build apk --release
# Output: build/app/release/app-release.apk
```

### App Bundle (for Google Play Store)

```bash
flutter build appbundle --release
# Output: build/app/release/app-release.aab
```

## 🔐 Production Signing

For Google Play Store, sign the APK:

1. **Create keystore** (one-time):
   ```bash
   keytool -genkey -v -keystore ~/dholera-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias dholera-admin
   ```

2. **Create signing config** (`android/key.properties`):
   ```properties
   storeFile=/path/to/dholera-key.jks
   storePassword=password
   keyPassword=password
   keyAlias=dholera-admin
   ```

3. **Build signed APK**:
   ```bash
   flutter build apk --release
   ```

## 📱 Testing the App

### On Emulator

```bash
# Start emulator first
emulator -avd MyEmulator &

# Run app
flutter run
```

### On Physical Device

```bash
# Enable USB debugging on device
# Connect device via USB

adb devices  # Verify connection

flutter run
```

### Testing Backend Connection

```bash
# From computer (same network as device)
ping your-api-server.com

# Or from device via ADB
adb shell ping your-api-server.com
```

## 🐛 Troubleshooting

### Build Fails After License Setup

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### App Crashes on Launch

1. Check logs: `adb logcat | grep -i flutter`
2. Verify backend URL in `api_config.dart`
3. Test backend is accessible: `adb shell curl your-api/api/auth/csrf-token`

### CPU Architecture Mismatch

```bash
# Build for all architectures
flutter build appbundle --release

# Or specific architecture
flutter build apk --release --target-platform android-arm64
```

## 📊 Build Output Info

After successful build, you'll see the APK path and size:

```
✅ APK built successfully!

📦 Output: build/app/release/app-release.apk
📊 Size: 62.5MB
```

## 🚢 Deployment Checklist

- [ ] Backend API configured and running
- [ ] API URL set in `lib/config/api_config.dart`
- [ ] Android SDK licenses accepted
- [ ] APK built successfully (`./build-apk.sh`)
- [ ] APK tested on device
- [ ] Admin login works with backend credentials
- [ ] Dashboard loads and displays data
- [ ] Release signing configured (for Play Store)

## 📚 Next Steps

### For Development

1. Modify app code in `lib/`
2. Test with `flutter run`
3. Build debug APK: `./build-apk.sh debug`

### For Production

1. Update backend URL for production server
2. Create signed keystore (see "Production Signing")
3. Build release APK: `./build-apk.sh`
4. Test APK thoroughly
5. Upload to Google Play Store or distribute APK

### For Distribution

**Google Play Store:**
- Upload signed AAB (app bundle)
- Complete store listing
- Submit for review

**Direct APK Distribution:**
- Share `app-release.apk` file
- Users install via `adb install` or download + install

## 💡 Pro Tips

1. **Save build logs:** `flutter build apk --release 2>&1 | tee build.log`
2. **Track APK versions:** Update version in `pubspec.yaml`
3. **Keep keystore safe:** Backup `android/key.properties` and keystore file
4. **Test on multiple devices:** Different Android versions and screen sizes
5. **Monitor app size:** Use `flutter build apk --analyze-size`

## 🔗 Useful Links

- [Flutter Deployment](https://flutter.dev/docs/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android SDK Setup](https://developer.android.com/studio/intro/update)
- [Dholera Backend API](../dholera-backend/README.md)

## ❓ Getting Help

If you encounter issues:

1. **Check documentation:** See linked files above
2. **Run diagnostics:** `flutter doctor -v`
3. **View error logs:** `flutter build apk --release --verbose`
4. **Search Flutter docs:** https://flutter.dev/docs

---

**Ready to build?** Start with: `./setup-build.sh` then `./build-apk.sh`

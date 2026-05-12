# Android SDK License Error - Solution

## The Problem

When building the Flutter APK, you may see:

```
FAILURE: Build failed with an exception.

com.android.builder.sdk.LicenceNotAcceptedException: 
Failed to install the following Android SDK packages as some licences have not been accepted.
    ndk;28.2.13676358 NDK (Side by side) 28.2.13676358
```

This happens because the Android NDK and SDK require explicit license acceptance before use.

## Solution 1: Automated Setup (Recommended)

Run the automated setup script:

```bash
cd dholera_admin_flutter
./setup-build.sh
```

This script will:
- Verify Flutter and Android SDK installation
- Accept all required licenses automatically
- Validate your build environment

## Solution 2: Manual License Acceptance via Android Studio

1. Open **Android Studio**
2. Go to: **Tools** → **SDK Manager**
3. Click the **SDK Tools** tab
4. Check these components:
   - Android NDK (Side by side) 28.2.x or higher
   - Android SDK Command-line Tools
5. Click **OK** and accept the license agreement popups

## Solution 3: Command Line License Acceptance

If you have `sdkmanager` available:

```bash
# Find your Android SDK
export ANDROID_SDK_ROOT=$HOME/Android/Sdk  # or your SDK location

# Accept licenses interactively
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses

# Type 'y' and press Enter for each license
```

## Solution 4: Manual License Files (Linux with system Android SDK)

If using system-wide Android SDK at `/usr/lib/android-sdk`:

```bash
# Create license directory
sudo mkdir -p /usr/lib/android-sdk/licenses

# Accept Android SDK licenses
sudo bash -c 'cat > /usr/lib/android-sdk/licenses/android-sdk-license << EOF
8933bad161af4d5e80854a3d99a2f18c8abf1456
d56f5187479451eabf01fb78af6dfcb131b33968
EOF'

# Accept NDK licenses
sudo bash -c 'cat > /usr/lib/android-sdk/licenses/ndk-license << EOF
79120722343a6f314e0719f863036319f60439a5
EOF'
```

## Solution 5: Set Correct Android SDK Path

Sometimes the build fails because it can't find the SDK:

```bash
# Check where your Android SDK is installed
find ~ -name "ndk-bundle" -type d 2>/dev/null

# If found, set the environment variable:
export ANDROID_SDK_ROOT="/path/to/your/sdk"

# Then try building again
flutter build apk --release
```

## Solution 6: Update Android SDK Components

The NDK version might be outdated:

```bash
# Update SDK components
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
  "platform-tools" \
  "build-tools;36.0.0" \
  "platforms;android-36" \
  "ndk;28.2.13676358"
```

## After Accepting Licenses

Once licenses are accepted, build should work:

```bash
# Clean previous build artifacts
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Output will be at:
# build/app/release/app-release.apk
```

## Verify License Acceptance

Check that licenses were accepted:

```bash
ls -la $ANDROID_SDK_ROOT/licenses/

# You should see files like:
# android-sdk-license
# ndk-license
# android-sdk-preview-license
```

## Common Issues

### "sdkmanager not found"
The SDK command-line tools aren't installed. Install them via Android Studio:
- Open Android Studio
- Tools → SDK Manager → SDK Tools
- Check "Android SDK Command-line Tools"

### "Permission denied" on Linux
When creating license files, you may need sudo. The setup script handles this automatically.

### "Still getting license error after acceptance"
Try these steps:
1. Run `flutter clean`
2. Verify ANDROID_SDK_ROOT is set: `echo $ANDROID_SDK_ROOT`
3. Check licenses exist: `ls $ANDROID_SDK_ROOT/licenses/`
4. Try building with verbose output: `flutter build apk --release --verbose`

## Environment Setup for Persistence

Add to your `.bashrc`, `.zshrc`, or `.bash_profile`:

```bash
# Android SDK
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Still Having Issues?

Run full diagnosis:

```bash
flutter doctor -v
```

This will show:
- Flutter version and paths
- Android SDK location and version
- Java version
- Any missing components

Share the output if you need help troubleshooting.

## Reference

- [Flutter Build Setup Documentation](https://flutter.dev/docs/deployment/android)
- [Android SDK Setup Guide](https://developer.android.com/studio/intro/update)
- [NDK Installation](https://developer.android.com/studio/projects/install-ndk)

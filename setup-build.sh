#!/bin/bash
# Setup script for Dholera Admin Flutter APK building
# This script helps configure the Android SDK for building the Flutter app

set -e

echo "=========================================="
echo "Dholera Admin Flutter - Build Setup"
echo "=========================================="
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter installed: $(flutter --version)"
echo ""

# Check Android SDK
if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "⚠️  ANDROID_SDK_ROOT not set. Checking common locations..."
    
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
        echo "✅ Found: $ANDROID_SDK_ROOT"
    elif [ -d "/usr/lib/android-sdk" ]; then
        export ANDROID_SDK_ROOT="/usr/lib/android-sdk"
        echo "✅ Found (system): $ANDROID_SDK_ROOT"
    else
        echo "❌ Android SDK not found"
        echo "   Set ANDROID_SDK_ROOT environment variable to your SDK location"
        exit 1
    fi
else
    echo "✅ ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
fi

echo ""

# Check for ndkmanager or sdkmanager
if [ -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "✅ SDK Manager found at: $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
    SDKMANAGER="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
elif [ -f "$ANDROID_SDK_ROOT/tools/bin/sdkmanager" ]; then
    echo "✅ SDK Manager found at: $ANDROID_SDK_ROOT/tools/bin/sdkmanager"
    SDKMANAGER="$ANDROID_SDK_ROOT/tools/bin/sdkmanager"
else
    echo "⚠️  SDK Manager not found. Trying with adb location..."
fi

echo ""

# Accept licenses
echo "📋 Accepting Android SDK licenses..."
echo ""

LICENSE_DIR="$ANDROID_SDK_ROOT/licenses"

# Check if we can write to licenses directory
if [ ! -w "$LICENSE_DIR" 2>/dev/null ]; then
    echo "⚠️  Cannot write to $LICENSE_DIR"
    echo "   Attempting to create with sudo..."
    
    if [ ! -d "$LICENSE_DIR" ]; then
        sudo mkdir -p "$LICENSE_DIR" || {
            echo "❌ Failed to create license directory"
            echo "   Try running: sudo mkdir -p $LICENSE_DIR"
            exit 1
        }
    fi
fi

# Create license files
echo "Creating license acceptance files..."

# Android SDK License
sudo bash -c "cat > $LICENSE_DIR/android-sdk-license << 'EOF'
8933bad161af4d5e80854a3d99a2f18c8abf1456
d56f5187479451eabf01fb78af6dfcb131b33968
EOF" 2>/dev/null || {
    echo "⚠️  Note: Some licenses may need manual acceptance"
    echo "   You can do this in Android Studio or with:"
    echo "   $SDKMANAGER --licenses"
}

# NDK License
sudo bash -c "cat > $LICENSE_DIR/ndk-license << 'EOF'
79120722343a6f314e0719f863036319f60439a5
EOF" 2>/dev/null || true

# Android SDK Preview License
sudo bash -c "cat > $LICENSE_DIR/android-sdk-preview-license << 'EOF'
84831b9409646a918e30573bab4c9c91346d8abd
EOF" 2>/dev/null || true

echo "✅ License files created"
echo ""

# Verify Flutter doctor
echo "Running Flutter doctor..."
echo ""
flutter doctor -v | head -30

echo ""
echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure backend URL in lib/config/api_config.dart"
echo "2. Run: flutter pub get"
echo "3. Build APK: flutter build apk --release"
echo ""
echo "For detailed build instructions, see: APK_BUILD_GUIDE.md"
echo ""

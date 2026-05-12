#!/bin/bash
# Flutter APK Build Script for Dholera Admin
# This script builds the release APK with proper configuration

set -e

echo "=========================================="
echo "Dholera Admin - Flutter APK Builder"
echo "=========================================="
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not installed"
    exit 1
fi

# Determine build type
BUILD_TYPE="${1:-release}"

if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
    echo "Usage: $0 [debug|release] [--clean]"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build release APK"
    echo "  $0 debug            # Build debug APK"
    echo "  $0 release --clean  # Clean build + release APK"
    exit 1
fi

# Check for --clean flag
CLEAN_BUILD=false
if [ "$2" == "--clean" ]; then
    CLEAN_BUILD=true
fi

echo "Build Type: $BUILD_TYPE"
echo ""

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 Cleaning previous builds..."
    flutter clean
    flutter pub get
    echo ""
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Build APK
echo "🔨 Building APK..."
echo ""

if [ "$BUILD_TYPE" = "debug" ]; then
    flutter build apk --debug --verbose
    APK_PATH="build/app/debug/app-debug.apk"
else
    flutter build apk --release --verbose
    APK_PATH="build/app/release/app-release.apk"
fi

echo ""
echo "=========================================="

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "✅ APK built successfully!"
    echo ""
    echo "📦 Output: $APK_PATH"
    echo "📊 Size: $APK_SIZE"
    echo ""
    
    # Installation option
    echo "Install options:"
    echo "  adb install $APK_PATH"
    echo "  flutter install"
    echo ""
else
    echo "❌ Build failed - APK not found at $APK_PATH"
    exit 1
fi

echo "=========================================="

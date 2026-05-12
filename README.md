# Dholera Admin Flutter App

A native Flutter application for managing Dholera Growth platform infrastructure data and leads on Android and iOS devices.

## Features

- ✅ **Admin Authentication** - JWT-based login with CSRF token protection
- ✅ **Dashboard** - Real-time analytics overview (leads, updates, visitors)
- ✅ **Lead Management** - View and manage project leads
- ✅ **Infrastructure Updates** - Create and track infrastructure updates
- ✅ **Analytics** - Track visitor sessions and engagement metrics
- ✅ **Secure API Communication** - Token-based API authentication

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10+)
- [Android Studio](https://developer.android.com/studio) or equivalent Android development environment
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- Backend API deployed and accessible

## Project Structure

```
lib/
├── main.dart              # App entry point with authentication wrapper
├── config/
│   └── api_config.dart    # API configuration and endpoints
├── services/
│   └── api_service.dart   # API client and HTTP communication
├── models/
│   └── auth_provider.dart # Authentication state management
└── pages/
    ├── login_page.dart    # Admin login page
    └── dashboard_page.dart # Main dashboard
```

## Setup

### 1. Install Dependencies

```bash
cd dholera_admin_flutter
flutter pub get
```

### 2. Android SDK License Setup (First Time Only)

**Important:** The first build requires accepting Android SDK licenses.

**Quick Setup (Automated):**
```bash
./setup-build.sh
```

**Or Manual:**
See [ANDROID_LICENSE_FIX.md](ANDROID_LICENSE_FIX.md) for detailed license acceptance instructions.

### 3. Configure API Endpoint

Update `lib/config/api_config.dart` to point to your backend server:

```dart
// For production (deployed backend)
static const String API_BASE_URL = 'https://your-api-server.com/api';
```

**Note:** If testing on a physical device with local backend, use device IP instead of `localhost`.

### 4. Run on Emulator/Device

```bash
flutter run
```

## Building APK

### Release APK (Production)

```bash
flutter build apk --release
# Output: build/app/release/app-release.apk
```

**Important:** Before building, read [APK_BUILD_GUIDE.md](APK_BUILD_GUIDE.md) for:
- Android SDK license acceptance (required for first-time builds)
- Keystore setup for signed releases
- Testing and deployment instructions
- Troubleshooting common build errors

### Install & Run

```bash
flutter install
```

## Authentication Flow

1. User enters email and password on login page
2. App requests CSRF token from backend
3. App sends login request with credentials and CSRF token
4. Backend validates and returns JWT token
5. Token is stored in device storage
6. User is redirected to dashboard
7. All subsequent API requests include JWT token

## API Integration

The `ApiService` class handles all backend communication with JWT token management and error handling.

## State Management

Uses Provider for state management. `AuthProvider` handles authentication status and API token management.

## Production Deployment

1. Update `api_config.dart` with production backend URL (HTTPS)
2. Update app version in `pubspec.yaml`
3. Build release APK: `flutter build apk --release`
4. Sign APK with production keystore
5. Test and deploy to Google Play Store or distribute via APK

## Support

Refer to:
- [QUICK_START.md](QUICK_START.md) - **Start here for fastest setup**
- [APK_BUILD_GUIDE.md](APK_BUILD_GUIDE.md) - Complete build & deployment instructions
- [ANDROID_LICENSE_FIX.md](ANDROID_LICENSE_FIX.md) - License acceptance troubleshooting
- Backend: `dholera-backend/README.md`
- Flutter docs: https://flutter.dev/docs
- Provider: https://pub.dev/packages/provider

---

**Built with Flutter + Dart | Connected to Dholera Backend API**

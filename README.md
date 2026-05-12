# Dholera Admin Mobile App

## Executive Summary

The **Dholera Admin App** is a native mobile application for managing the Dholera Growth platform. It provides administrators with real-time operational intelligence, lead management, infrastructure updates, and secure document distribution—all accessible from the field.

**Current Status:**
- ✅ APK builds successfully with `flutter build apk --release`
- ✅ Git repository configured for large binary artifacts (Git LFS)
- ✅ All core features operational and mission-ready
- ⚠️ Backend API endpoint configuration required for deployment

---

## Platform Architecture

### Core Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|----------|
| **Framework** | Flutter 3.10+ (Dart) | Cross-platform mobile development |
| **State Mgmt** | Provider Pattern | Centralized application state |
| **Persistence** | SharedPreferences | Secure token storage |
| **API Client** | Custom ApiService | Backend integration with resilient error handling |
| **Security** | JWT + CSRF tokens | API request authentication |
| **Build Target** | Android 5.0+ / iOS 11+ | Device compatibility range |

### Key Features

1. **Operational Dashboard**
   - Real-time metrics: Total leads, monthly growth, visitor engagement
   - Quick-glance project health indicators

2. **Lead Management System**
   - Comprehensive investor database with source tracking
   - One-tap calling and WhatsApp integration
   - Visit history and engagement analytics

3. **Infrastructure Updates (Blog)**
   - Publish project progress directly from field
   - Image and rich-text support
   - Timestamp tracking for all updates

4. **PDF & Document Manager**
   - Secure upload portal for Nakshas (plot maps) and brochures
   - Token-based access control
   - Automated expiration and revocation

5. **Business Settings**
   - Dynamic configuration of contact info and app settings
   - Multi-user access control

---

## Development & Deployment

### Build Process

```bash
# Setup (first time only)
export ANDROID_SDK_ROOT=~/.android/sdk
export ANDROID_HOME=~/.android/sdk
./setup-build.sh

# Build Release APK
flutter build apk --release
# Output: build/app/release/app-release.apk
```

### Required Configuration

Before deployment, update `lib/config/api_config.dart` with the backend API endpoint:

```dart
static const String API_BASE_URL = 'https://your-backend-domain.com/api';
```

### APK Distribution

- **Direct Install**: `adb install build/app/release/app-release.apk`
- **Google Play Store**: Use production keystore for signed APK
- **Internal Testing**: Share APK file directly with team members

---

## System Integration

The app communicates exclusively with the **Dholera Backend API** (Node.js Express):

- **Authentication**: JWT tokens with CSRF protection
- **Session Management**: Persistent session cookies for reliability
- **Error Resilience**: Automatic retry logic for network fluctuations
- **Data Validation**: Ultra-resilient JSON parsing

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── api_config.dart          # API endpoint configuration
├── services/
│   ├── api_service.dart         # Backend HTTP client
│   └── auth_service.dart        # Authentication logic
├── models/
│   ├── lead.dart                # Lead data model
│   ├── pdf_document.dart        # Document metadata
│   └── app_update.dart          # Infrastructure update model
├── pages/
│   ├── login_page.dart          # Admin authentication
│   ├── dashboard_page.dart      # Main operational dashboard
│   ├── leads_page.dart          # Lead management interface
│   └── pdf_manager_page.dart    # Document upload/view interface
└── widgets/                     # Reusable UI components
```

---

## Operational Requirements

### Hardware Requirements
- **Mobile Device**: Android 5.0+ or iOS 11+
- **Storage**: 60 MB free space for APK and app data
- **Network**: Reliable internet connection for API calls

### Software Requirements
- **Flutter SDK**: Version 3.10 or higher
- **Android SDK**: API 21+ (Android 5.0)
- **Java**: Version 17 or higher (for build tools)

### Environment Setup
```bash
cd dholera
flutter pub get
```

---

## Roadmap & Future Enhancements

- [ ] Multi-factor authentication for admin login
- [ ] Offline-first support with local database caching
- [ ] Push notifications for lead updates
- [ ] Advanced analytics and reporting
- [ ] iOS-specific optimizations

---

## Support & Documentation

- **Quick Start**: See [QUICK_START.md](QUICK_START.md)
- **APK Build Guide**: See [APK_BUILD_GUIDE.md](APK_BUILD_GUIDE.md)
- **Android License Issues**: See [ANDROID_LICENSE_FIX.md](ANDROID_LICENSE_FIX.md)
- **Backend API**: See [dholera-backend README](../Dholera-backend/README.md)
- **Web Frontend**: See [dholera-frontend README](../Dholera-frontend/README.md)

---

**Built with Flutter | Managed by Dholera Admin Team | Last Updated: May 2026**

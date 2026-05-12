# Dholera Project: Admin Command & Control (Mobile)

The **Dholera Admin App** is a mission-critical mobile application built with Flutter, designed for the on-the-ground management of the Dholera Growth platform. It provides administrators with real-time oversight of leads, infrastructure progress, and secure document distribution.

## 📱 Executive Overview

This application serves as the central management hub, allowing the Dholera team to respond to investor interest instantly and keep the public portal updated with the latest progress.

- **Native Performance**: Built with Flutter for smooth, cross-platform performance on Android and iOS.
- **Operational Intelligence**: Real-time dashboard providing bird's-eye view of project health.
- **Mobile First**: Optimized for field work, allowing admins to upload plot maps (Nakshas) and manage leads from anywhere.

## 🛡️ Recent "Senior Developer" Upgrades (May 2026)

I have implemented several enterprise-grade features to move the app from a prototype to a fully functional production tool:

### 1. Persistent Session Architecture
*   **Problem**: Users were forced to log in every time the app was opened.
*   **Solution**: Implemented a secure, dual-token persistence system. The app now saves the **JWT Token** and the **Session Cookie** in encrypted local storage.
*   **Result**: The app remains logged in across restarts, with an automatic "Verifying session..." check on startup.

### 2. Gallery & Media Integration
*   **Feature**: Added **Native Image Picking** to the Property Updates section.
*   **Functionality**: Admins can now snap a photo or pick an existing construction image from their phone gallery and upload it directly to the cloud via the backend.

### 3. Real-Time Lead Management
*   **Dynamic Status Control**: Added a status dropdown to lead details. You can now move leads from "New" → "Contacted" → "Converted" directly from your mobile screen.
*   **One-Tap Actions**: Hardened the integration for instant **WhatsApp** messaging and **Phone Calling**, optimized for modern Android/iOS permission systems.

### 4. Smart Data Synchronization (Pagination)
*   **Optimization**: Implemented "Lazy Loading" (Pagination) for the leads list. 
*   **Bug Fix**: Resolved an issue where duplicate leads appeared while scrolling. The app now fetches data in clean batches of 20, improving speed and reducing data usage.

## 🛠️ Technology & Security

| Feature | Implementation |
|---------|----------------|
| **Core Framework** | Flutter 3.10+ (Dart) |
| **State Management** | Provider Pattern |
| **API Client** | Custom Resilient `ApiService` with HTML-error detection |
| **Persistence** | Secure `SharedPreferences` (Token + Session Cookie) |
| **Permissions** | Android Package Visibility (Queries) for URL launching |

## 🚀 Key Modules

*   **Analytics Dashboard**: Real-time tracking of Total Leads, Growth, and Engagement.
*   **Property Blog**: Field-ready tool for publishing construction updates with high-res photos.
*   **Secure Document Center**: Portal for managing sensitive plot maps (Nakshas) with token-based view protection.
*   **Business Settings**: Centralized control for contact info and app configuration.

## 🔌 System Integration

The app is tightly integrated with the **Dholera Central API**:
- **Monorepo Layout**: For unified development, the entire ecosystem is now organized here:
    - `/dholera-frontend`: React-based Customer Web Portal.
    - `/dholera-backend`: Node.js/Express API Gateway.
- **Resilient Parsing**: Uses an ultra-resilient JSON handler to ensure the app never crashes even if the backend returns unexpected data formats.
- **Production Ready**: Fully configured to connect to the Railway production environment with SSL/HTTPS.

---
**Dholera Platform | Powering Infrastructure Management**

# Dholera Growth Evidence Platform

A high-conviction land-investment information platform designed to transform infrastructure evidence into qualified leads and site visits.

## 🏗️ Architecture

The platform is built with a modern decoupled architecture:
- **Frontend:** React + Vite (Multilingual UX, Material UI, PWA support).
- **Backend:** Node.js + Express (Sequelize ORM, SQLite, JWT Security).

## 📂 Project Structure

```text
dholera/
├── backend/                # Node.js Express API
│   ├── config/             # Database connection settings
│   ├── controllers/        # Business logic for API endpoints
│   ├── middleware/         # Auth & upload security layers
│   ├── models/             # Sequelize database models
│   ├── routes/             # API route definitions
│   ├── scripts/            # Database seeding & migration scripts
│   ├── services/           # External integrations (WhatsApp, etc.)
│   ├── uploads/            # Persistent storage for images/PDFs
│   ├── audit_exports/      # Exported lead reports
│   ├── index.js            # Server entry point
│   └── package.json        # Backend dependencies
├── frontend/               # React Vite Application
│   ├── public/             # Static assets (Sitemap, PWA manifest)
│   ├── src/                # React source code
│   │   ├── api/            # API client configurations
│   │   ├── components/     # Reusable UI components
│   │   ├── pages/          # Full page layouts (Public & Admin)
│   │   └── theme/          # MUI styling configuration
│   ├── package.json        # Frontend dependencies
│   └── vite.config.js      # Build & PWA configuration
├── infra/                  # Infrastructure config (Nginx, Render)
├── DEPLOYMENT.md           # Deployment instructions
└── README.md               # Main documentation
```

## 🚀 Getting Started

### 1. Backend Setup
```bash
cd backend
npm install
npm run dev
```
- API runs on: `http://localhost:3000`
- Database: Local `database.sqlite`

### 2. Frontend Setup
```bash
cd frontend
npm install
npm run dev
```
- UI runs on: `http://localhost:5173`

---

## 📱 Build Android APK (Admin Access)

To have full administrative control from your mobile device, follow these steps to wrap the project using **Capacitor**.

### Prerequisites
- [Android Studio](https://developer.android.com/studio) installed.
- Deployed Backend URL (APK cannot use `localhost`).

### Step-by-Step Build
1. **Initialize Capacitor:**
   ```bash
   cd frontend
   npm install @capacitor/core @capacitor/cli @capacitor/android
   npx cap init DholeraApp com.dholera.app --web-dir dist
   ```

2. **Configure Production API:**
   Update `frontend/.env` to point `VITE_API_BASE_URL` to your live server.

3. **Build & Sync:**
   ```bash
   npm run build
   npx cap add android
   npx cap sync android
   ```

4. **Generate APK in Android Studio:**
   ```bash
   npx cap open android
   ```
   - In Android Studio: **Build > Build Bundle(s) / APK(s) > Build APK(s)**.
   - Install the resulting `app-debug.apk` on your device.

### Admin Dashboard Access
Once the app is open on your phone:
- Navigate to `/admin/login` within the app.
- Log in with your admin credentials to manage leads and updates on the go.

---

## ✅ Final Verification
- [x] Redundant files (`.venv`, `cookies.txt`, `scratch_*.js`) removed.
- [x] Project structure consolidated into `backend` and `frontend`.
- [x] Admin-level APK workflow documented.
- [x] Node.js scripts standardized.

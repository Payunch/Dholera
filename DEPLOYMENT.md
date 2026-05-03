# Dholera Ecosystem - Deployment Setup

The ecosystem is split into two deployable units: Frontend (Vite/React) and Backend (FastAPI).

## Frontend Deployment (Vercel)
The frontend is optimized for static hosting with edge caching for maximum speed.
1. Connect the repository to Vercel.
2. **Framework Preset:** Vite.
3. **Build Command:** `npm run build`
4. **Output Directory:** `dist`
5. **Environment Variables:**
   - `VITE_API_URL`: Your backend domain (e.g., `https://api.dholeragrowth.com`)
   - `VITE_WHATSAPP_NUMBER`: Your business WhatsApp number (e.g., `919876543210`)

## Backend Deployment (Render / Railway)
The backend runs FastAPI with a PostgreSQL database.
1. Connect the repository to Render/Railway.
2. **Root Directory:** `backend/`
3. **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. **Database:** Attach a managed PostgreSQL database.
5. **Environment Variables:**
   - `DATABASE_URL`: Your Postgres connection string.
   - `SECRET_KEY`: Long random string for JWT generation.
   - `BACKEND_CORS_ORIGINS`: `["https://dholeragrowth.com", "http://localhost:5173"]`

## Progressive Web App (PWA)
- `manifest.webmanifest` and `sw.js` are served statically from `/public` in the frontend. 
- Mobile users visiting the site will be prompted to "Add to Home Screen". This fulfills the APK/Mobile App requirement seamlessly across Android and iOS without App Store review delays.

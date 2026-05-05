# Dholera Deployment And Security Steps

This project currently uses:
- Frontend: React + Vite (Vercel recommended)
- Backend: Node.js + Express + SQLite (Render/Railway recommended)

## 1) Backend deployment (Render)

Use [infra/render.backend.yaml](infra/render.backend.yaml) or configure manually:

1. Create a new Web Service from this repo.
2. Set Root Directory to `backend`.
3. Build Command: `npm install`
4. Start Command: `node index.js`
5. Health Check Path: `/healthz`

Required backend environment variables:

- `NODE_ENV=production`
- `PORT=3000`
- `ALLOWED_ORIGINS=https://your-frontend-domain.vercel.app`
- `ADMIN_USER=<strong-username>`
- `ADMIN_PASS=<strong-random-password>`
- `JWT_SECRET=<long-random-secret>`
- `ADMIN_LOCKOUT_THRESHOLD=5`
- `ADMIN_LOCKOUT_MS=1800000`

OTP + WhatsApp (recommended for production):

- `WHATSAPP_API_VERSION=v20.0`
- `WHATSAPP_PHONE_NUMBER_ID=<meta-phone-number-id>`
- `WHATSAPP_ACCESS_TOKEN=<meta-permanent-token>`
- `WHATSAPP_OTP_TEMPLATE_NAME=otp_verification`
- `WHATSAPP_TEMPLATE_LANGUAGE=en`

Notes:
- If WhatsApp credentials are missing, OTP still works in fallback mode (logged on server console).
- Backend now has `helmet`, CORS allowlist, request size limit, and rate limits enabled.
- Backend now stores security/audit events in `AuditLogs` (admin login outcomes, OTP events, and lead admin actions).

## 2) Frontend deployment (Vercel)

1. Import the repo in Vercel.
2. Framework Preset: `Vite`
3. Root Directory: `frontend`
4. Build Command: `npm run build`
5. Output Directory: `dist`

Frontend environment variables:

- `VITE_API_BASE_URL=https://your-backend-domain.onrender.com/api`
- `VITE_SITE_URL=https://your-frontend-domain.vercel.app`
- `VITE_WHATSAPP_NUMBER=919xxxxxxxxx`

After backend URL is set, redeploy frontend.

## 3) Complete OTP system checklist

1. Create and approve a WhatsApp template in Meta (for example, `otp_verification`) with one body variable for OTP.
2. Add WhatsApp env variables in backend host.
3. Test endpoint flow:
   - `POST /api/leads/send-otp`
   - `POST /api/leads/verify-otp`
4. Confirm lead token is stored in browser after verification and secure PDF opens.
5. Confirm OTP limits:
   - send OTP max 5/15min per IP
   - verify OTP max 15/15min per IP

## 4) Hardening checklist (must-do)

1. Set strong values for `ADMIN_PASS` and `JWT_SECRET`.
2. Restrict `ALLOWED_ORIGINS` to your real domains only.
3. Rotate WhatsApp and JWT secrets every 60-90 days.
4. Keep dependencies updated (`npm audit` monthly).
5. Enable HTTPS only on custom domains.
6. Keep admin URL private and monitor failed login attempts.

## 5) Post-deploy verification

1. Check health endpoint:
   - `GET https://your-backend-domain/healthz`
2. Check CORS by opening frontend and performing OTP send/verify.
3. Check admin login at `/admin/login`.
4. Check protected admin APIs return `401/403` without token.
5. Check PDF access requires a verified lead token.

# Dholera Growth Evidence Platform

High-conviction land-investment information platform that turns infrastructure evidence into qualified leads, WhatsApp conversations, and site visits.

## What is implemented

- React + Vite public website with multilingual UX
- FastAPI + SQLAlchemy + PostgreSQL backend
- JWT-based admin authentication
- Admin dashboard for updates and leads
- Image/PDF upload pipeline with thumbnail generation
- Public growth feed with filtering, pagination, and related updates
- SEO pages and sitemap generation
- PWA support through vite-plugin-pwa

## Repository structure

```text
.
|-- backend/
|   |-- app/
|   |   |-- api/
|   |   |-- core/
|   |   |-- db/
|   |   |-- models/
|   |   |-- schemas/
|   |   `-- services/
|   |-- scripts/
|   |-- uploads/
|   |-- .env.example
|   `-- requirements.txt
|-- frontend/
|   |-- public/
|   |-- scripts/
|   |-- src/
|   |-- .env.example
|   |-- package.json
|   |-- vercel.json
|   `-- vite.config.js
|-- infra/
|   |-- nginx-reverse-proxy.conf
|   `-- render.backend.yaml
|-- DEPLOYMENT.md
`-- STRATEGY.md
```

## Frontend structure

**Philosophy:** Lean real-estate lead engine, NOT enterprise SaaS. Favor clarity and speed over scalability blueprints.

### `/frontend/public`
Static assets:
- `manifest.webmanifest` — PWA metadata
- `robots.txt` — SEO directives
- `sitemap.xml` — Generated at build time
- `sw.js` — Service worker

### `/frontend/src`
**Core entry points:**
- `App.jsx` — Router, theme, context providers
- `main.jsx` — React entry point
- `theme.js` — MUI config (colors, typography, spacing)
- `styles.css` — Global CSS

**`/api`** — Single unified API client
- `client.js` — Axios instance with JWT token interceptor
- `api.js` — All routes (public, auth, admin) in one file; if it grows past 500 lines, split into public.js + admin.js

**`/components`** — Grouped by purpose, not by abstraction level

`/layouts`
- `MainLayout.jsx` — Header, footer, navigation for public pages
- `AdminLayout.jsx` — Sidebar for admin dashboard

`/common`
- `Seo.jsx` — Dynamic meta tags, OpenGraph, schema
- `SectionHeader.jsx` — Reusable section heading component
- `Loader.jsx` — Loading spinner

`/lead`
- `LeadForm.jsx` — Contact/inquiry form (one form, multiple CTA flows)
- `StickyWhatsAppButton.jsx` — Floating WhatsApp CTA

`/updates`
- `UpdateCard.jsx` — Single update card for feed display

**`/pages`** — Organized by public vs admin

`/public`
- `HomePage.jsx` — Project PDFs, Nakhsa maps, and DP layouts with lazy loading and skeleton screens
- `UpdatesPage.jsx` — Feed, filters, pagination (was GrowthTrackerPage)
- `UpdateDetailPage.jsx` — Single update + related
- `MapsPage.jsx` — Maps and corridor resources
- `ContactPage.jsx` — Lead capture, WhatsApp, site visits

`/admin`
- `LoginPage.jsx` — JWT login
- `DashboardPage.jsx` — Stats, recent leads, recent updates
- `LeadsPage.jsx` — Leads pipeline, filters, status updates
- `UpdatesManagePage.jsx` — Create, edit, delete, publish updates

**`/context`** — Global state
- `AuthContext.jsx` — User, token, login/logout
- `LanguageContext.jsx` — en/hi/gu locale

**`/data`** — Static content (not `/content`)
- `siteData.js` — Hero metrics, growth drivers, industry refs, map resources

**`/utils`** — Helper functions
- `analytics.js` — Event tracking (gtag, fbq)
- `localization.js` — Resolve multilingual text
- `whatsapp.js` — Build WhatsApp URL with preset messages

### `/frontend/scripts`
- `generate-sitemap.mjs` — Fetch update slugs from backend, write sitemap.xml

### Config files
- `package.json` — Dependencies
- `vite.config.js` — Build + PWA plugin
- `vercel.json` — SPA rewrites, cache headers
- `.env.example` — Template env vars

**Total pages: 5 public + 4 admin = 9 pages. Not 11.**

**Removed:**
- ❌ `FutureGrowthPage.jsx` — Merge into HomePage or as a section
- ❌ `LandingPage.jsx` — Dynamic campaign sections in HomePage instead
- ❌ Separate `publicApi.jsx` + `adminApi.jsx` → Single `api.js`
- ❌ Separate `uiCopy.js` → Localization strings live in component context
- ❌ Nested abstraction layers — Everything is co-located by feature

## Local development

### 1) Backend setup

```bash
cd /home/prs/Documents/dholera
python3 -m venv .venv
source .venv/bin/activate
pip install -r backend/requirements.txt
cp backend/.env.example backend/.env
```

Update backend environment values in `backend/.env`, especially:

- `DATABASE_URL`
- `SECRET_KEY`
- `BACKEND_CORS_ORIGINS`
- `DEFAULT_ADMIN_EMAIL`
- `DEFAULT_ADMIN_PASSWORD`

Run backend:

```bash
cd /home/prs/Documents/dholera/backend
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### 2) Seed default data

```bash
cd /home/prs/Documents/dholera
source .venv/bin/activate
cd backend
python scripts/seed.py
```

This creates:

- default admin user (from env values)
- sample updates
- sample leads

### 3) Frontend setup

```bash
cd /home/prs/Documents/dholera/frontend
npm install
cp .env.example .env
npm run dev
```

Default frontend URL: `http://localhost:5173`

### 4) Start both services quickly

Terminal 1:

```bash
cd /home/prs/Documents/dholera
source .venv/bin/activate
cd backend
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Terminal 2:

```bash
cd /home/prs/Documents/dholera/frontend
npm run dev
```

## Environment variables

### Backend (`backend/.env`)

```env
APP_NAME=Dholera Growth Evidence API
API_V1_STR=/api/v1
SECRET_KEY=change-this-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=1440
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/dholera_platform
BACKEND_CORS_ORIGINS=http://localhost:5173,https://your-vercel-domain.vercel.app
BASE_URL=http://localhost:8000
FRONTEND_URL=http://localhost:5173
WHATSAPP_NUMBER=919999999999
MAX_IMAGE_UPLOAD_MB=8
MAX_PDF_UPLOAD_MB=15
DEFAULT_ADMIN_NAME=Platform Admin
DEFAULT_ADMIN_EMAIL=admin@example.com
DEFAULT_ADMIN_PASSWORD=ChangeMe123!
```

### Frontend (`frontend/.env`)

```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_SITE_URL=http://localhost:5173
VITE_WHATSAPP_NUMBER=919999999999
VITE_GA_ID=
VITE_META_PIXEL_ID=
```

## Frontend routes

- `/` — Home with Project PDFs, Nakhsa Maps, and DP Maps (lazy loaded with skeleton screens)
- `/updates` — Growth tracker feed with filters and pagination
- `/updates/:slug` — Single update detail page
- `/maps` — Project maps and corridor resources
- `/contact` — Lead capture form, contact information, social links
- `/admin/login` — Admin authentication
- `/admin/dashboard` — Admin dashboard with stats and recent activity
- `/admin/updates` — Manage published updates (create, edit, delete)
- `/admin/leads` — Lead CRM with pipeline management

## API routes

### Public

- `GET /api/v1/public/health`
- `GET /api/v1/public/meta`
- `GET /api/v1/public/updates`
- `GET /api/v1/public/updates/{slug}`
- `POST /api/v1/public/leads`
- `GET /api/v1/public/sitemap-data`

### Auth

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

### Admin

- `GET /api/v1/admin/dashboard`
- `GET /api/v1/admin/meta`
- `GET /api/v1/admin/updates`
- `POST /api/v1/admin/updates`
- `PUT /api/v1/admin/updates/{id}`
- `DELETE /api/v1/admin/updates/{id}`
- `GET /api/v1/admin/leads`
- `PATCH /api/v1/admin/leads/{id}`

### Uploads

- `POST /api/v1/admin/uploads/image`
- `POST /api/v1/admin/uploads/pdf`

## Build and production

### Frontend

```bash
cd frontend
npm install
npm run sitemap
npm run build
```

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

For hosting details, use:

- `DEPLOYMENT.md`
- `infra/render.backend.yaml`
- `infra/nginx-reverse-proxy.conf`

## Verification commands

```bash
python3 -m compileall backend/app backend/scripts
cd frontend && npm run build
```

sudo /opt/lampp/lampp start

sudo /opt/lampp/lampp stop
sudo /opt/lampp/lampp restart
sudo /opt/lampp/manager-linux-x64.run

cd /home/prs/Documents/dholera/backend && /home/prs/Documents/dholera/backend/.venv/bin/python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
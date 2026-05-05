const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const express = require('express');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const csurf = require('csurf');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { sequelize } = require('./models');
const { testConnection } = require('./config/database');

const app = express();
const bootAt = new Date().toISOString();

const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:5173,http://localhost:5174')
  .split(',')
  .map(origin => origin.trim())
  .filter(Boolean);

const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' }
});

// Middleware
app.set('trust proxy', 1);
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' }
}));
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    // Reject disallowed origins without turning the request into a 500 error.
    return callback(null, false);
  },
  credentials: true
}));
app.use(globalLimiter);
app.use(express.json({ limit: '5mb' })); // Increased limit for larger articles
app.use(morgan('dev'));
app.use(cookieParser());

// Ensure required directories exist
const fs = require('fs');
const uploadsDir = path.join(__dirname, 'uploads');
const imagesDir = path.join(uploadsDir, 'images');
[uploadsDir, imagesDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`Created directory: ${dir}`);
  }
});

// Session store: use Redis when REDIS_URL provided, otherwise fallback to in-memory store (not for production)
let sessionStore = undefined;
if (process.env.REDIS_URL) {
  try {
    const { default: RedisStore } = require('connect-redis');
    const IORedis = require('ioredis');
    const client = new IORedis(process.env.REDIS_URL);
    sessionStore = new RedisStore({ client });
    console.log('Using Redis session store');
  } catch (err) {
    console.warn('Redis packages not available, falling back to in-memory session store:', err.message);
  }
} else {
  console.warn('REDIS_URL not set: using in-memory session store (not suitable for production)');
}

const SESSION_SECRET = process.env.SESSION_SECRET || process.env.JWT_SECRET || 'dev-session-secret';

app.use(session({
  store: sessionStore,
  secret: SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 24 * 60 * 60 * 1000 // 1 day
  }
}));

// Request logger for debugging (Moved after session middleware)
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  console.log('Session ID:', req.sessionID);
  console.log('Is Admin Session:', !!req.session?.isAdmin);
  next();
});

const csrfProtection = csurf();

// Apply CSRF only to admin/session-protected mutations.
app.use((req, res, next) => {
  const isSafeMethod = req.method === 'GET' || req.method === 'HEAD' || req.method === 'OPTIONS';
  if (isSafeMethod) return next();

  const isAuthMutation = req.path === '/api/auth/login' || req.path === '/api/auth/logout';
  const isAdminSessionMutation = Boolean(req.session?.isAdmin || req.cookies?.admin_access_token || req.cookies?.admin_refresh_token);
  const isPublicLeadMutation = [
    '/api/leads',
    '/api/leads/send-otp',
    '/api/leads/verify-otp',
    '/api/leads/save-direct',
    '/api/leads/verify',
    '/api/leads/track-returning',
    '/api/track'
  ].includes(req.path);

  if (isAuthMutation || (isAdminSessionMutation && !isPublicLeadMutation)) {
    return csrfProtection(req, res, next);
  }
  return next();
});

// Helper endpoint for frontend to fetch the CSRF token (establishes session cookie)
app.get('/api/auth/csrf-token', csrfProtection, (req, res) => {
  try {
    return res.json({ csrfToken: req.csrfToken() });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to generate CSRF token' });
  }
});
app.use('/uploads', (req, res, next) => {
  if (req.path.endsWith('.pdf')) {
    return res.status(403).json({ error: 'Direct PDF access is forbidden. Use secure viewer.' });
  }
  next();
}, express.static(path.join(__dirname, 'uploads')));

app.get('/healthz', (req, res) => {
  res.json({ ok: true, service: 'dholera-backend' });
});

app.get('/healthz/runtime', (req, res) => {
  const configuredPort = Number.parseInt(process.env.PORT || '3000', 10);
  res.json({
    ok: true,
    service: 'dholera-backend',
    bootAt,
    pid: process.pid,
    nodeEnv: process.env.NODE_ENV || 'development',
    configuredPort,
    allowedOrigins,
    uptimeSec: Math.round(process.uptime())
  });
});

// Routes
app.use('/api/leads', require('./routes/leads'));
app.use('/api/updates', require('./routes/updates'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/auth', require('./routes/auth'));
app.use('/api/track', require('./routes/track'));
app.use('/api/pdf', require('./routes/pdf'));
app.use('/api/whatsapp', require('./routes/whatsapp'));
app.use('/api/settings', require('./routes/settings'));

const PORT = process.env.PORT || 3000;

// Start audit exporter if configured
try {
  const { startAuditExporter } = require('./services/auditExporter');
  startAuditExporter();
} catch (err) {
  console.warn('Audit exporter not started:', err.message || err);
}

// Database Sync and Server Start
const shouldAlterSchema = process.env.DB_SYNC_ALTER === 'true';

(async () => {
  const connected = await testConnection();
  if (!connected) {
    console.error('[DB] ❌ Aborting server start due to database connection failure.');
    process.exit(1);
  }

  try {
    await sequelize.sync({ alter: shouldAlterSchema });
    console.log('[DB] Tables synced successfully.');
  } catch (err) {
    console.error('[DB] ❌ Failed to sync tables:', err.message);
    console.error('[DB] Try setting DB_SYNC_ALTER=true in .env to auto-migrate columns.');
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`[Server] ✅ Running on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
  });
})();

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err);
  
  if (err && err.code === 'EBADCSRFTOKEN') {
    return res.status(403).json({ error: 'Invalid CSRF token. Please refresh the page.' });
  }

  // Handle Multer errors
  if (err instanceof require('multer').MulterError) {
    return res.status(400).json({ error: `Upload error: ${err.message}` });
  }

  res.status(err.status || 500).json({ 
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
  });
});

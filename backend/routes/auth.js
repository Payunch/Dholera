const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const { logAuditEvent } = require('../services/auditLogger');
const { cleanText } = require('../utils/sanitize');
const {
  isMfaEnabled,
  verifyMfaCode,
  issueAdminTokens,
  rotateRefreshToken,
  revokeRefreshToken,
  setAuthCookies,
  clearAuthCookies,
  getTokenFromRequest,
  verifyAccessToken,
  getMfaProvisioningUri
} = require('../services/adminSecurity');

const ADMIN_USER = process.env.ADMIN_USER;
const ADMIN_PASS = process.env.ADMIN_PASS;
const JWT_SECRET = process.env.JWT_SECRET;
const LOGIN_WINDOW_MS = Number.parseInt(process.env.ADMIN_LOGIN_WINDOW_MS || `${15 * 60 * 1000}`, 10);
const LOGIN_MAX_ATTEMPTS = Number.parseInt(process.env.ADMIN_LOGIN_MAX_ATTEMPTS || '10', 10);
const LOGIN_LOCKOUT_THRESHOLD = Number.parseInt(process.env.ADMIN_LOCKOUT_THRESHOLD || '5', 10);
const LOGIN_LOCKOUT_MS = Number.parseInt(process.env.ADMIN_LOCKOUT_MS || `${30 * 60 * 1000}`, 10);
const failedLoginState = new Map();

if (!ADMIN_USER || !ADMIN_PASS || !JWT_SECRET) {
  console.warn('Missing ADMIN_USER/ADMIN_PASS/JWT_SECRET environment variables. Admin login is disabled.');
}

const safeEqual = (a, b) => {
  const aBuffer = Buffer.from(a || '', 'utf8');
  const bBuffer = Buffer.from(b || '', 'utf8');
  if (aBuffer.length !== bBuffer.length) return false;
  return crypto.timingSafeEqual(aBuffer, bBuffer);
};

const loginLimiter = rateLimit({
  windowMs: LOGIN_WINDOW_MS,
  max: LOGIN_MAX_ATTEMPTS,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many login attempts. Please try again later.' }
});

const getLockoutKey = (username, ip) => `${String(username || '').toLowerCase()}:${ip || 'unknown'}`;

const registerLoginFailure = (key) => {
  const now = Date.now();
  const current = failedLoginState.get(key) || { count: 0, lockUntil: 0 };
  const count = current.count + 1;
  const lockUntil = count >= LOGIN_LOCKOUT_THRESHOLD ? now + LOGIN_LOCKOUT_MS : 0;
  failedLoginState.set(key, { count, lockUntil });
  return { count, lockUntil };
};

const clearLoginFailure = (key) => {
  failedLoginState.delete(key);
};

const getTokenPayload = (req) => {
  const accessToken = getTokenFromRequest(req, 'admin_access_token');
  if (!accessToken) return null;
  try {
    return verifyAccessToken(accessToken);
  } catch (err) {
    return null;
  }
};

const verifyToken = (req, res, next) => {
  if (req.session?.isAdmin) {
    req.user = { role: 'admin', username: req.session.username };
    return next();
  }

  const accessPayload = getTokenPayload(req);
  if (accessPayload?.sub) {
    req.user = { role: 'admin', username: accessPayload.sub };
    req.authMethod = 'access-token';
    
    // Re-establish session if it's missing (e.g. server restarted but JWT cookie persists)
    // This is required because CSRF protection relies on the session secret.
    if (req.session && !req.session.isAdmin) {
      req.session.isAdmin = true;
      req.session.username = accessPayload.sub;
    }
    
    return next();
  }

  const refreshToken = req.cookies?.admin_refresh_token;
  if (refreshToken) {
    try {
      const rotated = rotateRefreshToken(refreshToken);
      if (rotated?.accessToken && rotated?.refreshToken) {
        setAuthCookies(res, rotated);
        const refreshedPayload = verifyAccessToken(rotated.accessToken);
        req.user = { role: 'admin', username: refreshedPayload.sub };
        req.authMethod = 'refresh-token';
        req.authRefreshed = true;

        // Re-establish session for rotated refresh token
        if (req.session && !req.session.isAdmin) {
          req.session.isAdmin = true;
          req.session.username = refreshedPayload.sub;
        }

        return next();
      }
    } catch (err) {
      clearAuthCookies(res);
    }
  }

  return res.status(401).json({ error: 'Unauthorized' });
};

router.post('/login', loginLimiter, async (req, res) => {
  if (!ADMIN_USER || !ADMIN_PASS || !JWT_SECRET) {
    await logAuditEvent({
      eventType: 'admin.login.unavailable',
      actorType: 'admin',
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent']
    });
    return res.status(503).json({ error: 'Admin auth is not configured on server.' });
  }

  const username = cleanText(req.body?.username, 80);
  const password = cleanText(req.body?.password, 120);
  const mfaCode = cleanText(req.body?.mfaCode, 16);
  const lockKey = getLockoutKey(username, req.ip);
  const lockInfo = failedLoginState.get(lockKey);

  if (lockInfo?.lockUntil && lockInfo.lockUntil > Date.now()) {
    await logAuditEvent({
      eventType: 'admin.login.locked',
      actorType: 'admin',
      actorId: username || null,
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: {
        lockUntil: new Date(lockInfo.lockUntil).toISOString()
      }
    });
    return res.status(429).json({ error: 'Account temporarily locked due to failed logins. Try later.' });
  }

  if (safeEqual(username, ADMIN_USER) && safeEqual(password, ADMIN_PASS)) {
    if (isMfaEnabled() && !verifyMfaCode(mfaCode)) {
      const failure = registerLoginFailure(lockKey);
      await logAuditEvent({
        eventType: 'admin.login.mfa_failed',
        actorType: 'admin',
        actorId: username || null,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: {
          failedCount: failure.count,
          lockUntil: failure.lockUntil ? new Date(failure.lockUntil).toISOString() : null
        }
      });
      return res.status(401).json({ error: 'Invalid MFA code', mfaRequired: true });
    }

    clearLoginFailure(lockKey);

    req.session.regenerate(async (err) => {
      if (err) {
        console.error('Session regenerate error:', err);
        return res.status(500).json({ error: 'Failed to create session' });
      }

      req.session.isAdmin = true;
      req.session.username = username;
      req.session.mfaEnabled = isMfaEnabled();

      const tokens = issueAdminTokens({ username });
      setAuthCookies(res, tokens);

      await logAuditEvent({
        eventType: 'admin.login.success',
        actorType: 'admin',
        actorId: username,
        success: true,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: {
          mfaEnabled: isMfaEnabled(),
          authMethod: 'session+jwt'
        }
      });

      res.json({ ok: true, username, mfaEnabled: isMfaEnabled() });
    });
  } else {
    const failure = registerLoginFailure(lockKey);
    await logAuditEvent({
      eventType: 'admin.login.failed',
      actorType: 'admin',
      actorId: username || null,
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: {
        failedCount: failure.count,
        lockUntil: failure.lockUntil ? new Date(failure.lockUntil).toISOString() : null
      }
    });
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

router.post('/refresh', async (req, res) => {
  const refreshToken = req.cookies?.admin_refresh_token;
  if (!refreshToken) {
    return res.status(401).json({ error: 'Missing refresh token' });
  }

  try {
    const rotated = rotateRefreshToken(refreshToken);
    if (!rotated) {
      clearAuthCookies(res);
      return res.status(401).json({ error: 'Refresh token expired or invalid' });
    }
    setAuthCookies(res, rotated);
    const payload = verifyAccessToken(rotated.accessToken);
    return res.json({ ok: true, username: payload.sub });
  } catch (err) {
    clearAuthCookies(res);
    return res.status(401).json({ error: 'Refresh token expired or invalid' });
  }
});

router.post('/logout', async (req, res) => {
  try {
    const username = req.session?.username || null;
    const refreshToken = req.cookies?.admin_refresh_token;
    revokeRefreshToken(refreshToken);
    req.session.destroy(async (err) => {
      if (err) return res.status(500).json({ error: 'Failed to destroy session' });
      clearAuthCookies(res);
      await logAuditEvent({
        eventType: 'admin.logout',
        actorType: 'admin',
        actorId: username,
        success: true,
        ip: req.ip,
        userAgent: req.headers['user-agent']
      });
      res.json({ ok: true });
    });
  } catch (err) {
    console.error('Logout error:', err);
    res.status(500).json({ error: 'Logout failed' });
  }
});

router.get('/me', verifyToken, (req, res) => {
  return res.json({ username: req.user?.username || req.session?.username || null, mfaEnabled: isMfaEnabled(), authMethod: req.authMethod || 'session' });
});

router.get('/mfa/status', (req, res) => {
  return res.json({ enabled: isMfaEnabled(), issuer: process.env.ADMIN_MFA_ISSUER || 'Dholera Growth Evidence Platform' });
});

router.get('/mfa/provisioning-uri', verifyToken, (req, res) => {
  const username = req.user?.username || req.session?.username || ADMIN_USER || 'admin';
  const uri = getMfaProvisioningUri({ username });
  if (!uri) return res.status(404).json({ error: 'MFA is not enabled' });
  return res.json({ uri });
});

module.exports = router;
module.exports.verifyToken = verifyToken;
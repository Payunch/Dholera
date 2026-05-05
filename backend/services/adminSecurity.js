const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const ACCESS_SECRET = process.env.ADMIN_JWT_SECRET || process.env.JWT_SECRET || 'dev-admin-access-secret';
const REFRESH_SECRET = process.env.ADMIN_REFRESH_TOKEN_SECRET || ACCESS_SECRET;
const ADMIN_MFA_SECRET = (process.env.ADMIN_MFA_SECRET || '').replace(/\s+/g, '').toUpperCase();
const ADMIN_MFA_ISSUER = process.env.ADMIN_MFA_ISSUER || 'Dholera Growth Evidence Platform';
const ACCESS_TOKEN_TTL_SECONDS = Number.parseInt(process.env.ADMIN_ACCESS_TOKEN_TTL_SECONDS || `${15 * 60}`, 10);
const REFRESH_TOKEN_TTL_SECONDS = Number.parseInt(process.env.ADMIN_REFRESH_TOKEN_TTL_SECONDS || `${30 * 24 * 60 * 60}`, 10);
const MFA_TIME_STEP_SECONDS = Number.parseInt(process.env.ADMIN_MFA_STEP_SECONDS || '30', 10);
const MFA_WINDOW = Number.parseInt(process.env.ADMIN_MFA_WINDOW || '1', 10);

const refreshTokenStore = new Map();

const base64Url = (value) => Buffer.from(value).toString('base64url');

const base32Decode = (input) => {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  const normalized = String(input || '').replace(/=+$/g, '').replace(/\s+/g, '').toUpperCase();
  let bits = '';
  for (const char of normalized) {
    const index = alphabet.indexOf(char);
    if (index === -1) continue;
    bits += index.toString(2).padStart(5, '0');
  }
  const bytes = [];
  for (let offset = 0; offset + 8 <= bits.length; offset += 8) {
    bytes.push(parseInt(bits.slice(offset, offset + 8), 2));
  }
  return Buffer.from(bytes);
};

const hotp = (secret, counter, digits = 6) => {
  const counterBuffer = Buffer.alloc(8);
  counterBuffer.writeUInt32BE(Math.floor(counter / 0x100000000), 0);
  counterBuffer.writeUInt32BE(counter & 0xffffffff, 4);
  const hmac = crypto.createHmac('sha1', secret).update(counterBuffer).digest();
  const offset = hmac[hmac.length - 1] & 0x0f;
  const code = ((hmac.readUInt32BE(offset) & 0x7fffffff) % 10 ** digits).toString();
  return code.padStart(digits, '0');
};

const getTotpCounter = (timestamp = Date.now()) => Math.floor(timestamp / 1000 / MFA_TIME_STEP_SECONDS);

const verifyTotp = (secret, token) => {
  if (!secret || !token) return false;
  const secretBuffer = base32Decode(secret);
  const provided = String(token).replace(/\D/g, '').slice(0, 6);
  if (!provided) return false;
  const counter = getTotpCounter();

  for (let drift = -MFA_WINDOW; drift <= MFA_WINDOW; drift += 1) {
    const expected = hotp(secretBuffer, counter + drift);
    if (crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(provided.padStart(6, '0')))) {
      return true;
    }
  }

  return false;
};

const isMfaEnabled = () => Boolean(ADMIN_MFA_SECRET);

const getCookieOptions = (maxAgeMs) => ({
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
  path: '/',
  maxAge: maxAgeMs
});

const getAuthCookies = ({ accessToken, refreshToken }) => ({
  accessToken,
  refreshToken
});

const setAuthCookies = (res, { accessToken, refreshToken }) => {
  if (accessToken) {
    res.cookie('admin_access_token', accessToken, getCookieOptions(ACCESS_TOKEN_TTL_SECONDS * 1000));
  }
  if (refreshToken) {
    res.cookie('admin_refresh_token', refreshToken, getCookieOptions(REFRESH_TOKEN_TTL_SECONDS * 1000));
  }
};

const clearAuthCookies = (res) => {
  res.clearCookie('admin_access_token', { path: '/' });
  res.clearCookie('admin_refresh_token', { path: '/' });
};

const issueAdminTokens = ({ username }) => {
  const now = Math.floor(Date.now() / 1000);
  const accessToken = jwt.sign(
    { sub: username, role: 'admin', typ: 'access' },
    ACCESS_SECRET,
    { expiresIn: ACCESS_TOKEN_TTL_SECONDS }
  );

  const jti = crypto.randomUUID();
  const refreshToken = jwt.sign(
    { sub: username, role: 'admin', typ: 'refresh', jti },
    REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_TTL_SECONDS }
  );

  refreshTokenStore.set(jti, {
    username,
    expiresAt: now + REFRESH_TOKEN_TTL_SECONDS
  });

  return getAuthCookies({ accessToken, refreshToken });
};

const revokeRefreshToken = (refreshToken) => {
  if (!refreshToken) return;
  try {
    const payload = jwt.verify(refreshToken, REFRESH_SECRET);
    if (payload?.jti) {
      refreshTokenStore.delete(payload.jti);
    }
  } catch (err) {
    // Ignore invalid/expired tokens when revoking.
  }
};

const verifyRefreshToken = (refreshToken) => {
  if (!refreshToken) return null;
  const payload = jwt.verify(refreshToken, REFRESH_SECRET);
  if (!payload?.jti) return null;
  const record = refreshTokenStore.get(payload.jti);
  if (!record) return null;
  if (record.username !== payload.sub) return null;
  if (record.expiresAt && record.expiresAt * 1000 <= Date.now()) {
    refreshTokenStore.delete(payload.jti);
    return null;
  }
  return payload;
};

const rotateRefreshToken = (refreshToken) => {
  const payload = verifyRefreshToken(refreshToken);
  if (!payload) return null;
  refreshTokenStore.delete(payload.jti);
  return issueAdminTokens({ username: payload.sub });
};

const verifyAccessToken = (accessToken) => {
  if (!accessToken) return null;
  return jwt.verify(accessToken, ACCESS_SECRET);
};

const getBearerToken = (authHeader = '') => {
  if (!authHeader) return '';
  if (authHeader.toLowerCase().startsWith('bearer ')) return authHeader.slice(7).trim();
  return authHeader.trim();
};

const getTokenFromRequest = (req, cookieName, headerName = 'authorization') => {
  const headerToken = getBearerToken(req.headers?.[headerName] || '');
  if (headerToken) return headerToken;
  return req.cookies?.[cookieName] || '';
};

const verifyMfaCode = (code) => {
  if (!isMfaEnabled()) return true;
  return verifyTotp(ADMIN_MFA_SECRET, code);
};

const getMfaProvisioningUri = ({ username }) => {
  if (!isMfaEnabled()) return '';
  const label = encodeURIComponent(`${ADMIN_MFA_ISSUER}:${username}`);
  const issuer = encodeURIComponent(ADMIN_MFA_ISSUER);
  return `otpauth://totp/${label}?secret=${ADMIN_MFA_SECRET}&issuer=${issuer}&algorithm=SHA1&digits=6&period=${MFA_TIME_STEP_SECONDS}`;
};

const getAccessTokenTtlSeconds = () => ACCESS_TOKEN_TTL_SECONDS;

const getRefreshTokenTtlSeconds = () => REFRESH_TOKEN_TTL_SECONDS;

module.exports = {
  ADMIN_MFA_ISSUER,
  isMfaEnabled,
  verifyMfaCode,
  getMfaProvisioningUri,
  issueAdminTokens,
  rotateRefreshToken,
  revokeRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  setAuthCookies,
  clearAuthCookies,
  getTokenFromRequest,
  getAccessTokenTtlSeconds,
  getRefreshTokenTtlSeconds
};
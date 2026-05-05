const cleanText = (value, maxLen = 255) => {
  if (value === undefined || value === null) return '';
  return String(value)
    .replace(/[<>]/g, '')
    // Strip null bytes and dangerous control chars BUT preserve \n (0x0A), \r (0x0D), \t (0x09)
    // so that article/blog paragraph formatting survives the round-trip.
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '')
    .trim()
    .slice(0, maxLen);
};

const cleanEmail = (value) => {
  const email = cleanText(value, 255).toLowerCase();
  if (!email) return '';
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email : '';
};

const cleanPathFragment = (value, maxLen = 120) => {
  const page = cleanText(value, maxLen);
  if (!page) return '';
  return page.startsWith('/') ? page : '';
};

const parsePositiveInt = (value, defaultValue = 0, max = Number.MAX_SAFE_INTEGER) => {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed < 0) return defaultValue;
  return Math.min(parsed, max);
};

module.exports = {
  cleanText,
  cleanEmail,
  cleanPathFragment,
  parsePositiveInt
};

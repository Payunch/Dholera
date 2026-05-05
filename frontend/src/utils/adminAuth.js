const ADMIN_TOKEN_KEY = 'admin_token';

export const getAdminToken = () => {
  return sessionStorage.getItem(ADMIN_TOKEN_KEY) || '';
};

export const setAdminToken = (token) => {
  if (!token) return;
  sessionStorage.setItem(ADMIN_TOKEN_KEY, token);
  // Clean up legacy storage location if present.
  localStorage.removeItem(ADMIN_TOKEN_KEY);
};

export const clearAdminToken = () => {
  sessionStorage.removeItem(ADMIN_TOKEN_KEY);
  localStorage.removeItem(ADMIN_TOKEN_KEY);
};

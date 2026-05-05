import { API_BASE_URL } from './apiBase';

let _cached = null;
export const fetchCsrfToken = async () => {
  if (_cached) return _cached;
  const res = await fetch(`${API_BASE_URL}/auth/csrf-token`, { credentials: 'include' });
  if (!res.ok) throw new Error('Failed to fetch CSRF token');
  const data = await res.json();
  _cached = data.csrfToken;
  return _cached;
};

export const clearCsrfCache = () => { _cached = null; };

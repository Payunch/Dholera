import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Paper, TextField, Typography, Button, Alert, Collapse } from '@mui/material';
import { API_BASE_URL } from '../../utils/apiBase';
import { fetchCsrfToken, clearCsrfCache } from '../../utils/csrf';

const AdminLogin = () => {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [mfaCode, setMfaCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [mfaEnabled, setMfaEnabled] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Ensure session cookie is established and get CSRF token
      const csrf = await fetchCsrfToken();
      const res = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', 'x-csrf-token': csrf },
        body: JSON.stringify({ username, password, mfaCode })
      });

      const data = await res.json();
      if (!res.ok) {
        // Invalidate cached token and show error
        clearCsrfCache();
        setMfaEnabled(Boolean(data.mfaRequired));
        throw new Error(data.error || 'Login failed');
      }

      // Important: Clear cache after login because session was regenerated
      clearCsrfCache();
      navigate('/admin');
    } catch (err) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', display: 'grid', placeItems: 'center', bgcolor: 'grey.100', p: 2 }}>
      <Paper sx={{ width: '100%', maxWidth: 420, p: 4, borderRadius: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, mb: 1 }}>
          Admin Login
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          Sign in to access lead and updates management.
        </Typography>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <form onSubmit={handleLogin}>
          <TextField
            fullWidth
            label="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            sx={{ mb: 2 }}
          />
          <TextField
            fullWidth
            type="password"
            label="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            sx={{ mb: 3 }}
          />

          <Collapse in={mfaEnabled}>
            <TextField
              fullWidth
              label="Authenticator code"
              value={mfaCode}
              onChange={(e) => setMfaCode(e.target.value)}
              sx={{ mb: 3 }}
              inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
              helperText="Enter the 6-digit code from your authenticator app if MFA is enabled."
            />
          </Collapse>

          <Button type="submit" fullWidth variant="contained" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign in'}
          </Button>
        </form>
      </Paper>
    </Box>
  );
};

export default AdminLogin;

import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Paper, TextField, Button, Grid, Divider, Alert, CircularProgress 
} from '@mui/material';
import SaveIcon from '@mui/icons-material/Save';
import WhatsAppIcon from '@mui/icons-material/WhatsApp';
import { API_BASE_URL } from '../../utils/apiBase';
import { fetchCsrfToken } from '../../utils/csrf';

const AdminSettings = () => {
  const [settings, setSettings] = useState({
    site_owner_name: '',
    phone: '',
    email: '',
    facebook: '',
    instagram: '',
    twitter: ''
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/settings`, { credentials: 'include' });
      if (res.ok) {
        const data = await res.json();
        console.log('Fetched settings:', data);
        // Ensure all fields are initialized even if not in database
        setSettings(prev => ({ 
          ...prev, 
          site_owner_name: data.site_owner_name || '',
          phone: data.phone || '',
          email: data.email || '',
          facebook: data.facebook || '',
          instagram: data.instagram || '',
          twitter: data.twitter || ''
        }));
      } else {
        console.error('Failed to fetch settings:', res.status);
      }
    } catch (err) {
      console.error('Failed to fetch settings', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    setMessage({ type: '', text: '' });
    
    // Validate phone number (10 digits starting with 6-9 for Indian mobile)
    const phoneRegex = /^[6-9]\d{9}$/;
    if (settings.phone && !phoneRegex.test(settings.phone)) {
      setMessage({ type: 'error', text: 'Phone number must be a valid 10-digit Indian mobile number (start with 6-9)' });
      setSaving(false);
      return;
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (settings.email && !emailRegex.test(settings.email)) {
      setMessage({ type: 'error', text: 'Please enter a valid email address' });
      setSaving(false);
      return;
    }
    
    try {
      const csrf = await fetchCsrfToken();
      const res = await fetch(`${API_BASE_URL}/settings`, {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'x-csrf-token': csrf
        },
        body: JSON.stringify(settings)
      });
      
      if (res.ok) {
        setMessage({ type: 'success', text: 'Settings saved successfully!' });
        // Refresh settings to reflect database state
        await fetchSettings();
      } else {
        throw new Error('Failed to save settings');
      }
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;

  return (
    <Box>
      <Typography variant="h4" sx={{ fontWeight: 800, mb: 3 }}>System Settings</Typography>
      
      {message.text && (
        <Alert severity={message.type} sx={{ mb: 3 }} onClose={() => setMessage({ type: '', text: '' })}>
          {message.text}
        </Alert>
      )}

      <Grid container spacing={4}>
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, borderRadius: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, gap: 1 }}>
              <WhatsAppIcon color="success" />
              <Typography variant="h6" sx={{ fontWeight: 700 }}>WhatsApp & Contact Details</Typography>
            </Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
              These details are used to pre-fill WhatsApp messages sent to leads.
            </Typography>
            
            <Divider sx={{ mb: 3 }} />

            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField 
                  fullWidth 
                  label="Site Owner Name" 
                  value={settings.site_owner_name} 
                  onChange={e => setSettings({...settings, site_owner_name: e.target.value})}
                  placeholder="e.g. Naresh Gohel"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField 
                  fullWidth 
                  label="WhatsApp / Phone" 
                  value={settings.phone} 
                  onChange={e => setSettings({...settings, phone: e.target.value})}
                  placeholder="e.g. 7435808031"
                  helperText="Format: 7435808031 (10 digits)"
                />
              </Grid>
              <Grid item xs={12}>
                <TextField 
                  fullWidth 
                  label="Contact Email" 
                  value={settings.email} 
                  onChange={e => setSettings({...settings, email: e.target.value})}
                  placeholder="e.g. gohelnaresh7707@gmail.com"
                />
              </Grid>
              
              <Grid item xs={12}>
                <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 700 }}>Social Links (Optional)</Typography>
              </Grid>
              
              <Grid item xs={12} sm={4}>
                <TextField 
                  fullWidth 
                  label="Facebook URL" 
                  value={settings.facebook} 
                  onChange={e => setSettings({...settings, facebook: e.target.value})}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <TextField 
                  fullWidth 
                  label="Instagram URL" 
                  value={settings.instagram} 
                  onChange={e => setSettings({...settings, instagram: e.target.value})}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <TextField 
                  fullWidth 
                  label="Twitter URL" 
                  value={settings.twitter} 
                  onChange={e => setSettings({...settings, twitter: e.target.value})}
                />
              </Grid>
            </Grid>

            <Box sx={{ mt: 4, display: 'flex', justifyContent: 'flex-end' }}>
              <Button 
                variant="contained" 
                size="large" 
                startIcon={saving ? <CircularProgress size={20} color="inherit" /> : <SaveIcon />} 
                onClick={handleSave}
                disabled={saving}
              >
                Save All Settings
              </Button>
            </Box>
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, bgcolor: 'primary.main', color: 'white' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Why this matters?</Typography>
            <Typography variant="body2" sx={{ opacity: 0.9 }}>
              Personalizing your communication increases conversion rates. By setting these details, 
              the WhatsApp messages generated for leads will feel more professional and authentic.
            </Typography>
            <Box sx={{ mt: 2, p: 2, bgcolor: 'rgba(255,255,255,0.1)', borderRadius: 2 }}>
              <Typography variant="caption" display="block" sx={{ fontWeight: 700, mb: 1 }}>Message Preview Example:</Typography>
              <Typography variant="caption" sx={{ fontStyle: 'italic', display: 'block' }}>
                "Hello [Lead Name] 👋 Thank you for your interest in Dholera Smart City. Site Owner: {settings.site_owner_name || 'Not Set'} | Phone: {settings.phone || 'Not Set'}"
              </Typography>
            </Box>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

export default AdminSettings;

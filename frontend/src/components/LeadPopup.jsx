import React, { useState, useEffect } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogContentText, TextField, DialogActions, Button, Box, Typography, IconButton, CircularProgress, Checkbox, FormControlLabel, Link } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import { Link as RouterLink } from 'react-router-dom';
import { useLead } from '../context/LeadContext';
import { API_BASE_URL } from '../utils/apiBase';

const LeadPopup = ({ sessionId, fingerprint, compulsory = false, onSuccess }) => {
  const { loginLead } = useLead();
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ name: '', phone: '', email: '' });
  const [consentAccepted, setConsentAccepted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    if (compulsory) {
      setOpen(true);
      return;
    }

    const hasSeenPopup = sessionStorage.getItem('hasSeenPopup');
    if (!hasSeenPopup) {
      const timer = setTimeout(() => {
        const token = localStorage.getItem('lead_token');
        if (!token) {
          setOpen(true);
          sessionStorage.setItem('hasSeenPopup', 'true');
        }
      }, 10000);
      return () => clearTimeout(timer);
    }
  }, [compulsory]);

  const handleSaveLead = async (e) => {
    e.preventDefault();
    if (!consentAccepted) {
      setError('Please accept the Terms & Conditions and Privacy Policy to continue.');
      return;
    }

    // Validate phone (10 digits starting with 6-9 for Indian numbers)
    const phoneRegex = /^[6-9]\d{9}$/;
    if (!phoneRegex.test(formData.phone)) {
      setError('Please enter a valid 10-digit Indian mobile number');
      return;
    }

    // Validate email if provided
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (formData.email && !emailRegex.test(formData.email)) {
      setError('Please enter a valid email address');
      return;
    }

    setLoading(true);
    setError('');
    try {
      const res = await fetch(`${API_BASE_URL}/leads/save-direct`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          ...formData, 
          sessionId, 
          browserFingerprint: fingerprint 
        })
      });
      const data = await res.json();
      if (res.ok) {
        if (data.lead_token) {
          localStorage.setItem('lead_token', data.lead_token);
          localStorage.setItem('lead_email', data.lead.email);
          localStorage.setItem('lead_phone', data.lead.phone);
          localStorage.setItem('lead_name', data.lead.name);
          
          loginLead({ 
            name: data.lead.name, 
            phone: data.lead.phone, 
            token: data.lead_token 
          });
        }
        setSubmitted(true);
        if (onSuccess) onSuccess(data);
        setTimeout(() => setOpen(false), 2000);
      } else {
        setError(data.error || 'Failed to save');
      }
    } catch (err) {
      setError('Connection error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = (event, reason) => {
    if (compulsory) return;
    if (reason === 'backdropClick' || reason === 'escapeKeyDown') return;
    setOpen(false);
  };

  return (
    <Dialog 
      open={open} 
      onClose={handleClose} 
      maxWidth="xs" 
      fullWidth
      disableEscapeKeyDown={compulsory}
    >
      <Box sx={{ position: 'relative', p: 3 }}>
        {!compulsory && (
          <IconButton sx={{ position: 'absolute', right: 8, top: 8 }} onClick={() => setOpen(false)}>
            <CloseIcon />
          </IconButton>
        )}
        
        <DialogTitle sx={{ fontWeight: 800, color: 'primary.main', textAlign: 'center', px: 0 }}>
          {submitted ? '✓ Saved' : compulsory ? '🔐 Unlock Documents' : 'Exclusive Access'}
        </DialogTitle>

        <DialogContent sx={{ px: 0 }}>
          {!submitted ? (
            <>
              <DialogContentText sx={{ mb: 3, textAlign: 'center' }}>
                Enter your details to unlock exclusive documents
              </DialogContentText>

              {error && <Typography color="error" sx={{ mb: 2, textAlign: 'center', fontWeight: 600 }}>{error}</Typography>}

              <form id="lead-form" onSubmit={handleSaveLead}>
                <TextField fullWidth margin="dense" label="Full Name" required value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} />
                <TextField 
                  fullWidth 
                  margin="dense" 
                  label="Mobile Number" 
                  placeholder="e.g. 9876543210"
                  required 
                  value={formData.phone} 
                  onChange={e => setFormData({...formData, phone: e.target.value})} 
                />
                <TextField fullWidth margin="dense" label="Email Address" type="email" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} placeholder="(Optional)" />
                <FormControlLabel
                  sx={{ mt: 1, alignItems: 'flex-start' }}
                  control={
                    <Checkbox
                      checked={consentAccepted}
                      onChange={e => setConsentAccepted(e.target.checked)}
                      sx={{ mt: 0.25 }}
                    />
                  }
                  label={(
                    <Typography variant="caption" color="text.secondary" sx={{ lineHeight: 1.6 }}>
                      I agree to the{' '}
                      <Link component={RouterLink} to="/terms-and-conditions" target="_blank" rel="noopener" underline="hover">
                        Terms & Conditions
                      </Link>{' '}
                      and{' '}
                      <Link component={RouterLink} to="/privacy-policy" target="_blank" rel="noopener" underline="hover">
                        Privacy Policy
                      </Link>{' '}
                      and consent to inquiry follow-up by phone, WhatsApp, or email.
                    </Typography>
                  )}
                />
              </form>
            </>
          ) : (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <Typography color="success.main" variant="h5" sx={{ fontWeight: 700, mb: 1 }}>
                Access Granted
              </Typography>
              <Typography variant="body1">
                Unlocking secure documents...
              </Typography>
            </Box>
          )}
        </DialogContent>

        {!submitted && (
          <DialogActions sx={{ pb: 0, pt: 2 }}>
            <Button 
              type="submit" 
              form="lead-form"
              variant="contained" 
              color="secondary" 
              fullWidth 
              size="large" 
              disabled={loading}
              sx={{ fontWeight: 800, py: 1.5, borderRadius: 2 }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Save'}
            </Button>
          </DialogActions>
        )}
      </Box>
    </Dialog>
  );
};

export default LeadPopup;

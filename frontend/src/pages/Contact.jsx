import React, { useState } from 'react';
import { Container, Typography, Grid, Paper, TextField, Button, Box, Alert, Checkbox, FormControlLabel, Link } from '@mui/material';
import WhatsAppIcon from '@mui/icons-material/WhatsApp';
import { Link as RouterLink } from 'react-router-dom';
import { API_BASE_URL } from '../utils/apiBase';
import Seo from '../components/Seo';
import { siteContact } from '../data/siteContact';

const Contact = () => {
  const [formData, setFormData] = useState({ name: '', phone: '', email: '' });
  const [status, setStatus] = useState('');
  const [consentAccepted, setConsentAccepted] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!consentAccepted) {
      setStatus('consent-error');
      return;
    }

    try {
      const res = await fetch(`${API_BASE_URL}/leads`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...formData, source: 'Contact Form' })
      });
      if (res.ok) {
        setStatus('success');
        setFormData({ name: '', phone: '', email: '' });
        setConsentAccepted(false);
      } else {
        setStatus('error');
      }
    } catch (err) {
      setStatus('error');
    }
  };

  const handleWhatsApp = () => {
    const text = encodeURIComponent(
      `Hello! I am interested in Dholera Smart City investment.\n\nContact person: ${siteContact.operatorName}\nPhone: ${siteContact.phoneDigits}\nEmail: ${siteContact.email}`
    );
    window.open(`https://wa.me/${siteContact.phoneE164}?text=${text}`, '_blank');
  };

  return (
    <Container maxWidth="md" sx={{ py: 8 }}>
      <Seo
        title="Contact"
        description="Request investment information, planning support, or a WhatsApp callback from the Dholera team."
        path="/contact"
      />
      <Typography variant="h2" sx={{ mb: 2, fontWeight: 800, color: 'primary.main', textAlign: 'center' }}>
        Get in Touch
      </Typography>
      <Typography variant="h6" color="text.secondary" sx={{ mb: 6, textAlign: 'center' }}>
        Connect with our experts for investment opportunities and planning details.
      </Typography>

      <Paper sx={{ p: 4, borderRadius: 4 }}>
        {status === 'success' && <Alert severity="success" sx={{ mb: 3 }}>Thank you! We will contact you shortly.</Alert>}
        {status === 'error' && <Alert severity="error" sx={{ mb: 3 }}>Something went wrong. Please try again.</Alert>}
        {status === 'consent-error' && <Alert severity="warning" sx={{ mb: 3 }}>Please accept the Terms & Conditions and Privacy Policy before submitting your details.</Alert>}
        
        <form onSubmit={handleSubmit}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <TextField fullWidth label="Full Name" required value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField fullWidth label="Phone Number" required value={formData.phone} onChange={e => setFormData({...formData, phone: e.target.value})} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth label="Email Address" type="email" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} />
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                sx={{ alignItems: 'flex-start', m: 0 }}
                control={
                  <Checkbox
                    checked={consentAccepted}
                    onChange={e => {
                      setConsentAccepted(e.target.checked);
                      if (status === 'consent-error') setStatus('');
                    }}
                    sx={{ mt: 0.25, mr: 1 }}
                  />
                }
                label={(
                  <Typography variant="body2" color="text.secondary" sx={{ lineHeight: 1.7 }}>
                    I agree to the{' '}
                    <Link component={RouterLink} to="/terms-and-conditions" underline="hover" target="_blank" rel="noopener">
                      Terms & Conditions
                    </Link>{' '}
                    and{' '}
                    <Link component={RouterLink} to="/privacy-policy" underline="hover" target="_blank" rel="noopener">
                      Privacy Policy
                    </Link>{' '}
                    and consent to being contacted by phone, WhatsApp, or email regarding my inquiry.
                  </Typography>
                )}
              />
            </Grid>
            <Grid item xs={12}>
              <Button type="submit" variant="contained" color="primary" size="large" fullWidth>
                Submit Inquiry
              </Button>
            </Grid>
          </Grid>
        </form>

        <Box sx={{ mt: 4, textAlign: 'center' }}>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>Or connect instantly via WhatsApp</Typography>
          <Button variant="contained" color="success" startIcon={<WhatsAppIcon />} onClick={handleWhatsApp} sx={{ borderRadius: 8 }}>
            Chat on WhatsApp
          </Button>
        </Box>
      </Paper>
    </Container>
  );
};

export default Contact;

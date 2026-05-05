import React from 'react';
import { Box, Container, Typography, Grid, Link } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import { siteContact } from '../data/siteContact';

const Footer = () => {
  return (
    <Box component="footer" sx={{ bgcolor: 'primary.dark', color: 'primary.contrastText', py: 6, mt: 'auto' }}>
      <Container maxWidth="xl">
        <Grid container spacing={4}>
          <Grid item xs={12} md={4}>
            <Typography variant="h5" sx={{ fontWeight: 800, mb: 2, letterSpacing: '-0.5px' }}>
              {siteContact.brandName.toUpperCase()}
            </Typography>
            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)' }}>
              The official portal for Dholera Smart City infrastructure, investment, and planning intelligence. Government-level trust, modern execution.
            </Typography>
          </Grid>
          <Grid item xs={12} md={4}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Quick Links</Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
              <Link component={RouterLink} to="/updates" color="inherit" underline="hover">Development Updates</Link>
              <Link component={RouterLink} to="/planning" color="inherit" underline="hover">Planning & Maps</Link>
              <Link component={RouterLink} to="/investment" color="inherit" underline="hover">Investment Overview</Link>
              <Link component={RouterLink} to="/contact" color="inherit" underline="hover">Contact Us</Link>
              <Link component={RouterLink} to="/terms-and-conditions" color="inherit" underline="hover">Terms & Conditions</Link>
              <Link component={RouterLink} to="/privacy-policy" color="inherit" underline="hover">Privacy Policy</Link>
            </Box>
          </Grid>
          <Grid item xs={12} md={4}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Contact</Typography>
            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)', mb: 1 }}>
              Email: {siteContact.email}
            </Typography>
            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)' }}>
              Phone: {siteContact.phoneDisplay}
            </Typography>
          </Grid>
        </Grid>
        <Box sx={{ mt: 5, pt: 3, borderTop: '1px solid rgba(255,255,255,0.1)', textAlign: 'center' }}>
          <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.5)' }}>
            &copy; {new Date().getFullYear()} {siteContact.brandName}. All rights reserved.
          </Typography>
        </Box>
      </Container>
    </Box>
  );
};

export default Footer;

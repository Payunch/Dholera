import React from 'react';
import { AppBar, Toolbar, Typography, Button, Box, Container, Avatar, Chip, Tooltip } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import CorporateFareIcon from '@mui/icons-material/CorporateFare';
import VerifiedIcon from '@mui/icons-material/Verified';
import { useLead } from '../context/LeadContext';

const Navbar = () => {
  const { verifiedLead } = useLead();

  return (
    <AppBar position="fixed" color="default" elevation={1} sx={{ backgroundColor: 'rgba(255, 255, 255, 0.95)', backdropFilter: 'blur(10px)' }}>
      <Container maxWidth="xl">
        <Toolbar disableGutters>
          <CorporateFareIcon sx={{ color: 'primary.main', mr: 1, fontSize: 32 }} />
          <Typography
            variant="h6"
            noWrap
            component={RouterLink}
            to="/"
            sx={{
              mr: 2,
              flexGrow: 1,
              fontFamily: 'Manrope',
              fontWeight: 800,
              color: 'primary.main',
              textDecoration: 'none',
              letterSpacing: '-0.5px'
            }}
          >
            DHOLERA PORTAL
          </Typography>
          
          <Box sx={{ display: { xs: 'none', md: 'flex' }, gap: 2, alignItems: 'center' }}>
            <Button component={RouterLink} to="/" sx={{ color: 'text.primary', fontWeight: 600 }}>Home</Button>
            <Button component={RouterLink} to="/updates" sx={{ color: 'text.primary', fontWeight: 600 }}>Updates</Button>
            <Button component={RouterLink} to="/planning" sx={{ color: 'text.primary', fontWeight: 600 }}>Planning & Maps</Button>
            <Button component={RouterLink} to="/investment" sx={{ color: 'text.primary', fontWeight: 600 }}>Investment</Button>
            
            {verifiedLead ? (
              <Tooltip title={`Verified: ${verifiedLead.name}`}>
                <Chip 
                  avatar={<Avatar sx={{ bgcolor: 'secondary.main' }}>{verifiedLead.name?.charAt(0)}</Avatar>}
                  label="Verified Investor"
                  variant="outlined"
                  color="secondary"
                  icon={<VerifiedIcon />}
                  sx={{ fontWeight: 700, px: 1 }}
                />
              </Tooltip>
            ) : (
              <Button component={RouterLink} to="/contact" variant="contained" color="primary" sx={{ borderRadius: 8, ml: 2, fontWeight: 700 }}>
                Inquire Now
              </Button>
            )}
          </Box>
        </Toolbar>
      </Container>
    </AppBar>
  );
};

export default Navbar;

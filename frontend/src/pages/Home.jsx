import React from 'react';
import { Box, Typography, Button, Container, Grid, Paper } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import MapIcon from '@mui/icons-material/Map';
import FactoryIcon from '@mui/icons-material/Factory';
import FlightTakeoffIcon from '@mui/icons-material/FlightTakeoff';
import Seo from '../components/Seo';

const Home = () => {
  return (
    <Box>
      <Seo
        title="Home"
        description="Dholera growth evidence, planning maps, and verified lead capture in one portal."
        path="/"
      />
      {/* Hero Section */}
      <Box sx={{
        position: 'relative',
        bgcolor: 'primary.dark',
        color: 'white',
        py: { xs: 10, md: 20 },
        overflow: 'hidden',
        textAlign: 'center'
      }}>
        <Container maxWidth="md" sx={{ position: 'relative', zIndex: 2 }}>
          <Typography variant="h1" sx={{ mb: 3, fontWeight: 800 }}>
            India's First Greenfield <Box component="span" sx={{ color: 'secondary.main' }}>Smart City</Box>
          </Typography>
          <Typography variant="h5" sx={{ mb: 5, color: 'rgba(255,255,255,0.8)', fontWeight: 400 }}>
            Invest in the future of infrastructure, powered by state-of-the-art connectivity, sustainability, and government-backed planning.
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
            <Button variant="contained" color="secondary" size="large" component={RouterLink} to="/contact" sx={{ px: 4, py: 1.5, fontSize: '1.1rem' }}>
              Explore Investment
            </Button>
            <Button variant="outlined" sx={{ color: 'white', borderColor: 'white', px: 4, py: 1.5, fontSize: '1.1rem', '&:hover': { borderColor: 'secondary.main', color: 'secondary.main' } }} component={RouterLink} to="/planning">
              View Master Plan
            </Button>
          </Box>
        </Container>
      </Box>

      {/* Infrastructure Metrics */}
      <Container maxWidth="xl" sx={{ mt: -6, position: 'relative', zIndex: 3, mb: 10 }}>
        <Grid container spacing={3} justifyContent="center">
          {[
            { title: '920 Sq. Km', desc: 'Total Development Area', icon: <MapIcon fontSize="large" color="primary" /> },
            { title: 'DMIC Corridor', desc: 'Direct Connectivity', icon: <FactoryIcon fontSize="large" color="primary" /> },
            { title: 'International Airport', desc: 'Under Construction', icon: <FlightTakeoffIcon fontSize="large" color="primary" /> },
          ].map((item, idx) => (
            <Grid item xs={12} md={4} key={idx}>
              <Paper sx={{ p: 4, textAlign: 'center', height: '100%', borderRadius: 4, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <Box sx={{ p: 2, bgcolor: 'rgba(10, 61, 98, 0.05)', borderRadius: '50%', mb: 2 }}>
                  {item.icon}
                </Box>
                <Typography variant="h4" sx={{ fontWeight: 800, color: 'primary.main', mb: 1 }}>{item.title}</Typography>
                <Typography variant="body1" color="text.secondary">{item.desc}</Typography>
              </Paper>
            </Grid>
          ))}
        </Grid>
      </Container>
    </Box>
  );
};

export default Home;

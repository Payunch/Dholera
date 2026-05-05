import React from 'react';
import { Container, Typography, Grid, Paper, Box } from '@mui/material';

const Investment = () => {
  return (
    <Container maxWidth="xl" sx={{ py: 8 }}>
      <Typography variant="h2" sx={{ mb: 2, fontWeight: 800, color: 'primary.main' }}>
        Investment Overview
      </Typography>
      <Typography variant="h6" color="text.secondary" sx={{ mb: 6 }}>
        Why Dholera is the prime destination for global and domestic investment.
      </Typography>

      <Grid container spacing={4}>
        {[
          { title: 'Strategic Location', desc: 'Located on the DMIC corridor, seamlessly connecting major industrial hubs.' },
          { title: 'Smart Infrastructure', desc: 'Underground utilities, smart grids, and sustainable water management.' },
          { title: 'Government Backing', desc: 'Full support from state and central governments with single-window clearances.' },
          { title: 'High ROI Potential', desc: 'Early entry in a greenfield city offers unmatched long-term appreciation.' },
        ].map((item, idx) => (
          <Grid item xs={12} md={6} key={idx}>
            <Paper sx={{ p: 4, borderRadius: 4, bgcolor: 'primary.main', color: 'white' }}>
              <Typography variant="h5" sx={{ fontWeight: 700, mb: 2, color: 'secondary.main' }}>
                {item.title}
              </Typography>
              <Typography variant="body1" sx={{ color: 'rgba(255,255,255,0.8)' }}>
                {item.desc}
              </Typography>
            </Paper>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
};

export default Investment;

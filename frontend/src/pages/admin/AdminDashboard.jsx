import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Typography, Grid, Paper, Box, Table, TableBody, TableCell, TableHead, TableRow, Chip, IconButton,
  Divider, List, ListItem, ListItemText, ListItemIcon
} from '@mui/material';
import WhatsAppIcon from '@mui/icons-material/WhatsApp';
import ContactPhoneIcon from '@mui/icons-material/ContactPhone';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TouchAppIcon from '@mui/icons-material/TouchApp';
import { API_BASE_URL } from '../../utils/apiBase';
import { sendWhatsAppMessage } from '../../utils/whatsapp';

const AdminDashboard = () => {
  const [leads, setLeads] = useState([]);
  const [waStats, setWaStats] = useState({
    totalClicks: 0,
    leadsContacted: 0,
    conversionsAfterWhatsApp: 0,
    responseRate: 'Manual'
  });
  const navigate = useNavigate();
  
  useEffect(() => {
    fetchData();
  }, [navigate]);

  const fetchData = async () => {
    try {
      const leadsRes = await fetch(`${API_BASE_URL}/leads`, { credentials: 'include' });
      if (leadsRes.status === 401 || leadsRes.status === 403) {
        navigate('/admin/login');
        return;
      }
      const leadsData = await leadsRes.json();
      setLeads(leadsData);

      const statsRes = await fetch(`${API_BASE_URL}/whatsapp/stats`, { credentials: 'include' });
      if (statsRes.ok) {
        const statsData = await statsRes.json();
        setWaStats(statsData);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleWhatsAppClick = async (lead) => {
    await sendWhatsAppMessage(lead);
    // Refresh data after a short delay to update status/counts
    setTimeout(fetchData, 2000);
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 4, fontWeight: 800 }}>Dashboard Overview</Typography>
      
      {/* Primary Stats */}
      <Grid container spacing={3} sx={{ mb: 6 }}>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, borderLeft: '4px solid #0a3d62', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}>
            <Typography color="text.secondary" gutterBottom sx={{ fontWeight: 600 }}>Total Leads</Typography>
            <Typography variant="h3" sx={{ fontWeight: 800, color: '#0a3d62' }}>{leads.length}</Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, borderLeft: '4px solid #e58e26', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}>
            <Typography color="text.secondary" gutterBottom sx={{ fontWeight: 600 }}>New Inquiries</Typography>
            <Typography variant="h3" sx={{ fontWeight: 800, color: '#e58e26' }}>
              {leads.filter(l => l.status === 'New').length}
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, borderRadius: 3, borderLeft: '4px solid #4caf50', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}>
            <Typography color="text.secondary" gutterBottom sx={{ fontWeight: 600 }}>Converted</Typography>
            <Typography variant="h3" sx={{ fontWeight: 800, color: '#4caf50' }}>
              {leads.filter(l => l.status === 'Converted').length}
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      <Grid container spacing={4}>
        {/* Recent Leads Table */}
        <Grid item xs={12} lg={8}>
          <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 1 }}>
            Recent Activity
          </Typography>
          <Paper sx={{ borderRadius: 3, overflow: 'hidden', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
            <Table>
              <TableHead sx={{ bgcolor: 'grey.50' }}>
                <TableRow>
                  <TableCell sx={{ fontWeight: 700 }}>Name</TableCell>
                  <TableCell sx={{ fontWeight: 700 }}>Source</TableCell>
                  <TableCell sx={{ fontWeight: 700 }}>Status</TableCell>
                  <TableCell sx={{ fontWeight: 700, textAlign: 'center' }}>WhatsApp</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {leads.slice(0, 6).map((lead) => (
                  <TableRow key={lead.id} hover>
                    <TableCell>
                      <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>{lead.name}</Typography>
                      <Typography variant="caption" color="text.secondary">{lead.phone}</Typography>
                    </TableCell>
                    <TableCell>
                      <Chip label={lead.source} size="small" variant="outlined" />
                    </TableCell>
                    <TableCell>
                      <Chip 
                        label={lead.status} 
                        size="small" 
                        color={lead.status === 'New' ? 'error' : lead.status === 'Converted' ? 'success' : 'warning'} 
                        sx={{ fontWeight: 600 }}
                      />
                    </TableCell>
                    <TableCell sx={{ textAlign: 'center' }}>
                      <IconButton color="success" onClick={() => handleWhatsAppClick(lead)}>
                        <WhatsAppIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Paper>
        </Grid>

        {/* WhatsApp Analytics Sidebar */}
        <Grid item xs={12} lg={4}>
          <Typography variant="h5" sx={{ mb: 3, fontWeight: 700 }}>WhatsApp Outreach</Typography>
          <Paper sx={{ p: 3, borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
            <List disablePadding>
              <ListItem sx={{ px: 0, py: 2 }}>
                <ListItemIcon>
                  <TouchAppIcon color="primary" />
                </ListItemIcon>
                <ListItemText 
                  primary={<Typography variant="h6" sx={{ fontWeight: 800 }}>{waStats.totalClicks}</Typography>}
                  secondary="Total WhatsApp Clicks"
                />
              </ListItem>
              <Divider variant="inset" component="li" />
              <ListItem sx={{ px: 0, py: 2 }}>
                <ListItemIcon>
                  <ContactPhoneIcon color="success" />
                </ListItemIcon>
                <ListItemText 
                  primary={<Typography variant="h6" sx={{ fontWeight: 800 }}>{waStats.leadsContacted}</Typography>}
                  secondary="Leads Contacted"
                />
              </ListItem>
              <Divider variant="inset" component="li" />
              <ListItem sx={{ px: 0, py: 2 }}>
                <ListItemIcon>
                  <TrendingUpIcon color="secondary" />
                </ListItemIcon>
                <ListItemText 
                  primary={<Typography variant="h6" sx={{ fontWeight: 800 }}>{waStats.conversionsAfterWhatsApp}</Typography>}
                  secondary="Conversions (via WA)"
                />
              </ListItem>
            </List>
            
            <Box sx={{ mt: 3, p: 2, bgcolor: 'success.light', borderRadius: 2, color: 'success.contrastText' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>Conversion Pulse</Typography>
              <Typography variant="body2" sx={{ opacity: 0.9 }}>
                {waStats.leadsContacted > 0 
                  ? `${Math.round((waStats.conversionsAfterWhatsApp / waStats.leadsContacted) * 100)}% of contacted leads converted.`
                  : "Start outreach to see conversion trends."}
              </Typography>
            </Box>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

export default AdminDashboard;

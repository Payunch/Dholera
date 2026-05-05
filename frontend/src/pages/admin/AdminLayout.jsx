import React from 'react';
import { Outlet, Link as RouterLink, useNavigate } from 'react-router-dom';
import { Box, Drawer, List, ListItem, ListItemIcon, ListItemText, Typography, AppBar, Toolbar, Button } from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import ArticleIcon from '@mui/icons-material/Article';
import ExitToAppIcon from '@mui/icons-material/ExitToApp';
import { clearAdminToken } from '../../utils/adminAuth';
import { fetchCsrfToken, clearCsrfCache } from '../../utils/csrf';
import { API_BASE_URL } from '../../utils/apiBase';

const drawerWidth = 240;

const AdminLayout = () => {
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      const csrf = await fetchCsrfToken();
      await fetch(`${API_BASE_URL}/auth/logout`, { method: 'POST', credentials: 'include', headers: { 'x-csrf-token': csrf } });
    } catch (err) {
      console.error('Logout error', err);
    }
    clearCsrfCache();
    clearAdminToken();
    navigate('/admin/login');
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
      <AppBar position="fixed" sx={{ width: `calc(100% - ${drawerWidth}px)`, ml: `${drawerWidth}px`, bgcolor: 'white', color: 'text.primary', boxShadow: 1 }}>
        <Toolbar>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1, fontWeight: 700 }}>
            Admin Control Panel
          </Typography>
          <Button startIcon={<ExitToAppIcon />} onClick={handleLogout} color="inherit">
            Logout
          </Button>
        </Toolbar>
      </AppBar>
      <Drawer
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: drawerWidth,
            boxSizing: 'border-box',
            bgcolor: 'primary.dark',
            color: 'white'
          },
        }}
        variant="permanent"
        anchor="left"
      >
        <Box sx={{ p: 2, textAlign: 'center' }}>
          <Typography variant="h6" sx={{ fontWeight: 800 }}>Dholera CRM</Typography>
        </Box>
        <List sx={{ mt: 2 }}>
          <ListItem button component={RouterLink} to="/admin">
            <ListItemIcon sx={{ color: 'rgba(255,255,255,0.7)' }}><DashboardIcon /></ListItemIcon>
            <ListItemText primary="Dashboard" />
          </ListItem>
          <ListItem button component={RouterLink} to="/admin/leads">
            <ListItemIcon sx={{ color: 'rgba(255,255,255,0.7)' }}><PeopleIcon /></ListItemIcon>
            <ListItemText primary="Leads Manager" />
          </ListItem>
          <ListItem button component={RouterLink} to="/admin/updates">
            <ListItemIcon sx={{ color: 'rgba(255,255,255,0.7)' }}><ArticleIcon /></ListItemIcon>
            <ListItemText primary="Updates Manager" />
          </ListItem>
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8 }}>
        <Outlet />
      </Box>
    </Box>
  );
};

export default AdminLayout;

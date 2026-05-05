import React, { useEffect, useState } from 'react';
import { 
  Typography, Paper, Table, TableBody, TableCell, TableHead, TableRow, Chip, IconButton, Box, Button, 
  Grid, TextField, Select, MenuItem, FormControl, InputLabel, Dialog, DialogTitle, DialogContent, DialogActions,
  Collapse, List, ListItem, ListItemText, ListItemIcon, LinearProgress, Alert, Tooltip
} from '@mui/material';
import WhatsAppIcon from '@mui/icons-material/WhatsApp';
import DownloadIcon from '@mui/icons-material/Download';
import EditNoteIcon from '@mui/icons-material/EditNote';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp';
import PictureAsPdfIcon from '@mui/icons-material/PictureAsPdf';
import StarIcon from '@mui/icons-material/Star';
import DoneAllIcon from '@mui/icons-material/DoneAll';
import { API_BASE_URL } from '../../utils/apiBase';
import { fetchCsrfToken } from '../../utils/csrf';
import { sendWhatsAppMessage, sendBulkWhatsApp } from '../../utils/whatsapp';

const Row = ({ lead, handleStatusChange, openWhatsApp, setCurrentLead, setTempNote, setNotesOpen }) => {
  const [open, setOpen] = useState(false);
  const pdfViews = lead.PdfViews || [];
  const sessions = lead.sessions || [];

  return (
    <React.Fragment>
      <TableRow hover sx={{ '& > *': { borderBottom: 'unset' } }}>
        <TableCell>
          <IconButton aria-label="expand row" size="small" onClick={() => setOpen(!open)}>
            {open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
          </IconButton>
        </TableCell>
        <TableCell>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>{lead.name}</Typography>
            {lead.returning_visitor && <Chip icon={<StarIcon />} label="Returning" size="small" color="warning" variant="outlined" />}
            {(lead.visit_count > 3 || pdfViews.length > 2 || lead.totalTimeSpent > 300) && <Chip label="🔥 High Interest" size="small" color="error" />}
          </Box>
          <Typography variant="body2" color="text.secondary">{lead.phone}</Typography>
          <Typography variant="body2" color="text.secondary">{lead.email}</Typography>
        </TableCell>
        <TableCell>
          <Chip label={lead.source} size="small" sx={{ mb: 1 }} />
          <Typography variant="body2" color="text.secondary">
            Visits: {lead.visit_count} | Engagement: {Math.round(lead.totalTimeSpent / 60)}m
          </Typography>
        </TableCell>
        <TableCell>
          <FormControl size="small" sx={{ minWidth: 130 }}>
            <Select 
              value={lead.status} 
              onChange={(e) => handleStatusChange(lead.id, e.target.value)}
              sx={{ 
                bgcolor: lead.status === 'New' ? '#ffebee' : lead.status === 'Converted' ? '#e8f5e9' : 'transparent',
                fontWeight: 600,
                borderRadius: 2
              }}
            >
              <MenuItem value="New">New</MenuItem>
              <MenuItem value="Contacted">Contacted</MenuItem>
              <MenuItem value="Follow-up">Follow-up</MenuItem>
              <MenuItem value="Converted">Converted</MenuItem>
              <MenuItem value="Closed">Closed</MenuItem>
            </Select>
          </FormControl>
        </TableCell>
        <TableCell>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Tooltip title={lead.whatsapp_sent_count > 0 ? `Sent ${lead.whatsapp_sent_count} times` : "Send WhatsApp"}>
              <IconButton color="success" onClick={() => openWhatsApp(lead)} sx={{ position: 'relative', bgcolor: 'success.light', color: 'success.dark', '&:hover': { bgcolor: 'success.main', color: 'white' } }}>
                <WhatsAppIcon />
                {lead.whatsapp_sent_count > 0 && (
                  <Chip 
                    label={lead.whatsapp_sent_count} 
                    size="small" 
                    sx={{ 
                      position: 'absolute', 
                      top: -8, 
                      right: -8, 
                      height: 18, 
                      minWidth: 18, 
                      fontSize: '10px',
                      bgcolor: 'error.main',
                      color: 'white',
                      fontWeight: 700,
                      border: '2px solid white'
                    }} 
                  />
                )}
              </IconButton>
            </Tooltip>
            <Tooltip title="Edit Notes">
              <IconButton color="primary" onClick={() => { setCurrentLead(lead); setTempNote(lead.notes || ''); setNotesOpen(true); }} sx={{ bgcolor: 'primary.light', color: 'primary.dark', '&:hover': { bgcolor: 'primary.main', color: 'white' } }}>
                <EditNoteIcon />
              </IconButton>
            </Tooltip>
          </Box>
        </TableCell>
      </TableRow>
      <TableRow>
        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={5}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Box sx={{ margin: 2, p: 3, bgcolor: '#f8fafc', borderRadius: 3, border: '1px solid #e2e8f0' }}>
              <Grid container spacing={4}>
                <Grid item xs={12} md={6}>
                  <Typography variant="subtitle2" sx={{ fontWeight: 800, mb: 2, color: '#1e293b', display: 'flex', alignItems: 'center', gap: 1 }}>
                    <PictureAsPdfIcon fontSize="small" color="error" /> Document Engagement
                  </Typography>
                  {pdfViews.length > 0 ? (
                    <List dense sx={{ bgcolor: 'white', borderRadius: 2, border: '1px solid #e2e8f0' }}>
                      {pdfViews.map((view, i) => (
                        <ListItem key={i} divider={i < pdfViews.length - 1}>
                          <ListItemText 
                            primary={<Typography variant="body2" sx={{ fontWeight: 600 }}>{view.PdfDocument?.title || 'Document'}</Typography>}
                            secondary={`${new Date(view.createdAt).toLocaleString()}`}
                          />
                        </ListItem>
                      ))}
                    </List>
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ fontStyle: 'italic' }}>No documents viewed yet.</Typography>
                  )}
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="subtitle2" sx={{ fontWeight: 800, mb: 2, color: '#1e293b', display: 'flex', alignItems: 'center', gap: 1 }}>
                    <DoneAllIcon fontSize="small" color="primary" /> Session Intelligence
                  </Typography>
                  <List dense sx={{ bgcolor: 'white', borderRadius: 2, border: '1px solid #e2e8f0' }}>
                    {sessions.map((session, i) => (
                      <ListItem key={i} divider={i < sessions.length - 1}>
                        <ListItemText 
                          primary={<Typography variant="body2" sx={{ fontWeight: 600 }}>Session {i + 1}: {Math.round(session.timeSpent / 60)} mins</Typography>}
                          secondary={`${new Date(session.createdAt).toLocaleString()} • ${JSON.parse(session.visitedPages || '[]').length} pages`}
                        />
                      </ListItem>
                    ))}
                  </List>
                </Grid>
              </Grid>
              <Box sx={{ mt: 3, p: 2, bgcolor: 'white', borderRadius: 2, border: '1px solid #e2e8f0' }}>
                <Typography variant="caption" sx={{ fontWeight: 700, color: 'text.secondary', display: 'block', mb: 0.5 }}>
                  USER JOURNEY PATHWAY:
                </Typography>
                <Typography variant="body2" color="text.primary">
                  {JSON.parse(lead.visited_pages || '[]').map(p => p.replace(/^\//, '').replace(/-/g, ' ')).join(' → ') || 'Home Page'}
                </Typography>
              </Box>
            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </React.Fragment>
  );
};

const AdminLeads = () => {
  const [leads, setLeads] = useState([]);
  const [filters, setFilters] = useState({ status: '', source: '', search: '', days: '' });
  
  const [notesOpen, setNotesOpen] = useState(false);
  const [currentLead, setCurrentLead] = useState(null);
  const [tempNote, setTempNote] = useState('');

  // Bulk WhatsApp State
  const [bulkDialogOpen, setBulkDialogOpen] = useState(false);
  const [bulkProgress, setBulkProgress] = useState({ current: 0, total: 0, name: '' });
  const [isBulkSending, setIsBulkSending] = useState(false);

  const fetchLeads = () => {
    const query = new URLSearchParams(filters).toString();
    fetch(`${API_BASE_URL}/leads?${query}`, {
      credentials: 'include'
    })
      .then(res => {
        if (res.status === 401 || res.status === 403) {
          window.location.href = '/admin/login';
          return [];
        }
        return res.json();
      })
      .then(data => setLeads(data))
      .catch(console.error);
  };

  useEffect(() => {
    fetchLeads();
  }, [filters]);

  const handleStatusChange = async (id, newStatus) => {
    try {
      const csrf = await fetchCsrfToken();
      await fetch(`${API_BASE_URL}/leads/${id}/status`, {
        method: 'PUT',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'x-csrf-token': csrf
        },
        body: JSON.stringify({ status: newStatus })
      });
      fetchLeads();
    } catch (err) {
      console.error(err);
    }
  };

  const handleNotesSave = async () => {
    try {
      const csrf = await fetchCsrfToken();
      await fetch(`${API_BASE_URL}/leads/${currentLead.id}/notes`, {
        method: 'PUT',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'x-csrf-token': csrf
        },
        body: JSON.stringify({ notes: tempNote })
      });
      setNotesOpen(false);
      fetchLeads();
    } catch (err) {
      console.error(err);
    }
  };

  const openWhatsApp = async (lead) => {
    await sendWhatsAppMessage(lead);
    // Refresh to update counts/status
    setTimeout(fetchLeads, 2000);
  };

  const handleBulkWhatsApp = () => {
    const newLeads = leads.filter(l => l.status === 'New');
    if (newLeads.length === 0) {
      alert("No 'New' leads found for bulk outreach.");
      return;
    }
    
    setBulkProgress({ current: 0, total: newLeads.length, name: '' });
    setBulkDialogOpen(true);
  };

  const startBulkSending = async () => {
    const newLeads = leads.filter(l => l.status === 'New');
    setIsBulkSending(true);
    
    await sendBulkWhatsApp(newLeads, (current, total, name) => {
      setBulkProgress({ current, total, name });
    });
    
    setIsBulkSending(false);
    setBulkDialogOpen(false);
    fetchLeads();
  };

  const exportExcel = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/leads/export`, {
        credentials: 'include'
      });

      if (!res.ok) {
        throw new Error('Failed to export leads');
      }

      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      const anchor = document.createElement('a');
      anchor.href = url;
      anchor.download = 'leads_export_dholera.xlsx';
      document.body.appendChild(anchor);
      anchor.click();
      anchor.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
    }
  };

  const totalLeads = leads.length;
  const contactedLeads = leads.filter(l => l.whatsapp_sent_count > 0 || l.status !== 'New').length;
  const returningCount = leads.filter(l => l.returning_visitor).length;
  const convertedCount = leads.filter(l => l.status === 'Converted').length;
  const avgTime = leads.length ? Math.round(leads.reduce((acc, l) => acc + (l.totalTimeSpent || 0), 0) / leads.length) : 0;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" sx={{ fontWeight: 800 }}>Lead Intelligence CRM</Typography>
        <Box sx={{ display: 'flex', gap: 2 }}>
          <Button variant="outlined" color="primary" startIcon={<DownloadIcon />} onClick={exportExcel}>
            Export
          </Button>
          <Button variant="contained" color="success" startIcon={<WhatsAppIcon />} onClick={handleBulkWhatsApp} sx={{ fontWeight: 700 }}>
            Bulk WhatsApp
          </Button>
        </Box>
      </Box>

      {/* Analytics Summary */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {[
          { label: 'Total Database', value: totalLeads, color: '#1e293b' },
          { label: 'Outreach Initiated', value: contactedLeads, color: '#166534' },
          { label: 'High Interest', value: leads.filter(l => l.visit_count > 3 || (l.PdfViews || []).length > 2 || l.totalTimeSpent > 300).length, color: '#991b1b' },
          { label: 'Avg Engagement', value: `${Math.round(avgTime/60)}m`, color: '#6b21a8' },
          { label: 'Converted Leads', value: convertedCount, color: '#075985' },
        ].map((stat, idx) => (
          <Grid item xs={12} sm={6} md={2.4} key={idx}>
            <Paper sx={{ p: 2, borderRadius: 3, textAlign: 'center', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderBottom: `4px solid ${stat.color}` }}>
              <Typography color="text.secondary" variant="caption" sx={{ fontWeight: 700, textTransform: 'uppercase' }}>{stat.label}</Typography>
              <Typography variant="h4" sx={{ fontWeight: 800, mt: 0.5, color: stat.color }}>{stat.value}</Typography>
            </Paper>
          </Grid>
        ))}
      </Grid>

      {/* Filter Bar */}
      <Paper sx={{ p: 2, mb: 3, borderRadius: 3, display: 'flex', gap: 2, alignItems: 'center', bgcolor: '#f1f5f9' }}>
        <TextField size="small" label="Search by Name, Phone or Email" sx={{ flexGrow: 1, bgcolor: 'white' }} value={filters.search} onChange={e => setFilters({...filters, search: e.target.value})} />
        <FormControl size="small" sx={{ minWidth: 150, bgcolor: 'white' }}>
          <InputLabel>All Statuses</InputLabel>
          <Select value={filters.status} label="All Statuses" onChange={e => setFilters({...filters, status: e.target.value})}>
            <MenuItem value="">All</MenuItem>
            <MenuItem value="New">New</MenuItem>
            <MenuItem value="Contacted">Contacted</MenuItem>
            <MenuItem value="Converted">Converted</MenuItem>
            <MenuItem value="Follow-up">Follow-up</MenuItem>
          </Select>
        </FormControl>
        <FormControl size="small" sx={{ minWidth: 150, bgcolor: 'white' }}>
          <InputLabel>Timeframe</InputLabel>
          <Select value={filters.days} label="Timeframe" onChange={e => setFilters({...filters, days: e.target.value})}>
            <MenuItem value="">All Time</MenuItem>
            <MenuItem value="1">Today</MenuItem>
            <MenuItem value="7">This Week</MenuItem>
            <MenuItem value="30">This Month</MenuItem>
          </Select>
        </FormControl>
      </Paper>

      {/* Leads Table */}
      <Paper sx={{ borderRadius: 3, overflow: 'hidden', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}>
        <Table>
          <TableHead sx={{ bgcolor: '#f8fafc' }}>
            <TableRow>
              <TableCell width={50} />
              <TableCell sx={{ fontWeight: 800, color: '#475569' }}>IDENTITY</TableCell>
              <TableCell sx={{ fontWeight: 800, color: '#475569' }}>ENGAGEMENT</TableCell>
              <TableCell sx={{ fontWeight: 800, color: '#475569' }}>PIPELINE STATUS</TableCell>
              <TableCell sx={{ fontWeight: 800, color: '#475569' }}>ACTIONS</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {leads.length > 0 ? leads.map((lead) => (
              <Row 
                key={lead.id} 
                lead={lead} 
                handleStatusChange={handleStatusChange} 
                openWhatsApp={openWhatsApp} 
                setCurrentLead={setCurrentLead} 
                setTempNote={setTempNote} 
                setNotesOpen={setNotesOpen} 
              />
            )) : (
              <TableRow>
                <TableCell colSpan={5} align="center" sx={{ py: 10 }}>
                  <Typography variant="h6" color="text.secondary">No leads found matching your filters.</Typography>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </Paper>

      {/* Notes Dialog */}
      <Dialog open={notesOpen} onClose={() => setNotesOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle sx={{ fontWeight: 800 }}>Lead Intelligence: {currentLead?.name}</DialogTitle>
        <DialogContent>
          <TextField
            multiline rows={6} fullWidth variant="outlined"
            placeholder="Record specific requirements, site visit preference, or plot numbers of interest..."
            value={tempNote} onChange={(e) => setTempNote(e.target.value)}
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions sx={{ p: 3 }}>
          <Button onClick={() => setNotesOpen(false)} variant="outlined">Discard</Button>
          <Button variant="contained" onClick={handleNotesSave} sx={{ fontWeight: 700 }}>Save to Lead Profile</Button>
        </DialogActions>
      </Dialog>

      {/* Bulk WhatsApp Dialog */}
      <Dialog open={bulkDialogOpen} onClose={() => !isBulkSending && setBulkDialogOpen(false)} fullWidth maxWidth="xs">
        <DialogTitle sx={{ fontWeight: 800, display: 'flex', alignItems: 'center', gap: 1 }}>
          <WhatsAppIcon color="success" /> Bulk Outreach
        </DialogTitle>
        <DialogContent>
          {!isBulkSending ? (
            <Typography sx={{ mt: 1, color: '#475569' }}>
              This will initiate personal WhatsApp chats for <strong>{leads.filter(l => l.status === 'New').length}</strong> new leads. 
              Each chat will open in a new tab with a 2-second delay.
            </Typography>
          ) : (
            <Box sx={{ mt: 2 }}>
              <Typography variant="body2" sx={{ mb: 1, fontWeight: 700 }}>
                Sending to: {bulkProgress.name}
              </Typography>
              <LinearProgress variant="determinate" value={(bulkProgress.current / bulkProgress.total) * 100} sx={{ height: 10, borderRadius: 5, mb: 1, bgcolor: '#e2e8f0', '& .MuiLinearProgress-bar': { borderRadius: 5 } }} />
              <Typography variant="caption" sx={{ display: 'block', textAlign: 'right', fontWeight: 700, color: 'success.main' }}>
                {bulkProgress.current} / {bulkProgress.total} COMPLETED
              </Typography>
              <Alert severity="warning" sx={{ mt: 3 }}>
                Do not close this window until the process is complete.
              </Alert>
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ p: 3 }}>
          {!isBulkSending && (
            <>
              <Button onClick={() => setBulkDialogOpen(false)}>Cancel</Button>
              <Button variant="contained" color="success" onClick={startBulkSending} sx={{ fontWeight: 700 }}>Initiate Outreach</Button>
            </>
          )}
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AdminLeads;

import React, { useEffect, useState } from 'react';
import { 
  Typography, Paper, Table, TableBody, TableCell, TableHead, TableRow, 
  Chip, Box, Button, Dialog, DialogTitle, DialogContent, DialogActions, 
  TextField, FormControlLabel, Switch, IconButton, MenuItem, CircularProgress, Alert, Snackbar
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import { API_BASE_URL } from '../../utils/apiBase';
import { fetchCsrfToken } from '../../utils/csrf';

const AdminUpdates = () => {
  const [updates, setUpdates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [open, setOpen] = useState(false);
  const [editingUpdate, setEditingUpdate] = useState(null);
  const [notification, setNotification] = useState({ open: false, message: '', severity: 'success' });
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    category: 'Infrastructure',
    published: true,
    image: null
  });
  const [imagePreview, setImagePreview] = useState(null);

  const categories = ['Infrastructure', 'Industrial', 'Planning', 'Investment', 'General'];

  const fetchUpdates = () => {
    setLoading(true);
    fetch(`${API_BASE_URL}/updates?all=true`, { credentials: 'include' })
      .then(res => {
        if (res.status === 401 || res.status === 403) {
          window.location.href = '/admin/login';
          return [];
        }
        return res.json();
      })
      .then(data => {
        if (Array.isArray(data)) {
          setUpdates(data);
        } else {
          console.error('Invalid updates data received:', data);
          setUpdates([]);
          if (data && data.error) showNotification(data.error, 'error');
        }
      })
      .catch(err => {
        console.error('Error fetching updates:', err);
        showNotification('Failed to load updates', 'error');
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchUpdates();
  }, []);

  const showNotification = (message, severity = 'success') => {
    setNotification({ open: true, message, severity });
  };

  const handleOpen = (update = null) => {
    // Safety: ensure update is an object and not an event
    if (update && typeof update === 'object' && update.title !== undefined) {
      setEditingUpdate(update);
      setFormData({
        title: update.title || '',
        content: update.content || '',
        category: update.category || 'General',
        published: update.published ?? true,
        image: null
      });
      // Clear any previously selected preview; the existing imageUrl is shown via the Box src fallback
      setImagePreview(null);
    } else {
      setEditingUpdate(null);
      setFormData({
        title: '',
        content: '',
        category: 'Infrastructure',
        published: true,
        image: null
      });
      setImagePreview(null);
    }
    setOpen(true);
  };


  const handleClose = () => {
    if (submitting) return;
    setOpen(false);
    setEditingUpdate(null);
    setImagePreview(null);
  };

  const handleInputChange = (e) => {
    const { name, value, checked, type } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleFileChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setFormData(prev => ({ ...prev, image: file }));
      // Generate local preview URL
      const objectUrl = URL.createObjectURL(file);
      setImagePreview(objectUrl);
    }
  };

  const handleSubmit = async () => {
    if (!formData.title || !formData.content) {
      showNotification('Title and content are required', 'error');
      return;
    }

    setSubmitting(true);
    console.log('Submitting update form...', { isEditing: !!editingUpdate });
    
    try {
      console.log('Fetching CSRF token...');
      const csrfToken = await fetchCsrfToken();
      console.log('CSRF token obtained.');

      const data = new FormData();
      data.append('title', formData.title.trim());
      data.append('content', formData.content.trim());
      data.append('category', formData.category);
      data.append('published', String(formData.published));
      
      if (formData.image) {
        data.append('image', formData.image);
      }

      const url = editingUpdate 
        ? `${API_BASE_URL}/updates/${editingUpdate.id}` 
        : `${API_BASE_URL}/updates`;
      
      const method = editingUpdate ? 'PUT' : 'POST';

      console.log(`Sending ${method} request to ${url}...`);
      const res = await fetch(url, {
        method,
        headers: {
          'x-csrf-token': csrfToken
        },
        body: data,
        credentials: 'include'
      });

      if (res.ok) {
        console.log('Update saved successfully.');
        showNotification(editingUpdate ? 'Update modified successfully' : 'Update created successfully');
        handleClose();
        fetchUpdates();
      } else {
        console.error('Update save failed with status:', res.status);
        let errorMessage = 'Failed to save update';
        try {
          const errData = await res.json();
          errorMessage = errData.error || errorMessage;
          console.error('Server error details:', errData);
        } catch (parseErr) {
          errorMessage = `Server error: ${res.status} ${res.statusText}`;
        }
        showNotification(errorMessage, 'error');
      }
    } catch (err) {
      console.error('Fatal submit error:', err);
      showNotification(err.message || 'An error occurred while saving', 'error');
      // Fallback alert for severe errors that might be missed in the snackbar
      if (err.message?.includes('CSRF')) {
        alert('Security session expired. Please refresh the page and try again.');
      }
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this update?')) return;

    try {
      const csrfToken = await fetchCsrfToken();
      const res = await fetch(`${API_BASE_URL}/updates/${id}`, {
        method: 'DELETE',
        headers: {
          'x-csrf-token': csrfToken
        },
        credentials: 'include'
      });

      if (res.ok) {
        showNotification('Update deleted');
        fetchUpdates();
      } else {
        showNotification('Failed to delete update', 'error');
      }
    } catch (err) {
      console.error(err);
      showNotification('An error occurred during deletion', 'error');
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 4, alignItems: 'center' }}>
        <Typography variant="h4" sx={{ fontWeight: 700 }}>Updates Manager</Typography>
        <Button 
          variant="contained" 
          color="primary" 
          onClick={() => handleOpen()}
          startIcon={<CloudUploadIcon />}
        >
          Create Update
        </Button>
      </Box>

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
          <CircularProgress />
        </Box>
      ) : (
        <Paper sx={{ borderRadius: 3, overflow: 'hidden' }}>
          <Table>
            <TableHead sx={{ bgcolor: 'grey.100' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 600 }}>Title</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Category</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {updates.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 6 }}>
                    <Typography color="text.secondary" gutterBottom>No updates found yet.</Typography>
                    <Button 
                      variant="outlined" 
                      color="primary" 
                      onClick={() => handleOpen()}
                      startIcon={<CloudUploadIcon />}
                      sx={{ mt: 1, borderRadius: 2, textTransform: 'none', fontWeight: 600 }}
                    >
                      Click here to create your first update
                    </Button>
                  </TableCell>
                </TableRow>
              ) : (
                updates.map((update) => (
                  <TableRow key={update.id}>
                    <TableCell>{update.title}</TableCell>
                    <TableCell><Chip label={update.category} size="small" /></TableCell>
                    <TableCell>{update.createdAt ? new Date(update.createdAt).toLocaleDateString() : 'N/A'}</TableCell>
                    <TableCell>
                      <Chip 
                        label={update.published ? 'Published' : 'Draft'} 
                        size="small" 
                        color={update.published ? 'success' : 'default'} 
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" color="primary" onClick={() => handleOpen(update)}>
                        <EditIcon />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(update.id)}>
                        <DeleteIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
        <DialogTitle>{editingUpdate ? 'Edit Update' : 'Create New Update'}</DialogTitle>
        <DialogContent sx={{ pt: 2 }}>
          <TextField
            fullWidth
            label="Title"
            name="title"
            value={formData.title}
            onChange={handleInputChange}
            sx={{ mb: 2 }}
            required
            error={!formData.title && submitting}
          />
          <TextField
            fullWidth
            label="Category"
            name="category"
            select
            value={formData.category}
            onChange={handleInputChange}
            sx={{ mb: 2 }}
          >
            {categories.map(cat => (
              <MenuItem key={cat} value={cat}>{cat}</MenuItem>
            ))}
          </TextField>
          <TextField
            fullWidth
            label="Content"
            name="content"
            multiline
            rows={16}
            value={formData.content}
            onChange={handleInputChange}
            sx={{ mb: 1 }}
            required
            error={!formData.content && submitting}
            helperText={`${formData.content.length.toLocaleString()} / 50,000 characters — use blank lines to create paragraphs`}
            inputProps={{ maxLength: 50000 }}
          />
          <Box sx={{ mb: 2 }} />
          <Box sx={{ mb: 2 }}>
            <Typography variant="subtitle2" gutterBottom>Header Image</Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
              <Button
                variant="outlined"
                component="label"
                startIcon={<CloudUploadIcon />}
              >
                Choose File
                <input type="file" hidden accept="image/*" onChange={handleFileChange} />
              </Button>
              <Typography variant="caption" color="text.secondary">
                {formData.image ? formData.image.name : 'No file chosen (JPG, PNG, WebP, SVG — max 5 MB)'}
              </Typography>
            </Box>
            {/* Image preview */}
            {(imagePreview || (editingUpdate?.imageUrl && !formData.image)) && (
              <Box
                component="img"
                src={imagePreview || `${(typeof window !== 'undefined' ? window.location.origin.replace('5173','3000').replace('5174','3000') : 'http://localhost:3000')}${editingUpdate?.imageUrl}`}
                alt="Preview"
                sx={{
                  mt: 1.5,
                  maxHeight: 180,
                  maxWidth: '100%',
                  borderRadius: 2,
                  border: '1px solid',
                  borderColor: 'divider',
                  objectFit: 'cover',
                  display: 'block'
                }}
              />
            )}
          </Box>
          <FormControlLabel
            control={<Switch name="published" checked={formData.published} onChange={handleInputChange} />}
            label="Published (Visible to public)"
          />
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={handleClose} disabled={submitting}>Cancel</Button>
          <Button 
            variant="contained" 
            onClick={handleSubmit} 
            disabled={submitting}
            startIcon={submitting ? <CircularProgress size={20} /> : null}
          >
            {submitting ? 'Saving...' : 'Save Update'}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar 
        open={notification.open} 
        autoHideDuration={6000} 
        onClose={() => setNotification({ ...notification, open: false })}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert severity={notification.severity} sx={{ width: '100%' }}>
          {notification.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default AdminUpdates;

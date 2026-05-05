import React, { useState, useEffect } from 'react';
import { Box, Typography, CircularProgress, IconButton, Paper, Button } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import { API_BASE_URL } from '../utils/apiBase';

const SecurePdfViewer = ({ pdfId, onClose }) => {
  const [blobUrl, setBlobUrl] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Use localStorage values directly to ensure we have the latest after verification
  const leadPhone = localStorage.getItem('lead_phone') || 'VERIFIED';
  const leadEmail = localStorage.getItem('lead_email') || 'VERIFIED';

  useEffect(() => {
    if (!pdfId) {
      setError('Invalid document ID');
      setLoading(false);
      return;
    }

    const fetchPdf = async () => {
      setLoading(true);
      setError(null);
      try {
        const token = localStorage.getItem('lead_token');
        if (!token) throw new Error('Verification required to access this document.');

        const res = await fetch(`${API_BASE_URL}/pdf/view/${pdfId}`, {
          headers: { 'Authorization': token }
        });

        if (!res.ok) {
          const errData = await res.json().catch(() => ({ error: 'Server error' }));
          throw new Error(errData.error || `Failed to load document (${res.status})`);
        }

        const blob = await res.blob();
        if (blob.type !== 'application/pdf') {
          console.warn('Received non-PDF blob type:', blob.type);
        }
        
        const url = URL.createObjectURL(blob);
        setBlobUrl(url);
      } catch (err) {
        console.error('SecurePdfViewer Fetch Error:', err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchPdf();

    return () => {
      if (blobUrl) {
        URL.revokeObjectURL(blobUrl);
      }
    };
  }, [pdfId]);

  return (
    <Box sx={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, bgcolor: 'rgba(0,0,0,0.9)', zIndex: 9999, display: 'flex', flexDirection: 'column' }}>
      <Box sx={{ p: 2, display: 'flex', justifyContent: 'flex-end', bgcolor: '#1e1e1e' }}>
        <IconButton color="error" onClick={onClose} sx={{ bgcolor: 'rgba(255,255,255,0.1)' }}>
          <CloseIcon />
        </IconButton>
      </Box>
      <Box sx={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', p: 2 }}>
        {loading && <CircularProgress color="primary" />}
        {error && (
          <Paper sx={{ p: 4, textAlign: 'center', bgcolor: '#fff', borderRadius: 4, maxWidth: 400 }}>
            <Typography variant="h5" color="primary" sx={{ fontWeight: 800, mb: 2 }}>Access Denied</Typography>
            <Typography color="text.secondary" variant="body1" sx={{ mb: 3 }}>{error}</Typography>
            <Button variant="contained" onClick={onClose}>Close Viewer</Button>
          </Paper>
        )}
        {blobUrl && (
          <Box sx={{ position: 'relative', width: '100%', height: '100%', maxWidth: '1100px', boxShadow: 24 }}>
            {/* Tiled Watermark */}
            <Box sx={{ 
              position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, 
              pointerEvents: 'none', zIndex: 10, overflow: 'hidden', opacity: 0.12,
              display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gridTemplateRows: 'repeat(4, 1fr)'
            }}>
              {[...Array(12)].map((_, i) => (
                <Box key={i} sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', transform: 'rotate(-30deg)' }}>
                  <Typography variant="caption" sx={{ color: 'black', fontWeight: 900, userSelect: 'none', textAlign: 'center' }}>
                    {leadPhone} <br/> {leadEmail}
                  </Typography>
                </Box>
              ))}
            </Box>
            
            <iframe 
              src={`${blobUrl}#toolbar=0&navpanes=0&scrollbar=0`} 
              width="100%" 
              height="100%" 
              style={{ border: 'none', background: '#fff' }}
              title="Secure Document Viewer"
              onContextMenu={(e) => e.preventDefault()}
            />
          </Box>
        )}
      </Box>
    </Box>
  );
};

export default SecurePdfViewer;

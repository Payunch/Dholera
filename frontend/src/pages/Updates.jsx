import React, { useEffect, useState } from 'react';
import {
  Container, Typography, Grid, Card, CardContent, CardMedia, Box,
  Chip, TextField, Dialog, Button, IconButton,
  Skeleton, InputAdornment, Divider
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import CloseIcon from '@mui/icons-material/Close';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import { API_BASE_URL } from '../utils/apiBase';
import Seo from '../components/Seo';

// Derives the backend base (e.g. http://localhost:3000) from API_BASE_URL
const BACKEND_BASE = API_BASE_URL.replace(/\/api$/, '');

const CATEGORY_COLORS = {
  Infrastructure: '#1565C0',
  Industrial:     '#2E7D32',
  Planning:       '#6A1B9A',
  Investment:     '#E65100',
  General:        '#37474F',
};

const getCategoryColor = (cat) => CATEGORY_COLORS[cat] || '#37474F';

/** Renders plain-text content respecting newlines as paragraphs */
const ArticleBody = ({ content }) => {
  if (!content) return null;
  const paragraphs = content.split(/\n\n+/).map(p => p.replace(/\n/g, ' '));
  return (
    <Box>
      {paragraphs.map((p, i) => (
        <Typography
          key={i}
          variant="body1"
          sx={{ mb: 2, lineHeight: 1.8, color: 'text.primary', whiteSpace: 'pre-wrap' }}
        >
          {p}
        </Typography>
      ))}
    </Box>
  );
};

const Updates = () => {
  const [updates, setUpdates] = useState([]);
  const [search, setSearch]   = useState('');
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null); // article open in modal
  const [activeCategory, setActiveCategory] = useState('All');

  const categories = ['All', 'Infrastructure', 'Industrial', 'Planning', 'Investment', 'General'];

  useEffect(() => {
    setLoading(true);
    const query = search ? `?search=${encodeURIComponent(search)}` : '';
    fetch(`${API_BASE_URL}/updates${query}`)
      .then(res => res.json())
      .then(data => setUpdates(Array.isArray(data) ? data : []))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [search]);

  const filtered = activeCategory === 'All'
    ? updates
    : updates.filter(u => u.category === activeCategory);

  const getImageSrc = (update) => {
    if (!update.imageUrl) return null;
    // imageUrl is stored as "/uploads/images/..." — prepend backend host
    if (update.imageUrl.startsWith('http')) return update.imageUrl;
    return `${BACKEND_BASE}${update.imageUrl}`;
  };

  return (
    <Container maxWidth="xl" sx={{ py: 8 }}>
      <Seo
        title="Development Updates"
        description="Search Dholera development updates, milestones, and evidence-backed announcements."
        path="/updates"
      />

      {/* Hero header */}
      <Box sx={{ mb: 6 }}>
        <Typography variant="h2" sx={{ fontWeight: 800, color: 'primary.main', mb: 1 }}>
          Development Updates
        </Typography>
        <Typography variant="h6" color="text.secondary">
          Stay informed on the latest infrastructure milestones in Dholera Smart City.
        </Typography>
      </Box>

      {/* Search + filter bar */}
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, mb: 4, alignItems: 'center' }}>
        <TextField
          label="Search updates"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          size="small"
          sx={{ width: 300 }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon fontSize="small" />
              </InputAdornment>
            ),
          }}
        />
        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
          {categories.map(cat => (
            <Chip
              key={cat}
              label={cat}
              clickable
              onClick={() => setActiveCategory(cat)}
              variant={activeCategory === cat ? 'filled' : 'outlined'}
              sx={{
                fontWeight: 600,
                bgcolor: activeCategory === cat ? getCategoryColor(cat) : 'transparent',
                color: activeCategory === cat ? '#fff' : 'text.secondary',
                borderColor: getCategoryColor(cat),
                '&:hover': { bgcolor: getCategoryColor(cat), color: '#fff' },
                transition: 'all 0.2s'
              }}
            />
          ))}
        </Box>
      </Box>

      {/* Grid */}
      <Grid container spacing={4}>
        {loading
          ? Array.from({ length: 6 }).map((_, i) => (
              <Grid item xs={12} sm={6} md={4} key={i}>
                <Card sx={{ borderRadius: 3, overflow: 'hidden' }}>
                  <Skeleton variant="rectangular" height={200} />
                  <CardContent>
                    <Skeleton width="40%" height={24} sx={{ mb: 1 }} />
                    <Skeleton width="85%" height={28} sx={{ mb: 1 }} />
                    <Skeleton width="100%" />
                    <Skeleton width="90%" />
                  </CardContent>
                </Card>
              </Grid>
            ))
          : filtered.length === 0
          ? (
              <Grid item xs={12}>
                <Box sx={{ textAlign: 'center', py: 10 }}>
                  <Typography variant="h5" color="text.secondary" gutterBottom>
                    No updates found
                  </Typography>
                  <Typography color="text.secondary">
                    {search ? 'Try a different search term.' : 'Check back soon for updates.'}
                  </Typography>
                </Box>
              </Grid>
            )
          : filtered.map(update => {
              const imgSrc = getImageSrc(update);
              const catColor = getCategoryColor(update.category);
              const preview = update.content
                ? update.content.replace(/\n/g, ' ').slice(0, 140) + (update.content.length > 140 ? '…' : '')
                : '';

              return (
                <Grid item xs={12} sm={6} md={4} key={update.id}>
                  <Card
                    sx={{
                      height: '100%',
                      display: 'flex',
                      flexDirection: 'column',
                      borderRadius: 3,
                      overflow: 'hidden',
                      cursor: 'pointer',
                      transition: 'transform 0.2s, box-shadow 0.2s',
                      '&:hover': {
                        transform: 'translateY(-4px)',
                        boxShadow: 6
                      }
                    }}
                    onClick={() => setSelected(update)}
                  >
                    {/* Image or coloured category banner */}
                    {imgSrc ? (
                      <CardMedia
                        component="img"
                        height="200"
                        image={imgSrc}
                        alt={update.title}
                        sx={{ objectFit: 'cover' }}
                        onError={(e) => {
                          e.target.style.display = 'none';
                        }}
                      />
                    ) : (
                      <Box
                        sx={{
                          height: 200,
                          bgcolor: catColor,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          px: 3
                        }}
                      >
                        <Typography
                          variant="h5"
                          sx={{ color: 'rgba(255,255,255,0.9)', fontWeight: 700, textAlign: 'center' }}
                        >
                          {update.category}
                        </Typography>
                      </Box>
                    )}

                    <CardContent sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1.5 }}>
                        <Chip
                          label={update.category}
                          size="small"
                          sx={{ bgcolor: catColor, color: '#fff', fontWeight: 600, fontSize: '0.7rem' }}
                        />
                        {update.createdAt && (
                          <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 0.3 }}>
                            <CalendarTodayIcon sx={{ fontSize: 12 }} />
                            {new Date(update.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
                          </Typography>
                        )}
                      </Box>

                      <Typography variant="h6" sx={{ fontWeight: 700, mb: 1, color: 'primary.dark', lineHeight: 1.3 }}>
                        {update.title}
                      </Typography>

                      <Typography variant="body2" color="text.secondary" sx={{ flexGrow: 1, lineHeight: 1.6 }}>
                        {preview}
                      </Typography>

                      <Typography
                        variant="caption"
                        sx={{
                          mt: 2,
                          color: catColor,
                          fontWeight: 700,
                          textTransform: 'uppercase',
                          letterSpacing: 0.5
                        }}
                      >
                        Read full article →
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
              );
            })}
      </Grid>

      {/* Full-screen article reader */}
      <Dialog
        open={Boolean(selected)}
        onClose={() => setSelected(null)}
        fullScreen
        scroll="paper"
        TransitionProps={{ unmountOnExit: true }}
        PaperProps={{ sx: { bgcolor: 'background.default' } }}
      >
        {selected && (
          <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>

            {/* ── Sticky top bar ── */}
            <Box
              sx={{
                position: 'sticky',
                top: 0,
                zIndex: 10,
                bgcolor: 'background.paper',
                borderBottom: '1px solid',
                borderColor: 'divider',
                px: { xs: 2, md: 4 },
                py: 1.5,
                display: 'flex',
                alignItems: 'center',
                gap: 2
              }}
            >
              <IconButton onClick={() => setSelected(null)} edge="start" aria-label="Close article">
                <CloseIcon />
              </IconButton>
              <Chip
                label={selected.category}
                size="small"
                sx={{
                  bgcolor: getCategoryColor(selected.category),
                  color: '#fff',
                  fontWeight: 700,
                  fontSize: '0.72rem'
                }}
              />
              <Typography
                variant="subtitle2"
                sx={{
                  flex: 1,
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  color: 'text.secondary'
                }}
              >
                {selected.title}
              </Typography>
              <Button
                variant="outlined"
                size="small"
                onClick={() => setSelected(null)}
                sx={{ display: { xs: 'none', sm: 'inline-flex' }, textTransform: 'none' }}
              >
                ← Back to Updates
              </Button>
            </Box>

            {/* ── Hero image ── */}
            {getImageSrc(selected) && (
              <Box
                component="img"
                src={getImageSrc(selected)}
                alt={selected.title}
                sx={{
                  width: '100%',
                  maxHeight: { xs: 240, sm: 380, md: 500 },
                  objectFit: 'cover',
                  display: 'block',
                  flexShrink: 0
                }}
                onError={(e) => { e.target.style.display = 'none'; }}
              />
            )}

            {/* ── Article body ── */}
            <Box
              sx={{
                flex: 1,
                width: '100%',
                maxWidth: 780,
                mx: 'auto',
                px: { xs: 2, sm: 4, md: 6 },
                py: { xs: 4, md: 6 }
              }}
            >
              {/* Meta row */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 3, flexWrap: 'wrap' }}>
                <Chip
                  label={selected.category}
                  sx={{
                    bgcolor: getCategoryColor(selected.category),
                    color: '#fff',
                    fontWeight: 700,
                    fontSize: '0.75rem'
                  }}
                />
                {selected.createdAt && (
                  <Typography
                    variant="body2"
                    color="text.secondary"
                    sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}
                  >
                    <CalendarTodayIcon sx={{ fontSize: 14 }} />
                    {new Date(selected.createdAt).toLocaleDateString('en-IN', {
                      weekday: 'long',
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric'
                    })}
                  </Typography>
                )}
              </Box>

              {/* Title */}
              <Typography
                variant="h3"
                sx={{
                  fontWeight: 900,
                  lineHeight: 1.2,
                  mb: 4,
                  color: 'text.primary',
                  fontSize: { xs: '1.8rem', sm: '2.2rem', md: '2.6rem' }
                }}
              >
                {selected.title}
              </Typography>

              <Divider sx={{ mb: 4 }} />

              {/* Full article content */}
              <ArticleBody content={selected.content} />
            </Box>

            {/* ── Footer close button ── */}
            <Box
              sx={{
                borderTop: '1px solid',
                borderColor: 'divider',
                py: 3,
                px: { xs: 2, md: 4 },
                display: 'flex',
                justifyContent: 'center'
              }}
            >
              <Button
                variant="contained"
                size="large"
                onClick={() => setSelected(null)}
                sx={{ px: 6, borderRadius: 3, textTransform: 'none', fontWeight: 700 }}
              >
                ← Back to All Updates
              </Button>
            </Box>
          </Box>
        )}
      </Dialog>
    </Container>
  );
};

export default Updates;

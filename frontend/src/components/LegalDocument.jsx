import React from 'react';
import { Box, Chip, Container, Link, Paper, Stack, Typography } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import Seo from './Seo';
import { siteContact } from '../data/siteContact';

const LegalDocument = ({ title, description, path, scopeLabel, intro, sections }) => {
  return (
    <Box sx={{ bgcolor: 'background.default', py: { xs: 6, md: 10 } }}>
      <Seo title={title} description={description} path={path} />
      <Container maxWidth="md">
        <Paper sx={{ p: { xs: 3, md: 5 }, borderRadius: 4, border: '1px solid rgba(10, 61, 98, 0.08)' }}>
          <Stack spacing={2} sx={{ mb: 4 }}>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1.5} useFlexGap flexWrap="wrap">
              <Chip label={scopeLabel} color="primary" variant="outlined" />
              <Chip label={`Effective ${siteContact.effectiveDateLabel}`} color="secondary" variant="outlined" />
            </Stack>
            <Typography variant="h2" sx={{ color: 'primary.main', fontWeight: 800 }}>
              {title}
            </Typography>
            <Typography variant="body1" color="text.secondary" sx={{ fontSize: '1.05rem' }}>
              {intro}
            </Typography>
          </Stack>

          <Stack spacing={4}>
            {sections.map((section) => (
              <Box key={section.title}>
                <Typography variant="h5" sx={{ fontWeight: 800, mb: 1.5, color: 'primary.main' }}>
                  {section.title}
                </Typography>

                {section.paragraphs?.map((paragraph) => (
                  <Typography key={paragraph} variant="body1" sx={{ mb: 1.5, lineHeight: 1.8 }}>
                    {paragraph}
                  </Typography>
                ))}

                {section.bullets?.length ? (
                  <Box component="ul" sx={{ pl: 3, mb: 0 }}>
                    {section.bullets.map((bullet) => (
                      <Box component="li" key={bullet} sx={{ mb: 1 }}>
                        <Typography variant="body1" sx={{ lineHeight: 1.8 }}>
                          {bullet}
                        </Typography>
                      </Box>
                    ))}
                  </Box>
                ) : null}
              </Box>
            ))}
          </Stack>

          <Box sx={{ mt: 5, pt: 3, borderTop: '1px solid rgba(10, 61, 98, 0.08)' }}>
            <Typography variant="body2" color="text.secondary" sx={{ lineHeight: 1.8 }}>
              Questions about this document can be sent to{' '}
              <Link href={`mailto:${siteContact.email}`} underline="hover">
                {siteContact.email}
              </Link>{' '}
              or discussed at{' '}
              <Link href={`tel:${siteContact.phoneE164}`} underline="hover">
                {siteContact.phoneDisplay}
              </Link>.
              {' '}You can also review our{' '}
              <Link component={RouterLink} to="/privacy-policy" underline="hover">
                Privacy Policy
              </Link>{' '}
              and{' '}
              <Link component={RouterLink} to="/terms-and-conditions" underline="hover">
                Terms & Conditions
              </Link>.
            </Typography>
          </Box>
        </Paper>
      </Container>
    </Box>
  );
};

export default LegalDocument;

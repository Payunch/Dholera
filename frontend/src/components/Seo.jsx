import React from 'react';
import { Helmet } from 'react-helmet-async';

const SITE_URL = import.meta.env.VITE_SITE_URL || 'http://localhost:5173';

const Seo = ({ title, description, path = '/', image = '/favicon.svg' }) => {
  const resolvedTitle = title ? `${title} | Dholera Portal` : 'Dholera Portal';
  const url = `${SITE_URL.replace(/\/$/, '')}${path.startsWith('/') ? path : `/${path}`}`;

  return (
    <Helmet>
      <title>{resolvedTitle}</title>
      <meta name="description" content={description || 'Infrastructure intelligence, planning maps, and lead capture for Dholera Smart City.'} />
      <link rel="canonical" href={url} />
      <meta property="og:title" content={resolvedTitle} />
      <meta property="og:description" content={description || 'Infrastructure intelligence, planning maps, and lead capture for Dholera Smart City.'} />
      <meta property="og:url" content={url} />
      <meta property="og:type" content="website" />
      <meta property="og:image" content={`${SITE_URL.replace(/\/$/, '')}${image.startsWith('/') ? image : `/${image}`}`} />
      <meta name="twitter:card" content="summary_large_image" />
    </Helmet>
  );
};

export default Seo;
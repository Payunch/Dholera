import { Helmet } from "react-helmet-async";

const siteUrl = import.meta.env.VITE_SITE_URL || "https://example.com";

export default function Seo({
  title,
  description,
  path = "/",
  image = "/favicon.svg",
  schema,
}) {
  const canonical = new URL(path, siteUrl).toString();
  const imageUrl = image.startsWith("http") ? image : new URL(image, siteUrl).toString();

  return (
    <Helmet>
      <title>{title}</title>
      <meta name="description" content={description} />
      <link rel="canonical" href={canonical} />
      <meta property="og:type" content="website" />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:url" content={canonical} />
      <meta property="og:image" content={imageUrl} />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={imageUrl} />
      <link rel="manifest" href="/manifest.webmanifest" />
      {schema ? <script type="application/ld+json">{JSON.stringify(schema)}</script> : null}
    </Helmet>
  );
}

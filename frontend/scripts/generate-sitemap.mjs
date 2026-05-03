import { writeFile } from "node:fs/promises";

const siteUrl = process.env.VITE_SITE_URL || "https://example.com";
const apiBase = process.env.VITE_API_BASE_URL || "http://localhost:8000/api/v1";
const routes = ["/", "/development-feed", "/project-maps", "/future-growth", "/contact"];

async function fetchUpdates() {
  try {
    const response = await fetch(`${apiBase}/public/sitemap-data`);
    if (!response.ok) {
      return [];
    }

    const payload = await response.json();
    return (payload.updates || []).map((update) => ({
      path: `/updates/${update.slug}`,
      lastmod: update.updated_at || undefined,
    }));
  } catch (error) {
    console.warn("Sitemap generation fell back to static routes:", error.message);
    return [];
  }
}

function buildUrlEntry(path, lastmod) {
  return `  <url>\n    <loc>${siteUrl}${path}</loc>${
    lastmod ? `\n    <lastmod>${lastmod}</lastmod>` : ""
  }\n  </url>`;
}

const dynamicRoutes = await fetchUpdates();
const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${[
  ...routes.map((route) => buildUrlEntry(route)),
  ...dynamicRoutes.map((route) => buildUrlEntry(route.path, route.lastmod)),
].join("\n")}\n</urlset>\n`;

await writeFile(new URL("../public/sitemap.xml", import.meta.url), xml, "utf8");
console.log("Sitemap generated with", routes.length + dynamicRoutes.length, "entries");


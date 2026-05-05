import { writeFile } from "node:fs/promises";

const siteUrl = process.env.VITE_SITE_URL || "https://example.com";
const routes = [
  "/",
  "/updates",
  "/planning",
  "/investment",
  "/contact",
  "/terms-and-conditions",
  "/privacy-policy",
];

function buildUrlEntry(path) {
  return `  <url>\n    <loc>${siteUrl}${path}</loc>\n  </url>`;
}

const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${routes
  .map((route) => buildUrlEntry(route))
  .join("\n")}\n</urlset>\n`;

await writeFile(new URL("../public/sitemap.xml", import.meta.url), xml, "utf8");
console.log("Sitemap generated with", routes.length, "entries");

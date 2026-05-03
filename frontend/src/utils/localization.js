import { apiOrigin } from "../api/client";

export function resolveLocalizedValue(locale, value) {
  if (!value) return "";
  if (typeof value === "string") return value;
  return value[locale] || value.en || Object.values(value).find(Boolean) || "";
}

export function getLocalizedField(item, field, locale) {
  if (!item) return "";
  return item[`${field}_${locale}`] || item[`${field}_en`] || item[field] || "";
}

export function formatDate(value, locale = "en") {
  if (!value) return "";
  return new Intl.DateTimeFormat(locale === "gu" ? "gu-IN" : locale === "hi" ? "hi-IN" : "en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

export function resolveMediaUrl(url) {
  if (!url) return "";
  if (url.startsWith("http")) return url;
  return `${apiOrigin}${url}`;
}

export function tagsInputToArray(value) {
  return value
    .split(",")
    .map((tag) => tag.trim())
    .filter(Boolean);
}


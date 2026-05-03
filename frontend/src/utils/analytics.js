const whatsappNumber = import.meta.env.VITE_WHATSAPP_NUMBER || "919999999999";

export function trackEvent(name, params = {}) {
  if (window.gtag) {
    window.gtag("event", name, params);
  }
  if (window.fbq) {
    window.fbq("trackCustom", name, params);
  }
  if (import.meta.env.DEV) {
    console.debug("[tracking]", name, params);
  }
}

export function trackPageView(pathname) {
  trackEvent("page_view", { page_path: pathname });
}

export function buildWhatsAppUrl(message) {
  return `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(message)}`;
}


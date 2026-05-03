# Dholera Growth Ecosystem - Business Strategy

## 1. CRM Architecture
The CRM system tracks lead engagement from the point of entry (Ads/Organic) to the final sale.
- **Lead Capture:** Captures UTM parameters (utm_source, utm_medium, utm_campaign) via hidden fields in the React frontend.
- **Engagement Tracking:** Tracks which specific update (`source="update:slug"`) triggered the conversion.
- **WhatsApp Integration:** Pre-fills context (e.g., "Hi, I'm interested in this growth update: Tata Factory Progress") directly into WhatsApp Web/App when users click "WhatsApp Now".
- **Pipeline Stages:** New -> Site Visit Planned -> Negotiation -> Closed/Lost.

## 2. WhatsApp Automation Flow
- **Inbound Trigger:** Customer clicks sticky WhatsApp CTA or Update-specific WhatsApp CTA.
- **Message Prefill:** System generates context (e.g., "I want the latest corridor growth map").
- **Admin Alert:** `BackgroundTasks` in the FastAPI backend (`create_update`) log alerts that notify sales teams to follow up on a newly pushed update. 
*(Future Extension: Connect the backend to a Meta WhatsApp Cloud API webhook to automatically reply to inbound messages with a PDF Map Pack).*

## 3. Meta Ads Strategy
- **Visuals:** Drone footage of moving machinery, expressway construction, or Tata electronics perimeter.
- **Ad Copy Angle:** "Dholera isn't just planned, it's being built right now. See the real-time growth evidence."
- **Landing Pages:** Ads route specifically to `/landing?theme=industrial` or `/landing?theme=map` to match the exact search intent of the user.
- **Avoid:** Generic "Luxury living" renders. Use raw, high-quality, verified infrastructure updates.

## 4. Content Strategy
Generate updates that trigger investment confidence:
1. **Corridor Movement:** "Ahmedabad-Dholera Expressway Segment 4 Reaches 80% Completion."
2. **Industrial Updates:** "New Substation Commissioned Near Activation Area."
3. **Planning References:** "Town Planning Scheme 2 Boundary Walls Initiated."
4. **Visual Evidence:** Weekly "Before vs. Now" sliders or 30-second drone sweeps (YouTube Shorts embeds).
5. **Cadence:** Minimum 1 high-quality update per week to maintain the "movement" psychology.

## 5. Push Notification System (PWA)
- **Installability:** App is a PWA (Progressive Web App). Users can install "Dholera Growth" directly to their mobile home screen.
- **Trigger:** When an Admin creates a new update in the dashboard, the backend triggers a notification event.
- **Client Delivery:** The `sw.js` (Service Worker) intercepts the push and displays a native mobile notification: *"New infrastructure activity detected! Tap to view."*

## 6. SEO Optimization
- **SSR / Meta Tags:** `react-helmet-async` ensures each Growth Tracker update has its own OpenGraph image and dynamic title for social sharing (WhatsApp/Facebook previews).
- **Sitemap:** The `scripts/generate-sitemap.mjs` outputs a clean `sitemap.xml` referencing all dynamic update slugs for Google Indexing.

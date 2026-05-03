import { useEffect, useState } from "react";
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Container,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
  List,
  ListItem,
  ListItemText,
  Paper,
  Stack,
  TextField,
  Alert,
  Typography,
} from "@mui/material";
import EastRoundedIcon from "@mui/icons-material/EastRounded";
import EventAvailableRoundedIcon from "@mui/icons-material/EventAvailableRounded";
import FileDownloadOutlinedIcon from "@mui/icons-material/FileDownloadOutlined";
import MessageOutlinedIcon from "@mui/icons-material/MessageOutlined";
import TrendingUpRoundedIcon from "@mui/icons-material/TrendingUpRounded";
import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import Seo from "../components/Seo";
import SectionHeader from "../components/SectionHeader";
import UpdateCard from "../components/UpdateCard";
import LeadForm from "../components/LeadForm";
import { publicApi } from "../api/publicApi";
import { useLanguage } from "../context/LanguageContext";
import {
  connectivitySignals,
  growthDrivers,
  heroMetrics,
  mapResources,
  nearbyIndustries,
} from "../content/siteData";
import { buildWhatsAppUrl, trackEvent } from "../utils/analytics";
import { resolveLocalizedValue } from "../utils/localization";

export default function HomePage() {
  const { locale, t } = useLanguage();
  const [pdfError, setPdfError] = useState("");
  const [feed, setFeed] = useState({ featured: null, items: [] });
  const [loading, setLoading] = useState(true);
  const [pdfDialogOpen, setPdfDialogOpen] = useState(false);
  const [pdfCategory, setPdfCategory] = useState(null);
  const [pdfForm, setPdfForm] = useState({ name: "", phone: "", email: "" });
  const [pdfSubmitting, setPdfSubmitting] = useState(false);

  const openPdfOrPrompt = (category) => {
    const key = `pdf_access_${category}`;
    if (window.localStorage.getItem(key)) {
      window.open(`/pdf/pdfs.html?category=${encodeURIComponent(category)}`, "_blank");
      return;
    }
    setPdfCategory(category);
    setPdfForm({ name: "", phone: "", email: "" });
    setPdfError("");
    setPdfDialogOpen(true);
  };

  const closePdfDialog = () => {
    setPdfDialogOpen(false);
    setPdfCategory(null);
    setPdfError("");
  };

  const submitPdfForm = async () => {
    setPdfError("");
    if (!pdfForm.name.trim() || !pdfForm.phone.trim()) {
      setPdfError("Name and mobile number are required.");
      return;
    }
    setPdfSubmitting(true);
    try {
      const emailTrim = pdfForm.email.trim();
      const payload = {
        name: pdfForm.name.trim(),
        phone: pdfForm.phone.trim(),
        source: `pdf_${pdfCategory}`,
        message: `Requested ${pdfCategory} PDFs`,
      };
      // Include email only if it is not empty
      if (emailTrim) {
        payload.email = emailTrim;
      }
      await publicApi.submitLead(payload);
      // mark as granted for this category for this browser session
      const key = `pdf_access_${pdfCategory}`;
      window.localStorage.setItem(key, String(Date.now()));
      closePdfDialog();
      window.open(`/pdf/pdfs.html?category=${encodeURIComponent(pdfCategory)}`, "_blank");
    } catch (err) {
      setPdfError(err?.response?.data?.detail || "Submission failed. Please try again.");
    } finally {
      setPdfSubmitting(false);
    }
  };

  useEffect(() => {
    let active = true;
    publicApi
      .getUpdates({ page_size: 4, include_featured: true })
      .then((data) => {
        if (!active) return;
        setFeed({
          featured: data.featured,
          items: data.items || [],
        });
      })
      .finally(() => {
        if (active) {
          setLoading(false);
        }
      });

    return () => {
      active = false;
    };
  }, []);

  const feedItems = (feed.items || []).filter((item) => item.id !== feed.featured?.id).slice(0, 3);

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Dholera Infrastructure Intelligence | Growth Evidence System"
        description="A production-ready infrastructure intelligence platform built to convert trust into land-buying inquiries, WhatsApp conversations, and site visits."
        path="/"
        schema={{
          "@context": "https://schema.org",
          "@type": "RealEstateAgent",
          name: "Dholera Infrastructure Intelligence",
          areaServed: "Dholera",
          description:
            "Infrastructure intelligence and investment confidence platform for land buyers seeking growth evidence, development activity, and corridor monitor updates.",
          url: `${import.meta.env.VITE_SITE_URL || "https://example.com"}/`,
        }}
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <Grid container spacing={4} className="hero-shell" sx={{ p: { xs: 2.5, md: 4 } }}>
          <Grid item xs={12} md={7} sx={{ position: "relative", zIndex: 1 }}>
            <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.45 }}>
              <Typography
                variant="overline"
                sx={{ color: "primary.main", fontWeight: 900, letterSpacing: "0.14em" }}
              >
                REAL-TIME EVIDENCE
              </Typography>
              <Typography variant="h1" sx={{ mt: 1.5, fontSize: { xs: "2.8rem", md: "4.3rem" } }}>
                Dholera is building. See it.
              </Typography>
              <Typography sx={{ mt: 2.5, fontSize: { xs: "1rem", md: "1.05rem" }, color: "text.secondary", maxWidth: 680 }}>
                Track expressway progress, industrial movement, and corridor momentum. Every week, new growth evidence.
              </Typography>
              <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5} sx={{ mt: 3.5 }}>
                <Button
                  component={Link}
                  to="/contact?intent=site-visit"
                  variant="contained"
                  size="large"
                  startIcon={<EventAvailableRoundedIcon />}
                >
                  {t("cta_site_visit")}
                </Button>
                <Button
                  component="a"
                  href={buildWhatsAppUrl("Hello, I want to discuss land opportunities and the latest growth tracker updates.")}
                  target="_blank"
                  rel="noreferrer"
                  variant="outlined"
                  size="large"
                  startIcon={<MessageOutlinedIcon />}
                  onClick={() => trackEvent("cta_whatsapp_home_hero", { location: "hero" })}
                >
                  {t("cta_whatsapp")}
                </Button>
                <Button
                  component={Link}
                  to="/growth-tracker"
                  size="large"
                  endIcon={<EastRoundedIcon />}
                >
                  Explore Tracker
                </Button>
              </Stack>
            </motion.div>

            <Grid container spacing={2} sx={{ mt: 2 }}>
              {heroMetrics.map((metric) => (
                <Grid item xs={12} sm={4} key={metric.stat}>
                  <Card sx={{ height: "100%", bgcolor: "rgba(255,255,255,0.88)" }}>
                    <CardContent>
                      <Typography variant="h6">{metric.stat}</Typography>
                      <Typography sx={{ mt: 1, color: "text.secondary" }}>
                        {resolveLocalizedValue(locale, metric.label)}
                      </Typography>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          </Grid>

          <Grid item xs={12} md={5}>
            <motion.div initial={{ opacity: 0, scale: 0.98 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.5 }}>
              <Box className="hero-map-panel" sx={{ p: 3.5 }}>
                <Box className="map-route" sx={{ top: 96, left: 40, width: "72%", height: 12, transform: "rotate(18deg)" }} />
                <Box className="map-route" sx={{ top: 212, left: 90, width: "54%", height: 10, transform: "rotate(-14deg)" }} />
                <Box className="map-node" sx={{ top: 88, left: 52 }} />
                <Box className="map-node" sx={{ top: 165, right: 72 }} />
                <Box className="map-node" sx={{ top: 224, left: 118 }} />

                <Stack spacing={2.5} sx={{ position: "relative", zIndex: 1 }}>
                  <Chip label="Corridor Monitoring Board" color="secondary" sx={{ alignSelf: "flex-start" }} />
                  <Typography variant="h3" sx={{ maxWidth: 360 }}>
                    Infrastructure activity, planning cues, and evidence in one view.
                  </Typography>
                  <Typography sx={{ color: "rgba(255,255,255,0.78)", lineHeight: 1.6 }}>
                    • <strong>Weekly updates</strong> on expressway, industrial, and planning progress
                  </Typography>
                  <Typography sx={{ color: "rgba(255,255,255,0.78)", lineHeight: 1.6 }}>
                    • <strong>Direct connection</strong> to site visits and inquiries
                  </Typography>
                </Stack>
              </Box>
            </motion.div>
          </Grid>
        </Grid>

        <Dialog open={pdfDialogOpen} onClose={closePdfDialog} fullWidth maxWidth="sm">
          <DialogTitle>Provide details to access documents</DialogTitle>
          <DialogContent>
            <Stack spacing={2} sx={{ mt: 1 }}>
              <TextField
                label="Name"
                value={pdfForm.name}
                onChange={(e) => setPdfForm((p) => ({ ...p, name: e.target.value }))}
                required
              />
              <TextField
                label="Mobile number"
                value={pdfForm.phone}
                onChange={(e) => setPdfForm((p) => ({ ...p, phone: e.target.value }))}
                required
              />
              <TextField
                label="Email (optional)"
                type="email"
                value={pdfForm.email}
                onChange={(e) => setPdfForm((p) => ({ ...p, email: e.target.value }))}
              />
              {pdfError ? <Alert severity="error">{pdfError}</Alert> : null}
            </Stack>
          </DialogContent>
          <DialogActions sx={{ px: 3, py: 2 }}>
            <Button onClick={closePdfDialog}>Cancel</Button>
            <Button disabled={pdfSubmitting} variant="contained" onClick={submitPdfForm}>
              {pdfSubmitting ? "Submitting..." : "Continue to documents"}
            </Button>
          </DialogActions>
        </Dialog>

      </Container>

      <Container maxWidth="xl" sx={{ mt: 8 }}>
        <SectionHeader
          eyebrow={{ en: "LIVE GROWTH MONITOR", hi: "लाइव ग्रोथ मॉनिटर", gu: "લાઇવ ગ્રોથ મોનિટર" }}
          title={{
            en: t("latest_activity"),
            hi: "इन्फ्रास्ट्रक्चर गतिविधि",
            gu: "ઇન્ફ્રાસ્ટ્રક્ચર પ્રવૃત્તિ",
          }}
          description={{
            en: "A continuous monitor of expressway, industrial activity, and corridor expansion that keeps momentum visible and investment confidence high.",
            hi: "एक्सप्रेसवे, औद्योगिक गतिविधि और कॉरिडोर विस्तार का एक निरंतर मॉनिटर जो गति और निवेश भरोसे को दृश्यमान रखता है।",
            gu: "એક્સપ્રેસવે, ઔદ્યોગિક પ્રવૃત્તિ અને કોરિડોર વિસ્તરણનું સતત મોનિટર જે ગતિ અને રોકાણના વિશ્વાસને દૃશ્યમાન રાખે છે.",
          }}
          action={
            <Button component={Link} to="/growth-tracker" endIcon={<EastRoundedIcon />}>
              View Growth Tracker
            </Button>
          }
        />

        {loading ? (
          <Stack sx={{ py: 8, alignItems: "center" }}>
            <CircularProgress />
          </Stack>
        ) : (
          <Grid container spacing={3} sx={{ mt: 1 }}>
            {feed.featured ? (
              <Grid item xs={12}>
                <UpdateCard update={feed.featured} featured />
              </Grid>
            ) : null}
            {feedItems.map((item) => (
              <Grid item xs={12} md={4} key={item.id}>
                <UpdateCard update={item} />
              </Grid>
            ))}
          </Grid>
        )}
      </Container>

      <Container maxWidth="xl" sx={{ mt: 8 }}>
        <SectionHeader
          eyebrow={{ en: t("maps_heading"), hi: "मैप्स और कनेक्टिविटी", gu: "મેપ્સ અને કનેક્ટિવિટી" }}
          title={{
            en: "Connectivity evidence that supports faster land decisions.",
            hi: "कनेक्टिविटी प्रमाण जो तेज़ भूमि निर्णयों का समर्थन करते हैं।",
            gu: "કનેક્ટિવિટી આધાર જે ઝડપી જમીન નિર્ણયોનું સમર્થન કરે છે.",
          }}
          description={{
            en: "DP maps, corridor overlays, Google orientation, nearby industries, and distance cues designed to reduce friction before a site visit.",
            hi: "DP मैप्स, कॉरिडोर ओवरले, गूगल ओरिएंटेशन, उद्योग संदर्भ और दूरी संकेत जो साइट विजिट से पहले अस्पष्टता कम करते हैं।",
            gu: "DP મેપ્સ, કોરિડોર ઓવરલે, ગૂગલ ઓરિએન્ટેશન, ઉદ્યોગ સંદર્ભ અને અંતર સંકેતો જે સાઇટ વિઝિટ પહેલાં ગૂંચવણ ઘટાડે છે.",
          }}
        />

        <Grid container spacing={3} sx={{ mt: 1 }}>
          <Grid item xs={12} lg={7}>
            <Paper className="admin-surface" sx={{ overflow: "hidden", p: 1.5 }}>
              <Box
                component="iframe"
                title="Dholera map"
                src="https://www.google.com/maps?q=Dholera%20Special%20Investment%20Region&output=embed"
                sx={{ width: "100%", height: { xs: 300, md: 440 }, borderRadius: 3 }}
              />
            </Paper>
          </Grid>
          <Grid item xs={12} lg={5}>
            <Stack spacing={2.5}>
              {connectivitySignals.map((signal) => (
                <Card key={signal.title.en}>
                  <CardContent>
                    <Typography variant="h6">{resolveLocalizedValue(locale, signal.title)}</Typography>
                    <Typography sx={{ mt: 1, color: "text.secondary" }}>
                      {resolveLocalizedValue(locale, signal.description)}
                    </Typography>
                  </CardContent>
                </Card>
              ))}
            </Stack>
          </Grid>
        </Grid>

        <Grid container spacing={3} sx={{ mt: 1 }}>
          {mapResources.map((resource) => (
            <Grid item xs={12} md={4} key={resource.title.en}>
              <Card sx={{ height: "100%" }}>
                <CardContent>
                  <Typography variant="h6">{resolveLocalizedValue(locale, resource.title)}</Typography>
                  <Typography sx={{ mt: 1, color: "text.secondary" }}>
                    {resolveLocalizedValue(locale, resource.description)}
                  </Typography>
                  <Chip label={resource.distance} sx={{ mt: 2 }} />
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      <Container maxWidth="xl" sx={{ mt: 8 }}>
        <SectionHeader
          eyebrow={{ en: t("growth_heading"), hi: "यह क्षेत्र क्यों बढ़ रहा है", gu: "આ વિસ્તાર કેમ વિકસી રહ્યો છે" }}
          title={{
            en: "Evidence that reframes the area from interest to importance.",
            hi: "ऐसे संकेत जो रुचि को महत्व में बदलते हैं।",
            gu: "રસને મહત્વમાં બદલતા આધારબિંદુઓ.",
          }}
          description={{
            en: "Visitors should leave with the sense that infrastructure, accessibility, planning activity, and industrial movement are steadily increasing the area's relevance.",
            hi: "उपयोगकर्ता को यह महसूस होना चाहिए कि इन्फ्रास्ट्रक्चर, पहुंच, प्लानिंग गतिविधि और औद्योगिक गति इस क्षेत्र की अहमियत बढ़ा रही है।",
            gu: "મુલાકાતીને એવું લાગવું જોઈએ કે ઇન્ફ્રાસ્ટ્રક્ચર, ઍક્સેસ, આયોજન પ્રવૃત્તિ અને ઔદ્યોગિક ગતિ વિસ્તારનું મહત્વ વધારી રહી છે.",
          }}
        />

        <Grid container spacing={3} sx={{ mt: 1 }}>
          {growthDrivers.map((driver) => (
            <Grid item xs={12} md={6} key={driver.title.en}>
              <Card sx={{ height: "100%" }}>
                <CardContent>
                  <Stack direction="row" spacing={1.5} alignItems="center">
                    <TrendingUpRoundedIcon color="secondary" />
                    <Typography variant="h6">{resolveLocalizedValue(locale, driver.title)}</Typography>
                  </Stack>
                  <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                    {resolveLocalizedValue(locale, driver.description)}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      <Container maxWidth="xl" sx={{ mt: 8 }}>
        <SectionHeader
          eyebrow={{ en: "PROJECT DOCUMENTATION", hi: "प्रोजेक्ट दस्तावेज", gu: "પ્રોજેક્ટ દસ્તાવેજો" }}
          title={{
            en: "Technical drawings, master plans & reference maps.",
            hi: "तकनीकी ड्राइंग, मास्टर प्लान और संदर्भ मानचित्र।",
            gu: "તકનીકી રેખાંકન, માસ્ટર પ્લાન અને સંદર્ભ નકશા.",
          }}
          description={{
            en: "Access comprehensive planning documents, cadastral maps, and zoning details to make informed investment decisions.",
            hi: "विस्तृत योजना दस्तावेज, भूखंड मानचित्र और क्षेत्रीय विवरण तक पहुंचें।",
            gu: "વ્યાપક આયોજન દસ્તાવેજો, ભાગીદારી નકશા અને ક્ષેત્રીય વિગતો તક પહોંચો.",
          }}
        />

        <Grid container spacing={2.5} sx={{ mt: 1 }}>
          {[
            { key: "naksha", title: "Naksha 28", subtitle: "Plot subdivision and layout maps" },
            { key: "all", title: "PDF 28", subtitle: "All technical documents" },
            { key: "dp", title: "DP Maps", subtitle: "Development plan references" },
          ].map((card) => (
            <Grid item xs={12} sm={6} md={4} key={card.key}>
              <Card
                sx={{
                  height: "100%",
                  textDecoration: "none",
                  color: "inherit",
                  cursor: "pointer",
                  transition: "all 0.3s cubic-bezier(0.22, 1, 0.36, 1)",
                  background: "linear-gradient(135deg, rgba(27, 74, 110, 0.05) 0%, rgba(74, 144, 226, 0.05) 100%)",
                  border: "2px solid rgba(27, 74, 110, 0.1)",
                  "&:hover": {
                    transform: "translateY(-8px)",
                    boxShadow: "0 16px 32px rgba(27, 74, 110, 0.15)",
                    borderColor: "primary.main",
                    background: "linear-gradient(135deg, rgba(27, 74, 110, 0.1) 0%, rgba(74, 144, 226, 0.1) 100%)",
                  },
                }}
                onClick={() => {
                  const key = `pdf_access_${card.key}`;
                  if (window.localStorage.getItem(key)) {
                    window.open(`/pdf/pdfs.html?category=${encodeURIComponent(card.key)}`, "_blank");
                    return;
                  }
                  setPdfCategory(card.key);
                  setPdfDialogOpen(true);
                }}
              >
                <CardContent sx={{ textAlign: "center", py: 3 }}>
                  <FileDownloadOutlinedIcon sx={{ fontSize: "3rem", color: "primary.main", mb: 1.5 }} />
                  <Typography variant="h6" fontWeight={700}>
                    {card.title}
                  </Typography>
                  <Typography sx={{ mt: 1, color: "text.secondary", fontSize: "0.9rem" }}>
                    {card.subtitle}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      <Container maxWidth="xl" sx={{ mt: 8 }}>
        <Grid container spacing={3}>
          <Grid item xs={12} lg={5}>
            <Card sx={{ height: "100%", bgcolor: "primary.dark", color: "#fff" }}>
              <CardContent sx={{ p: { xs: 3, md: 4 } }}>
                <Typography variant="overline" sx={{ color: "secondary.light", letterSpacing: "0.14em", fontWeight: 800 }}>
                  SITE-VISIT CONVERSION
                </Typography>
                <Typography variant="h3" sx={{ mt: 1.5, maxWidth: 420 }}>
                  Use map evidence and recent activity to move serious prospects into scheduled visits.
                </Typography>
                <Stack spacing={1.5} sx={{ mt: 3 }}>
                  {nearbyIndustries.map((item) => (
                    <Paper key={item.name} sx={{ p: 2, bgcolor: "rgba(255,255,255,0.08)", color: "#fff" }}>
                      <Typography fontWeight={700}>{item.name}</Typography>
                      <Typography sx={{ mt: 0.4, color: "rgba(255,255,255,0.74)" }}>{item.distance}</Typography>
                    </Paper>
                  ))}
                </Stack>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} lg={7}>
            <LeadForm
              title={t("contact_heading")}
              subtitle="Request a map pack, site visit, price sheet, or consultation. Every lead is stored in the platform for follow-up and qualification."
              source="homepage"
              ctaType="site-visit"
              buttonLabel={t("cta_site_visit")}
              showVisitDate
            />
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}

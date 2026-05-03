import { Box, Button, Container, Grid, Paper, Stack, Typography, Chip } from "@mui/material";
import { motion } from "framer-motion";
import { useSearchParams } from "react-router-dom";
import MessageOutlinedIcon from "@mui/icons-material/MessageOutlined";
import AdsClickIcon from "@mui/icons-material/AdsClick";
import TrendingUpRoundedIcon from "@mui/icons-material/TrendingUpRounded";
import Seo from "../components/Seo";
import LeadForm from "../components/LeadForm";
import { buildWhatsAppUrl, trackEvent } from "../utils/analytics";

export default function LandingPage() {
  const [searchParams] = useSearchParams();
  const theme = searchParams.get("theme") || "corridor"; // corridor, map, industrial

  const getContent = () => {
    switch (theme) {
      case "map":
        return {
          title: "Access the Latest Infrastructure & Corridor Growth Maps.",
          subtitle: "Stop relying on outdated PDFs. Get the evidence-led corridor monitor and DP map pack for Dholera SIR directly via WhatsApp.",
          cta: "Request Map Pack",
          whatsapp: "Hi, I want the latest corridor growth map.",
        };
      case "industrial":
        return {
          title: "Track Real-Time Industrial Movement in Dholera.",
          subtitle: "From Tata Electronics to global supply chain hubs—see the infrastructure momentum that's turning land into high-value investment assets.",
          cta: "Request Industrial Update",
          whatsapp: "Hi, I want details on industrial movement and land opportunities.",
        };
      default:
        return {
          title: "Infrastructure Evidence. Investment Confidence.",
          subtitle: "Dholera is moving. Track expressway progress, corridor expansion, and industrial planning with our evidence-led intelligence system.",
          cta: "Request Site Visit",
          whatsapp: "Hi, I'm interested in Dholera growth evidence and land opportunities.",
        };
    }
  };

  const content = getContent();

  return (
    <Box sx={{ bgcolor: "background.default", minHeight: "100vh" }}>
      <Seo 
        title={`${content.title} | Dholera Infrastructure Intelligence`}
        description={content.subtitle}
        path={`/landing?theme=${theme}`}
      />

      <Box sx={{ bgcolor: "primary.dark", color: "#fff", pt: { xs: 6, md: 10 }, pb: { xs: 8, md: 12 } }}>
        <Container maxWidth="xl">
          <Grid container spacing={6} alignItems="center">
            <Grid item xs={12} md={7}>
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }}>
                <Stack direction="row" spacing={1} sx={{ mb: 2 }}>
                  <Chip label="Intelligence Report" color="secondary" size="small" sx={{ fontWeight: 700 }} />
                  <Chip label="Real-Time Monitor" variant="outlined" size="small" sx={{ color: "#fff", borderColor: "rgba(255,255,255,0.3)" }} />
                </Stack>
                <Typography variant="h1" sx={{ fontSize: { xs: "2.5rem", md: "4rem" }, color: "inherit" }}>
                  {content.title}
                </Typography>
                <Typography sx={{ mt: 3, fontSize: "1.25rem", color: "rgba(255,255,255,0.8)", maxWidth: 600 }}>
                  {content.subtitle}
                </Typography>
                
                <Stack direction={{ xs: "column", sm: "row" }} spacing={2} sx={{ mt: 5 }}>
                  <Button
                    component="a"
                    href={buildWhatsAppUrl(content.whatsapp)}
                    target="_blank"
                    variant="contained"
                    color="secondary"
                    size="large"
                    startIcon={<MessageOutlinedIcon />}
                    onClick={() => trackEvent("cta_whatsapp_landing", { theme })}
                    sx={{ height: 56, px: 4, fontSize: "1.1rem" }}
                  >
                    WhatsApp Intelligence Request
                  </Button>
                </Stack>
              </motion.div>
            </Grid>
            <Grid item xs={12} md={5}>
              <Paper sx={{ p: 4, bgcolor: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", backdropFilter: "blur(10px)", color: "#fff" }}>
                <Stack spacing={3}>
                  <Stack direction="row" spacing={2}>
                    <AdsClickIcon color="secondary" />
                    <Box>
                      <Typography fontWeight={700}>Infrastructure Tracker</Typography>
                      <Typography variant="body2" sx={{ color: "rgba(255,255,255,0.6)" }}>See roads, power, and planning in real-time.</Typography>
                    </Box>
                  </Stack>
                  <Stack direction="row" spacing={2}>
                    <TrendingUpRoundedIcon color="secondary" />
                    <Box>
                      <Typography fontWeight={700}>Momentum Evidence</Typography>
                      <Typography variant="body2" sx={{ color: "rgba(255,255,255,0.6)" }}>Shift from "interest" to "importance" with real data.</Typography>
                    </Box>
                  </Stack>
                  <Stack direction="row" spacing={2}>
                    <MessageOutlinedIcon color="secondary" />
                    <Box>
                      <Typography fontWeight={700}>Consultation Path</Typography>
                      <Typography variant="body2" sx={{ color: "rgba(255,255,255,0.6)" }}>Direct access to site visit booking and map packs.</Typography>
                    </Box>
                  </Stack>
                </Stack>
              </Paper>
            </Grid>
          </Grid>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ mt: -6, position: "relative", zIndex: 10, pb: 10 }}>
        <Grid container spacing={4} justifyContent="center">
          <Grid item xs={12} lg={10}>
            <LeadForm 
              title="Secure Your Intelligence Brief"
              subtitle="Enter your details below to receive the latest corridor maps, industrial updates, and schedule a site visit with our senior consultants."
              source={`landing_${theme}`}
              ctaType={theme === "map" ? "map-request" : "consultation"}
              buttonLabel={content.cta}
              showVisitDate
            />
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}

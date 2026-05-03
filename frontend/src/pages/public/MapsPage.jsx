import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Grid,
  Paper,
  Stack,
  Typography,
} from "@mui/material";
import MapRoundedIcon from "@mui/icons-material/MapRounded";
import RoomRoundedIcon from "@mui/icons-material/RoomRounded";
import ShareLocationRoundedIcon from "@mui/icons-material/ShareLocationRounded";
import { Link } from "react-router-dom";
import Seo from "../../components/common/Seo";
import SectionHeader from "../../components/common/SectionHeader";
import LeadForm from "../../components/lead/LeadForm";
import { useLanguage } from "../../context/LanguageContext";
import { mapResources, nearbyIndustries } from "../../data/siteData";
import { resolveLocalizedValue } from "../../utils/localization";

export default function MapsPage() {
  const { locale, t } = useLanguage();

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Project Maps | Dholera Growth Evidence"
        description="DP maps, corridor references, location context, and Google map orientation designed to support clearer land-investment decisions."
        path="/maps"
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <SectionHeader
          eyebrow={{ en: t("maps_heading"), hi: "मैप्स और कनेक्टिविटी", gu: "મેપ્સ અને કનેક્ટિવિટી" }}
          title={{
            en: "Project maps that turn geography into investor confidence.",
            hi: "प्रोजेक्ट मैप्स जो भूगोल को निवेशक भरोसे में बदलते हैं।",
            gu: "પ્રોજેક્ટ મેપ્સ જે ભૂગોળને રોકાણકાર વિશ્વાસમાં બદલે છે.",
          }}
          description={{
            en: "Map layers, Google orientation, distance indicators, and nearby industrial references that help explain why a site visit is worth scheduling.",
            hi: "मैप लेयर्स, गूगल ओरिएंटेशन, दूरी संकेत और औद्योगिक संदर्भ जो बताते हैं कि साइट विजिट क्यों करनी चाहिए।",
            gu: "મેપ લેયર્સ, ગૂગલ ઓરિએન્ટેશન, અંતર સંકેતો અને ઔદ્યોગિક સંદર્ભો જે સમજાવે છે કે સાઇટ વિઝિટ કેમ યોગ્ય છે.",
          }}
        />

        <Grid container spacing={3} sx={{ mt: 1 }}>
          {mapResources.map((resource) => (
            <Grid item xs={12} md={4} key={resource.title.en}>
              <Card sx={{ height: "100%" }}>
                <CardContent>
                  <Stack direction="row" spacing={1.5} alignItems="center">
                    <MapRoundedIcon color="secondary" />
                    <Typography variant="h6">{resolveLocalizedValue(locale, resource.title)}</Typography>
                  </Stack>
                  <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                    {resolveLocalizedValue(locale, resource.description)}
                  </Typography>
                  <Typography sx={{ mt: 2, fontWeight: 700 }}>{resource.distance}</Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        <Grid container spacing={3} sx={{ mt: 1 }}>
          <Grid item xs={12} lg={8}>
            <Paper className="admin-surface" sx={{ p: 1.5 }}>
              <Box
                component="iframe"
                title="Project map embed"
                src="https://www.google.com/maps?q=Dholera%20Special%20Investment%20Region&output=embed"
                sx={{ width: "100%", height: { xs: 320, md: 520 }, borderRadius: 3 }}
              />
            </Paper>
          </Grid>
          <Grid item xs={12} lg={4}>
            <Card sx={{ height: "100%", bgcolor: "primary.dark", color: "#fff" }}>
              <CardContent sx={{ p: 3.5 }}>
                <Stack direction="row" spacing={1.5} alignItems="center">
                  <ShareLocationRoundedIcon color="secondary" />
                  <Typography variant="h5">Nearby references and access cues</Typography>
                </Stack>
                <Stack spacing={1.8} sx={{ mt: 3 }}>
                  {nearbyIndustries.map((item) => (
                    <Paper key={item.name} sx={{ p: 2, bgcolor: "rgba(255,255,255,0.08)", color: "#fff" }}>
                      <Typography fontWeight={700}>{item.name}</Typography>
                      <Typography sx={{ mt: 0.4, color: "rgba(255,255,255,0.72)" }}>{item.distance}</Typography>
                    </Paper>
                  ))}
                </Stack>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Grid container spacing={3} sx={{ mt: 2 }}>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Stack direction="row" spacing={1.5} alignItems="center">
                  <RoomRoundedIcon color="primary" />
                  <Typography variant="h6">Map-request workflow</Typography>
                </Stack>
                <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                  Request the map pack from this page to receive the route context, corridor references, and planning cues your inquiry needs.
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Typography variant="h6">Suggested use during calls</Typography>
                <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                  Open the map page during investor calls, explain corridor adjacency, then move straight to site-visit or price-sheet conversion without breaking context.
                </Typography>
                <Button component={Link} to="/contact?intent=map-pack" sx={{ mt: 2 }}>
                  {t("cta_map_request")}
                </Button>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Box sx={{ mt: 6 }}>
          <LeadForm
            title="Request a detailed map pack"
            subtitle="Collect serious inquiries directly from the maps page so the conversation can continue in WhatsApp or a scheduled site visit."
            source="maps-page"
            ctaType="map-request"
            buttonLabel={t("cta_map_request")}
          />
        </Box>
      </Container>
    </Box>
  );
}

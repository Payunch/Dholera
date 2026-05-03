import {
  Box,
  Card,
  CardContent,
  Container,
  Grid,
  Stack,
  Typography,
} from "@mui/material";
import TimelineRoundedIcon from "@mui/icons-material/TimelineRounded";
import Seo from "../components/Seo";
import SectionHeader from "../components/SectionHeader";
import LeadForm from "../components/LeadForm";
import { useLanguage } from "../context/LanguageContext";
import { futureMilestones, growthDrivers } from "../content/siteData";
import { resolveLocalizedValue } from "../utils/localization";

export default function FutureGrowthPage() {
  const { locale, t } = useLanguage();

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Future Growth | Dholera Growth Evidence"
        description="A clear infrastructure-led narrative for why the area matters now, what momentum looks like next, and how the platform converts interest into action."
        path="/future-growth"
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <SectionHeader
          eyebrow={{ en: t("growth_heading"), hi: "यह क्षेत्र क्यों बढ़ रहा है", gu: "આ વિસ્તાર કેમ વિકસી રહ્યો છે" }}
          title={{
            en: "An infrastructure-led case for future land importance.",
            hi: "भविष्य की भूमि महत्ता के लिए इन्फ्रास्ट्रक्चर-आधारित तर्क।",
            gu: "ભવિષ્યની જમીન મહત્તા માટે ઇન્ફ્રાસ્ટ્રક્ચર આધારિત તર્ક.",
          }}
          description={{
            en: "The growth story is organized around movement, access, planning, and repeatable conversion. The goal is to make visitors feel they are watching an area become more central.",
            hi: "विकास कहानी को मूवमेंट, एक्सेस, प्लानिंग और कन्वर्ज़न के आधार पर व्यवस्थित किया गया है ताकि उपयोगकर्ता क्षेत्र को अधिक महत्वपूर्ण होता महसूस करें।",
            gu: "વૃદ્ધિ વાર્તા ગતિ, ઍક્સેસ, આયોજન અને કન્વર્ઝન આસપાસ ગોઠવાઈ છે જેથી મુલાકાતીને વિસ્તાર વધુ કેન્દ્રસ્થાન બનતો લાગે.",
          }}
        />

        <Grid container spacing={3} sx={{ mt: 1 }}>
          {futureMilestones.map((milestone) => (
            <Grid item xs={12} md={4} key={milestone.year}>
              <Card sx={{ height: "100%" }}>
                <CardContent>
                  <Typography variant="overline" sx={{ color: "secondary.main", fontWeight: 800, letterSpacing: "0.12em" }}>
                    {milestone.year}
                  </Typography>
                  <Typography variant="h5" sx={{ mt: 1 }}>
                    {resolveLocalizedValue(locale, milestone.title)}
                  </Typography>
                  <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                    {resolveLocalizedValue(locale, milestone.description)}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        <Grid container spacing={3} sx={{ mt: 1 }}>
          {growthDrivers.map((driver) => (
            <Grid item xs={12} md={6} key={driver.title.en}>
              <Card sx={{ height: "100%" }}>
                <CardContent>
                  <Stack direction="row" spacing={1.5} alignItems="center">
                    <TimelineRoundedIcon color="primary" />
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

        <Box sx={{ mt: 6 }}>
          <LeadForm
            title="Turn growth signals into an investor plan"
            subtitle="If the growth narrative aligns with your holding strategy, request a consultation, current pricing support, or a corridor-specific site visit."
            source="future-growth"
            ctaType="consultation"
            buttonLabel={t("cta_consultation")}
          />
        </Box>
      </Container>
    </Box>
  );
}


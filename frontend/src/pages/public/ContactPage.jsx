import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Grid,
  Stack,
  Typography,
} from "@mui/material";
import CallRoundedIcon from "@mui/icons-material/CallRounded";
import EventAvailableRoundedIcon from "@mui/icons-material/EventAvailableRounded";
import WhatsAppIcon from "@mui/icons-material/WhatsApp";
import EmailIcon from "@mui/icons-material/Email";
import FacebookIcon from "@mui/icons-material/Facebook";
import TwitterIcon from "@mui/icons-material/Twitter";
import InstagramIcon from "@mui/icons-material/Instagram";
import { Link, useLocation } from "react-router-dom";
import Seo from "../../components/common/Seo";
import SectionHeader from "../../components/common/SectionHeader";
import LeadForm from "../../components/lead/LeadForm";
import { useLanguage } from "../../context/LanguageContext";
import { buildWhatsAppUrl } from "../../utils/analytics";

export default function ContactPage() {
  const { t } = useLanguage();
  const location = useLocation();
  const intent = new URLSearchParams(location.search).get("intent") || "";

  const defaultMessageByIntent = {
    "site-visit": "I would like to schedule a site visit and understand current availability.",
    "map-pack": "Please send the latest map pack and corridor reference set.",
    "project-brief": "Please share the project brief and current investment overview.",
  };

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Contact and Lead Capture | Dholera Growth Evidence"
        description="Request a site visit, map pack, project brief, price sheet, or consultation. Every inquiry flows into the lead management dashboard."
        path="/contact"
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <SectionHeader
          eyebrow={{ en: "CONNECT", hi: "जुड़ें", gu: "જોડાવો" }}
          title={{
            en: "Let's discuss your next move.",
            hi: "अपने अगले कदम पर चर्चा करें।",
            gu: "તમારાં આગલા પગલું પર ચર્ચા કરીએ.",
          }}
        />

        <Grid container spacing={3} sx={{ mt: 2 }}>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Stack direction="row" spacing={1.5} alignItems="center">
                  <WhatsAppIcon color="success" sx={{ fontSize: 32 }} />
                  <Typography variant="h6" sx={{ fontWeight: 700 }}>Quick Chat</Typography>
                </Stack>
                <Typography sx={{ mt: 2, color: "text.secondary", fontSize: "0.95rem" }}>
                  Immediate questions? Start a WhatsApp conversation.
                </Typography>
                <Button
                  component="a"
                  href={buildWhatsAppUrl("Hi, I want to learn more about land options.")} 
                  target="_blank"
                  rel="noreferrer"
                  variant="contained"
                  sx={{ mt: 2 }}
                >
                  Open WhatsApp
                </Button>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Stack direction="row" spacing={1.5} alignItems="center">
                  <EventAvailableRoundedIcon sx={{ fontSize: 32, color: "primary.main" }} />
                  <Typography variant="h6" sx={{ fontWeight: 700 }}>Site Visit</Typography>
                </Stack>
                <Typography sx={{ mt: 2, color: "text.secondary", fontSize: "0.95rem" }}>
                  Schedule a ground visit to see progress firsthand.
                </Typography>
                <Button component={Link} to="#form" variant="contained" sx={{ mt: 2 }}>
                  Request Visit
                </Button>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Grid container spacing={3} sx={{ mt: 4 }}>
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Contact Information</Typography>
                <Stack spacing={2}>
                  <Box>
                    <Typography color="text.secondary" fontSize="0.9rem">Property Dealer</Typography>
                    <Typography variant="h6" sx={{ fontWeight: 700 }}>Gohel Naresh Bhai</Typography>
                  </Box>
                  <Stack spacing={1}>
                    <Stack direction="row" alignItems="center" spacing={1}>
                      <CallRoundedIcon sx={{ fontSize: 20, color: "primary.main" }} />
                      <Box>
                        <Typography color="text.secondary" fontSize="0.85rem">Mobile</Typography>
                        <Button
                          component="a"
                          href="tel:0909090909"
                          sx={{ textTransform: "none", p: 0, justifyContent: "flex-start", fontSize: "0.95rem", fontWeight: 600 }}
                        >
                          0909090909
                        </Button>
                      </Box>
                    </Stack>
                    <Stack direction="row" alignItems="center" spacing={1}>
                      <EmailIcon sx={{ fontSize: 20, color: "primary.main" }} />
                      <Box>
                        <Typography color="text.secondary" fontSize="0.85rem">Email</Typography>
                        <Button
                          component="a"
                          href="mailto:a@gmail.com"
                          sx={{ textTransform: "none", p: 0, justifyContent: "flex-start", fontSize: "0.95rem", fontWeight: 600 }}
                        >
                          a@gmail.com
                        </Button>
                      </Box>
                    </Stack>
                  </Stack>
                </Stack>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Follow us</Typography>
                <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                  <Button
                    component="a"
                    href="https://facebook.com"
                    target="_blank"
                    rel="noreferrer"
                    variant="contained"
                    size="small"
                    startIcon={<FacebookIcon />}
                    sx={{ backgroundColor: "#1877F2", "&:hover": { backgroundColor: "#0A66C2" } }}
                  >
                    Facebook
                  </Button>
                  <Button
                    component="a"
                    href="https://twitter.com"
                    target="_blank"
                    rel="noreferrer"
                    variant="contained"
                    size="small"
                    startIcon={<TwitterIcon />}
                    sx={{ backgroundColor: "#000", "&:hover": { backgroundColor: "#333" } }}
                  >
                    Twitter
                  </Button>
                  <Button
                    component="a"
                    href="https://instagram.com"
                    target="_blank"
                    rel="noreferrer"
                    variant="contained"
                    size="small"
                    startIcon={<InstagramIcon />}
                    sx={{ 
                      background: "linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%)",
                      "&:hover": { opacity: 0.85 }
                    }}
                  >
                    Instagram
                  </Button>
                </Stack>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Box sx={{ mt: 6 }}>
          <LeadForm
            title="Submit a qualified inquiry"
            subtitle="Choose the route that fits your buying stage and we will take it forward with the right documents, map context, or visit coordination."
            source="contact-page"
            ctaType={intent || "consultation"}
            buttonLabel={t("lead_submit")}
            showVisitDate={intent === "site-visit"}
            defaultMessage={defaultMessageByIntent[intent] || ""}
          />
        </Box>
      </Container>
    </Box>
  );
}

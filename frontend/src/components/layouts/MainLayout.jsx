import {
  AppBar,
  Box,
  Button,
  Container,
  Divider,
  Drawer,
  FormControl,
  IconButton,
  MenuItem,
  Select,
  Stack,
  Toolbar,
  Typography,
} from "@mui/material";
import MenuIcon from "@mui/icons-material/Menu";
import MapOutlinedIcon from "@mui/icons-material/MapOutlined";
import MessageOutlinedIcon from "@mui/icons-material/MessageOutlined";
import { useState } from "react";
import { NavLink, Outlet } from "react-router-dom";
import { useLanguage } from "../../context/LanguageContext";
import { buildWhatsAppUrl, trackEvent } from "../../utils/analytics";
import { footerHighlights } from "../../data/siteData";
import { resolveLocalizedValue } from "../../utils/localization";

const navItems = [
  { key: "nav_home", to: "/" },
  { key: "nav_feed", to: "/updates" },
  { key: "nav_maps", to: "/maps" },
  { key: "nav_contact", to: "/contact" },
];

export default function MainLayout() {
  const { locale, setLocale, t } = useLanguage();
  const [open, setOpen] = useState(false);

  const renderNavLink = (item) => (
    <Button
      key={item.to}
      component={NavLink}
      to={item.to}
      color="inherit"
      onClick={() => setOpen(false)}
      sx={{
        color: "text.secondary",
        "&.active": {
          color: "primary.main",
        },
      }}
    >
      {t(item.key)}
    </Button>
  );

  return (
    <Box>
      <AppBar
        position="sticky"
        color="transparent"
        elevation={0}
        sx={{ backdropFilter: "blur(16px)", borderBottom: "1px solid rgba(27, 74, 110, 0.08)" }}
      >
        <Toolbar sx={{ py: 1 }}>
          <Container
            maxWidth="xl"
            sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 2 }}
          >
            <Stack component={NavLink} to="/" spacing={0.2}>
              <Typography variant="caption" sx={{ color: "primary.main", fontWeight: 800, letterSpacing: "0.16em" }}>
                GROWTH EVIDENCE PLATFORM
              </Typography>
              <Typography variant="h6">{t("brand")}</Typography>
            </Stack>

            <Stack direction="row" alignItems="center" spacing={1.5} sx={{ display: { xs: "none", md: "flex" } }}>
              {navItems.map(renderNavLink)}
            </Stack>

            <Stack direction="row" alignItems="center" spacing={1}>
              <FormControl size="small" sx={{ minWidth: 110, display: { xs: "none", sm: "block" } }}>
                <Select
                  value={locale}
                  onChange={(event) => setLocale(event.target.value)}
                  sx={{ borderRadius: 999, bgcolor: "background.paper" }}
                >
                  <MenuItem value="en">English</MenuItem>
                  <MenuItem value="hi">हिन्दी</MenuItem>
                  <MenuItem value="gu">ગુજરાતી</MenuItem>
                </Select>
              </FormControl>

              <Button
                component="a"
                href={buildWhatsAppUrl("Hello, I want to discuss land opportunities and book a site visit.")}
                target="_blank"
                rel="noreferrer"
                variant="contained"
                startIcon={<MessageOutlinedIcon />}
                onClick={() => trackEvent("cta_whatsapp_header", { location: "header" })}
                sx={{ display: { xs: "none", sm: "inline-flex" } }}
              >
                {t("cta_whatsapp")}
              </Button>

              <IconButton
                onClick={() => setOpen(true)}
                sx={{ display: { xs: "inline-flex", md: "none" } }}
                aria-label="Open navigation"
              >
                <MenuIcon />
              </IconButton>
            </Stack>
          </Container>
        </Toolbar>
      </AppBar>

      <Drawer anchor="right" open={open} onClose={() => setOpen(false)}>
        <Box sx={{ width: 300, p: 3 }}>
          <Typography variant="h6">{t("brand")}</Typography>
          <Stack spacing={1.5} sx={{ mt: 3 }}>
            {navItems.map((item) => (
              <Button
                key={item.to}
                component={NavLink}
                to={item.to}
                onClick={() => setOpen(false)}
                sx={{ justifyContent: "flex-start" }}
              >
                {t(item.key)}
              </Button>
            ))}
            <Divider sx={{ my: 1 }} />
            <FormControl size="small">
              <Select value={locale} onChange={(event) => setLocale(event.target.value)}>
                <MenuItem value="en">English</MenuItem>
                <MenuItem value="hi">हिन्दी</MenuItem>
                <MenuItem value="gu">ગુજરાતી</MenuItem>
              </Select>
            </FormControl>
            <Button
              component="a"
              href={buildWhatsAppUrl("Hello, I want to discuss land opportunities and book a site visit.")}
              target="_blank"
              rel="noreferrer"
              variant="contained"
              startIcon={<MessageOutlinedIcon />}
            >
              {t("cta_whatsapp")}
            </Button>
            <Button component={NavLink} to="/maps" startIcon={<MapOutlinedIcon />}>
              {t("cta_map_request")}
            </Button>
          </Stack>
        </Box>
      </Drawer>

      <Box component="main">
        <Outlet />
      </Box>

      <Box sx={{ mt: 10, py: 6, borderTop: "1px solid rgba(27, 74, 110, 0.08)", bgcolor: "rgba(255,255,255,0.8)" }}>
        <Container maxWidth="xl">
          <Stack direction={{ xs: "column", md: "row" }} justifyContent="space-between" spacing={3}>
            <Box maxWidth={620}>
              <Typography variant="overline" sx={{ color: "primary.main", letterSpacing: "0.14em", fontWeight: 800 }}>
                TRUST TO INQUIRY TO SITE VISIT
              </Typography>
              <Typography variant="h3" sx={{ mt: 1, mb: 1.5 }}>
                A calm, evidence-led platform built to convert land interest into qualified conversations.
              </Typography>
              <Typography color="text.secondary">
                The experience is designed to make momentum visible quickly, then guide visitors into WhatsApp conversations, map requests, site visits, and investment consultations.
              </Typography>
            </Box>
            <Stack spacing={1.2} sx={{ minWidth: { md: 340 } }}>
              {footerHighlights.map((item) => (
                <Typography key={item} className="metric-pill">
                  {resolveLocalizedValue(locale, item)}
                </Typography>
              ))}
            </Stack>
          </Stack>
        </Container>
      </Box>
    </Box>
  );
}

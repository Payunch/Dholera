import { Box, Stack, Typography } from "@mui/material";
import { resolveLocalizedValue } from "../../utils/localization";
import { useLanguage } from "../../context/LanguageContext";

export default function SectionHeader({ eyebrow, title, description, action }) {
  const { locale } = useLanguage();

  return (
    <Stack
      direction={{ xs: "column", md: "row" }}
      justifyContent="space-between"
      alignItems={{ xs: "flex-start", md: "flex-end" }}
      spacing={2}
    >
      <Box maxWidth={720}>
        {eyebrow ? (
          <Typography
            variant="overline"
            sx={{ color: "primary.main", fontWeight: 800, letterSpacing: "0.14em" }}
          >
            {resolveLocalizedValue(locale, eyebrow)}
          </Typography>
        ) : null}
        <Typography variant="h2" sx={{ mt: 1, fontSize: { xs: "2rem", md: "2.8rem" } }}>
          {resolveLocalizedValue(locale, title)}
        </Typography>
        {description ? (
          <Typography sx={{ mt: 1.5, color: "text.secondary", maxWidth: 760 }}>
            {resolveLocalizedValue(locale, description)}
          </Typography>
        ) : null}
      </Box>
      {action}
    </Stack>
  );
}

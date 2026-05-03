import { useEffect, useState } from "react";
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Container,
  Grid,
  Stack,
  Typography,
} from "@mui/material";
import ArrowBackRoundedIcon from "@mui/icons-material/ArrowBackRounded";
import FileDownloadOutlinedIcon from "@mui/icons-material/FileDownloadOutlined";
import { Link, useParams } from "react-router-dom";
import Seo from "../../components/common/Seo";
import UpdateCard from "../../components/updates/UpdateCard";
import LeadForm from "../../components/lead/LeadForm";
import { api } from "../../api/api";
import { useLanguage } from "../../context/LanguageContext";
import { formatDate, getLocalizedField, resolveMediaUrl } from "../../utils/localization";

export default function UpdateDetailPage() {
  const { slug } = useParams();
  const { locale, t } = useLanguage();
  const [update, setUpdate] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    setLoading(true);
    api.public
      .getUpdateDetail(slug)
      .then((data) => {
        if (active) {
          setUpdate(data);
        }
      })
      .finally(() => {
        if (active) {
          setLoading(false);
        }
      });

    return () => {
      active = false;
    };
  }, [slug]);

  if (loading) {
    return (
      <Stack sx={{ py: 12, alignItems: "center" }}>
        <CircularProgress />
      </Stack>
    );
  }

  if (!update) {
    return (
      <Container maxWidth="lg" sx={{ py: 10 }}>
        <Typography variant="h4">Update not found.</Typography>
      </Container>
    );
  }

  const title = getLocalizedField(update, "title", locale);
  const description = getLocalizedField(update, "desc", locale);
  const imageUrl = resolveMediaUrl(update.image_url || update.thumbnail_url);
  const pdfUrl = resolveMediaUrl(update.pdf_url);

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title={`${title} | Dholera Growth Evidence`}
        description={description}
        path={`/updates/${update.slug}`}
        image={imageUrl || "/favicon.svg"}
        schema={{
          "@context": "https://schema.org",
          "@type": "Article",
          headline: title,
          description,
          datePublished: update.created_at,
          dateModified: update.updated_at,
          image: imageUrl || `${import.meta.env.VITE_SITE_URL || "https://example.com"}/favicon.svg`,
        }}
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <Button component={Link} to="/updates" startIcon={<ArrowBackRoundedIcon />}>
          {t("back_to_feed")}
        </Button>

        <Grid container spacing={4} sx={{ mt: 1 }}>
          <Grid item xs={12} lg={8}>
            <Stack spacing={3}>
              <Box
                sx={{
                  overflow: "hidden",
                  minHeight: 320,
                  borderRadius: 4,
                  background: imageUrl
                    ? `center / cover no-repeat url(${imageUrl})`
                    : "linear-gradient(135deg, rgba(27,74,110,0.95), rgba(17,41,60,0.95))",
                }}
              />

              <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5} alignItems={{ sm: "center" }}>
                <Chip label={update.category} color="primary" />
                {update.is_featured ? <Chip label={t("featured")} color="secondary" /> : null}
                <Typography color="text.secondary">{formatDate(update.created_at, locale)}</Typography>
              </Stack>

              <Typography variant="h1" sx={{ fontSize: { xs: "2.6rem", md: "3.7rem" } }}>
                {title}
              </Typography>
              <Typography sx={{ color: "text.secondary", whiteSpace: "pre-line", fontSize: "1.05rem" }}>
                {description}
              </Typography>

              {(update.video_url || update.embed_code) && (
                <Box sx={{ mt: 3, mb: 3 }}>
                  {update.embed_code ? (
                    <Box
                      dangerouslySetInnerHTML={{ __html: update.embed_code }}
                      sx={{
                        "& iframe": { width: "100%", minHeight: { xs: 240, md: 460 }, borderRadius: 3, border: "none" }
                      }}
                    />
                  ) : (
                    <Box
                      component="video"
                      controls
                      src={resolveMediaUrl(update.video_url)}
                      sx={{ width: "100%", borderRadius: 3, backgroundColor: "#000" }}
                    />
                  )}
                </Box>
              )}

              {update.tags?.length ? (
                <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                  {update.tags.map((tag) => (
                    <Chip key={tag} label={`#${tag}`} variant="outlined" />
                  ))}
                </Stack>
              ) : null}

              {pdfUrl ? (
                <Button component="a" href={pdfUrl} target="_blank" startIcon={<FileDownloadOutlinedIcon />}>
                  Download Brief
                </Button>
              ) : null}
            </Stack>
          </Grid>
          <Grid item xs={12} lg={4}>
            <Stack spacing={3}>
              <Card>
                <CardContent>
                  <Typography variant="h6">Next steps</Typography>
                  <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
                    Interested in this project activity? Start a WhatsApp conversation or schedule a site visit.
                  </Typography>
                  <Button component={Link} to="/contact" fullWidth variant="contained" sx={{ mt: 2 }}>
                    Get in touch
                  </Button>
                </CardContent>
              </Card>

              <Card>
                <CardContent>
                  <Typography variant="h6">Earlier activity</Typography>
                  <Typography sx={{ mt: 1.5, color: "text.secondary", fontSize: "0.9rem" }}>
                    Return to the growth tracker to browse infrastructure activity by category or keyword.
                  </Typography>
                  <Button component={Link} to="/updates" fullWidth variant="outlined" sx={{ mt: 2 }}>
                    View all updates
                  </Button>
                </CardContent>
              </Card>
            </Stack>
          </Grid>
        </Grid>

        <Box sx={{ mt: 8 }}>
          <LeadForm
            title="Capture this momentum"
            subtitle="Turn your interest in this infrastructure activity into a site visit and direct conversation flow."
            source="update-detail"
            ctaType="site-visit"
            buttonLabel={t("lead_submit")}
          />
        </Box>
      </Container>
    </Box>
  );
}

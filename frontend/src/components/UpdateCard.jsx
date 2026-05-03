import {
  Box,
  Button,
  Card,
  CardActions,
  CardContent,
  CardMedia,
  Chip,
  IconButton,
  Stack,
  Tooltip,
  Typography,
} from "@mui/material";
import EastOutlinedIcon from "@mui/icons-material/EastOutlined";
import ApartmentOutlinedIcon from "@mui/icons-material/ApartmentOutlined";
import MessageOutlinedIcon from "@mui/icons-material/MessageOutlined";
import MapOutlinedIcon from "@mui/icons-material/MapOutlined";
import PictureAsPdfOutlinedIcon from "@mui/icons-material/PictureAsPdfOutlined";
import PlayCircleOutlineIcon from "@mui/icons-material/PlayCircleOutline";
import { Link } from "react-router-dom";
import { useLanguage } from "../context/LanguageContext";
import { formatDate, getLocalizedField, resolveMediaUrl } from "../utils/localization";
import { buildWhatsAppUrl, trackEvent } from "../utils/analytics";

export default function UpdateCard({ update, featured = false }) {
  const { locale, t } = useLanguage();
  const title = getLocalizedField(update, "title", locale);
  const description = getLocalizedField(update, "desc", locale);
  const imageUrl = resolveMediaUrl(update.thumbnail_url || update.image_url);
  const pdfUrl = resolveMediaUrl(update.pdf_url);
  const hasVideo = !!(update.video_url || update.embed_code);

  const handleWhatsApp = (e) => {
    e.preventDefault();
    trackEvent("cta_whatsapp_update_card", { update_slug: update.slug });
    window.open(buildWhatsAppUrl(`Hi, I'm interested in this growth update: ${title}. Can you share more details?`), "_blank");
  };

  return (
    <Card sx={{ height: "100%", display: "flex", flexDirection: "column" }}>
      {imageUrl ? (
        <Box sx={{ position: "relative" }}>
          <CardMedia component="img" image={imageUrl} alt={title} sx={{ height: featured ? 320 : 220 }} />
          {hasVideo && (
            <Box
              sx={{
                position: "absolute",
                top: 0, left: 0, right: 0, bottom: 0,
                display: "flex", alignItems: "center", justifyContent: "center",
                bgcolor: "rgba(0,0,0,0.3)"
              }}
            >
              <PlayCircleOutlineIcon sx={{ fontSize: 64, color: "rgba(255,255,255,0.8)" }} />
            </Box>
          )}
        </Box>
      ) : (
        <Box
          sx={{
            position: "relative",
            height: featured ? 320 : 220,
            p: 3,
            display: "flex",
            alignItems: "flex-end",
            background:
              "linear-gradient(135deg, rgba(27,74,110,0.98), rgba(17,41,60,0.95)), radial-gradient(circle at top right, rgba(182,146,84,0.4), transparent 30%)",
            color: "#fff",
          }}
        >
          {hasVideo && (
             <Box
               sx={{
                 position: "absolute",
                 top: 0, left: 0, right: 0, bottom: 0,
                 display: "flex", alignItems: "center", justifyContent: "center",
                 bgcolor: "rgba(0,0,0,0.3)"
               }}
             >
               <PlayCircleOutlineIcon sx={{ fontSize: 64, color: "rgba(255,255,255,0.5)" }} />
             </Box>
          )}
          <Stack spacing={1.2} sx={{ position: "relative", zIndex: 1 }}>
            <ApartmentOutlinedIcon fontSize="large" />
            <Typography variant="h5">{title}</Typography>
          </Stack>
        </Box>
      )}

      <CardContent sx={{ flexGrow: 1 }}>
        <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ mb: 2 }}>
          <Chip label={update.category} color="primary" variant="outlined" size="small" />
          {update.is_featured ? <Chip label={t("featured")} color="secondary" size="small" /> : null}
        </Stack>
        <Typography variant="caption" color="text.secondary">
          {formatDate(update.created_at, locale)}
        </Typography>
        <Typography variant="h5" sx={{ mt: 1, fontWeight: 700 }}>
          {title}
        </Typography>
        <Typography sx={{ mt: 1.2, color: "text.secondary" }} className={featured ? "line-clamp-3" : "line-clamp-2"}>
          {description}
        </Typography>
      </CardContent>

      <CardActions sx={{ px: 2, pb: 2, justifyContent: "space-between" }}>
        <Button
          component={Link}
          to={`/updates/${update.slug}`}
          endIcon={<EastOutlinedIcon />}
          size="small"
        >
          {t("read_more")}
        </Button>

        <Stack direction="row" spacing={0.5}>
          <Tooltip title={t("cta_whatsapp")}>
            <IconButton size="small" color="primary" onClick={handleWhatsApp}>
              <MessageOutlinedIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title={t("cta_map_request")}>
            <IconButton size="small" component={Link} to="/project-maps">
              <MapOutlinedIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          {pdfUrl && (
            <Tooltip title={t("cta_brief")}>
              <IconButton size="small" component="a" href={pdfUrl} target="_blank">
                <PictureAsPdfOutlinedIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </Stack>
      </CardActions>
    </Card>
  );
}


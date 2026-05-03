import { useState } from "react";
import { useSearchParams } from "react-router-dom";
import {
  Alert,
  Box,
  Button,
  Grid,
  MenuItem,
  Paper,
  Stack,
  TextField,
  Typography,
} from "@mui/material";
import SendRoundedIcon from "@mui/icons-material/SendRounded";
import { api } from "../../api/api";
import { useLanguage } from "../../context/LanguageContext";
import { trackEvent } from "../../utils/analytics";

export default function LeadForm({
  title,
  subtitle,
  source = "general",
  ctaType = "consultation",
  buttonLabel,
  showVisitDate = false,
  defaultMessage = "",
}) {
  const { locale, t } = useLanguage();
  const [searchParams] = useSearchParams();
  const [form, setForm] = useState({
    name: "",
    phone: "",
    email: "",
    message: defaultMessage,
    preferredVisitDate: "",
  });
  const [feedback, setFeedback] = useState({ type: "", message: "" });
  const [submitting, setSubmitting] = useState(false);

  const onChange = (field) => (event) => {
    setForm((previous) => ({ ...previous, [field]: event.target.value }));
  };

  const onSubmit = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    setFeedback({ type: "", message: "" });

    const composedMessage = [
      form.message,
      showVisitDate && form.preferredVisitDate
        ? `Preferred site visit date: ${form.preferredVisitDate}`
        : "",
    ]
      .filter(Boolean)
      .join("\n");

    try {
      await api.public.submitLead({
        name: form.name,
        phone: form.phone,
        email: form.email || undefined,
        message: composedMessage || undefined,
        source,
        cta_type: ctaType,
        preferred_language: locale,
        utm_source: searchParams.get("utm_source"),
        utm_medium: searchParams.get("utm_medium"),
        utm_campaign: searchParams.get("utm_campaign"),
      });
      trackEvent("lead_submit", { source, ctaType, locale });
      setFeedback({ type: "success", message: t("lead_success") });
      setForm({
        name: "",
        phone: "",
        email: "",
        message: defaultMessage,
        preferredVisitDate: "",
      });
    } catch (error) {
      setFeedback({
        type: "error",
        message: error.response?.data?.detail || t("lead_error"),
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Paper className="admin-surface" sx={{ p: { xs: 2.5, md: 3.5 } }}>
      <Typography variant="h4">{title}</Typography>
      <Box component="form" onSubmit={onSubmit} sx={{ mt: 3 }}>
        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label={t("lead_name")}
              value={form.name}
              onChange={onChange("name")}
              required
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label={t("lead_phone")}
              value={form.phone}
              onChange={onChange("phone")}
              required
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              minRows={3}
              multiline
              label={t("lead_message")}
              value={form.message}
              onChange={onChange("message")}
            />
          </Grid>
        </Grid>
        <Button type="submit" variant="contained" size="large" endIcon={<SendRoundedIcon />} disabled={submitting} sx={{ mt: 3 }}>
          {buttonLabel || t("lead_submit")}
        </Button>
        {feedback.message ? (
          <Alert severity={feedback.type === "success" ? "success" : "error"} sx={{ mt: 2 }}>
            {feedback.message}
          </Alert>
        ) : null}
      </Box>
    </Paper>
  );
}

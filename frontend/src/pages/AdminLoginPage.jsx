import { useState } from "react";
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Stack,
  TextField,
  Typography,
} from "@mui/material";
import LoginRoundedIcon from "@mui/icons-material/LoginRounded";
import { Navigate, useNavigate } from "react-router-dom";
import Seo from "../components/Seo";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";

export default function AdminLoginPage() {
  const { login, user } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: "", password: "" });
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  if (user) {
    return <Navigate to="/admin/dashboard" replace />;
  }

  const onSubmit = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    setError("");
    try {
      await login(form);
      navigate("/admin/dashboard", { replace: true });
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Login failed.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Box sx={{ minHeight: "100vh", display: "grid", placeItems: "center", py: 6 }}>
      <Seo title="Admin Login | Dholera Growth Evidence" description="Admin authentication for the land-investment platform dashboard." path="/admin/login" />
      <Container maxWidth="sm">
        <Card>
          <CardContent sx={{ p: { xs: 3, md: 4 } }}>
            <Typography variant="overline" sx={{ color: "primary.main", fontWeight: 800, letterSpacing: "0.12em" }}>
              CONTENT OPERATIONS
            </Typography>
            <Typography variant="h3" sx={{ mt: 1 }}>
              {t("admin_login")}
            </Typography>
            <Typography sx={{ mt: 1.5, color: "text.secondary" }}>
              Secure access for update publishing, multilingual content management, media uploads, and lead operations.
            </Typography>
            <Box component="form" onSubmit={onSubmit} sx={{ mt: 3 }}>
              <Stack spacing={2}>
                <TextField
                  label="Email"
                  type="email"
                  value={form.email}
                  onChange={(event) => setForm((previous) => ({ ...previous, email: event.target.value }))}
                  required
                />
                <TextField
                  label="Password"
                  type="password"
                  value={form.password}
                  onChange={(event) => setForm((previous) => ({ ...previous, password: event.target.value }))}
                  required
                />
                <Button type="submit" variant="contained" size="large" startIcon={<LoginRoundedIcon />} disabled={submitting}>
                  Sign in
                </Button>
                {error ? <Alert severity="error">{error}</Alert> : null}
              </Stack>
            </Box>
          </CardContent>
        </Card>
      </Container>
    </Box>
  );
}


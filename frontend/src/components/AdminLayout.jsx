import {
  AppBar,
  Box,
  Button,
  Container,
  Stack,
  Toolbar,
  Typography,
} from "@mui/material";
import DashboardRoundedIcon from "@mui/icons-material/DashboardRounded";
import FeedRoundedIcon from "@mui/icons-material/FeedRounded";
import GroupRoundedIcon from "@mui/icons-material/GroupRounded";
import LogoutRoundedIcon from "@mui/icons-material/LogoutRounded";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";

export default function AdminLayout() {
  const { user, logout } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/admin/login", { replace: true });
  };

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: "#f2f0ea" }}>
      <AppBar position="sticky" color="inherit" elevation={0} sx={{ borderBottom: "1px solid rgba(27, 74, 110, 0.08)" }}>
        <Toolbar>
          <Container
            maxWidth="xl"
            sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 2 }}
          >
            <Stack>
              <Typography variant="caption" sx={{ color: "primary.main", fontWeight: 800, letterSpacing: "0.14em" }}>
                ADMIN OPERATIONS
              </Typography>
              <Typography variant="h6">{user?.name || "Admin"}</Typography>
            </Stack>
            <Stack direction="row" spacing={1} flexWrap="wrap">
              <Button component={NavLink} to="/admin/dashboard" startIcon={<DashboardRoundedIcon />}>
                {t("admin_dashboard")}
              </Button>
              <Button component={NavLink} to="/admin/updates" startIcon={<FeedRoundedIcon />}>
                {t("admin_updates")}
              </Button>
              <Button component={NavLink} to="/admin/leads" startIcon={<GroupRoundedIcon />}>
                {t("admin_leads")}
              </Button>
              <Button color="inherit" startIcon={<LogoutRoundedIcon />} onClick={handleLogout}>
                {t("admin_logout")}
              </Button>
            </Stack>
          </Container>
        </Toolbar>
      </AppBar>
      <Container maxWidth="xl" sx={{ py: 4 }}>
        <Outlet />
      </Container>
    </Box>
  );
}


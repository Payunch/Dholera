import { CssBaseline, CircularProgress, Box } from "@mui/material";
import { ThemeProvider } from "@mui/material/styles";
import { HelmetProvider } from "react-helmet-async";
import { BrowserRouter, Navigate, Route, Routes, useLocation } from "react-router-dom";
import { Suspense, lazy, useEffect } from "react";
import theme from "./theme";
import { LanguageProvider } from "./context/LanguageContext";
import { AuthProvider, useAuth } from "./context/AuthContext";
import MainLayout from "./components/layouts/MainLayout";
import ProtectedRoute from "./components/common/ProtectedRoute";
import AdminLayout from "./components/layouts/AdminLayout";
import StickyWhatsAppButton from "./components/lead/StickyWhatsAppButton";
import { trackPageView } from "./utils/analytics";

const HomePage = lazy(() => import("./pages/public/HomePage"));
const UpdatesPage = lazy(() => import("./pages/public/UpdatesPage"));
const UpdateDetailPage = lazy(() => import("./pages/public/UpdateDetailPage"));
const MapsPage = lazy(() => import("./pages/public/MapsPage"));
const ContactPage = lazy(() => import("./pages/public/ContactPage"));
const LoginPage = lazy(() => import("./pages/admin/LoginPage"));
const DashboardPage = lazy(() => import("./pages/admin/DashboardPage"));
const UpdatesManagePage = lazy(() => import("./pages/admin/UpdatesManagePage"));
const LeadsPage = lazy(() => import("./pages/admin/LeadsPage"));
const NotFoundPage = lazy(() => import("./pages/NotFoundPage"));

function ScrollToTopAndTrack() {
  const location = useLocation();

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "smooth" });
    trackPageView(location.pathname);
  }, [location.pathname]);

  return null;
}

function AdminRootRedirect() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <Box sx={{ display: "grid", minHeight: "100vh", placeItems: "center" }}>
        <CircularProgress />
      </Box>
    );
  }

  return user ? <Navigate to="/admin/dashboard" replace /> : <Navigate to="/admin/login" replace />;
}

function AppFallback() {
  return (
    <Box sx={{ display: "grid", minHeight: "50vh", placeItems: "center" }}>
      <CircularProgress />
    </Box>
  );
}

export default function App() {
  return (
    <HelmetProvider>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <LanguageProvider>
          <AuthProvider>
            <BrowserRouter>
              <ScrollToTopAndTrack />
              <StickyWhatsAppButton />
              <Suspense fallback={<AppFallback />}>
                <Routes>
                  <Route element={<MainLayout />}>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/updates" element={<UpdatesPage />} />
                    <Route path="/updates/:slug" element={<UpdateDetailPage />} />
                    <Route path="/maps" element={<MapsPage />} />
                    <Route path="/contact" element={<ContactPage />} />
                  </Route>

                  <Route path="/admin" element={<AdminRootRedirect />} />
                  <Route path="/admin/login" element={<LoginPage />} />
                  <Route
                    path="/admin"
                    element={
                      <ProtectedRoute>
                        <AdminLayout />
                      </ProtectedRoute>
                    }
                  >
                    <Route path="dashboard" element={<DashboardPage />} />
                    <Route path="updates" element={<UpdatesManagePage />} />
                    <Route path="leads" element={<LeadsPage />} />
                  </Route>

                  <Route path="*" element={<NotFoundPage />} />
                </Routes>
              </Suspense>
            </BrowserRouter>
          </AuthProvider>
        </LanguageProvider>
      </ThemeProvider>
    </HelmetProvider>
  );
}

import React from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import Layout from './components/Layout';
import Home from './pages/Home';
import Updates from './pages/Updates';
import Planning from './pages/Planning';
import Investment from './pages/Investment';
import Contact from './pages/Contact';
import PrivacyPolicy from './pages/PrivacyPolicy';
import TermsAndConditions from './pages/TermsAndConditions';
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminLayout from './pages/admin/AdminLayout';
import AdminLeads from './pages/admin/AdminLeads';
import AdminUpdates from './pages/admin/AdminUpdates';
import AdminLogin from './pages/admin/AdminLogin';

import ScrollToTop from './components/ScrollToTop';
import { useVisitorTracking } from './hooks/useVisitorTracking';
import LeadPopup from './components/LeadPopup';
import { LeadProvider } from './context/LeadContext';
import { API_BASE_URL } from './utils/apiBase';

import { useEffect, useState } from 'react';

const ProtectedAdmin = ({ children }) => {
  const [loading, setLoading] = useState(true);
  const [ok, setOk] = useState(false);
  
  useEffect(() => {
    let mounted = true;
    fetch(`${API_BASE_URL}/auth/me`, { credentials: 'include' })
      .then(res => {
        if (!mounted) return;
        if (res.ok) setOk(true);
        else setOk(false);
      })
      .catch(() => setOk(false))
      .finally(() => mounted && setLoading(false));
    return () => { mounted = false; };
  }, []);

  if (loading) return null;
  if (!ok) return <Navigate to="/admin/login" replace />;
  return children;
};

function AppContent() {
  const { sessionId, fingerprint } = useVisitorTracking();
  const location = useLocation();
  const isAdminPath = location.pathname.startsWith('/admin');

  return (
    <LeadProvider>
      <ScrollToTop />
      {!isAdminPath && <LeadPopup sessionId={sessionId} fingerprint={fingerprint} />}
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="updates" element={<Updates />} />
          <Route path="planning" element={<Planning />} />
          <Route path="investment" element={<Investment />} />
          <Route path="contact" element={<Contact />} />
          <Route path="privacy-policy" element={<PrivacyPolicy />} />
          <Route path="terms-and-conditions" element={<TermsAndConditions />} />
        </Route>
        <Route path="/admin/login" element={<AdminLogin />} />
        <Route path="/admin" element={<ProtectedAdmin><AdminLayout /></ProtectedAdmin>}>
          <Route index element={<AdminDashboard />} />
          <Route path="leads" element={<AdminLeads />} />
          <Route path="updates" element={<AdminUpdates />} />
        </Route>
      </Routes>
    </LeadProvider>
  );
}

function App() {
  return <AppContent />;
}

export default App;

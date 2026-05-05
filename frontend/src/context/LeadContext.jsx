import React, { createContext, useContext, useState, useEffect } from 'react';
import { API_BASE_URL } from '../utils/apiBase';

const LeadContext = createContext();

export const LeadProvider = ({ children }) => {
  const [verifiedLead, setVerifiedLead] = useState(null);
  // Start with loading=true so nothing renders until the DB verification is done.
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const verifySession = async () => {
      const token = localStorage.getItem('lead_token');

      if (!token) {
        // No token stored — no need to hit the backend.
        if (!cancelled) setLoading(false);
        return;
      }

      try {
        const response = await fetch(`${API_BASE_URL}/leads/verify-token`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });

        if (cancelled) return;

        if (response.ok) {
          const data = await response.json();
          // Merge fresh DB data with local token
          setVerifiedLead({ ...data.lead, token });
        } else {
          // 401 / 404 → lead was deleted from the DB or token expired
          logoutLead();
        }
      } catch (err) {
        if (cancelled) return;
        console.error('Failed to verify lead session:', err);
        // Network error — keep the local session so the user isn't kicked on
        // every transient failure, but DO NOT grant access to gated content.
        // Components that guard content should check `verifiedLead` AND
        // whether the backend is reachable independently.
        const name  = localStorage.getItem('lead_name');
        const phone = localStorage.getItem('lead_phone');
        setVerifiedLead({ name, phone, token, _offline: true });
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    verifySession();

    return () => { cancelled = true; };
  }, []);

  const loginLead = (leadData) => {
    setVerifiedLead(leadData);
  };

  const logoutLead = () => {
    localStorage.removeItem('lead_token');
    localStorage.removeItem('lead_name');
    localStorage.removeItem('lead_phone');
    localStorage.removeItem('lead_email');
    setVerifiedLead(null);
  };

  return (
    <LeadContext.Provider value={{ verifiedLead, loginLead, logoutLead, loading }}>
      {children}
    </LeadContext.Provider>
  );
};

export const useLead = () => useContext(LeadContext);

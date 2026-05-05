import { useEffect, useRef } from 'react';
import { useLocation } from 'react-router-dom';
import { API_BASE_URL } from '../utils/apiBase';

const generateSessionId = () => {
  return '_' + Math.random().toString(36).substr(2, 9) + Date.now().toString(36);
};

const getBrowserFingerprint = () => {
  const { userAgent, language, hardwareConcurrency, deviceMemory } = navigator;
  const { width, height, colorDepth } = window.screen;
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  ctx.textBaseline = "top";
  ctx.font = "14px 'Arial'";
  ctx.fillText("dholera-smart-city-v1", 2, 2);
  const canvasData = canvas.toDataURL();
  
  const str = `${userAgent}|${language}|${hardwareConcurrency}|${deviceMemory}|${width}x${height}x${colorDepth}|${canvasData}`;
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return 'fp_' + Math.abs(hash).toString(36);
};

export const useVisitorTracking = () => {
  const location = useLocation();
  const isAdminPath = location.pathname.startsWith('/admin');
  const sessionRef = useRef(sessionStorage.getItem('visitorSessionId'));
  const fingerprintRef = useRef(localStorage.getItem('visitorFingerprint'));
  
  useEffect(() => {
    // Skip tracking on admin pages
    if (isAdminPath) {
      return;
    }

    if (!sessionRef.current) {
      sessionRef.current = generateSessionId();
      sessionStorage.setItem('visitorSessionId', sessionRef.current);
    }

    if (!fingerprintRef.current) {
      fingerprintRef.current = getBrowserFingerprint();
      localStorage.setItem('visitorFingerprint', fingerprintRef.current);
    }

    // Check if this fingerprint is already a verified lead
    const checkReturning = async () => {
      const existingToken = localStorage.getItem('lead_token');
      if (!existingToken) {
        try {
          const res = await fetch(`${API_BASE_URL}/leads/check-visitor/${fingerprintRef.current}`);
          const data = await res.json();
          if (data.verified && data.lead_token) {
            localStorage.setItem('lead_token', data.lead_token);
            localStorage.setItem('lead_email', data.lead.email);
            localStorage.setItem('lead_phone', data.lead.phone);
            localStorage.setItem('lead_name', data.lead.name);
          }
        } catch (err) {
          console.error('Check visitor error:', err);
        }
      }
    };

    checkReturning();

    const interval = setInterval(() => {
      const token = localStorage.getItem('lead_token');
      
      if (token) {
        // Authenticated Tracking
        fetch(`${API_BASE_URL}/leads/track-returning`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token
          },
          body: JSON.stringify({
            page: location.pathname,
            timeSpent: 5
          })
        }).then(async res => {
          if (res.status === 404 || res.status === 401 || res.status === 403) {
            localStorage.removeItem('lead_token');
            localStorage.removeItem('lead_email');
            localStorage.removeItem('lead_phone');
            localStorage.removeItem('lead_name');
            return null;
          }
          return res.json();
        }).then(data => {
          if (data && data.lead) {
            localStorage.setItem('lead_email', data.lead.email);
            localStorage.setItem('lead_phone', data.lead.phone);
          }
        }).catch(err => console.error('Tracking error:', err));
      } else {
        // Anonymous Tracking
        fetch(`${API_BASE_URL}/track`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            sessionId: sessionRef.current,
            browserFingerprint: fingerprintRef.current,
            page: location.pathname,
            timeSpent: 5,
            source: document.referrer || 'Direct',
            deviceType: /Mobi|Android/i.test(navigator.userAgent) ? 'Mobile' : 'Desktop'
          })
        }).catch(err => console.error('Tracking error:', err));
      }
    }, 5000);

    return () => clearInterval(interval);
  }, [location.pathname]);

  return { sessionId: sessionRef.current, fingerprint: fingerprintRef.current };
};

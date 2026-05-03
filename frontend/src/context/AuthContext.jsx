import { createContext, useContext, useEffect, useState } from "react";
import { adminApi } from "../api/adminApi";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => window.localStorage.getItem("admin_token"));
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(Boolean(token));

  const logout = () => {
    window.localStorage.removeItem("admin_token");
    setToken(null);
    setUser(null);
    setLoading(false);
  };

  useEffect(() => {
    if (!token) {
      setLoading(false);
      return undefined;
    }

    let active = true;
    setLoading(true);
    adminApi
      .me()
      .then((profile) => {
        if (active) {
          setUser(profile);
          setLoading(false);
        }
      })
      .catch(() => {
        if (active) {
          logout();
        }
      });

    return () => {
      active = false;
    };
  }, [token]);

  const login = async (payload) => {
    const data = await adminApi.login(payload);
    window.localStorage.setItem("admin_token", data.access_token);
    setToken(data.access_token);
    setUser(data.user);
    setLoading(false);
    return data;
  };

  const value = {
    token,
    user,
    loading,
    login,
    logout,
    isAuthenticated: Boolean(user),
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}

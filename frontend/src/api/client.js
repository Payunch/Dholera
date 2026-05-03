import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://127.0.0.1:8000/api/v1";

const client = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
});

client.interceptors.request.use((config) => {
  const token = window.localStorage.getItem("admin_token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const apiBaseUrl = API_BASE_URL;
export const apiOrigin = API_BASE_URL.replace(/\/api\/v1\/?$/, "");

export default client;


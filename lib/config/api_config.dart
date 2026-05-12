// API Configuration for Dholera Admin API
// 
// Update this based on your deployment environment:
// - Development: https://your-api-server.com/api
// - Production: https://your-api-server.com/api

class ApiConfig {
  // Production Railway Backend URL
  static const String apiBaseUrl = 'https://dholera-backend-production.up.railway.app/api';
  //  static const String apiBaseUrl = 'http://192.168.31.212:3000/api'; 

  // API Endpoints
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String logoutEndpoint = '$apiBaseUrl/auth/logout';
  static const String meEndpoint = '$apiBaseUrl/auth/me';
  static const String csrfTokenEndpoint = '$apiBaseUrl/auth/csrf-token';
  
  // Leads endpoints
  static const String leadsEndpoint = '$apiBaseUrl/leads';
  static const String leadDetailEndpoint = '$apiBaseUrl/leads';
  
  // Updates endpoints
  static const String updatesEndpoint = '$apiBaseUrl/updates';
  
  // Analytics endpoints
  static const String analyticsEndpoint = '$apiBaseUrl/analytics';
}

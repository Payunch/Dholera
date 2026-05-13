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
  
  // New User Auth flow
  static const String registerRequestEndpoint = '$apiBaseUrl/leads/register-request';
  static const String verifyRegistrationOtpEndpoint = '$apiBaseUrl/leads/verify-registration-otp';
  static const String setupPasscodeEndpoint = '$apiBaseUrl/leads/setup-passcode';
  static const String loginWithPasscodeEndpoint = '$apiBaseUrl/leads/login-with-passcode';
  
  // Updates endpoints
  static const String updatesEndpoint = '$apiBaseUrl/updates';
  
  // Analytics endpoints
  static const String analyticsEndpoint = '$apiBaseUrl/analytics';
  static const String detailedAnalyticsEndpoint = '$apiBaseUrl/analytics/detailed';

  // PDF endpoints
  static const String pdfsEndpoint = '$apiBaseUrl/pdfs';
  
  // Settings endpoints
  static const String settingsEndpoint = '$apiBaseUrl/settings';
}

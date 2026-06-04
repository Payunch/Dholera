// API Configuration for Dholera Admin API
// 
// Update this based on your deployment environment:
// - Development: https://your-api-server.com/api
// - Production: https://your-api-server.com/api

class ApiConfig {
  // --- CONFIGURATION ---
  // Set this to true to use your local machine's IP (for mobile testing)
  // Set to false to use the production URL
  static const bool useLocalBackend = false;
  
  // Replace with your computer's local IP address (e.g., 192.168.1.5)
  // You can find this by running 'ipconfig' in your terminal
  static const String localIp = '192.168.31.212'; 

  // Your production backend URL (Railway or Render)
  static const String productionUrl = 'https://api.dholeraplatform.com/api';

  static String get apiBaseUrl => useLocalBackend 
      ? 'http://$localIp:3001/api' 
      : productionUrl;
  // ---------------------

  // API Endpoints
  static String get loginEndpoint => '$apiBaseUrl/auth/login';
  static String get logoutEndpoint => '$apiBaseUrl/auth/logout';
  static String get meEndpoint => '$apiBaseUrl/auth/me';
  static String get csrfTokenEndpoint => '$apiBaseUrl/auth/csrf-token';
  static String get sessionsEndpoint => '$apiBaseUrl/auth/sessions';
  
  // Leads endpoints
  static String get leadsEndpoint => '$apiBaseUrl/leads';
  static String get leadDetailEndpoint => '$apiBaseUrl/leads';
  static String get importLeadsEndpoint => '$apiBaseUrl/leads/import';
  static String get markAsReadEndpoint => '$apiBaseUrl/leads'; // + /:id/read
  
  // Export/Backup endpoints
  static String get exportLeadsEndpoint => '$apiBaseUrl/leads/export';
  static String get exportSessionsEndpoint => '$apiBaseUrl/analytics/export/sessions';
  static String get exportUpdatesEndpoint => '$apiBaseUrl/analytics/export/updates';
  static String get exportPdfsEndpoint => '$apiBaseUrl/analytics/export/pdfs';
  static String get systemBackupEndpoint => '$apiBaseUrl/leads/system/backup';
  static String get systemRestoreEndpoint => '$apiBaseUrl/leads/system/restore';
  
  // New User Auth flow
  static String get registerRequestEndpoint => '$apiBaseUrl/leads/register-request';
  static String get verifyRegistrationOtpEndpoint => '$apiBaseUrl/leads/verify-registration-otp';
  static String get setupPasscodeEndpoint => '$apiBaseUrl/leads/setup-passcode';
  static String get loginWithPasscodeEndpoint => '$apiBaseUrl/leads/login-with-passcode';
  
  // Updates endpoints
  static String get updatesEndpoint => '$apiBaseUrl/updates';
  
  // Analytics endpoints
  static String get analyticsEndpoint => '$apiBaseUrl/analytics';
  static String get detailedAnalyticsEndpoint => '$apiBaseUrl/analytics/detailed';

  // PDF endpoints
  static String get pdfsEndpoint => '$apiBaseUrl/pdfs';
  
  // Settings endpoints
  static String get settingsEndpoint => '$apiBaseUrl/settings';

  // Preferences endpoints
  static String get preferencesEndpoint => '$apiBaseUrl/preferences';
  static String get translationsEndpoint => '$apiBaseUrl/preferences/translations';
}

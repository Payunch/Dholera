import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../analytics.dart' as analytics;

/// Auth provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final BiometricService _biometricService = BiometricService();
  final _secureStorage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;
  bool _isLoading = true; // Start with loading true
  bool _canUseBiometrics = false;
  bool _hasSavedCredentials = false;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get canUseBiometrics => _canUseBiometrics;
  bool get hasSavedCredentials => _hasSavedCredentials;
  
  /// Initialize auth state (check if token exists and is valid)
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    
    // Check biometric availability
    _canUseBiometrics = await _biometricService.isBiometricAvailable();
    
    // Check if we have saved email/pass for auto-login
    final savedEmail = await _secureStorage.read(key: 'saved_email');
    final savedPass = await _secureStorage.read(key: 'saved_passcode');
    _hasSavedCredentials = savedEmail != null && savedPass != null;

    final token = await _apiService.getAuthToken();
    if (token != null) {
      try {
        final result = await _apiService.getMe();
        if (result['success'] == true) {
          _user = result['data'];
          _isAuthenticated = true;
        } else {
          // Token might be expired or invalid
          await _apiService.clearAuthToken();
          _isAuthenticated = false;
          _user = null;
        }
      } catch (e) {
        // Network error or other issue
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Login with email and password
  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        _error = null;

        if (rememberMe) {
          await _secureStorage.write(key: 'saved_email', value: email);
          await _secureStorage.write(key: 'saved_passcode', value: password);
          _hasSavedCredentials = true;
        }

        try {
          // Log login event and set user id for analytics
          await analytics.logLogin(method: 'email');
          if (_user != null && _user!['id'] != null) {
            await analytics.setUserId(_user!['id'].toString());
          }
        } catch (_) {}
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Biometric Login using saved credentials
  Future<bool> loginWithBiometrics() async {
    if (!_canUseBiometrics || !_hasSavedCredentials) return false;

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return false;

    final email = await _secureStorage.read(key: 'saved_email');
    final pass = await _secureStorage.read(key: 'saved_passcode');

    if (email != null && pass != null) {
      return await login(email, pass, rememberMe: true);
    }
    return false;
  }
  
  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.logout();
      // Note: We keep the saved credentials for biometric login even after logout
      // to allow the user to quickly log back in.
    } catch (e) {
      _error = e.toString();
    } finally {
      _isAuthenticated = false;
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Completely clear all saved credentials (Forget Me)
  Future<void> forgetMe() async {
    await _secureStorage.delete(key: 'saved_email');
    await _secureStorage.delete(key: 'saved_passcode');
    _hasSavedCredentials = false;
    notifyListeners();
  }
  
  /// Fetch current user info
  Future<void> fetchCurrentUser() async {
    try {
      final result = await _apiService.getMe();
      
      if (result['success'] == true) {
        _user = result['data'];
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}

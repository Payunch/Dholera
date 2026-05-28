import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../analytics.dart' as analytics;

/// Auth provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;
  bool _isLoading = true; // Start with loading true
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  /// Initialize auth state (check if token exists and is valid)
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    
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
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        _error = null;
        try {
          // Log login event and set user id for analytics
          analytics.logLogin(method: 'email');
          if (_user != null && _user!['id'] != null) {
            analytics.setUserId(_user!['id'].toString());
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
  
  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.logout();
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

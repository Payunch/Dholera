import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Auth provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;
  bool _isLoading = false;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  /// Initialize auth state (check if token exists)
  Future<void> initAuth() async {
    final token = await _apiService.getAuthToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }
  
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true || result['user'] != null) {
        _user = result['user'];
        _isAuthenticated = true;
        _error = null;
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
      _isAuthenticated = false;
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Fetch current user info
  Future<void> fetchCurrentUser() async {
    try {
      final result = await _apiService.getMe();
      
      if (result['success'] != false) {
        _user = result;
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

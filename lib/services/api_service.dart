import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// API Service for handling all HTTP requests to the backend with session and security support
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();

  // Internal session state
  String? _sessionCookie;
  
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (_sessionCookie == null) {
      _sessionCookie = prefs.getString('session_cookie');
    }
    return prefs.getString('auth_token');
  }
  
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('session_cookie');
    _sessionCookie = null;
  }

  // Fetches a fresh CSRF token from the server before every mutation
  Future<String?> _refreshCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.csrfTokenEndpoint),
        headers: {
          ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Capture/update the session cookie
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('session_cookie', _sessionCookie!);
        }
        final data = jsonDecode(response.body);
        return data['csrfToken']?.toString();
      }
    } catch (e) {
      // Silent failure - return null on CSRF refresh error
    }
    return null;
  }

  // Header builder for GET requests
  Future<Map<String, String>> _getFetchHeaders() async {
    final token = await getAuthToken(); // This also loads _sessionCookie if null
    return {
      'Accept': 'application/json',
      ...?(token != null ? {'Authorization': 'Bearer $token'} : null),
      ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
    };
  }

  // Header builder for POST/PUT/DELETE requests (Includes CSRF)
  Future<Map<String, String>> _getMutationHeaders() async {
    final token = await getAuthToken(); // This also loads _sessionCookie if null
    final csrfToken = await _refreshCsrfToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?(token != null ? {'Authorization': 'Bearer $token'} : null),
      ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
      ...?(csrfToken != null ? {'X-CSRF-Token': csrfToken} : null), // FIXED X-CSR-Token typo
    };
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final csrfToken = await _refreshCsrfToken();
      
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          ...?(csrfToken != null ? {'X-CSRF-Token': csrfToken} : null),
          ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
        },
        body: jsonEncode({
          'username': email, // Backend uses 'username'
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
          await prefs.setString('session_cookie', _sessionCookie!);
        }
        if (data['token'] != null) {
          await setAuthToken(data['token'].toString());
        }
        return {'success': true, 'user': data['user'] ?? data};
      } else {
        return _handleJsonResponse(response);
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.meEndpoint),
        headers: await _getFetchHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Session expired'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> getLeads({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.leadsEndpoint}?page=$page&limit=$limit'),
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'leads');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.analyticsEndpoint),
        headers: await _getFetchHeaders(),
      );
      // Fallback if the backend returns a flat object instead of nested 'analytics'
      final res = _handleJsonResponse(response);
      if (res['success'] == true) {
         // if it's nested in 'analytics' or 'data', handle it, otherwise use root
         final data = res['data'];
         if (data is Map && data.containsKey('analytics')) {
           return {'success': true, 'analytics': data['analytics']};
         }
         return {'success': true, 'analytics': data};
      }
      return res;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.updatesEndpoint}?all=true'),
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'updates');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createUpdate(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse(ApiConfig.updatesEndpoint);
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.fields['title'] = data['title']?.toString() ?? '';
      request.fields['content'] = data['content']?.toString() ?? '';
      request.fields['category'] = data['category']?.toString() ?? 'General';
      request.fields['published'] = (data['published'] == true).toString();
      
      if (data['imagePath'] != null && data['imagePath'].toString().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', data['imagePath']));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response, 'update');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteUpdate(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.updatesEndpoint}/$id'),
        headers: await _getMutationHeaders(),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPdfs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/pdf/list'), // RESTORED ORIGINAL
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'pdfs');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadPdf(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}/pdf/upload'); // RESTORED ORIGINAL
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken; // FIXED TYPO
      
      request.fields['title'] = data['title']?.toString() ?? '';
      request.fields['category'] = data['category']?.toString() ?? 'Brochure';
      request.fields['is_protected'] = (data['is_protected'] ?? true).toString();
      
      if (data['pdfPath'] != null) {
        request.files.add(await http.MultipartFile.fromPath('pdf', data['pdfPath']));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response, 'pdf');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<String> getPdfViewUrl(int pdfId) async {
    final token = await getAuthToken();
    final baseUrl = ApiConfig.apiBaseUrl;
    return '$baseUrl/pdf/view/$pdfId?token=$token'; // RESTORED ORIGINAL
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/settings'), // RESTORED ORIGINAL
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'settings');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/settings'), // RESTORED ORIGINAL
        headers: await _getMutationHeaders(),
        body: jsonEncode(data),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Future<bool> logout() async {
    try {
      await http.post(
        Uri.parse(ApiConfig.logoutEndpoint), 
        headers: await _getMutationHeaders()
      );
      await clearAuthToken();
      return true;
    } catch (e) {
      await clearAuthToken();
      return false;
    }
  }

  /// Helper to handle JSON responses and provide consistent error messages
  Map<String, dynamic> _handleJsonResponse(http.Response response, [String? arrayKey]) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    
    try {
      final body = response.body;
      if (body.isEmpty) {
        return isSuccess ? {'success': true} : {'success': false, 'error': 'Empty response from server (Status: ${response.statusCode})'};
      }

      final data = jsonDecode(body);
      if (isSuccess) {
        // If we expect a specific array/data key
        if (arrayKey != null) {
          if (data is List) {
            return {'success': true, arrayKey: data};
          } else if (data is Map && data.containsKey(arrayKey)) {
            return {'success': true, arrayKey: data[arrayKey]};
          } else if (data is Map && data.containsKey('data')) {
            return {'success': true, arrayKey: data['data']};
          } else if (data is Map) {
             return {'success': true, arrayKey: data}; // fallback
          }
        }
        
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'error': (data is Map) ? (data['error'] ?? data['message'] ?? 'Error ${response.statusCode}') : 'Error ${response.statusCode}'
        };
      }
    } catch (e) {
      if (isSuccess && response.body.isEmpty) {
        return {'success': true};
      }
      
      // Handle non-JSON responses (HTML error pages)
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html')) {
        if (response.statusCode == 404) {
          return {'success': false, 'error': 'API endpoint not found (404).'};
        }
        if (response.statusCode == 401) {
          return {'success': false, 'error': 'Unauthorized access (401).'};
        }
        return {'success': false, 'error': 'Server error (HTML). Status: ${response.statusCode}'};
      }
      
      return {'success': false, 'error': 'Unexpected response format (Status: ${response.statusCode})'};
    }
  }
}

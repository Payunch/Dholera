import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    _sessionCookie ??= prefs.getString('session_cookie');
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
          'Accept': 'application/json',
          'User-Agent': 'DholeraAdminApp/1.0',
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
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Session expired, clear it so the next main request handles redirection
        await clearAuthToken();
      }
    } catch (e) {
      // Silent failure - return null on CSRF refresh error
    }
    return null;
  }

  // Header builder for GET requests
  Future<Map<String, String>> _getFetchHeaders() async {
    final token = await getAuthToken(); // This also loads _sessionCookie if null
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'User-Agent': 'DholeraAdminApp/1.0',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (_sessionCookie != null) headers['cookie'] = _sessionCookie!;
    return headers;
  }

  // Header builder for POST/PUT/DELETE requests (Includes CSRF)
  Future<Map<String, String>> _getMutationHeaders() async {
    final token = await getAuthToken(); // This also loads _sessionCookie if null
    final csrfToken = await _refreshCsrfToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'DholeraAdminApp/1.0',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (_sessionCookie != null) headers['cookie'] = _sessionCookie!;
    if (csrfToken != null) headers['X-CSRF-Token'] = csrfToken;
    return headers;
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final csrfToken = await _refreshCsrfToken();
      
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'DholeraAdminApp/1.0',
          // ignore: use_null_aware_elements
          if (csrfToken != null) 'X-CSRF-Token': csrfToken,
          // ignore: use_null_aware_elements
          if (_sessionCookie != null) 'cookie': _sessionCookie!,
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
          await prefs.setString('session_cookie', _sessionCookie!);
        }
        
        // Capture JWT token from response body (Backend now returns 'token')
        final authToken = data['token'] ?? data['accessToken'];
        if (authToken != null) {
          await setAuthToken(authToken.toString());
        }
        
        return {'success': true, 'user': data['user'] ?? data};
      } else {
        return _handleJsonResponse(response);
      }
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.meEndpoint),
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'data');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  // --- NEW USER AUTH METHODS ---

  Future<Map<String, dynamic>> registerRequest({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.registerRequestEndpoint),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.verifyRegistrationOtpEndpoint),
        headers: headers,
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> setupPasscode({
    required String phone,
    required String passcode,
  }) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.setupPasscodeEndpoint),
        headers: headers,
        body: jsonEncode({
          'phone': phone,
          'passcode': passcode,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lead_token'] != null) {
          await setAuthToken(data['lead_token']);
        }
        return {'success': true, 'data': data};
      }
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithPasscode({
    required String phone,
    required String passcode,
  }) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.loginWithPasscodeEndpoint),
        headers: headers,
        body: jsonEncode({
          'phone': phone,
          'passcode': passcode,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lead_token'] != null) {
          await setAuthToken(data['lead_token']);
        }
        return {'success': true, 'data': data};
      }
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
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
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> updateLeadStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.leadsEndpoint}/$id/status'),
        headers: await _getMutationHeaders(),
        body: jsonEncode({'status': status}),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }
  
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.analyticsEndpoint),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      
      return _handleJsonResponse(response, 'analytics');
    } catch (e) {
      return _handleRequestError(e);
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
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> createUpdate(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse(ApiConfig.updatesEndpoint);
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['User-Agent'] = 'DholeraAdminApp/1.0';
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.fields['title'] = data['title']?.toString() ?? '';
      request.fields['content'] = data['content']?.toString() ?? '';
      request.fields['category'] = data['category']?.toString() ?? 'General';
      request.fields['published'] = (data['published'] == true).toString();
      if (data['imageUrl'] != null) request.fields['imageUrl'] = data['imageUrl'].toString();
      
      if (data['imagePath'] != null && data['imagePath'].toString().isNotEmpty) {
        final extension = data['imagePath'].toString().split('.').last.toLowerCase();
        String mimeType = 'image/jpeg';
        if (extension == 'png') mimeType = 'image/png';
        if (extension == 'webp') mimeType = 'image/webp';
        if (extension == 'svg') mimeType = 'image/svg+xml';

        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          data['imagePath'],
          contentType: MediaType.parse(mimeType),
        ));
      }
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 2));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response, 'update');
    } catch (e) {
      return _handleRequestError(e);
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
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getPdfs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/pdf/list'),
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'pdfs');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> uploadPdf(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}/pdf/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['User-Agent'] = 'DholeraAdminApp/1.0';
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.fields['title'] = data['title']?.toString() ?? '';
      request.fields['category'] = data['category']?.toString() ?? 'Brochure';
      request.fields['is_protected'] = (data['is_protected'] ?? true).toString();
      
      if (data['pdfPath'] != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'pdf', 
          data['pdfPath'],
          contentType: MediaType('application', 'pdf'),
        ));
      }
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response, 'pdf');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<String> getPdfViewUrl(int pdfId) async {
    final token = await getAuthToken();
    final baseUrl = ApiConfig.apiBaseUrl;
    return '$baseUrl/pdf/view/$pdfId?token=$token';
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/settings'),
        headers: await _getFetchHeaders(),
      );
      return _handleJsonResponse(response, 'settings');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/settings'),
        headers: await _getMutationHeaders(),
        body: jsonEncode(data),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }
  
  Future<bool> logout() async {
    try {
      await http.post(
        Uri.parse(ApiConfig.logoutEndpoint), 
        headers: await _getMutationHeaders()
      );
    } catch (e) {
      // Ignore
    } finally {
      await clearAuthToken();
    }
    return true;
  }

  /// Helper to handle JSON responses and provide consistent error messages
  Map<String, dynamic> _handleJsonResponse(http.Response response, [String? arrayKey]) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    
    try {
      final body = response.body;
      if (body.isEmpty) {
        return isSuccess ? {'success': true} : {'success': false, 'error': 'Empty response (Status: ${response.statusCode})'};
      }

      final data = jsonDecode(body);
      if (isSuccess) {
        if (arrayKey != null) {
          if (data is List) return {'success': true, arrayKey: data};
          if (data is Map && data.containsKey(arrayKey)) return {'success': true, arrayKey: data[arrayKey]};
          if (data is Map && data.containsKey('data')) return {'success': true, arrayKey: data['data']};
          if (data is Map && data.containsKey('analytics')) return {'success': true, arrayKey: data['analytics']};
          return {'success': true, arrayKey: data};
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'error': (data is Map) ? (data['error'] ?? data['message'] ?? 'Error ${response.statusCode}') : 'Error ${response.statusCode}'
        };
      }
    } catch (e) {
      if (isSuccess && response.body.isEmpty) return {'success': true};
      
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html')) {
        if (response.statusCode == 404) return {'success': false, 'error': 'API endpoint not found (404).'};
        if (response.statusCode == 401) return {'success': false, 'error': 'Unauthorized access (401).'};
        return {'success': false, 'error': 'Server Error (HTML). Status: ${response.statusCode}'};
      }
      
      return {'success': false, 'error': 'Format error (Status: ${response.statusCode})'};
    }
  }

  /// Centralized error handling for network issues
  Map<String, dynamic> _handleRequestError(dynamic e) {
    if (e is SocketException) {
      return {
        'success': false, 
        'error': 'Network connection issue (reset by peer). Please ensure backend is running and reachable.'
      };
    }
    return {'success': false, 'error': e.toString()};
  }
}

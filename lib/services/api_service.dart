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
    return prefs.getString('auth_token');
  }
  
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
    final token = await getAuthToken();
    return {
      'Accept': 'application/json',
      ...?(token != null ? {'Authorization': 'Bearer $token'} : null),
      ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
    };
  }

  // Header builder for POST/PUT/DELETE requests (Includes CSRF)
  Future<Map<String, String>> _getMutationHeaders() async {
    final token = await getAuthToken();
    final csrfToken = await _refreshCsrfToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?(token != null ? {'Authorization': 'Bearer $token'} : null),
      ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
      ...?(csrfToken != null ? {'X-CSRF-Token': csrfToken} : null),
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
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
        }
        if (data['token'] != null) {
          await setAuthToken(data['token'].toString());
        }
        return {'success': true, 'user': data['user'] ?? data};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
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
        throw Exception('Session expired');
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'leads': data is List ? data : []};
      } else {
        throw Exception('Failed to fetch leads');
      }
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
      if (response.statusCode == 200) {
        return {'success': true, 'analytics': jsonDecode(response.body)};
      } else {
        throw Exception('Failed to fetch analytics');
      }
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'updates': data is List ? data : []};
      } else {
        throw Exception('Failed to fetch updates');
      }
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
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'update': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Failed to create update');
      }
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
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        throw Exception('Failed to delete update');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPdfs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/pdf/list'),
        headers: await _getFetchHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'pdfs': data is List ? data : []};
      } else {
        throw Exception('Failed to fetch PDFs');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadPdf(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}/pdf/upload');
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.fields['title'] = data['title']?.toString() ?? '';
      request.fields['category'] = data['category']?.toString() ?? 'Brochure';
      request.fields['is_protected'] = (data['is_protected'] ?? true).toString();
      
      if (data['pdfPath'] != null) {
        request.files.add(await http.MultipartFile.fromPath('pdf', data['pdfPath']));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'pdf': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Failed to upload PDF');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
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
      if (response.statusCode == 200) {
        return {'success': true, 'settings': jsonDecode(response.body)};
      } else {
        throw Exception('Failed to fetch settings');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/settings'),
        headers: await _getMutationHeaders(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        throw Exception('Failed to update settings');
      }
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
}

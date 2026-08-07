import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../config/api_config.dart';

/// API Service for handling all HTTP requests to the backend with session and security support
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();

  // Secure storage for sensitive data
  final _secureStorage = const FlutterSecureStorage();
  final _appCheck = FirebaseAppCheck.instance;

  // Expose configuration for system tasks
  String get apiBaseUrl => ApiConfig.apiBaseUrl;
  http.Client get apiClient => http.Client();

  // Internal session state
  String? _sessionCookie;
  
  Future<String?> getAuthToken() async {
    try {
      _sessionCookie ??= await _secureStorage.read(key: 'session_cookie');
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      try { await _secureStorage.deleteAll(); } catch (_) {}
      return null;
    }
  }
  
  Future<void> setAuthToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (e) {
      try {
        await _secureStorage.deleteAll();
        await _secureStorage.write(key: 'auth_token', value: token);
      } catch (_) {}
    }
  }
  
  Future<void> clearAuthToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'session_cookie');
    } catch (e) {
      try { await _secureStorage.deleteAll(); } catch (_) {}
    }
    _sessionCookie = null;
  }

  // ROADMAP PHASE 6: APP CHECK TOKEN FETCH
  Future<String?> _getAppCheckToken() async {
    try {
      return await _appCheck.getToken();
    } catch (e) {
      return null;
    }
  }

  // Fetches a fresh CSRF token from the server before every mutation
  Future<String?> _refreshCsrfToken() async {
    try {
      final appCheckToken = await _getAppCheckToken();

      final response = await http.get(
        Uri.parse(ApiConfig.csrfTokenEndpoint),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DholeraAdminApp/1.0',
          if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
          ...?(_sessionCookie != null ? {'cookie': _sessionCookie!} : null),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Capture/update the session cookie
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
          await _secureStorage.write(key: 'session_cookie', value: _sessionCookie!);
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
    final appCheckToken = await _getAppCheckToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'User-Agent': 'DholeraAdminApp/1.0',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (_sessionCookie != null) headers['cookie'] = _sessionCookie!;
    if (appCheckToken != null) headers['X-Firebase-AppCheck'] = appCheckToken;
    return headers;
  }

  // Header builder for POST/PUT/DELETE requests (Includes CSRF)
  Future<Map<String, String>> getMutationHeaders() async {
    final token = await getAuthToken(); // This also loads _sessionCookie if null
    final csrfToken = await _refreshCsrfToken();
    final appCheckToken = await _getAppCheckToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'DholeraAdminApp/1.0',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (_sessionCookie != null) headers['cookie'] = _sessionCookie!;
    if (appCheckToken != null) headers['X-Firebase-AppCheck'] = appCheckToken;
    if (csrfToken != null) headers['X-CSRF-Token'] = csrfToken;
    return headers;
  }

  // Private version for internal use
  Future<Map<String, String>> _getMutationHeaders() async => getMutationHeaders();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final csrfToken = await _refreshCsrfToken();
      final appCheckToken = await _getAppCheckToken();
      
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'DholeraAdminApp/1.0',
          if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
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
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
          await _secureStorage.write(key: 'session_cookie', value: _sessionCookie!);
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
      ).timeout(const Duration(seconds: 15));
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
    required String verificationToken,
  }) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.setupPasscodeEndpoint),
        headers: headers,
        body: jsonEncode({
          'phone': phone,
          'passcode': passcode,
          'verificationToken': verificationToken,
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
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response, 'leads');
    } catch (e) {
      throw Exception('Failed to get leads: $e');
    }
  }

  // Create a new lead (Public endpoint)
  Future<Map<String, dynamic>> createLead(Map<String, dynamic> leadData) async {
    try {
      final headers = await _getMutationHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.leadsEndpoint),
        headers: headers,
        body: jsonEncode(leadData),
      );
      return _handleJsonResponse(response, 'create lead');
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  Future<Map<String, dynamic>> updateLeadStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.leadsEndpoint}/$id/status'),
        headers: await _getMutationHeaders(),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 15));
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

  Future<Map<String, dynamic>> getDetailedAnalytics(DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      final response = await http.get(
        Uri.parse('${ApiConfig.detailedAnalyticsEndpoint}?start=$startStr&end=$endStr'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleJsonResponse(response, 'analytics');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getBiOverview() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/bi/overview'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }
  Future<String?> downloadExcelExport() async {
    try {
      final headers = await _getFetchHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.leadsEndpoint}/export'),
        headers: headers,
      ).timeout(const Duration(minutes: 1)); // Longer timeout for exports

      if (response.statusCode == 200) {
        return 'success';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response> downloadExcelExportRaw() async {
    final headers = await _getFetchHeaders();
    return http.get(
      Uri.parse('${ApiConfig.leadsEndpoint}/export'),
      headers: headers,
    ).timeout(const Duration(minutes: 1));
  }

  Future<Map<String, dynamic>> getUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.updatesEndpoint}?all=true'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
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
      request.fields['imagePosition'] = data['imagePosition']?.toString() ?? 'top';
      if (data['publishedAt'] != null) request.fields['publishedAt'] = data['publishedAt'].toString();
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

  Future<Map<String, dynamic>> updateUpdate(int id, Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse('${ApiConfig.updatesEndpoint}/$id');
      final request = http.MultipartRequest('PUT', uri);
      
      request.headers['User-Agent'] = 'DholeraAdminApp/1.0';
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      if (data['title'] != null) request.fields['title'] = data['title'].toString();
      if (data['content'] != null) request.fields['content'] = data['content'].toString();
      if (data['category'] != null) request.fields['category'] = data['category'].toString();
      if (data['published'] != null) request.fields['published'] = data['published'].toString();
      if (data['imagePosition'] != null) request.fields['imagePosition'] = data['imagePosition'].toString();
      if (data['publishedAt'] != null) request.fields['publishedAt'] = data['publishedAt'].toString();
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
      ).timeout(const Duration(seconds: 15));
      final result = _handleJsonResponse(response, 'pdfs');
      if (result['success'] != true || (result['pdfs'] as List?)?.isEmpty == true || result['pdfs'] == null) {
        return _getMockPdfs();
      }
      return result;
    } catch (e) {
      return _getMockPdfs();
    }
  }

  Future<Map<String, dynamic>> getMyVaultPdfs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/pdf/my-vault'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
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
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response, 'settings');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getTranslations(String lang) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.translationsEndpoint}/$lang'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DholeraAdminApp/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> updatePreferences({String? language, String? theme}) async {
    try {
      final token = await getAuthToken();
      if (token == null) return {'success': false, 'error': 'Not logged in'};

      final headers = await _getMutationHeaders();
      headers['x-lead-token'] = token;

      final response = await http.post(
        Uri.parse('${ApiConfig.preferencesEndpoint}/user'),
        headers: headers,
        body: jsonEncode({
          if (language != null) 'language': language,
          if (theme != null) 'theme': theme,
        }),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
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
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<void> trackActivity(String page) async {
    try {
      final token = await getAuthToken();
      if (token == null) return;

      final headers = await _getMutationHeaders();
      headers['Authorization'] = 'Bearer $token';

      await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/leads/track-returning'),
        headers: headers,
        body: jsonEncode({
          'page': 'App: $page',
          'timeSpent': 10, // Incremental tracking
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent fail for tracking
    }
  }

  // --- CONTENT METHODS ---

  Future<Map<String, dynamic>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/content/projects'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      final result = _handleJsonResponse(response, 'projects');
      if (result['success'] != true || (result['projects'] as List?)?.isEmpty == true || result['projects'] == null) {
        return _getMockProjects();
      }
      return result;
    } catch (e) {
      return _getMockProjects();
    }
  }

  Future<Map<String, dynamic>> getTpMaps() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/content/tp-maps'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      final result = _handleJsonResponse(response, 'tpMaps');
      if (result['success'] != true || (result['tpMaps'] as List?)?.isEmpty == true || result['tpMaps'] == null) {
        return _getMockTpMaps();
      }
      return result;
    } catch (e) {
      return _getMockTpMaps();
    }
  }

  // --- ADMIN CONTENT MANAGEMENT ---

  Future<Map<String, dynamic>> saveProject(Map<String, dynamic> data, {int? id}) async {
    try {
      final url = id == null 
          ? '${ApiConfig.apiBaseUrl}/content/projects'
          : '${ApiConfig.apiBaseUrl}/content/projects/$id';
      
      final response = id == null
          ? await http.post(Uri.parse(url), headers: await _getMutationHeaders(), body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: await _getMutationHeaders(), body: jsonEncode(data));
          
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> deleteProject(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.apiBaseUrl}/content/projects/$id'),
        headers: await _getMutationHeaders(),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> saveTpMap(Map<String, dynamic> data, {int? id}) async {
    try {
      final url = id == null 
          ? '${ApiConfig.apiBaseUrl}/content/tp-maps'
          : '${ApiConfig.apiBaseUrl}/content/tp-maps/$id';
      
      final response = id == null
          ? await http.post(Uri.parse(url), headers: await _getMutationHeaders(), body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: await _getMutationHeaders(), body: jsonEncode(data));
          
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTpMap(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.apiBaseUrl}/content/tp-maps/$id'),
        headers: await _getMutationHeaders(),
      );
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getPortals() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/content/portals'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      final result = _handleJsonResponse(response, 'portals');
      if (result['success'] != true || (result['portals'] as List?)?.isEmpty == true || result['portals'] == null) {
        return _getMockPortals();
      }
      return result;
    } catch (e) {
      return _getMockPortals();
    }
  }

  Future<Map<String, dynamic>> getUserSessions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.sessionsEndpoint),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response, 'sessions');
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> importLeads(String filePath) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse(ApiConfig.importLeadsEndpoint);
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['User-Agent'] = 'DholeraAdminApp/1.0';
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
        contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      ));
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }
  
  Future<Map<String, dynamic>> markLeadAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.markAsReadEndpoint}/$id/read'),
        headers: await _getMutationHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<http.Response> downloadExport(String endpoint) async {
    return await http.get(
      Uri.parse(endpoint),
      headers: await _getFetchHeaders(),
    ).timeout(const Duration(minutes: 2));
  }

  Future<Map<String, dynamic>> restoreSystem(String filePath) async {
    try {
      final token = await getAuthToken();
      final csrfToken = await _refreshCsrfToken();
      final uri = Uri.parse(ApiConfig.systemRestoreEndpoint);
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['User-Agent'] = 'DholeraAdminApp/1.0';
      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (_sessionCookie != null) request.headers['cookie'] = _sessionCookie!;
      if (csrfToken != null) request.headers['X-CSRF-Token'] = csrfToken;
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
        contentType: MediaType('application', 'json'),
      ));
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await http.post(
        Uri.parse(ApiConfig.logoutEndpoint), 
        headers: await _getMutationHeaders()
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Ignore
    } finally {
      await clearAuthToken();
    }
    return {'success': true};
  }

  // --- PAYMENT APPROVAL METHODS ---

  Future<Map<String, dynamic>> getPendingApprovals() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/payment/admin/pending'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getPendingCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/payment/admin/count-pending'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 10));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> approvePayment(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/payment/admin/approve/$transactionId'),
        headers: await _getMutationHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  // --- DATABASE EXPLORER METHODS ---

  Future<Map<String, dynamic>> getDatabaseTables() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/admin/db/tables'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<Map<String, dynamic>> getTableRawData(String tableName) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/admin/db/raw/$tableName'),
        headers: await _getFetchHeaders(),
      ).timeout(const Duration(seconds: 20));
      return _handleJsonResponse(response);
    } catch (e) {
      return _handleRequestError(e);
    }
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
        if (response.statusCode == 502) return {'success': false, 'error': 'Backend is starting up or temporarily unavailable (502). Please try again in a minute.'};
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
    if (e.toString().contains('TimeoutException')) {
      return {
        'success': false,
        'error': 'Connection timed out (15s). The server might be busy or starting up. Please try again.'
      };
    }
    return {'success': false, 'error': e.toString()};
  }

  // --- MOCK DATA FALLBACKS ---
  
  Map<String, dynamic> _getMockProjects() {
    return {
      'success': true,
      'projects': [
        {
          'id': 1,
          'title': 'Dholera Smart City Phase 1',
          'description': 'The very first phase of the Dholera Smart City development encompassing core infrastructure.',
          'image_url': 'assets/images/about_banner.png',
          'status': 'In Progress',
          'completion_percentage': 60,
          'expected_completion': '2026-12-31',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 2,
          'title': 'Tata Solar Manufacturing Plant',
          'description': 'India\'s largest solar cell and module manufacturing facility in Dholera SIR.',
          'image_url': 'assets/images/tata.png',
          'status': 'Completed',
          'completion_percentage': 100,
          'expected_completion': '2025-01-01',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      ]
    };
  }

  Map<String, dynamic> _getMockTpMaps() {
    return {
      'success': true,
      'tpMaps': [
        {
          'id': 1,
          'title': 'Town Planning Scheme 1',
          'description': 'Official TP Map for Scheme 1 Residential and Commercial plots.',
          'image_url': 'assets/images/sub1.png',
          'pdf_url': null,
          'version': '1.0',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      ]
    };
  }

  Map<String, dynamic> _getMockPortals() {
    return {
      'success': true,
      'portals': [
        {
          'id': 1,
          'name': 'Dholera SIR Official',
          'url': 'https://dholerasir.com',
          'description': 'Official Government website for Dholera SIR.',
          'category': 'Government',
          'category_subtitle': 'Official Portals',
          'icon_name': 'account_balance',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 2,
          'name': 'Gujarat RERA',
          'url': 'https://gujrera.gujarat.gov.in',
          'description': 'Real Estate Regulatory Authority portal for Gujarat.',
          'category': 'Real Estate',
          'category_subtitle': 'Regulatory Authorities',
          'icon_name': 'home',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      ]
    };
  }

  Map<String, dynamic> _getMockPdfs() {
    return {
      'success': true,
      'pdfs': [
        {
          'id': 1,
          'title': 'Dholera Master Plan',
          'file_path': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          'category': 'Brochure',
          'is_protected': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      ]
    };
  }
}

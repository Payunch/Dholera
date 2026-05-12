import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://dholera-backend-production.up.railway.app/api';
  
  // 1. Get CSRF
  final res1 = await http.get(Uri.parse('$baseUrl/auth/csrf-token'));
  final csrfToken = jsonDecode(res1.body)['csrfToken'];
  final cookie = res1.headers['set-cookie'];
  
  print('CSRF: $csrfToken');
  
  // 2. Login (we don't have creds, but we can try to guess or maybe there is a default admin?)
  // Actually, let's just see what happens if we use the backend without auth.
}

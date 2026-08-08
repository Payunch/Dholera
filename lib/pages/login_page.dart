import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'admin/admin_bottom_nav_bar.dart';
import 'user/user_bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    
    if (username.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Username and Phone Number are required.');
      return;
    }
    
    // 10-digit mobile number validation
    if (phone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      setState(() => _error = 'Please enter a valid 10-digit Indian mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Public access collects a lead. OTP-based identity verification will be
      // added later; this flow must not be used to grant protected content.
      final response = await _apiService.createLead({'name': username, 'phone': phone, 'source': 'App'});
      if (response['success'] == true) {
        await _routeToApp({'name': username, 'phone': phone}, AppRole.userInvestor);
      } else {
        setState(() => _error = response['error'] ?? 'Failed to register. Please try again.');
      }
    } catch (e) {
      setState(() => _error = 'Connection Error: Unable to reach the server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeToApp(Map<String, dynamic>? userData, AppRole role) async {
    String? token = await _apiService.getAuthToken();
    token ??= userData?['token'] ?? userData?['accessToken'] ?? 'temp_public_token';
    
    if (token != null && mounted) {
      context.read<AuthBloc>().add(AuthLoginRequested(
        token: token,
        userName: userData?['name'] ?? 'Guest User',
        role: role,
      ));

      await NotificationService().syncTokenWithBackend();

      if (!mounted) return;

      if (role == AppRole.adminOwner) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminBottomNavBar()),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserBottomNavBar()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset('assets/images/logo.png', height: 100),
                ),
                const SizedBox(height: 48),
                Card(
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ENTER APP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'FULL NAME',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'PHONE NUMBER',
                          icon: Icons.phone_android,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7A00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'CONTINUE',
                                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
        prefixIcon: Icon(icon, color: const Color(0xFFFF7A00)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF7A00)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'user/user_bottom_nav_bar.dart';
import 'admin/admin_bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _api = ApiService();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _otp = TextEditingController();
  bool _signUp = false,
      _adminMode = false,
      _forgotPassword = false,
      _resetCodeSent = false,
      _loading = false;
  String? _error, _message;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _password,
      _confirmPassword,
      _otp,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    Map<String, dynamic> result;
    if (_adminMode) {
      result = await _api.login(email, _password.text);
    } else if (_forgotPassword) {
      if (_resetCodeSent) {
        if (_password.text.length < 8 ||
            _password.text != _confirmPassword.text) {
          setState(() {
            _error = 'Use matching passwords of at least 8 characters.';
            _loading = false;
          });
          return;
        }
        result = await _api.resetPassword(
          email: email,
          otp: _otp.text.trim(),
          password: _password.text,
        );
      } else {
        result = await _api.requestPasswordReset(email);
        if (result['success'] == true) {
          setState(() {
            _resetCodeSent = true;
            _message = 'Verification code sent. Check your email.';
          });
        }
      }
    } else if (_signUp) {
      if (_name.text.trim().isEmpty ||
          _phone.text.trim().length != 10 ||
          _password.text.length < 8 ||
          _password.text != _confirmPassword.text) {
        setState(() {
          _error = 'Enter your details and matching 8-character password.';
          _loading = false;
        });
        return;
      }
      result = await _api.userSignup(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: email,
        password: _password.text,
      );
    } else {
      result = await _api.userLogin(
        identifier: email,
        password: _password.text,
      );
    }
    if (result['success'] == true && (_adminMode || result['token'] != null)) {
      await _enterApp(result, isAdmin: _adminMode);
    } else if (mounted) {
      setState(() => _error = result['error'] ?? 'Please try again.');
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _enterApp(
    Map<String, dynamic> result, {
    bool isAdmin = false,
  }) async {
    final user = Map<String, dynamic>.from(result['user'] ?? {});
    final token = await _api.getAuthToken() ?? result['token']?.toString();
    if (token == null) {
      if (mounted)
        setState(() => _error = 'Unable to create a secure session.');
      return;
    }
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        token: token,
        userName:
            user['name']?.toString() ?? user['username']?.toString() ?? 'User',
        role: isAdmin ? AppRole.adminOwner : AppRole.userInvestor,
      ),
    );
    await NotificationService().syncTokenWithBackend();
    if (mounted) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              isAdmin ? const AdminBottomNavBar() : const UserBottomNavBar(),
        ),
        (_) => false,
      );
    }
  }

  void _switchMode() => setState(() {
    _signUp = !_signUp;
    _adminMode = false;
    _forgotPassword = false;
    _resetCodeSent = false;
    _error = null;
    _message = null;
  });
  void _openForgot() => setState(() {
    _forgotPassword = true;
    _adminMode = false;
    _signUp = false;
    _resetCodeSent = false;
    _error = null;
    _message = null;
  });

  @override
  Widget build(BuildContext context) {
    final title = _adminMode
        ? 'ADMIN SIGN IN'
        : _forgotPassword
        ? (_resetCodeSent ? 'RESET PASSWORD' : 'FORGOT PASSWORD')
        : (_signUp ? 'CREATE ACCOUNT' : 'SIGN IN');
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
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white.withValues(alpha: .06),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 84),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_signUp && !_adminMode) ...[
                      _field(_name, 'FULL NAME', Icons.person_outline),
                      const SizedBox(height: 12),
                      _field(
                        _phone,
                        'MOBILE NUMBER',
                        Icons.phone_android,
                        keyboard: TextInputType.phone,
                      ),
                    ],
                    if (_signUp && !_adminMode) const SizedBox(height: 12),
                    _field(
                      _email,
                      _adminMode ? 'ADMIN USERNAME' : 'EMAIL ADDRESS',
                      Icons.email_outlined,
                      keyboard: TextInputType.emailAddress,
                    ),
                    if (_forgotPassword && _resetCodeSent) ...[
                      const SizedBox(height: 12),
                      _field(
                        _otp,
                        '6-DIGIT EMAIL CODE',
                        Icons.password_outlined,
                        keyboard: TextInputType.number,
                      ),
                    ],
                    if (_adminMode || !_forgotPassword || _resetCodeSent) ...[
                      const SizedBox(height: 12),
                      _field(
                        _password,
                        'PASSWORD',
                        Icons.lock_outline,
                        secret: true,
                      ),
                      if (_signUp || _resetCodeSent) ...[
                        const SizedBox(height: 12),
                        _field(
                          _confirmPassword,
                          'CONFIRM PASSWORD',
                          Icons.lock_outline,
                          secret: true,
                        ),
                      ],
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : Text(
                                _forgotPassword
                                    ? (_resetCodeSent
                                          ? 'RESET PASSWORD'
                                          : 'SEND CODE')
                                    : (_signUp ? 'CREATE ACCOUNT' : 'SIGN IN'),
                              ),
                      ),
                    ),
                    if (!_forgotPassword && !_adminMode)
                      if (!_adminMode)
                        TextButton(
                          onPressed: _loading ? null : _openForgot,
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                    TextButton(
                      onPressed: _loading ? null : _switchMode,
                      child: Text(
                        _forgotPassword
                            ? 'Back to sign in'
                            : (_signUp
                                  ? 'Already have an account? Sign in'
                                  : 'New here? Create an account'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                        _adminMode = !_adminMode;
                        _signUp = false;
                        _forgotPassword = false;
                        _resetCodeSent = false;
                        _error = null;
                        _message = null;
                      }),
                child: Text(
                  _adminMode ? 'Back to user sign in' : 'Administrator sign in',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool secret = false,
    TextInputType? keyboard,
  }) => TextField(
    controller: controller,
    obscureText: secret,
    keyboardType: keyboard,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFFF7A00)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF7A00)),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import 'user/user_bottom_nav_bar.dart';
import 'admin/admin_bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _otp = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _otpFocus = FocusNode();
  bool _signUp = true,
      _adminMode = false,
      _loginByMobile = false,
      _forgotPassword = false,
      _resetCodeSent = false,
      _loading = false;
  String? _error, _message;

  @override
  void initState() {
    super.initState();
    for (final controller in [_name, _phone, _email, _password, _confirmPassword, _otp]) {
      controller.addListener(_rebuildForInputChange);
    }
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _password, _confirmPassword, _otp]) {
      controller.removeListener(_rebuildForInputChange);
    }
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
    for (final f in [
      _nameFocus,
      _phoneFocus,
      _emailFocus,
      _passwordFocus,
      _confirmPasswordFocus,
      _otpFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  void _rebuildForInputChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearAuthFields({
    bool clearName = false,
    bool clearPhone = false,
    bool clearEmail = true,
    bool clearPassword = true,
    bool clearOtp = true,
    bool clearConfirm = true,
  }) {
    if (clearName) _name.clear();
    if (clearPhone) _phone.clear();
    if (clearEmail) _email.clear();
    if (clearPassword) _password.clear();
    if (clearOtp) _otp.clear();
    if (clearConfirm) _confirmPassword.clear();
  }

  Future<void> _submit() async {
    final identifier = _email.text.trim();
    if (_signUp && !_adminMode) {
      final formOk = _formKey.currentState?.validate() ?? false;
      if (!formOk) {
        setState(() => _loading = false);
        return;
      }
    }
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    Map<String, dynamic> result;
    bool loggedInAsAdmin = _adminMode;

    if (_adminMode) {
      result = await _api.login(identifier, _password.text);
      loggedInAsAdmin = true;
    } else if (_forgotPassword) {
      if (!_isValidEmail(identifier)) {
        setState(() {
          _error = 'Enter a valid email address to reset your password.';
          _loading = false;
        });
        return;
      }
      if (_resetCodeSent) {
        if (!RegExp(r'^\d{4}$').hasMatch(_password.text) ||
            _password.text != _confirmPassword.text) {
          setState(() {
            _error = 'Use matching 4-digit PINs.';
            _loading = false;
          });
          return;
        }
        result = await _api.resetPassword(
          email: identifier,
          otp: _otp.text.trim(),
          password: _password.text,
        );
      } else {
        result = await _api.requestPasswordReset(identifier);
        if (result['success'] == true) {
          setState(() {
            _resetCodeSent = true;
            _message = 'Verification code sent. Check your email.';
          });
        }
      }
    } else if (_signUp) {
      final nameText = _name.text.trim();
      final phoneText = _phone.text.trim();
      if (nameText.isEmpty) {
        setState(() {
          _error = 'Enter your full name.';
          _loading = false;
        });
        FocusScope.of(context).requestFocus(_nameFocus);
        return;
      }
      if (!_isValidMobile(phoneText)) {
        setState(() {
          _error = 'Enter a valid 10-digit mobile number.';
          _loading = false;
        });
        FocusScope.of(context).requestFocus(_phoneFocus);
        return;
      }
      if (!_isValidEmail(identifier)) {
        setState(() {
          _error = 'Enter a valid email like name@example.com.';
          _loading = false;
        });
        FocusScope.of(context).requestFocus(_emailFocus);
        return;
      }
      _error = null;
      final signupPassword = await _collectSignupPassword();
      if (signupPassword == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }
      debugPrint(
        '[signup] submit name="$nameText" phone="$phoneText" email="$identifier" '
        'terms=${signupPassword['acceptedTerms'] == true} privacy=${signupPassword['acceptedPrivacy'] == true} '
        'pinLen=${signupPassword['password']?.toString().length ?? 0}',
      );
      result = await _api.userSignup(
        name: nameText,
        phone: phoneText,
        email: identifier,
        password: signupPassword['password']?.toString() ?? '',
        acceptedTerms: signupPassword['acceptedTerms'] == true,
        acceptedPrivacy: signupPassword['acceptedPrivacy'] == true,
      );
      debugPrint('[signup] response => $result');
    } else {
      final isEmail = _isValidEmail(identifier);
      final isMobile = _isValidMobile(identifier);

      if (_loginByMobile && !isMobile) {
        setState(() {
          _error = 'Enter a valid 10-digit mobile number.';
          _loading = false;
        });
        return;
      }

      if (!_loginByMobile && !isEmail) {
        setState(() {
          _error = 'Enter a valid email address.';
          _loading = false;
        });
        return;
      }

      result = await _api.userLogin(
        identifier: identifier,
        password: _password.text,
      );
    }
    if (result['success'] == true && (loggedInAsAdmin || result['token'] != null)) {
      final resolvedEmail = _extractEmail(result) ??
          (_isValidEmail(identifier) ? identifier : null);
      await _enterApp(
        result,
        isAdmin: loggedInAsAdmin,
        userEmail: resolvedEmail,
      );
    } else if (mounted) {
      final serverError = result['error']?.toString().trim();
      setState(() {
        _error = (serverError != null && serverError.isNotEmpty)
            ? serverError
            : 'Signup failed. Check your details and try again.';
      });
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _enterApp(
    Map<String, dynamic> result, {
    bool isAdmin = false,
    String? userEmail,
  }) async {
    final navigator = Navigator.of(context);
    final authBloc = context.read<AuthBloc>();
    final user = Map<String, dynamic>.from(result['user'] ?? {});
    final token = await _api.getAuthToken() ?? result['token']?.toString();
    if (token == null) {
      if (mounted) {
        setState(() => _error = 'Unable to create a secure session.');
      }
      return;
    }
    authBloc.add(
      AuthLoginRequested(
        token: token,
        userName:
            user['name']?.toString() ?? user['username']?.toString() ?? 'User',
        userEmail: userEmail ?? user['email']?.toString(),
        role: isAdmin ? AppRole.adminOwner : AppRole.userInvestor,
      ),
    );
    await NotificationService().syncTokenWithBackend();
    if (!mounted) return;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            isAdmin ? const AdminBottomNavBar() : const UserBottomNavBar(),
      ),
      (_) => false,
    );
  }

  void _switchMode() => setState(() {
    _signUp = !_signUp;
    _adminMode = false;
    _loginByMobile = false;
    _forgotPassword = false;
    _resetCodeSent = false;
    _clearAuthFields(clearName: true, clearPhone: true);
    _error = null;
    _message = null;
  });
  void _openForgot() => setState(() {
    _forgotPassword = true;
    _adminMode = false;
    _loginByMobile = false;
    _signUp = false;
    _resetCodeSent = false;
    _clearAuthFields(clearName: true, clearPhone: true);
    _error = null;
    _message = null;
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = _clampDouble(screenWidth - 32, 320, 460);
    final cardPadding = _clampDouble(screenWidth * 0.07, 20, 28);
    final logoHeight = _clampDouble(screenWidth * 0.20, 72, 108);
    final titleSize = _clampDouble(screenWidth * 0.054, 22, 30);
    final subtitleSize = _clampDouble(screenWidth * 0.032, 12, 15);
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
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: Card(
                color: Colors.white.withValues(alpha: .08),
                elevation: 24,
                shadowColor: Colors.black.withValues(alpha: .25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _signUp && !_adminMode
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: Image.asset('assets/images/logo.png', height: logoHeight)),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _adminMode
                            ? 'Admin users can continue with username and password.'
                            : _forgotPassword
                                ? 'Recover access with your email address.'
                                : 'Choose a simple sign in or sign up flow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleSize,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _modePill('SIGN UP', !_adminMode && _signUp && !_forgotPassword),
                          _modePill('SIGN IN', !_adminMode && !_signUp && !_forgotPassword),
                          _modePill('ADMIN', _adminMode),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_signUp && !_adminMode) ...[
                        _field(
                          _name,
                          'FULL NAME',
                          Icons.person_outline,
                          focusNode: _nameFocus,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Enter your full name.'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _phone,
                          'MOBILE NUMBER',
                          Icons.phone_android,
                          keyboard: TextInputType.phone,
                          focusNode: _phoneFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) =>
                              _isValidMobile(value?.trim() ?? '')
                                  ? null
                                  : 'Enter a valid 10-digit mobile number.',
                        ),
                        const SizedBox(height: 12),
                      ],
                      _field(
                        _email,
                        _adminMode
                            ? 'ADMIN USERNAME'
                            : _forgotPassword
                                ? 'EMAIL ADDRESS'
                                : (_signUp
                                    ? 'EMAIL ADDRESS'
                                    : (_loginByMobile ? 'MOBILE NUMBER' : 'EMAIL ADDRESS')),
                        _adminMode
                            ? Icons.admin_panel_settings_outlined
                            : (_signUp
                                ? Icons.email_outlined
                                : (_loginByMobile
                                    ? Icons.phone_android_outlined
                                    : Icons.mail_outline)),
                        keyboard: _adminMode
                            ? TextInputType.emailAddress
                            : (_signUp || _forgotPassword || !_loginByMobile
                                ? TextInputType.emailAddress
                                : TextInputType.phone),
                        focusNode: _emailFocus,
                        inputFormatters: _adminMode
                            ? null
                            : (_signUp || _forgotPassword || !_loginByMobile
                                ? [LengthLimitingTextInputFormatter(64)]
                                : [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ]),
                        validator: _adminMode
                            ? null
                            : (value) {
                                final text = value?.trim() ?? '';
                                if (_forgotPassword) {
                                  return _isValidEmail(text)
                                      ? null
                                      : 'Enter a valid email address.';
                                }
                                if (_signUp) {
                                  return _isValidEmail(text)
                                      ? null
                                      : 'Enter a valid email like name@example.com.';
                                }
                                if (_loginByMobile) {
                                  return _isValidMobile(text)
                                      ? null
                                      : 'Enter a valid 10-digit mobile number.';
                                }
                                return _isValidEmail(text)
                                    ? null
                                    : 'Enter a valid email address.';
                              },
                        suffixIcon: (!_signUp && !_adminMode && !_forgotPassword)
                            ? IconButton(
                                tooltip: _loginByMobile ? 'Switch to email sign in' : 'Switch to mobile sign in',
                                onPressed: _loading
                                    ? null
                                    : () => setState(() {
                                        _loginByMobile = !_loginByMobile;
                                        _email.clear();
                                        _password.clear();
                                        _error = null;
                                        _message = null;
                                      }),
                                icon: Icon(
                                  _loginByMobile ? Icons.phone_android_outlined : Icons.mail_outline,
                                  color: const Color(0xFFFF7A00),
                                ),
                              )
                            : null,
                      ),
                      if (!_adminMode && !_forgotPassword && !_signUp) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _loginByMobile
                                ? 'Use the mobile number registered with your account.'
                                : 'Use the email registered with your account.',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      ],
                      if (_forgotPassword && _resetCodeSent) ...[
                        const SizedBox(height: 12),
                        _field(
                          _otp,
                          '6-DIGIT EMAIL CODE',
                          Icons.password_outlined,
                          keyboard: TextInputType.number,
                          focusNode: _otpFocus,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (_forgotPassword && _resetCodeSent && !RegExp(r'^\d{6}$').hasMatch(text)) {
                              return 'Enter the 6-digit code sent to your email.';
                            }
                            return null;
                          },
                        ),
                      ],
                      if ((_adminMode || !_forgotPassword || _resetCodeSent) && !_signUp) ...[
                        const SizedBox(height: 12),
                        _field(
                          _password,
                          _adminMode ? 'PASSWORD' : 'PASSWORD (4 DIGITS)',
                          Icons.lock_outline,
                          secret: true,
                          focusNode: _passwordFocus,
                          keyboard: _adminMode ? null : TextInputType.number,
                          inputFormatters: _adminMode
                              ? null
                              : [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                          validator: (value) {
                            final text = value ?? '';
                            if (_forgotPassword && !_resetCodeSent) return null;
                            if (_adminMode) {
                              if (text.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              return null;
                            }
                            if (!RegExp(r'^\d{4}$').hasMatch(text)) {
                              return 'Password must be exactly 4 digits.';
                            }
                            return null;
                          },
                        ),
                        if (_resetCodeSent) ...[
                          const SizedBox(height: 12),
                          _field(
                            _confirmPassword,
                            _adminMode ? 'CONFIRM PASSWORD' : 'CONFIRM PIN',
                            Icons.lock_outline,
                            secret: true,
                            focusNode: _confirmPasswordFocus,
                            keyboard: _adminMode ? null : TextInputType.number,
                            inputFormatters: _adminMode
                                ? null
                                : [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                            validator: (value) {
                              final text = value ?? '';
                              if (_password.text.isEmpty) return 'Confirm your password.';
                              if (text != _password.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.lightGreenAccent),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading || !_canContinueSignup ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _forgotPassword
                                      ? (_resetCodeSent ? 'RESET PASSWORD' : 'SEND CODE')
                                      : (_signUp ? 'CONTINUE' : 'SIGN IN'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!_forgotPassword && !_adminMode && !_signUp)
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
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                _adminMode = !_adminMode;
                                _signUp = false;
                                _loginByMobile = false;
                                _forgotPassword = false;
                                _resetCodeSent = false;
                                _clearAuthFields(clearName: true, clearPhone: true);
                                _error = null;
                                _message = null;
                              }),
                        child: Text(
                          _adminMode ? 'Back to user sign in' : 'Administrator sign in',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modePill(String text, bool selected) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: _loading
          ? null
          : (_) {
              setState(() {
                _adminMode = text == 'ADMIN';
                _forgotPassword = text == 'FORGOT';
                _signUp = text == 'SIGN UP';
                _loginByMobile = false;
                _resetCodeSent = false;
                _clearAuthFields(clearName: true, clearPhone: true);
                _error = null;
                _message = null;
              });
            },
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      selectedColor: const Color(0xFFFF7A00),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool secret = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    FocusNode? focusNode,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    obscureText: secret,
    keyboardType: keyboard,
    inputFormatters: inputFormatters,
    style: const TextStyle(color: Colors.white),
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFFF7A00)),
      suffixIcon: suffixIcon,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24, width: 1.2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF7A00), width: 2.6),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1.6),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2.2),
      ),
    ),
  );

  Future<Map<String, dynamic>?> _collectSignupPassword() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    var acceptedPrivacy = false;
    var acceptedTerms = false;
    var attempts = 0;
    DateTime? blockedUntil;
    String? errorText;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final now = DateTime.now();
            if (blockedUntil != null && now.isAfter(blockedUntil!)) {
              blockedUntil = null;
              attempts = 0;
            }
            final isLocked = blockedUntil != null;
            final remainingSeconds = isLocked
                ? blockedUntil!.difference(now).inSeconds.clamp(1, 9999)
                : 0;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0B132B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create 4-digit password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Numbers only. Three invalid attempts will lock this step briefly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'PASSWORD (4 DIGITS)',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF7A00)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF7A00), width: 2.6),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1.6),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 2.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'CONFIRM PASSWORD',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF7A00)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF7A00), width: 2.6),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1.6),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 2.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: acceptedPrivacy,
                        onChanged: isLocked
                            ? null
                            : (value) => setModalState(() {
                                acceptedPrivacy = value ?? false;
                              }),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        checkColor: Colors.white,
                        activeColor: const Color(0xFFFF7A00),
                        side: const BorderSide(color: Colors.white54),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            const Text('I agree to the', style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                              ),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFFFF7A00),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                        value: acceptedTerms,
                        onChanged: isLocked
                            ? null
                            : (value) => setModalState(() {
                                acceptedTerms = value ?? false;
                              }),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        checkColor: Colors.white,
                        activeColor: const Color(0xFFFF7A00),
                        side: const BorderSide(color: Colors.white54),
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            const Text('I agree to the', style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TermsPage()),
                              ),
                              child: const Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  color: Color(0xFFFF7A00),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ],
                      if (isLocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Try again in ${remainingSeconds}s.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLocked
                              ? null
                              : () {
                                  final password = passwordController.text.trim();
                                  final confirm = confirmController.text.trim();
                                  String? validationError;
                                  if (!RegExp(r'^\d{4}$').hasMatch(password)) {
                                    validationError = 'Password must be exactly 4 digits.';
                                  } else if (confirm != password) {
                                    validationError = 'Passwords do not match.';
                                  } else if (!acceptedPrivacy || !acceptedTerms) {
                                    validationError = 'Accept both Privacy Policy and Terms & Conditions.';
                                  }

                                  if (validationError != null) {
                                    attempts += 1;
                                    if (attempts >= 3) {
                                      blockedUntil = DateTime.now().add(const Duration(minutes: 2));
                                      attempts = 0;
                                    }
                                    setModalState(() {
                                      errorText = validationError;
                                    });
                                    return;
                                  }

                                  Navigator.pop(sheetContext, {
                                    'password': password,
                                    'acceptedPrivacy': acceptedPrivacy,
                                    'acceptedTerms': acceptedTerms,
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(isLocked ? 'LOCKED' : 'CONFIRM PASSWORD'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    passwordController.dispose();
    confirmController.dispose();
    return result;
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty || email.contains(' ')) {
      return false;
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return false;
    }

    final localPart = parts[0];
    final domainPart = parts[1];
    if (localPart.isEmpty || domainPart.isEmpty) {
      return false;
    }

    if (localPart.startsWith('.') ||
        localPart.endsWith('.') ||
        localPart.contains('..') ||
        domainPart.startsWith('.') ||
        domainPart.endsWith('.') ||
        domainPart.contains('..')) {
      return false;
    }

    final localValid = RegExp(r'^[A-Za-z0-9._%+-]{1,64}$').hasMatch(localPart);
    final domainValid = RegExp(r'^[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$').hasMatch(domainPart);
    if (!localValid || !domainValid) {
      return false;
    }

    final topLevelDomain = domainPart.split('.').last;
    return topLevelDomain.length >= 2;
  }

  bool _isValidMobile(String value) {
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  bool get _canContinueSignup {
    if (!_signUp || _adminMode) {
      return true;
    }
    return _name.text.trim().isNotEmpty &&
        _isValidMobile(_phone.text.trim()) &&
        _isValidEmail(_email.text.trim());
  }

  String? _extractEmail(Map<String, dynamic> result) {
    final user = result['user'];
    if (user is Map<String, dynamic>) {
      final email = user['email']?.toString().trim();
      if (email != null && email.isNotEmpty) return email;
    }
    final data = result['data'];
    if (data is Map<String, dynamic>) {
      final email = data['email']?.toString().trim();
      if (email != null && email.isNotEmpty) return email;
    }
    final email = result['email']?.toString().trim();
    if (email != null && email.isNotEmpty) return email;
    return null;
  }
}

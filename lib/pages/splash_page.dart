import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/preferences/preferences_bloc.dart';
import '../blocs/preferences/preferences_state.dart';
import 'language_page.dart';
import 'onboarding_page.dart';
import 'role_selection_page.dart';
import 'dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    try {
      // Maximum time to wait in splash
      final timeout = Future.delayed(const Duration(seconds: 5));
      
      // Artificial delay for splash animation
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      final prefState = context.read<PreferencesBloc>().state;
      final authState = context.read<AuthBloc>().state;

      if (!prefState.isLanguageSelected) {
        _replacePage(const LanguagePage());
      } else if (!prefState.isOnboardingDone) {
        _replacePage(const OnboardingPage());
      } else if (authState.status == AuthStatus.authenticated) {
        _replacePage(const DashboardPage());
      } else {
        _replacePage(const RoleSelectionPage());
      }
    } catch (e) {
      debugPrint('Splash Navigation Error: $e');
      // Fallback to role selection if everything fails
      if (mounted) {
        _replacePage(const RoleSelectionPage());
      }
    }
  }

  void _replacePage(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset('assets/images/logo.png', height: 120),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
            ),
          ],
        ),
      ),
    );
  }
}

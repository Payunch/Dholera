import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/preferences/preferences_bloc.dart';
import 'language_page.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
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
        _replacePage(const LoginPage());
      }
    } catch (e) {
      debugPrint('Splash Navigation Error: $e');
      // Fallback to login if everything fails
      if (mounted) {
        _replacePage(const LoginPage());
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
              tag: 'splash_images',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/futuristic_dholera.png', height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/strategic-location.png', height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/dholerasirGujrat.webp', height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.white)),
                  ),
                ],
              ),
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

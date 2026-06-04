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
    // Artificial delay for splash animation/feel
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefState = context.read<PreferencesBloc>().state;
    final authState = context.read<AuthBloc>().state;

    if (!prefState.isLanguageSelected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguagePage()),
      );
    } else if (!prefState.isOnboardingDone) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else if (authState.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    }
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

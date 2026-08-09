import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/preferences/preferences_bloc.dart';
import '../services/api_service.dart';
import 'language_page.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
import 'admin/admin_bottom_nav_bar.dart';
import 'user/user_bottom_nav_bar.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final ApiService _apiService = ApiService();
  bool _updateGateChecked = false;

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

      if (!_updateGateChecked) {
        _updateGateChecked = true;
        final mustStop = await _checkForRequiredUpdate();
        if (mustStop || !mounted) {
          return;
        }
      }

      // Wait if auth is still loading (up to 3 seconds max)
      int waitCount = 0;
      while (mounted && context.read<AuthBloc>().state.status == AuthStatus.loading && waitCount < 15) {
        await Future.delayed(const Duration(milliseconds: 200));
        waitCount++;
      }

      if (!mounted) return;

      final prefState = context.read<PreferencesBloc>().state;
      final authState = context.read<AuthBloc>().state;

      if (!prefState.isLanguageSelected) {
        _replacePage(const LanguagePage());
      } else if (!prefState.isOnboardingDone) {
        _replacePage(const OnboardingPage());
      } else if (authState.status == AuthStatus.authenticated) {
        _replacePage(
          authState.role == AppRole.adminOwner
              ? const AdminBottomNavBar()
              : const UserBottomNavBar(),
        );
      } else {
        final token = await _apiService.getAuthToken();
        final storedInfo = await _apiService.getUserInfo();
        final storedRole = storedInfo['role'];
        if (token != null && token.isNotEmpty) {
          _replacePage(
            storedRole == AppRole.adminOwner.name
                ? const AdminBottomNavBar()
                : const UserBottomNavBar(),
          );
        } else {
          _replacePage(const LoginPage());
        }
      }
    } catch (e) {
      debugPrint('Splash Navigation Error: $e');
      if (mounted) {
        _replacePage(const LoginPage());
      }
    }
  }

  Future<bool> _checkForRequiredUpdate() async {
    try {
      final appInfo = await _apiService.getAppInfo();
      if (appInfo['success'] != true) {
        return false;
      }

      final requiredBuild = int.tryParse(appInfo['requiredBuildNumber']?.toString() ?? '');
      final apkUrl = appInfo['apkUrl']?.toString().trim() ?? '';
      final updateTitle = appInfo['updateTitle']?.toString().trim().isNotEmpty == true
          ? appInfo['updateTitle'].toString().trim()
          : 'Update Required';
      final updateMessage = appInfo['updateMessage']?.toString().trim().isNotEmpty == true
          ? appInfo['updateMessage'].toString().trim()
          : 'A newer APK is available. Please update to continue.';
      final releaseNotes = appInfo['releaseNotes']?.toString().trim() ?? '';

      if (requiredBuild == null) {
        return false;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (currentBuild >= requiredBuild) {
        return false;
      }

      if (!mounted) {
        return true;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(updateTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(updateMessage),
                  if (releaseNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      releaseNotes,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: apkUrl.isEmpty
                    ? null
                    : () async {
                        Navigator.of(dialogContext).pop();
                        final uri = Uri.tryParse(apkUrl);
                        if (uri != null) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                child: const Text('Update Now'),
              ),
            ],
          );
        },
      );
      return true;
    } catch (e) {
      debugPrint('Update gate error: $e');
      return false;
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

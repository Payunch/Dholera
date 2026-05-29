import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'models/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'consent.dart';
import 'widgets/consent_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // Initialize Google Mobile Ads SDK for AdMob
  if (_shouldInitializeMobileAds()) {
    MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: []));
    await MobileAds.instance.initialize();
  }
  // Initialize consent manager before app start
  await ConsentManager.init();
  // Apply analytics collection setting based on consent (if set)
  try {
    // final analyticsEnabled = ConsentManager.analyticsConsent ?? false;
    // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(analyticsEnabled);
  } catch (_) {}
  runApp(const MyApp());
}

bool _shouldInitializeMobileAds() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
      ],
      child: MaterialApp(
        title: 'Dholera Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        // navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Wrapper widget to handle authentication routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text('Verifying session...', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          return Stack(
            children: [
              DashboardPage(),
              if (!ConsentManager.isConsentSet()) const _ConsentPrompt(),
            ],
          );
        } else {
          return Stack(
            children: [
              LoginPage(),
              if (!ConsentManager.isConsentSet()) const _ConsentPrompt(),
            ],
          );
        }
      },
    );
  }
}

class _ConsentPrompt extends StatefulWidget {
  const _ConsentPrompt();

  @override
  State<_ConsentPrompt> createState() => _ConsentPromptState();
}

class _ConsentPromptState extends State<_ConsentPrompt> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _dialogShown || ConsentManager.isConsentSet()) {
        return;
      }
      _dialogShown = true;
      await showDialog(
        context: context,
        builder: (_) => const ConsentDialog(),
        barrierDismissible: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

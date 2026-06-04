import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/localization/localization_bloc.dart';
import 'blocs/localization/localization_state.dart';
import 'blocs/preferences/preferences_bloc.dart';
import 'blocs/leads/leads_bloc.dart';
import 'blocs/leads/leads_event.dart';
import 'pages/splash_page.dart';
import 'consent.dart';
import 'widgets/consent_dialog.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize App Check (Roadmap Phase 6)
    // Use Play Integrity for Android
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
      webProvider: ReCaptchaEnterpriseProvider('6LcV6pYqAAAAANL-9I66S6-U3hW_6_n0v0W6-w6X'), // Site Key
    );

    // Initialize real-time notifications
    await NotificationService().initialize();
  } catch (e) {
    if (kDebugMode) print('Firebase initialization failed: $e');
  }

  // Initialize Google Mobile Ads SDK for AdMob
  if (_shouldInitializeMobileAds()) {
    await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: []));
    await MobileAds.instance.initialize();
  }
  // Initialize consent manager before app start
  await ConsentManager.init();
  // Apply analytics collection setting based on consent (if set)
  try {
    final analyticsEnabled = ConsentManager.analyticsConsent ?? false;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(analyticsEnabled);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => LocalizationBloc()..add(LoadTranslations())),
        BlocProvider(create: (_) => PreferencesBloc()),
        BlocProvider(create: (_) => LeadsBloc()..add(const FetchLeadsRequested())),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localizationState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final colors = themeState.colors;
              return MaterialApp(
                title: 'Dholera Admin',
                locale: localizationState.locale,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('hi'),
                  Locale('mr'),
                  Locale('ta'),
                  Locale('te'),
                  Locale('kn'),
                ],
                theme: ThemeData(
                  scaffoldBackgroundColor: colors.background,
                  primaryColor: colors.primary,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: colors.primary,
                    surface: colors.card,
                    onSurface: colors.textPrimary,
                    secondary: colors.secondary,
                  ),
                  useMaterial3: true,
                ),
                home: const SplashPage(),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
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

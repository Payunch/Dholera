import 'package:dholera_admin_flutter/blocs/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:io';

import 'firebase_options.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/localization/localization_bloc.dart';
import 'blocs/localization/localization_event.dart';
import 'blocs/localization/localization_state.dart';
import 'blocs/preferences/preferences_bloc.dart';
import 'blocs/leads/leads_bloc.dart';
import 'blocs/leads/leads_event.dart';
import 'services/notification_service.dart';
import 'services/deep_link_service.dart';
import 'consent.dart';

import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in parallel where possible, but don't let them crash the app
  await Future.wait([
    _initFirebase(),
    _initAds(),
    ConsentManager.init(),
  ]);
  
  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Don't wait forever for App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    ).timeout(const Duration(seconds: 5), onTimeout: () => null);

    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
}

Future<void> _initAds() async {
  try {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await MobileAds.instance.initialize();
    }
  } catch (e) {
    debugPrint('Ads initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    DeepLinkService().initialize(_navigatorKey);
  }

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
              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Dholera Platform',
                debugShowCheckedModeBanner: false,
                theme: themeState.colors.toThemeData(),
                locale: localizationState.locale,
                home: const SplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}

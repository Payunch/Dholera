import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics? _analytics;

FirebaseAnalytics? get _safeAnalytics {
  if (_analytics != null) return _analytics;
  try {
    _analytics = FirebaseAnalytics.instance;
    return _analytics;
  } catch (_) {
    return null;
  }
}

Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
  final analytics = _safeAnalytics;
  if (analytics == null) return;
  await analytics.logEvent(name: name, parameters: parameters);
}

Future<void> setUserId(String? id) async {
  final analytics = _safeAnalytics;
  if (analytics == null) return;
  await analytics.setUserId(id: id);
}

Future<void> setUserProperty(String name, String value) async {
  final analytics = _safeAnalytics;
  if (analytics == null) return;
  await analytics.setUserProperty(name: name, value: value);
}

Future<void> logLogin({String method = 'unknown'}) async {
  final analytics = _safeAnalytics;
  if (analytics == null) return;
  await analytics.logLogin(loginMethod: method);
}

Future<void> logSignUp({String method = 'unknown'}) async {
  final analytics = _safeAnalytics;
  if (analytics == null) return;
  await analytics.logSignUp(signUpMethod: method);
}


import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
  await _analytics.logEvent(name: name, parameters: parameters);
}

Future<void> setUserId(String? id) async {
  await _analytics.setUserId(id: id);
}

Future<void> setUserProperty(String name, String value) async {
  await _analytics.setUserProperty(name: name, value: value);
}

Future<void> logLogin({String method = 'unknown'}) async {
  await _analytics.logLogin(loginMethod: method);
}

Future<void> logSignUp({String method = 'unknown'}) async {
  await _analytics.logSignUp(signUpMethod: method);
}


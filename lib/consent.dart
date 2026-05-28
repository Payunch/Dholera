import 'package:shared_preferences/shared_preferences.dart';

class ConsentManager {
  static const _kAnalyticsKey = 'consent_analytics';
  static const _kAdsKey = 'consent_ads';

  static SharedPreferences? _prefs;

  static bool? analyticsConsent;
  static bool? adsConsent;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs!.containsKey(_kAnalyticsKey)) {
      analyticsConsent = _prefs!.getBool(_kAnalyticsKey);
    }
    if (_prefs!.containsKey(_kAdsKey)) {
      adsConsent = _prefs!.getBool(_kAdsKey);
    }
  }

  static Future<void> setAnalyticsConsent(bool allowed) async {
    analyticsConsent = allowed;
    await _prefs?.setBool(_kAnalyticsKey, allowed);
  }

  static Future<void> setAdsConsent(bool allowed) async {
    adsConsent = allowed;
    await _prefs?.setBool(_kAdsKey, allowed);
  }

  static bool isConsentSet() {
    return analyticsConsent != null && adsConsent != null;
  }
}

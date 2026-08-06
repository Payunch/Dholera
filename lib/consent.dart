import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConsentManager {
  static const _kAnalyticsKey = 'consent_analytics';
  static const _kAdsKey = 'consent_ads';

  static const _storage = FlutterSecureStorage();

  static bool? analyticsConsent;
  static bool? adsConsent;

  static Future<void> init() async {
    final analytics = await _storage.read(key: _kAnalyticsKey);
    final ads = await _storage.read(key: _kAdsKey);
    
    if (analytics != null) {
      analyticsConsent = analytics == 'true';
    }
    if (ads != null) {
      adsConsent = ads == 'true';
    }
  }

  static Future<void> setAnalyticsConsent(bool allowed) async {
    analyticsConsent = allowed;
    await _storage.write(key: _kAnalyticsKey, value: allowed.toString());
  }

  static Future<void> setAdsConsent(bool allowed) async {
    adsConsent = allowed;
    await _storage.write(key: _kAdsKey, value: allowed.toString());
  }

  static bool isConsentSet() {
    return analyticsConsent != null && adsConsent != null;
  }
}

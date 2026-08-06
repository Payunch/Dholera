import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Use Google test ad unit IDs for development
  static String get bannerAdUnitId {
    // Test ad unit id for Android banner
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) { ad.dispose(); },
      ),
    );
  }

  static Future<InterstitialAd?> loadInterstitial() async {
    InterstitialAd? loaded;
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { loaded = ad; },
        onAdFailedToLoad: (error) {},
      ),
    );
    return loaded;
  }
}

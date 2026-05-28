import 'package:flutter/material.dart';
import '../consent.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';

class ConsentDialog extends StatefulWidget {
  const ConsentDialog({super.key});

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _analytics = false;
  bool _ads = false;

  @override
  void initState() {
    super.initState();
    _analytics = ConsentManager.analyticsConsent ?? false;
    _ads = ConsentManager.adsConsent ?? false;
  }

  Future<void> _saveAndClose() async {
    await ConsentManager.setAnalyticsConsent(_analytics);
    await ConsentManager.setAdsConsent(_ads);
    // Apply analytics setting
    try {
      // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(_analytics);
    } catch (_) {}
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Analytics & Ads Consent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Allow analytics and personalized ads to improve the app experience?'),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Analytics (GA4)'),
            value: _analytics,
            onChanged: (v) => setState(() => _analytics = v),
          ),
          SwitchListTile(
            title: const Text('Enable Personalized Ads (AdMob)'),
            value: _ads,
            onChanged: (v) => setState(() => _ads = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ConsentManager.setAnalyticsConsent(false);
            await ConsentManager.setAdsConsent(false);
            try {
              // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
            } catch (_) {}
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Reject All'),
        ),
        ElevatedButton(onPressed: _saveAndClose, child: const Text('Save')),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_event.dart';
import '../blocs/preferences/preferences_bloc.dart';
import '../blocs/preferences/preferences_event.dart';
import 'onboarding_page.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Choose your Language',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select your preferred language to continue',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageItem(context, 'English', 'English', const Locale('en')),
                    _buildLanguageItem(context, 'हिंदी', 'Hindi', const Locale('hi')),
                    _buildLanguageItem(context, 'मराठी', 'Marathi', const Locale('mr')),
                    _buildLanguageItem(context, 'தமிழ்', 'Tamil', const Locale('ta')),
                    _buildLanguageItem(context, 'తెలుగు', 'Telugu', const Locale('te')),
                    _buildLanguageItem(context, 'ಕನ್ನಡ', 'Kannada', const Locale('kn')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String name, String englishName, Locale locale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(englishName),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.read<LocalizationBloc>().add(LocalizationChanged(locale));
          context.read<PreferencesBloc>().add(LanguageSelected());
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingPage()),
          );
        },
      ),
    );
  }
}

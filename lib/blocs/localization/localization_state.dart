import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocalizationState extends Equatable {
  final Locale locale;
  final Map<String, String> translations;
  final bool isLoading;

  const LocalizationState({
    this.locale = const Locale('hi'),
    this.translations = const {},
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [locale, translations, isLoading];

  LocalizationState copyWith({
    Locale? locale,
    Map<String, String>? translations,
    bool? isLoading,
  }) {
    return LocalizationState(
      locale: locale ?? this.locale,
      translations: translations ?? this.translations,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String translate(String key) => translations[key] ?? key;
}

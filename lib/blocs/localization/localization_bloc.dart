import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'localization_event.dart';
import 'localization_state.dart';
import '../../services/api_service.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  final ApiService _apiService = ApiService();

  LocalizationBloc() : super(const LocalizationState()) {
    on<LocalizationChanged>(_onLocalizationChanged);
    on<LoadTranslations>(_onLoadTranslations);
  }

  Future<Map<String, String>> _loadLocalTranslations(String langCode) async {
    try {
      final String response = await rootBundle.loadString('assets/l10n/$langCode.json');
      final data = await json.decode(response);
      return Map<String, String>.from(data);
    } catch (e) {
      return {};
    }
  }

  Future<void> _onLocalizationChanged(LocalizationChanged event, Emitter<LocalizationState> emit) async {
    emit(state.copyWith(locale: event.locale, isLoading: true));
    
    // 1. Load Local first
    final localTranslations = await _loadLocalTranslations(event.locale.languageCode);
    emit(state.copyWith(translations: localTranslations));

    try {
      // 2. Sync with backend for updates
      final response = await _apiService.getTranslations(event.locale.languageCode);
      if (response['success'] == true) {
        final remoteTranslations = Map<String, String>.from(response['data'] ?? {});
        emit(state.copyWith(
          translations: {...localTranslations, ...remoteTranslations},
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
    
    // Sync with backend if logged in
    await _apiService.updatePreferences(language: event.locale.languageCode);
  }

  Future<void> _onLoadTranslations(LoadTranslations event, Emitter<LocalizationState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // 1. Load Local first
    final localTranslations = await _loadLocalTranslations(state.locale.languageCode);
    emit(state.copyWith(translations: localTranslations));

    try {
      final response = await _apiService.getTranslations(state.locale.languageCode);
      if (response['success'] == true) {
        final remoteTranslations = Map<String, String>.from(response['data'] ?? {});
        emit(state.copyWith(
          translations: {...localTranslations, ...remoteTranslations},
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}

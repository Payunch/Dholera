import 'package:flutter_bloc/flutter_bloc.dart';
import 'localization_event.dart';
import 'localization_state.dart';
import '../../services/api_service.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  final ApiService _apiService = ApiService();

  LocalizationBloc() : super(const LocalizationState()) {
    on<LocalizationChanged>(_onLocalizationChanged);
    on<LoadTranslations>(_onLoadTranslations);
  }

  Future<void> _onLocalizationChanged(LocalizationChanged event, Emit<LocalizationState> emit) async {
    emit(state.copyWith(locale: event.locale, isLoading: true));
    try {
      final response = await _apiService.getTranslations(event.locale.languageCode);
      if (response['success'] == true) {
        emit(state.copyWith(
          locale: event.locale,
          translations: Map<String, String>.from(response['data'] ?? {}),
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

  Future<void> _onLoadTranslations(LoadTranslations event, Emit<LocalizationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _apiService.getTranslations(state.locale.languageCode);
      if (response['success'] == true) {
        emit(state.copyWith(
          translations: Map<String, String>.from(response['data'] ?? {}),
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

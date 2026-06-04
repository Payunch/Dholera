import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'preferences_event.dart';
import 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final _storage = const FlutterSecureStorage();

  PreferencesBloc() : super(const PreferencesState()) {
    on<LanguageSelected>(_onLanguageSelected);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<LoadPreferences>(_onLoadPreferences);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final langSelected = await _storage.read(key: 'isLanguageSelected');
    final onboardingDone = await _storage.read(key: 'isOnboardingDone');
    
    add(LoadPreferences(
      isLanguageSelected: langSelected == 'true',
      isOnboardingDone: onboardingDone == 'true',
    ));
  }

  void _onLoadPreferences(LoadPreferences event, Emit<PreferencesState> emit) {
    emit(state.copyWith(
      isLanguageSelected: event.isLanguageSelected,
      isOnboardingDone: event.isOnboardingDone,
    ));
  }

  void _onLanguageSelected(LanguageSelected event, Emit<PreferencesState> emit) {
    emit(state.copyWith(isLanguageSelected: true));
    _storage.write(key: 'isLanguageSelected', value: 'true');
  }

  void _onOnboardingCompleted(OnboardingCompleted event, Emit<PreferencesState> emit) {
    emit(state.copyWith(isOnboardingDone: true));
    _storage.write(key: 'isOnboardingDone', value: 'true');
  }
}

// Add LoadPreferences event to preferences_event.dart if needed, or handle it here
class LoadPreferences extends PreferencesEvent {
  final bool isLanguageSelected;
  final bool isOnboardingDone;
  LoadPreferences({required this.isLanguageSelected, required this.isOnboardingDone});
}

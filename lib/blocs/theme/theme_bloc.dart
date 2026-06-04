import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../services/api_service.dart';
import '../../theme/board_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ApiService _apiService = ApiService();

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    emit(ThemeState(boardTheme: event.boardTheme));
    
    // Sync with backend if possible
    await _apiService.updatePreferences(
      theme: event.boardTheme == AppBoardTheme.blueBoard ? 'dark' : 'light'
    );
  }
}

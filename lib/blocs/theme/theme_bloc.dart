import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../services/api_service.dart';
import '../../theme/board_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  String _currentMode = 'auto'; // 'light', 'dark', 'auto'

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeChanged>(_onThemeChanged);
    on<AutoThemeRefresh>(_onAutoThemeRefresh);
    on<LoadThemePreference>(_onLoadThemePreference);
    
    _startTimer();
    add(LoadThemePreference());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_currentMode == 'auto') {
        add(AutoThemeRefresh());
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadThemePreference(LoadThemePreference event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    _currentMode = prefs.getString('theme_mode') ?? 'auto';
    
    if (_currentMode == 'auto') {
      _applyAutoTheme(emit);
    } else {
      final theme = _currentMode == 'dark' ? AppBoardTheme.blueBoard : AppBoardTheme.standard;
      emit(ThemeState(boardTheme: theme));
    }
  }

  void _onAutoThemeRefresh(AutoThemeRefresh event, Emitter<ThemeState> emit) {
    if (_currentMode == 'auto') {
      _applyAutoTheme(emit);
    }
  }

  void _applyAutoTheme(Emitter<ThemeState> emit) {
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;
    final targetTheme = isNight ? AppBoardTheme.blueBoard : AppBoardTheme.standard;
    
    if (state.boardTheme != targetTheme) {
      emit(ThemeState(boardTheme: targetTheme));
    }
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    emit(ThemeState(boardTheme: event.boardTheme));
    
    _currentMode = event.boardTheme == AppBoardTheme.blueBoard ? 'dark' : 'light';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _currentMode);
    
    // Sync with backend if possible
    await _apiService.updatePreferences(
      theme: _currentMode
    );
  }
}

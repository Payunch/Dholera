import 'package:equatable/equatable.dart';
import '../../theme/board_theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final AppBoardTheme boardTheme;
  const ThemeChanged(this.boardTheme);
  @override
  List<Object?> get props => [boardTheme];
}

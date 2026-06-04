import 'package:equatable/equatable.dart';
import '../../theme/board_theme.dart';

class ThemeState extends Equatable {
  final AppBoardTheme boardTheme;

  const ThemeState({this.boardTheme = AppBoardTheme.blueBoard});

  BoardThemeData get colors => boardTheme == AppBoardTheme.blueBoard 
      ? BoardThemeData.blueBoard() 
      : BoardThemeData.beigeBoard();

  @override
  List<Object?> get props => [boardTheme];

  Map<String, dynamic> toJson() => {'boardTheme': boardTheme.index};

  factory ThemeState.fromJson(Map<String, dynamic> json) => ThemeState(
        boardTheme: AppBoardTheme.values[json['boardTheme'] as int? ?? 0],
      );
}

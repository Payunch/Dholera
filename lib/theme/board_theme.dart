import 'package:flutter/material.dart';

enum AppBoardTheme { blueBoard, beigeBoard, standard }

class BoardThemeData {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;
  final Color dialog;
  final Color bottomNav;
  final Color refreshIndicator;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const BoardThemeData({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
    required this.dialog,
    required this.bottomNav,
    required this.refreshIndicator,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static BoardThemeData blueBoard() {
    return const BoardThemeData(
      background: Color(0xFF0B132B),
      primary: Color(0xFFFF7A00),
      secondary: Color(0xFF1C2541),
      card: Color(0xFF1C2541),
      textPrimary: Colors.white,
      textSecondary: Color(0xFF5BC0BE),
      border: Color(0xFF3A506B),
      divider: Color(0xFF3A506B),
      dialog: Color(0xFF1C2541),
      bottomNav: Color(0xFF0B132B),
      refreshIndicator: Color(0xFFFF7A00),
      shimmerBase: Color(0xFF1C2541),
      shimmerHighlight: Color(0xFF3A506B),
    );
  }

  static BoardThemeData beigeBoard() {
    return const BoardThemeData(
      background: Color(0xFFF5F5DC),
      primary: Color(0xFF8B4513),
      secondary: Color(0xFFD2B48C),
      card: Colors.white,
      textPrimary: Color(0xFF2F4F4F),
      textSecondary: Color(0xFF556B2F),
      border: Color(0xFFDEB887),
      divider: Color(0xFFDEB887),
      dialog: Colors.white,
      bottomNav: Color(0xFFF5F5DC),
      refreshIndicator: Color(0xFF8B4513),
      shimmerBase: Color(0xFFE5E5CA),
      shimmerHighlight: Color(0xFFF5F5DC),
    );
  }

  static BoardThemeData standard() => blueBoard();

  ThemeData toThemeData() {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: divider,
      dialogBackgroundColor: dialog,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: background.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
      ).copyWith(
        primary: primary,
        secondary: secondary,
        surface: card,
      ),
    );
  }
}

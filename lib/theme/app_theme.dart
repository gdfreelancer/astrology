import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFBF5);
  static const Color ink = Color(0xFF302B3D);
  static const Color muted = Color(0xFF898393);
  static const Color plum = Color(0xFF7255A5);
  static const Color saffron = Color(0xFFE5A34B);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: plum,
        brightness: Brightness.light,
        surface: background,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

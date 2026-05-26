import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg         = Color(0xFF0B0F1A);
  static const surface    = Color(0xFF111827);
  static const surface2   = Color(0xFF1A2236);
  static const border     = Color(0xFF1E2D45);
  static const teamA      = Color(0xFFF59E0B);
  static const teamALight = Color(0xFFFCD34D);
  static const teamB      = Color(0xFF38BDF8);
  static const teamBLight = Color(0xFF7DD3FC);
  static const net        = Color(0xFFE2E8F0);
  static const courtMain  = Color(0xFFC4833A);
  static const courtDark  = Color(0xFFB87530);
  static const lineColor  = Colors.white;
  static const textMain   = Color(0xFFF1F5F9);
  static const muted      = Color(0xFF64748B);
  static const deuce      = Color(0xFFEF4444);
  static const advantage  = Color(0xFF10B981);
  static const setter     = Color(0xFFF59E0B);
  static const libero     = Color(0xFF34D399);
  static const middleB    = Color(0xFFA78BFA);
  static const outside    = Color(0xFF60A5FA);
  static const warning    = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.teamA,
      secondary: AppColors.teamB,
      surface: AppColors.surface,
      error: AppColors.deuce,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.textMain, displayColor: AppColors.textMain),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      foregroundColor: AppColors.textMain,
    ),
    // FIX: Changed CardTheme to CardThemeData
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerColor: AppColors.border,
    useMaterial3: true,
  );

  static TextStyle get bebasH1 => GoogleFonts.bebasNeue(
    fontSize: 42, letterSpacing: 2, color: AppColors.textMain,
  );

  static TextStyle get bebasH2 => GoogleFonts.bebasNeue(
    fontSize: 26, letterSpacing: 1.5, color: AppColors.textMain,
  );

  static TextStyle get bebasH3 => GoogleFonts.bebasNeue(
    fontSize: 18, letterSpacing: 1, color: AppColors.textMain,
  );

  static TextStyle get mono => GoogleFonts.dmMono(
    fontSize: 11, color: AppColors.textMain,
  );

  static TextStyle get monoMuted => GoogleFonts.dmMono(
    fontSize: 11, color: AppColors.muted,
  );
}
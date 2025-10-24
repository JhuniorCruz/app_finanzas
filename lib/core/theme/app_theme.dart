import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color.fromARGB(255, 48, 50, 191);
  //static const primary = Color(0xFF6366F1);
  static const accent = Color(0xFF10B981);
  static const destructive = Color(0xFFEF4444);
  static const background = Color(0xFFF8F9FC);
  static const foreground = Color(0xFF1E293B);
  static const border = Color(0xFFE2E8F0);
  static const inputBg = Color(0xFFF8FAFC);
  static const switchTrack = Color(0xFFCBD5E1);

  // Gradientes KPI (aprox)
  static const kpiGoodFrom = Color(0xFFEFFDF5);
  static const kpiGoodTo = Color(0xE6D1F7E8);
  static const kpiWarnFrom = Color(0xFFFFF7E8);
  static const kpiWarnTo = Color(0xE6FFE7B5);
  static const kpiDangerFrom = Color(0xFFFFEBEE);
  static const kpiDangerTo = Color(0xE6FFCDD2);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.destructive,
      background: AppColors.background,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.foreground,
      onSurface: AppColors.foreground,
      onError: Colors.white,
    ),
  );

  final inter = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
    labelMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
  );
  // Fuerza color de texto global oscuro
  final textTheme = inter.apply(
    bodyColor: AppColors.foreground,
    displayColor: AppColors.foreground,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.border, width: 2),
      ),
    ),

    // === Inputs globales (labels/hints/prefix/íconos visibles) ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

      labelStyle: const TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),

      prefixStyle: const TextStyle(
        color: Color(0xFF475569),
        fontWeight: FontWeight.w600,
      ),
      suffixIconColor: const Color(0xFF94A3B8),
      prefixIconColor: const Color(0xFF94A3B8),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    // Botones globales
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        minimumSize: const Size.fromHeight(56),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        minimumSize: const Size.fromHeight(56),
        backgroundColor: Colors.white,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        minimumSize: const Size.fromHeight(56),
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
    ),

    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith(
        (_) => AppColors.switchTrack,
      ),
      thumbColor: MaterialStateProperty.resolveWith((_) => Colors.white),
    ),

    dividerColor: AppColors.border,
  );
}

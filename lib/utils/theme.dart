// ثيم التطبيق — مطابق لألوان الموقع الأصلي
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  // خط العناوين — Changa
  static TextStyle get headingFont => GoogleFonts.changa(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  // خط النصوص — IBM Plex Sans Arabic
  static TextStyle get bodyFont => GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.grass,
          secondary: AppColors.amber,
          surface: AppColors.surface,
          error: AppColors.red,
          onPrimary: Color(0xFF07130A),
          onSurface: AppColors.ink,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.changa(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          headlineMedium: GoogleFonts.changa(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleLarge: GoogleFonts.changa(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleMedium: GoogleFonts.changa(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyLarge: GoogleFonts.ibmPlexSansArabic(color: AppColors.ink),
          bodyMedium: GoogleFonts.ibmPlexSansArabic(color: AppColors.ink),
          bodySmall: GoogleFonts.ibmPlexSansArabic(color: AppColors.muted),
          labelLarge: GoogleFonts.changa(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bg.withOpacity(0.85),
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.changa(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.ink,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.line),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintStyle: GoogleFonts.ibmPlexSansArabic(color: AppColors.faint),
          labelStyle:
              GoogleFonts.ibmPlexSansArabic(color: AppColors.muted, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lineStrong),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lineStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grass, width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.grass,
          unselectedItemColor: AppColors.faint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.line,
        iconTheme: const IconThemeData(color: AppColors.ink),
      );

  // خط العناوين المساعد
  static TextStyle heading({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.changa(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.ink,
      );

  // خط النصوص المساعد
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.ibmPlexSansArabic(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.ink,
        height: height,
      );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';

/// Tema Cartoonesco do Aplicativo RM Guide
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.spaceDark,
      primaryColor: AppColors.portalGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.portalGreen,
        secondary: AppColors.portalLime,
        tertiary: AppColors.mortyYellow,
        surface: AppColors.spaceCard,
        error: AppColors.errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.creepster(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.portalGreen,
          letterSpacing: 2.0,
        ),
        headlineLarge: GoogleFonts.bangers(
          fontSize: 28,
          color: AppColors.portalGreen,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.bangers(
          fontSize: 22,
          color: AppColors.mortyYellow,
          letterSpacing: 1.2,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.spaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bangers(
          fontSize: 24,
          color: AppColors.portalGreen,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.portalGreen, size: 26),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.portalGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          textStyle: GoogleFonts.bangers(
            fontSize: 18,
            letterSpacing: 1.2,
          ),
          elevation: 4,
          shadowColor: AppColors.portalGlow.withValues(alpha: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.spaceCardLight,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.portalLime,
        suffixIconColor: AppColors.portalLime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.portalGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.portalLime.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.portalGreen, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),
    );
  }
}

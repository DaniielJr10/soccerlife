import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Tema oscuro profesional de SoccerLife.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary:       AppColors.primary,
        secondary:     AppColors.secondary,
        surface:       AppColors.surface,
        error:         AppColors.danger,
        onPrimary:     AppColors.textOnPrimary,
        onSecondary:   AppColors.textPrimary,
        onSurface:     AppColors.textPrimary,
        onError:       AppColors.textPrimary,
      ),
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium:   TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:    TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge:     TextStyle(color: AppColors.textPrimary,   fontSize: 15),
        bodyMedium:    TextStyle(color: AppColors.textSecondary, fontSize: 14),
        bodySmall:     TextStyle(color: AppColors.textMuted,     fontSize: 12),
        labelLarge:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600),
        labelMedium:   TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }
}

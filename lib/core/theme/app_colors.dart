import 'package:flutter/material.dart';

/// Paleta de colores centralizada de SoccerLife.
/// Inspirada en herramientas de análisis deportivo profesional.
class AppColors {
  AppColors._();

  // Fondos
  static const Color background     = Color(0xFF0A0E1A);
  static const Color surface        = Color(0xFF111827);
  static const Color surfaceAlt     = Color(0xFF1A2235);
  static const Color card           = Color(0xFF1E2D40);

  // Acento principal — verde esmeralda deportivo
  static const Color primary        = Color(0xFF00D4AA);
  static const Color primaryDark    = Color(0xFF009E7F);
  static const Color primaryLight   = Color(0xFF4DFFD9);

  // Acento secundario — azul eléctrico
  static const Color secondary      = Color(0xFF3B82F6);
  static const Color secondaryDark  = Color(0xFF1D4ED8);

  // Semáforo de métricas
  static const Color success        = Color(0xFF22C55E);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color danger         = Color(0xFFEF4444);
  static const Color info           = Color(0xFF06B6D4);

  // Tarjetas de fútbol
  static const Color cardYellow     = Color(0xFFF59E0B);
  static const Color cardRed        = Color(0xFFEF4444);

  // Texto
  static const Color textPrimary    = Color(0xFFF1F5F9);
  static const Color textSecondary  = Color(0xFF94A3B8);
  static const Color textMuted      = Color(0xFF475569);
  static const Color textOnPrimary  = Color(0xFF0A0E1A);

  // Bordes
  static const Color border         = Color(0xFF243044);
  static const Color borderLight    = Color(0xFF2D3F56);

  // Gradientes listos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [card, surfaceAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

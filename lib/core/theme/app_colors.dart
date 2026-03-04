import 'package:flutter/material.dart';

/// Paleta de colores centralizada de SoccerLife — tema claro profesional.
/// Versión 2.0 — paleta más vibrante y moderna.
class AppColors {
  AppColors._();

  // ── Fondos ─────────────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF0F4F8);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceAlt     = Color(0xFFF8FAFC);
  static const Color card           = Color(0xFFFFFFFF);

  // ── Acento principal — verde esmeralda deportivo ───────────────────────────
  static const Color primary        = Color(0xFF059669);
  static const Color primaryDark    = Color(0xFF047857);
  static const Color primaryLight   = Color(0xFF34D399);

  // ── Acento secundario — azul índigo ───────────────────────────────────────
  static const Color secondary      = Color(0xFF4F46E5);
  static const Color secondaryDark  = Color(0xFF3730A3);
  static const Color secondaryLight = Color(0xFF818CF8);

  // ── Semáforo de métricas ──────────────────────────────────────────────────
  static const Color success        = Color(0xFF10B981);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color danger         = Color(0xFFEF4444);
  static const Color info           = Color(0xFF0EA5E9);

  // ── Tarjetas de fútbol ────────────────────────────────────────────────────
  static const Color cardYellow     = Color(0xFFF59E0B);
  static const Color cardRed        = Color(0xFFEF4444);

  // ── Texto ─────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF475569);
  static const Color textMuted      = Color(0xFF94A3B8);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ── Bordes ────────────────────────────────────────────────────────────────
  static const Color border         = Color(0xFFE2E8F0);
  static const Color borderLight    = Color(0xFFF1F5F9);

  // ── Sombras ───────────────────────────────────────────────────────────────
  static const Color shadow         = Color(0x14000000);
  static const Color shadowMedium   = Color(0x1F000000);

  // ── Gradientes listos ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF253656), Color(0xFF1a2a4a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── BoxShadows reutilizables ───────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(color: shadow, blurRadius: 12, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get buttonShadow => [
    const BoxShadow(color: shadow, blurRadius: 8, offset: Offset(0, 3)),
  ];
}

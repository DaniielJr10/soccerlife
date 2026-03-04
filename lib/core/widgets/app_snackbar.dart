import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utilidad centralizada de SnackBars con diseño consistente.
///
/// Uso:
/// ```dart
/// AppSnackbar.exito(context, '¡Guardado correctamente!');
/// AppSnackbar.error(context, 'Error de conexión');
/// AppSnackbar.info(context, 'Procesando...');
/// ```
class AppSnackbar {
  AppSnackbar._();

  // ── Éxito ──────────────────────────────────────────────────────────────────
  static void exito(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje: mensaje,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  static void error(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje: mensaje,
      color: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  // ── Advertencia ───────────────────────────────────────────────────────────
  static void advertencia(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje: mensaje,
      color: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  // ── Informativo ───────────────────────────────────────────────────────────
  static void info(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje: mensaje,
      color: AppColors.info,
      icon: Icons.info_outline_rounded,
    );
  }

  // ── Implementación interna ─────────────────────────────────────────────────
  static void _mostrar(
    BuildContext context, {
    required String mensaje,
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          elevation: 4,
        ),
      );
  }
}

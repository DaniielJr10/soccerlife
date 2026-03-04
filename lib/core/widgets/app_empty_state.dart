import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Estado vacío reutilizable con ícono, título, subtítulo y acción opcional.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: color, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 28),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../statistics/domain/entities/statistics_entity.dart';

/// Fila de 3 métricas clave que aparece justo debajo del header.
class QuickStatsWidget extends StatelessWidget {
  final StatisticsEntity stats;
  final int partidosCount;

  const QuickStatsWidget({
    super.key,
    required this.stats,
    required this.partidosCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _QuickStat(
            value: partidosCount.toString(),
            label: 'Partidos',
            icon: Icons.sports_soccer_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _QuickStat(
            value: stats.goles.toString(),
            label: 'Goles',
            icon: Icons.sports_soccer,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          _QuickStat(
            value: stats.asistencias.toString(),
            label: 'Asistencias',
            icon: Icons.sports_handball_rounded,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

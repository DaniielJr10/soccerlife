import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../matches/domain/entities/match_entity.dart';

/// Ítem compacto de partido reciente para el dashboard.
class RecentMatchItem extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback? onTap;

  const RecentMatchItem({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final resultado = match.resultado;
    final resultColor = _resultColor(resultado);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Resultado badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  resultado ?? '—',
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs ${match.rival}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _formatDate(match.fecha),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (match.competicion.isNotEmpty) ...[
                        const Text(
                          ' · ',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        Text(
                          match.competicion,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Score
            if (match.golesLocal != null)
              Text(
                '${match.golesLocal} - ${match.golesVisitante}',
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color _resultColor(String? r) {
    if (r == 'V') return AppColors.success;
    if (r == 'D') return AppColors.danger;
    if (r == 'E') return AppColors.warning;
    return AppColors.textMuted;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

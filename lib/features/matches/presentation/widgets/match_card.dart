import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';

/// Tarjeta de partido para la lista de Partidos.
class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final resultado  = match.resultado;
    final badgeColor = _resultColor(resultado);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _ResultBadge(resultado: resultado, color: badgeColor),
            const SizedBox(width: 14),
            Expanded(child: _MatchInfo(match: match)),
            _Metrics(match: match),
            if (onEdit != null)
              _EditButton(onEdit: onEdit!),
            if (onDelete != null)
              _DeleteButton(onDelete: onDelete!),
          ],
        ),
      ),
    );
  }

  static Color _resultColor(String? r) {
    if (r == 'V') return AppColors.success;
    if (r == 'D') return AppColors.danger;
    if (r == 'E') return AppColors.warning;
    return AppColors.textMuted;
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _ResultBadge extends StatelessWidget {
  final String? resultado;
  final Color color;
  const _ResultBadge({required this.resultado, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          resultado ?? '—',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _MatchInfo extends StatelessWidget {
  final MatchEntity match;
  const _MatchInfo({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vs ${match.rival}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _TagRow(match: match),
        const SizedBox(height: 4),
        _DateRow(fecha: match.fecha),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  final MatchEntity match;
  const _TagRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        _Tag(label: match.tipo, color: AppColors.secondary),
        if (match.competicion.isNotEmpty)
          _Tag(label: match.competicion, color: AppColors.primary),
        if (match.posicion.isNotEmpty)
          _Tag(label: match.posicion, color: AppColors.info),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime fecha;
  const _DateRow({required this.fecha});

  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    return Text(
      '${fecha.day} ${_months[fecha.month - 1]} ${fecha.year}',
      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    );
  }
}

class _Metrics extends StatelessWidget {
  final MatchEntity match;
  const _Metrics({required this.match});

  @override
  Widget build(BuildContext context) {
    if (!match.esFinalizado) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.schedule_rounded, color: AppColors.textMuted, size: 18),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (match.golesLocal != null)
            Text(
              '${match.golesLocal}–${match.golesVisitante}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: AppColors.primary, size: 12),
              Text(
                ' ${match.goles}  ',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Icon(Icons.sports_handball_rounded,
                  color: AppColors.success, size: 12),
              Text(
                ' ${match.asistencias}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onEdit;
  const _EditButton({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit_outlined, size: 20),
      color: AppColors.primary,
      onPressed: onEdit,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded, size: 20),
      color: AppColors.danger,
      onPressed: onDelete,
      visualDensity: VisualDensity.compact,
    );
  }
}

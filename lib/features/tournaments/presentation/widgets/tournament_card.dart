import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament_entity.dart';

/// Tarjeta visual de un torneo en la lista.
class TournamentCard extends StatelessWidget {
  final TournamentEntity torneo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TournamentCard({
    super.key,
    required this.torneo,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = torneo.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono con color del torneo
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: color.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.emoji_events_rounded,
                        color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          torneo.nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (torneo.descripcion.isNotEmpty) ...
                          [
                            const SizedBox(height: 2),
                            Text(
                              torneo.descripcion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                      ],
                    ),
                  ),
                  _StatusChip(activo: torneo.estaActivo, color: color),
                  PopupMenuButton<String>(
                    color: AppColors.surface,
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onSelected: (v) {
                      if (v == 'edit') onEdit?.call();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Editar',
                              style:
                                  TextStyle(color: AppColors.textPrimary)),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded,
                              color: AppColors.danger, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style:
                                  TextStyle(color: AppColors.danger)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Barra separadora con gradiente del color del torneo
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _DateRow(torneo: torneo),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool activo;
  final Color color;
  const _StatusChip({required this.activo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        activo ? 'Activo' : 'Finalizado',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final TournamentEntity torneo;
  const _DateRow({required this.torneo});

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded,
            size: 11, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '${_fmt(torneo.fechaInicio)}  →  ${_fmt(torneo.fechaFin)}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

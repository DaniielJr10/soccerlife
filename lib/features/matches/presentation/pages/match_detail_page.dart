import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';

/// Vista detallada de un partido con todas sus estadísticas.
class MatchDetailPage extends StatelessWidget {
  final MatchEntity match;

  const MatchDetailPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final resultado = match.resultado;
    final resultColor = _resultColor(resultado);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('vs ${match.rival}'),
        leading: const BackButton(color: AppColors.textSecondary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildScoreCard(resultado, resultColor),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Estadísticas del partido'),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildPrecisionCard(),
          if (match.notas != null && match.notas!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard(String? resultado, Color resultColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [resultColor.withOpacity(0.2), AppColors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: resultColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                match.golesLocal?.toString() ?? '—',
                style: TextStyle(
                  color: resultColor,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '–',
                  style: TextStyle(
                    color: resultColor.withOpacity(0.6),
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Text(
                match.golesVisitante?.toString() ?? '—',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _resultLabel(resultado),
              style: TextStyle(
                color: resultColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.calendar_today_rounded, label: 'Fecha',
              value: _formatDate(match.fecha)),
          _Divider(),
          _InfoRow(icon: Icons.access_time_rounded, label: 'Hora',
              value: match.hora),
          if (match.lugar.isNotEmpty) ...[
            _Divider(),
            _InfoRow(icon: Icons.place_rounded, label: 'Lugar', value: match.lugar),
          ],
          if (match.tipo.isNotEmpty) ...[
            _Divider(),
            _InfoRow(icon: Icons.category_rounded, label: 'Tipo', value: match.tipo),
          ],
          if (match.competicion.isNotEmpty) ...[
            _Divider(),
            _InfoRow(icon: Icons.emoji_events_rounded, label: 'Competición',
                value: match.competicion),
          ],
          if (match.posicion.isNotEmpty) ...[
            _Divider(),
            _InfoRow(icon: Icons.person_pin_rounded, label: 'Posición',
                value: match.posicion),
          ],
          _Divider(),
          _InfoRow(icon: Icons.timer_rounded, label: 'Minutos jugados',
              value: '${match.minutosJugados} min'),
          if (match.valoracion != null) ...[
            _Divider(),
            _InfoRow(
              icon: Icons.star_rounded,
              label: 'Valoración',
              value: match.valoracion!.toStringAsFixed(1),
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      _StatItem('Goles',           match.goles,            Icons.sports_soccer,                AppColors.primary),
      _StatItem('Asistencias',     match.asistencias,      Icons.sports_handball_rounded,       AppColors.secondary),
      _StatItem('Remates',         match.remates,          Icons.ads_click_rounded,             AppColors.info),
      _StatItem('Al arco',         match.rematesAlArco,    Icons.gps_fixed_rounded,             AppColors.success),
      _StatItem('Pases ✓',         match.pasesCompletados, Icons.check_circle_outline_rounded,  AppColors.success),
      _StatItem('Pases ✗',         match.pasesFallidos,    Icons.cancel_outlined,               AppColors.danger),
      _StatItem('Regates ✓',       match.regatesExitosos,  Icons.directions_run_rounded,        AppColors.primary),
      _StatItem('Regates ✗',       match.regatesFallidos,  Icons.remove_circle_outline_rounded, AppColors.warning),
      _StatItem('Faltas comet.',   match.faltasCometidas,  Icons.warning_amber_rounded,         AppColors.warning),
      _StatItem('Faltas recib.',   match.faltasRecibidas,  Icons.medical_services_rounded,      AppColors.info),
      _StatItem('T. Amarillas',    match.tarjetasAmarillas,Icons.square_rounded,                AppColors.cardYellow),
      _StatItem('T. Rojas',        match.tarjetasRojas,    Icons.square_rounded,                AppColors.cardRed),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatGridTile(item: items[i]),
    );
  }

  Widget _buildPrecisionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Precisión',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 14),
          _PrecisionRow('Remates al arco', match.precisionRemates,
              AppColors.secondary),
          const SizedBox(height: 10),
          _PrecisionRow('Pases completados', match.precisionPases,
              AppColors.primary),
          const SizedBox(height: 10),
          _PrecisionRow('Regates exitosos', match.precisionRegates,
              AppColors.success),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notas',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 8),
          Text(match.notas!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Color _resultColor(String? r) {
    if (r == 'V') return AppColors.success;
    if (r == 'D') return AppColors.danger;
    if (r == 'E') return AppColors.warning;
    return AppColors.textMuted;
  }

  String _resultLabel(String? r) {
    if (r == 'V') return 'VICTORIA';
    if (r == 'D') return 'DERROTA';
    if (r == 'E') return 'EMPATE';
    return 'SIN RESULTADO';
  }

  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 16),
          const SizedBox(width: 10),
          Text(label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
      color: AppColors.border, height: 1, thickness: 1);
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatGridTile extends StatelessWidget {
  final _StatItem item;
  const _StatGridTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.value > 0
            ? item.color.withOpacity(0.08)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.value > 0 ? item.color.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 18),
          const SizedBox(height: 4),
          Text(
            item.value.toString(),
            style: TextStyle(
              color: item.value > 0 ? item.color : AppColors.textMuted,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            item.label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PrecisionRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _PrecisionRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 100)) / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

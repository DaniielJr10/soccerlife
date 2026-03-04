import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../matches/application/providers/match_provider.dart';
import '../../application/providers/statistics_provider.dart';
import '../../domain/entities/statistics_entity.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/stat_progress_row.dart';

/// Página completa de estadísticas acumuladas del jugador.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().load();
      final mp = context.read<MatchProvider>();
      if (mp.played.isEmpty) mp.loadPlayed();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Estadísticas',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Ofensiva'),
            Tab(text: 'General'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            onPressed: () {
              context.read<StatisticsProvider>().load();
              context.read<MatchProvider>().loadPlayed();
            },
          ),
        ],
      ),
      body: Consumer2<StatisticsProvider, MatchProvider>(
        builder: (_, provider, matchProvider, __) {
          if (provider.isLoading) {
            return const AppLoading(message: 'Cargando estadísticas...');
          }
          if (provider.status == StatsStatus.error) {
            return AppErrorView(
              message: provider.errorMessage ?? 'Error desconocido',
              onRetry: provider.load,
            );
          }
          final partidosCount = matchProvider.played.length;
          return TabBarView(
            controller: _tabs,
            children: [
              _SummaryTab(stats: provider.stats, partidosCount: partidosCount),
              _OffensiveTab(stats: provider.stats),
              _GeneralTab(stats: provider.stats, partidosCount: partidosCount),
            ],
          );
        },
      ),
    );
  }
}

// ── Tab: Resumen ─────────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  final StatisticsEntity stats;
  final int partidosCount;
  const _SummaryTab({required this.stats, required this.partidosCount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _ResultDistCard(stats: stats, partidosCount: partidosCount),
        const SizedBox(height: 16),
        RadarChartWidget(stats: stats),
        const SizedBox(height: 16),
        _StatGroupCard(
          title: 'Contribución ofensiva',
          children: [
            _BigStat(
              value: stats.goles.toString(),
              label: 'Goles',
              sub: '${stats.golesPorPartido.toStringAsFixed(2)} por partido',
              color: AppColors.primary,
              icon: Icons.sports_soccer,
            ),
            _BigStat(
              value: stats.asistencias.toString(),
              label: 'Asistencias',
              sub: partidosCount > 0
                  ? '${(stats.asistencias / partidosCount).toStringAsFixed(2)} por partido'
                  : '—',
              color: AppColors.secondary,
              icon: Icons.sports_handball_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatGroupCard(
          title: 'Tiempo de juego',
          children: [
            _BigStat(
              value: stats.minutosFormateados,
              label: 'Total',
              sub: partidosCount > 0
                  ? '${(stats.minutosJugados / partidosCount).toStringAsFixed(0)} min/partido'
                  : '—',
              color: AppColors.info,
              icon: Icons.timer_rounded,
            ),
            _BigStat(
              value: stats.valoracionPromedio > 0
                  ? stats.valoracionPromedio.toStringAsFixed(1)
                  : '—',
              label: 'Rating prom.',
              sub: 'sobre 10',
              color: AppColors.warning,
              icon: Icons.star_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DisciplineCard(stats: stats),
      ],
    );
  }
}

// ── Tab: Ofensiva ────────────────────────────────────────────────────────────

class _OffensiveTab extends StatelessWidget {
  final StatisticsEntity stats;
  const _OffensiveTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _StatCard(
          title: 'Remates',
          children: [
            StatProgressRow(
              label: 'Total remates',
              value: stats.remates.toString(),
              progress: stats.remates / (stats.remates == 0 ? 1 : stats.remates),
              color: AppColors.info,
            ),
            StatProgressRow(
              label: 'Al arco',
              value: stats.rematesAlArco.toString(),
              progress: stats.precisionRemates / 100,
              color: AppColors.success,
              detail: '${stats.precisionRemates.toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatCard(
          title: 'Pases',
          children: [
            StatProgressRow(
              label: 'Completados',
              value: stats.pasesCompletados.toString(),
              progress: stats.precisionPases / 100,
              color: AppColors.primary,
              detail: '${stats.precisionPases.toStringAsFixed(1)}%',
            ),
            StatProgressRow(
              label: 'Fallidos',
              value: stats.pasesFallidos.toString(),
              progress: stats.pasesFallidos /
                  ((stats.pasesCompletados + stats.pasesFallidos) == 0
                      ? 1
                      : (stats.pasesCompletados + stats.pasesFallidos)),
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatCard(
          title: 'Regates',
          children: [
            StatProgressRow(
              label: 'Exitosos',
              value: stats.regatesExitosos.toString(),
              progress: stats.precisionRegates / 100,
              color: AppColors.success,
              detail: '${stats.precisionRegates.toStringAsFixed(1)}%',
            ),
            StatProgressRow(
              label: 'Fallidos',
              value: stats.regatesFallidos.toString(),
              progress: stats.regatesFallidos /
                  ((stats.regatesExitosos + stats.regatesFallidos) == 0
                      ? 1
                      : (stats.regatesExitosos + stats.regatesFallidos)),
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Tab: General ─────────────────────────────────────────────────────────────

class _GeneralTab extends StatelessWidget {
  final StatisticsEntity stats;
  final int partidosCount;
  const _GeneralTab({required this.stats, required this.partidosCount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _StatCard(
          title: 'Faltas',
          children: [
            StatProgressRow(
              label: 'Cometidas',
              value: stats.faltasCometidas.toString(),
              progress: stats.faltasCometidas /
                  ((stats.faltasCometidas + stats.faltasRecibidas) == 0
                      ? 1
                      : (stats.faltasCometidas + stats.faltasRecibidas)),
              color: AppColors.warning,
            ),
            StatProgressRow(
              label: 'Recibidas',
              value: stats.faltasRecibidas.toString(),
              progress: stats.faltasRecibidas /
                  ((stats.faltasCometidas + stats.faltasRecibidas) == 0
                      ? 1
                      : (stats.faltasCometidas + stats.faltasRecibidas)),
              color: AppColors.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatCard(
          title: 'Disciplina',
          children: [
            StatProgressRow(
              label: 'Tarjetas amarillas',
              value: stats.tarjetasAmarillas.toString(),
              progress: stats.tarjetasAmarillas /
                  (partidosCount == 0 ? 1 : partidosCount),
              color: AppColors.cardYellow,
            ),
            StatProgressRow(
              label: 'Tarjetas rojas',
              value: stats.tarjetasRojas.toString(),
              progress: stats.tarjetasRojas /
                  (partidosCount == 0 ? 1 : partidosCount),
              color: AppColors.cardRed,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AllTimeCard(stats: stats, partidosCount: partidosCount),
      ],
    );
  }
}

// ── Widgets compartidos ──────────────────────────────────────────────────────

class _ResultDistCard extends StatelessWidget {
  final StatisticsEntity stats;
  final int partidosCount;
  const _ResultDistCard({required this.stats, required this.partidosCount});

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resultados',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Text('$partidosCount partidos',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ResultPill('V', stats.partidosGanados, AppColors.success),
              const SizedBox(width: 8),
              _ResultPill('E', stats.partidosEmpatados, AppColors.warning),
              const SizedBox(width: 8),
              _ResultPill('D', stats.partidosPerdidos, AppColors.danger),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: stats.partidosGanados,
                    child: Container(color: AppColors.success),
                  ),
                  Flexible(
                    flex: stats.partidosEmpatados,
                    child: Container(color: AppColors.warning),
                  ),
                  Flexible(
                    flex: stats.partidosPerdidos,
                    child: Container(color: AppColors.danger),
                  ),
                  if (partidosCount == 0)
                    Flexible(
                      flex: 1,
                      child: Container(color: AppColors.border),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Efectividad: ${stats.porcentajeVictorias.toStringAsFixed(1)}%',
            style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _ResultPill(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(count.toString(),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 22)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _StatGroupCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 14),
          Row(
            children: children
                .map((c) => Expanded(child: c))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  final String sub;
  final Color color;
  final IconData icon;
  const _BigStat({
    required this.value,
    required this.label,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 32, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        Text(sub,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  final StatisticsEntity stats;
  const _DisciplineCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DisciplineItem(
              count: stats.tarjetasAmarillas,
              label: 'T. Amarillas',
              color: AppColors.cardYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DisciplineItem(
              count: stats.tarjetasRojas,
              label: 'T. Rojas',
              color: AppColors.cardRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DisciplineItem(
              count: stats.faltasCometidas,
              label: 'Faltas com.',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _DisciplineItem(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _StatCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _AllTimeCard extends StatelessWidget {
  final StatisticsEntity stats;
  final int partidosCount;
  const _AllTimeCard({required this.stats, required this.partidosCount});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Partidos jugados', partidosCount.toString()),
      ('Goles totales',    stats.goles.toString()),
      ('Asistencias',      stats.asistencias.toString()),
      ('Remates',          stats.remates.toString()),
      ('Remates al arco',  stats.rematesAlArco.toString()),
      ('Pases completados',stats.pasesCompletados.toString()),
      ('Pases fallidos',   stats.pasesFallidos.toString()),
      ('Regates exitosos', stats.regatesExitosos.toString()),
      ('Regates fallidos', stats.regatesFallidos.toString()),
      ('Faltas cometidas', stats.faltasCometidas.toString()),
      ('Faltas recibidas', stats.faltasRecibidas.toString()),
      ('Minutos jugados',  stats.minutosFormateados),
    ];

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
          const Text('Totales acumulados',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  Text(r.$2,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../models/usuario_model.dart';
import '../../../../services/storage_service.dart';
import '../../../matches/application/providers/match_provider.dart';
import '../../../matches/presentation/pages/match_detail_page.dart';
import '../../../profile_picture/application/profile_picture_provider.dart';
import '../../../statistics/application/providers/statistics_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/recent_match_item.dart';

/// Página principal del dashboard — resumen ejecutivo del rendimiento.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UsuarioModel _usuario = UsuarioModel.vacio();
  bool _cargandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadUser() async {
    final u = await StorageService.obtenerUsuarioModel();
    if (mounted) setState(() { _usuario = u; _cargandoUsuario = false; });
  }

  void _loadData() {
    context.read<StatisticsProvider>().load();
    context.read<MatchProvider>().loadPlayed();
    context.read<ProfilePictureProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Consumer2<ProfilePictureProvider, StatisticsProvider>(
                builder: (_, picProvider, statsProvider, __) => DashboardHeader(
                  usuario: _usuario,
                  cargando: _cargandoUsuario,
                  photoBytes: picProvider.photoBytes,
                  rating: statsProvider.stats.valoracionPromedio > 0
                      ? statsProvider.stats.valoracionPromedio
                      : null,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildRecentMatches()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: AppColors.textOnPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'SoccerLife',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        _buildSeasonBadge(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSeasonBadge() {
    final year = DateTime.now().year;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Text(
        'Temporada $year',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Consumer2<StatisticsProvider, MatchProvider>(
      builder: (_, statsProvider, matchProvider, __) {
        if (statsProvider.isLoading && matchProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: AppLoading(),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          child: QuickStatsWidget(
            stats: statsProvider.stats,
            partidosCount: matchProvider.played.length,
          ),
        );
      },
    );
  }

  Widget _buildRecentMatches() {
    return Consumer<MatchProvider>(
      builder: (_, provider, __) {
        final recientes = provider.played.take(5).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Últimos partidos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const AppLoading()
              else if (recientes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Aún no tienes partidos registrados',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...recientes.map(
                  (m) => RecentMatchItem(
                    match: m,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchDetailPage(match: m),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}



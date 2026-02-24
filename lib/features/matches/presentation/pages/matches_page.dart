import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../application/providers/match_provider.dart';
import '../widgets/match_card.dart';
import 'match_detail_page.dart';
import 'match_form_page.dart';

/// Listado de partidos jugados con opción de registro.
class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadPlayed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            onPressed: () => context.read<MatchProvider>().loadPlayed(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar partido',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<MatchProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading && provider.played.isEmpty) {
            return const AppLoading(message: 'Cargando partidos...');
          }
          if (provider.status == MatchStatus.error &&
              provider.played.isEmpty) {
            return AppErrorView(
              message: provider.errorMessage ?? 'Error desconocido',
              onRetry: () => provider.loadPlayed(),
            );
          }
          if (provider.played.isEmpty) {
            return AppEmptyState(
              icon: Icons.sports_soccer_rounded,
              title: 'Sin partidos',
              subtitle: 'Registra tu primer partido\npulsando el botón inferior.',
              action: ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Registrar partido'),
              ),
            );
          }
          return _buildList(provider);
        },
      ),
    );
  }

  Widget _buildList(MatchProvider provider) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: provider.loadPlayed,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.played.length,
        itemBuilder: (_, i) {
          final match = provider.played[i];
          return MatchCard(
            match: match,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MatchDetailPage(match: match)),
            ),
            onDelete: () => _confirmDelete(provider, match.id!),
          );
        },
      ),
    );
  }

  void _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MatchFormPage()),
    );
    if (saved == true && mounted) {
      context.read<MatchProvider>().loadPlayed();
    }
  }

  void _confirmDelete(MatchProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar partido',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '¿Estás seguro? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              provider.deleteMatch(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

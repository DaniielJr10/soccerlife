import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../application/tournament_provider.dart';
import '../../domain/entities/tournament_entity.dart';
import '../widgets/tournament_card.dart';
import 'tournament_form_page.dart';

/// PÃ¡gina principal de Torneos: lista todos los torneos del jugador.
class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TournamentProvider>().load(),
    );
  }

  Future<void> _openForm({TournamentEntity? torneo}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentFormPage(torneo: torneo),
      ),
    );
    if (mounted) context.read<TournamentProvider>().load();
  }

  Future<void> _confirmDelete(TournamentEntity torneo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar torneo',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Â¿Eliminar "${torneo.nombre}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<TournamentProvider>().delete(torneo.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        title: const Text(
          'Torneos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo torneo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<TournamentProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const AppLoading(message: 'Cargando torneos...');
          }

          if (provider.status == TournamentStatus.error) {
            return AppErrorView(
              message: provider.errorMessage ?? 'Error al cargar torneos',
              onRetry: () => provider.load(),
            );
          }

          if (provider.items.isEmpty) {
            return AppEmptyState(
              icon: Icons.emoji_events_rounded,
              title: 'Sin torneos registrados',
              subtitle:
                  'Crea tu primer torneo para organizar\ntus partidos por competición.',
              action: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Crear torneo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () => provider.load(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.items.length,
              itemBuilder: (_, i) {
                final t = provider.items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TournamentCard(
                    torneo: t,
                    onEdit: () => _openForm(torneo: t),
                    onDelete: () => _confirmDelete(t),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


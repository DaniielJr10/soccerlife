import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/tournament_provider.dart';
import '../../domain/entities/tournament_entity.dart';
import '../widgets/tournament_card.dart';
import 'tournament_form_page.dart';

/// Página principal de Torneos: lista todos los torneos del jugador.
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
        content: Text('¿Eliminar "${torneo.nombre}"?',
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
        title: const Text('Torneos',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: Consumer<TournamentProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.status == TournamentStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage ?? 'Error',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => provider.load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.textMuted, size: 56),
                  const SizedBox(height: 14),
                  const Text('Sin torneos registrados',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00f5ff),
                        foregroundColor: Colors.black),
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar torneo',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () => provider.load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.items.length,
              itemBuilder: (_, i) {
                final t = provider.items[i];
                return TournamentCard(
                  torneo: t,
                  onEdit: () => _openForm(torneo: t),
                  onDelete: () => _confirmDelete(t),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

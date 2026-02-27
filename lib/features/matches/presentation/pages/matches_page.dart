import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../application/providers/match_provider.dart';
import '../../domain/entities/match_entity.dart';
import '../widgets/match_card.dart';
import 'match_detail_page.dart';
import 'match_form_page.dart';

/// Listado de partidos jugados con opción de registro y filtros.
class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

// Opciones de filtro
enum _Filtro { todos, victoria, empate, derrota }

class _MatchesPageState extends State<MatchesPage> {
  _Filtro _filtroActivo = _Filtro.todos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadPlayed();
    });
  }

  List<MatchEntity> _aplicarFiltro(List<MatchEntity> partidos) {
    switch (_filtroActivo) {
      case _Filtro.victoria:
        return partidos.where((m) => m.resultado == 'V').toList();
      case _Filtro.empate:
        return partidos.where((m) => m.resultado == 'E').toList();
      case _Filtro.derrota:
        return partidos.where((m) => m.resultado == 'D').toList();
      case _Filtro.todos:
        return partidos;
    }
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

          final filtrados = _aplicarFiltro(provider.played);
          return Column(
            children: [
              _buildFilterBar(provider.played),
              Expanded(child: _buildList(provider, filtrados)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(List<MatchEntity> todos) {
    // Contadores por resultado
    int wins   = todos.where((m) => m.resultado == 'V').length;
    int draws  = todos.where((m) => m.resultado == 'E').length;
    int losses = todos.where((m) => m.resultado == 'D').length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _FilterChip(
              label: 'Todos',
              count: todos.length,
              color: AppColors.textSecondary,
              selected: _filtroActivo == _Filtro.todos,
              onTap: () => setState(() => _filtroActivo = _Filtro.todos),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Victorias',
              count: wins,
              color: AppColors.success,
              selected: _filtroActivo == _Filtro.victoria,
              onTap: () => setState(() => _filtroActivo = _Filtro.victoria),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Empates',
              count: draws,
              color: AppColors.warning,
              selected: _filtroActivo == _Filtro.empate,
              onTap: () => setState(() => _filtroActivo = _Filtro.empate),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Derrotas',
              count: losses,
              color: AppColors.danger,
              selected: _filtroActivo == _Filtro.derrota,
              onTap: () => setState(() => _filtroActivo = _Filtro.derrota),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(MatchProvider provider, List<MatchEntity> filtrados) {
    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer_rounded,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Sin partidos con este filtro',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: provider.loadPlayed,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: filtrados.length,
        itemBuilder: (_, i) {
          final match = filtrados[i];
          return MatchCard(
            match: match,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MatchDetailPage(match: match)),
            ),
            onEdit: () => _openEditForm(match),
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

  void _openEditForm(match) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MatchFormPage(match: match)),
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

// ── Chip de filtro ────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? color : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

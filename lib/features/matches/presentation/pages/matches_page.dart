import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../statistics/application/providers/statistics_provider.dart';
import '../../../tournaments/application/tournament_provider.dart';
import '../../../tournaments/domain/entities/tournament_entity.dart';
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

// Opciones de filtro por resultado
enum _Filtro { todos, victoria, empate, derrota }

class _MatchesPageState extends State<MatchesPage> {
  _Filtro _filtroActivo = _Filtro.todos;
  // null = sin filtro de torneo; valor = torneoId seleccionado
  String? _torneoFiltroId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadPlayed();
      // Cargar torneos para el filtro (si aún no están cargados)
      final tp = context.read<TournamentProvider>();
      if (tp.items.isEmpty) tp.load();
    });
  }

  /// Filtra la lista base por el torneo seleccionado.
  List<MatchEntity> _filtrarPorTorneo(List<MatchEntity> partidos) {
    if (_torneoFiltroId == null) return partidos;
    return partidos.where((m) => m.torneoId == _torneoFiltroId).toList();
  }

  /// Aplica el filtro de resultado sobre una lista ya filtrada por torneo.
  List<MatchEntity> _filtrarPorResultado(List<MatchEntity> lista) {
    switch (_filtroActivo) {
      case _Filtro.victoria:
        return lista.where((m) => m.resultado == 'V').toList();
      case _Filtro.empate:
        return lista.where((m) => m.resultado == 'E').toList();
      case _Filtro.derrota:
        return lista.where((m) => m.resultado == 'D').toList();
      case _Filtro.todos:
        return lista;
    }
  }

  Future<void> _reloadAll() => Future.wait([
        context.read<MatchProvider>().loadPlayed(),
        context.read<StatisticsProvider>().load(),
      ]);

  /// Etiqueta del filtro de resultado activo (cadena simple para pasar a widgets).
  String _resultadoLabelActual() {
    switch (_filtroActivo) {
      case _Filtro.victoria: return 'victorias';
      case _Filtro.empate:   return 'empates';
      case _Filtro.derrota:  return 'derrotas';
      case _Filtro.todos:    return '';
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
            onPressed: _reloadAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar partido',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer2<MatchProvider, TournamentProvider>(
        builder: (_, provider, torneoProvider, __) {
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

          // Lista filtrada por torneo (base para los contadores)
          final porTorneo = _filtrarPorTorneo(provider.played);
          // Lista final: torneo + resultado
          final filtrados = _filtrarPorResultado(porTorneo);

          // Torneo actualmente seleccionado (para el empty state)
          // Usamos variable local para evitar problemas de null-promotion
          final torneoActivo = _torneoFiltroId == null
              ? null
              : torneoProvider.items.cast<TournamentEntity?>().firstWhere(
                  (t) => t?.id == _torneoFiltroId,
                  orElse: () => null,
                );

          // Extraemos los valores que necesita el empty state para evitar
          // pasar el enum privado _Filtro a otro widget (causa DebugService null)
          final resultadoLabel = _resultadoLabelActual();
          final filtroEsTodos  = _filtroActivo == _Filtro.todos;

          return Column(
            children: [
              _buildFilterBar(porTorneo),
              if (torneoProvider.items.isNotEmpty)
                _buildTournamentFilterBar(torneoProvider.items),
              Expanded(
                child: _buildList(
                  provider, filtrados, torneoActivo,
                  resultadoLabel: resultadoLabel,
                  filtroEsTodos: filtroEsTodos,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTournamentFilterBar(List<TournamentEntity> torneos) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por torneo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TorneoChip(
                  label: 'Todos',
                  color: AppColors.textSecondary,
                  selected: _torneoFiltroId == null,
                  onTap: () => setState(() => _torneoFiltroId = null),
                ),
                ...torneos.map((t) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _TorneoChip(
                    label: t.nombre,
                    color: t.color,
                    selected: _torneoFiltroId == t.id,
                    onTap: () => setState(() {
                      _torneoFiltroId = t.id;
                      _filtroActivo = _Filtro.todos;
                    }),
                  ),
                )),
              ],
            ),
          ),
        ],
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

  Widget _buildList(
    MatchProvider provider,
    List<MatchEntity> filtrados,
    TournamentEntity? torneoActivo, {
    required String resultadoLabel,
    required bool filtroEsTodos,
  }) {
    if (filtrados.isEmpty) {
      return _EmptyFilterState(
        torneoNombre: torneoActivo?.nombre,
        torneoColor:  torneoActivo?.color,
        resultadoLabel: resultadoLabel,
        filtroEsTodos:  filtroEsTodos,
        onClearTorneo:    () => setState(() => _torneoFiltroId = null),
        onClearResultado: () => setState(() => _filtroActivo = _Filtro.todos),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: () async => _reloadAll(),
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
      _reloadAll();
    }
  }

  void _openEditForm(match) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MatchFormPage(match: match)),
    );
    if (saved == true && mounted) {
      _reloadAll();
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
              provider.deleteMatch(id).then((_) {
                if (mounted) context.read<StatisticsProvider>().load();
              });
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
          color: selected ? color.withOpacity(0.12) : AppColors.surfaceAlt,
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

// ── Chip de filtro por torneo ─────────────────────────────────────────────────

class _TorneoChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TorneoChip({
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.emoji_events_rounded, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state contextual por filtro ────────────────────────────────────────
// NOTA: recibe tipos simples (String/Color/bool) en lugar del enum privado
// _Filtro y TournamentEntity para evitar errores de serialización en DevTools.

class _EmptyFilterState extends StatelessWidget {
  /// Nombre del torneo seleccionado, o null si no hay filtro de torneo.
  final String? torneoNombre;
  /// Color del torneo, o null para usar el color primario de la app.
  final Color? torneoColor;
  /// Etiqueta del resultado filtrado ('victorias', 'empates', 'derrotas', '').
  final String resultadoLabel;
  /// true cuando el filtro de resultado está en "Todos".
  final bool filtroEsTodos;
  final VoidCallback onClearTorneo;
  final VoidCallback onClearResultado;

  const _EmptyFilterState({
    required this.torneoNombre,
    required this.torneoColor,
    required this.resultadoLabel,
    required this.filtroEsTodos,
    required this.onClearTorneo,
    required this.onClearResultado,
  });

  @override
  Widget build(BuildContext context) {
    final hasTorneo    = torneoNombre != null && torneoNombre!.isNotEmpty;
    final hasResultado = !filtroEsTodos && resultadoLabel.isNotEmpty;
    // Variable local para promotion de null segura
    final color        = (hasTorneo ? torneoColor : null) ?? AppColors.primary;
    final nombre       = torneoNombre ?? '';

    final String titulo = hasTorneo
        ? 'Sin partidos en $nombre'
        : 'Sin partidos con este filtro';

    final String subtitulo = hasTorneo && hasResultado
        ? 'No tienes $resultadoLabel registradas\nen "$nombre".'
        : hasTorneo
            ? 'Aún no has registrado ningún partido\nvinculado a "$nombre".'
            : 'No hay partidos que coincidan\ncon el filtro seleccionado.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasTorneo
                    ? Icons.emoji_events_rounded
                    : Icons.sports_soccer_rounded,
                size: 38,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (hasResultado && hasTorneo) ...[
              _ActionButton(
                label: 'Ver todos los resultados',
                icon: Icons.clear_rounded,
                color: color,
                onTap: onClearResultado,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Ver todos los torneos',
                icon: Icons.emoji_events_outlined,
                color: AppColors.textSecondary,
                onTap: onClearTorneo,
              ),
            ] else if (hasTorneo) ...[
              _ActionButton(
                label: 'Ver todos los partidos',
                icon: Icons.sports_soccer_rounded,
                color: color,
                onTap: onClearTorneo,
              ),
            ] else if (hasResultado) ...[
              _ActionButton(
                label: 'Quitar filtro',
                icon: Icons.clear_rounded,
                color: AppColors.primary,
                onTap: onClearResultado,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

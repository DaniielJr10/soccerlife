import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/logros_service.dart';

/// Página de logros — muestra los achievements del jugador con diseño premium.
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<dynamic> _logros = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'todos'; // todos | desbloqueados | bloqueados

  int get _totalPuntos => _logros
      .where((l) => l['desbloqueado'] == true)
      .fold(0, (sum, l) => sum + (l['puntos'] as int? ?? 0));

  int get _desbloqueados =>
      _logros.where((l) => l['desbloqueado'] == true).length;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    final result = await LogrosService.obtenerLogrosUsuario();
    if (mounted) {
      setState(() {
        _cargando = false;
        if (result['success'] == true) {
          _logros = result['logros'] as List<dynamic>;
        } else {
          _error = result['message'] as String?;
        }
      });
    }
  }

  List<dynamic> get _logrosFiltrados {
    if (_filtro == 'desbloqueados') {
      return _logros.where((l) => l['desbloqueado'] == true).toList();
    }
    if (_filtro == 'bloqueados') {
      return _logros.where((l) => l['desbloqueado'] != true).toList();
    }
    return _logros;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverAppBar()],
        body: _cargando
            ? const _LoadingState()
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _cargar)
                : _logros.isEmpty
                    ? const _EmptyState()
                    : _buildContent(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _AchievementsHeader(
          total: _logros.length,
          desbloqueados: _desbloqueados,
          puntos: _totalPuntos,
        ),
      ),
      title: const Text(
        'Logros',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
          onPressed: _cargar,
        ),
      ],
    );
  }

  Widget _buildContent() {
    final logros = _logrosFiltrados;
    return Column(
      children: [
        _FilterBar(
          filtro: _filtro,
          onChanged: (f) => setState(() => _filtro = f),
          total: _logros.length,
          desbloqueados: _desbloqueados,
        ),
        Expanded(
          child: logros.isEmpty
              ? const Center(
                  child: Text(
                    'No hay logros en esta categoría',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  physics: const ClampingScrollPhysics(),
                  itemCount: logros.length,
                  itemBuilder: (_, i) => _LogroCard(logro: logros[i]),
                ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _AchievementsHeader extends StatelessWidget {
  final int total;
  final int desbloqueados;
  final int puntos;

  const _AchievementsHeader({
    required this.total,
    required this.desbloqueados,
    required this.puntos,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : desbloqueados / total;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1F35), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatBadge(
                icon: Icons.military_tech_rounded,
                value: '$desbloqueados/$total',
                label: 'Desbloqueados',
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _StatBadge(
                icon: Icons.bolt_rounded,
                value: '$puntos',
                label: 'Puntos XP',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String filtro;
  final ValueChanged<String> onChanged;
  final int total;
  final int desbloqueados;

  const _FilterBar({
    required this.filtro,
    required this.onChanged,
    required this.total,
    required this.desbloqueados,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Todos ($total)',
              active: filtro == 'todos',
              onTap: () => onChanged('todos'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Desbloqueados ($desbloqueados)',
              active: filtro == 'desbloqueados',
              onTap: () => onChanged('desbloqueados'),
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Bloqueados (${total - desbloqueados})',
              active: filtro == 'bloqueados',
              onTap: () => onChanged('bloqueados'),
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Logro Card ────────────────────────────────────────────────────────────────

class _LogroCard extends StatelessWidget {
  final dynamic logro;
  const _LogroCard({required this.logro});

  static const Map<String, Color> _rarezaColores = {
    'Común': AppColors.textSecondary,
    'Raro': AppColors.info,
    'Épico': Color(0xFFA855F7),
    'Legendario': AppColors.warning,
  };

  static const Map<String, IconData> _categoriaIconos = {
    'partidos': Icons.sports_soccer_rounded,
    'goles': Icons.sports_soccer_rounded,
    'racha': Icons.local_fire_department_rounded,
    'especial': Icons.star_rounded,
  };

  bool get _desbloqueado => logro['desbloqueado'] == true;

  Color get _rarezaColor =>
      _rarezaColores[logro['logro']?['rareza'] ?? logro['rareza']] ??
      AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final info = logro['logro'] as Map<String, dynamic>? ?? logro;
    final titulo = info['titulo']?.toString() ?? '—';
    final descripcion = info['descripcion']?.toString() ?? '';
    final rareza = info['rareza']?.toString() ?? 'Común';
    final categoria = info['categoria']?.toString() ?? 'especial';
    final puntos = info['puntos'] as int? ?? 0;
    final progreso = logro['progreso'] as Map<String, dynamic>?;
    final actual = progreso?['actual'] as num? ?? 0;
    final requerido = progreso?['requerido'] as num? ?? 1;
    final pct = (actual / requerido).clamp(0.0, 1.0).toDouble();

    final iconData = _categoriaIconos[categoria] ?? Icons.military_tech_rounded;
    final color = _rarezaColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _desbloqueado
            ? color.withValues(alpha: 0.06)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _desbloqueado
              ? color.withValues(alpha: 0.35)
              : AppColors.border,
          width: _desbloqueado ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _desbloqueado
                    ? color.withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _desbloqueado
                      ? color.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                iconData,
                color: _desbloqueado ? color : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            color: _desbloqueado
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RarezaBadge(rareza: rareza, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_desbloqueado) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        const Text(
                          'Desbloqueado',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+$puntos XP',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppColors.border,
                              valueColor:
                                  AlwaysStoppedAnimation(color),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$actual/$requerido',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RarezaBadge extends StatelessWidget {
  final String rareza;
  final Color color;
  const _RarezaBadge({required this.rareza, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        rareza,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Estados ───────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Cargando logros...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textMuted, size: 52),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech_outlined,
              color: AppColors.textMuted, size: 64),
          SizedBox(height: 16),
          Text(
            'Aún no tienes logros',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Registra partidos y mejora tus\nestadísticas para desbloquearlos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

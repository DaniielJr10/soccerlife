import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/tournaments/application/tournament_provider.dart';
import '../../../../features/tournaments/domain/entities/tournament_entity.dart';
import '../../application/providers/match_provider.dart';
import '../../domain/entities/match_entity.dart';
import '../widgets/stats_form_section.dart';

/// Formulario para registrar un partido jugado con todas sus estadísticas.
class MatchFormPage extends StatefulWidget {
  const MatchFormPage({super.key});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Campos básicos
  final _rivalCtrl         = TextEditingController();
  final _lugarCtrl         = TextEditingController();
  final _competicionCtrl   = TextEditingController();
  final _horaCtrl          = TextEditingController(text: '15:00');
  final _notasCtrl         = TextEditingController();
  final _golesLocalCtrl    = TextEditingController(text: '0');
  final _golesVisitCtrl    = TextEditingController(text: '0');
  final _minutosCtrl       = TextEditingController(text: '90');

  DateTime _fecha          = DateTime.now();
  double _valoracion       = 5.0;

  // Torneo asociado
  String? _torneoId;
  String? _torneoNombre;

  // Lista local de torneos (cargada una sola vez — no usa Consumer para
  // evitar que rebuilds del provider congelen el formulario)
  List<TournamentEntity> _torneos = [];

  // Estadísticas - contador
  final Map<String, int> _stats = {
    'goles': 0, 'asistencias': 0,
    'remates': 0, 'rematesAlArco': 0,
    'pasesCompletados': 0, 'pasesFallidos': 0,
    'regatesExitosos': 0, 'regatesFallidos': 0,
    'faltasCometidas': 0, 'faltasRecibidas': 0,
    'tarjetasAmarillas': 0, 'tarjetasRojas': 0,
  };

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarTorneos());
  }

  /// Carga torneos una sola vez en estado local.
  /// Usa los datos ya en caché del provider si están disponibles,
  /// o lanza load() sin bloquear el formulario.
  Future<void> _cargarTorneos() async {
    final provider = context.read<TournamentProvider>();
    if (provider.items.isNotEmpty) {
      if (mounted) setState(() => _torneos = provider.items);
      return;
    }
    try {
      await provider.load();
      if (mounted) setState(() => _torneos = provider.items);
    } catch (_) {
      // Falla silenciosamente: el formulario funciona sin torneos
    }
  }

  @override
  void dispose() {
    for (final c in [_rivalCtrl, _lugarCtrl, _competicionCtrl,
        _horaCtrl, _notasCtrl, _golesLocalCtrl, _golesVisitCtrl,
        _minutosCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar partido'),
        leading: const BackButton(color: AppColors.textSecondary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            _SectionTitle(title: 'Información del partido'),
            _buildRival(),
            Row(children: [_buildFecha()]),
            _Row2(left: _buildHora(), right: _buildLugar()),
            _buildCompeticion(),
            _buildTorneoSelector(),
            const SizedBox(height: 8),
            _SectionTitle(title: 'Resultado'),
            _buildScore(),
            _buildMinutos(),
            _buildRating(),
            const SizedBox(height: 8),
            _SectionTitle(title: 'Estadísticas personales'),
            StatsFormSection(
              values: _stats,
              onChanged: (k, v) => setState(() => _stats[k] = v),
            ),
            const SizedBox(height: 8),
            _SectionTitle(title: 'Notas'),
            _buildNotas(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── Campos básicos ──────────────────────────────────────────────────────

  Widget _buildRival() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _rivalCtrl,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Equipo rival *',
          prefixIcon: Icon(Icons.group_rounded),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildFecha() {
    return _FieldBox(
      label: 'Fecha *',
      value: _formatDate(_fecha),
      icon: Icons.calendar_today_rounded,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (_, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _fecha = picked);
      },
    );
  }

  Widget _buildHora() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 10),
        child: TextFormField(
          controller: _horaCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Hora *',
            prefixIcon: Icon(Icons.access_time_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Requerida' : null,
        ),
      ),
    );
  }

  Widget _buildLugar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: _lugarCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Lugar'),
        ),
      ),
    );
  }

  Widget _buildCompeticion() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _competicionCtrl,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(labelText: 'Competición'),
      ),
    );
  }

  Widget _buildTorneoSelector() {
    if (_torneos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: _torneoId,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Torneo (opcional)',
          prefixIcon: Icon(Icons.emoji_events_rounded),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Sin torneo',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ..._torneos.map(
            (t) => DropdownMenuItem(
              value: t.id,
              child: Row(children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: t.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(t.nombre,
                    overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ),
        ],
        onChanged: (v) => setState(() {
          _torneoId     = v;
          _torneoNombre = v == null
              ? null
              : _torneos.firstWhere((t) => t.id == v).nombre;
        }),
      ),
    );
  }

  Widget _buildScore() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _golesLocalCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              decoration: const InputDecoration(labelText: 'Goles local'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '–',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _golesVisitCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              decoration: const InputDecoration(labelText: 'Goles rival'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinutos() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _minutosCtrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Minutos jugados',
          prefixIcon: Icon(Icons.timer_rounded),
          suffixText: 'min',
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Valoración',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text(
                  _valoracion.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Slider(
              value: _valoracion,
              min: 1,
              max: 10,
              divisions: 18,
              activeColor: AppColors.warning,
              inactiveColor: AppColors.border,
              onChanged: (v) => setState(() => _valoracion = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _notasCtrl,
        maxLines: 3,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Notas del partido',
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: Icon(Icons.notes_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _guardando ? null : _save,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
      ),
      child: _guardando
          ? const SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2),
            )
          : const Text('Guardar partido', style: TextStyle(fontSize: 16)),
    );
  }

  // ── Lógica ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final match = MatchEntity(
      rival:            _rivalCtrl.text.trim(),
      fecha:            _fecha,
      hora:             _horaCtrl.text.trim(),
      lugar:            _lugarCtrl.text.trim(),
      tipo:             'partido',
      competicion:      _competicionCtrl.text.trim(),
      estado:           'finalizado',
      notas:            _notasCtrl.text.trim(),
      torneoId:         _torneoId,
      torneoNombre:     _torneoNombre,
      golesLocal:       int.tryParse(_golesLocalCtrl.text) ?? 0,
      golesVisitante:   int.tryParse(_golesVisitCtrl.text) ?? 0,
      posicion:         '',
      minutosJugados:   int.tryParse(_minutosCtrl.text) ?? 90,
      valoracion:       _valoracion,
      goles:            _stats['goles'] ?? 0,
      asistencias:      _stats['asistencias'] ?? 0,
      remates:          _stats['remates'] ?? 0,
      rematesAlArco:    _stats['rematesAlArco'] ?? 0,
      pasesCompletados: _stats['pasesCompletados'] ?? 0,
      pasesFallidos:    _stats['pasesFallidos'] ?? 0,
      regatesExitosos:  _stats['regatesExitosos'] ?? 0,
      regatesFallidos:  _stats['regatesFallidos'] ?? 0,
      faltasCometidas:  _stats['faltasCometidas'] ?? 0,
      faltasRecibidas:  _stats['faltasRecibidas'] ?? 0,
      tarjetasAmarillas:_stats['tarjetasAmarillas'] ?? 0,
      tarjetasRojas:    _stats['tarjetasRojas'] ?? 0,
    );

    final ok = await context.read<MatchProvider>().registerPlayed(match);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<MatchProvider>().errorMessage ?? 'Error al guardar',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ── Helpers de layout ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) => Row(children: [left, right]);
}

class _FieldBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _FieldBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                    Text(value,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

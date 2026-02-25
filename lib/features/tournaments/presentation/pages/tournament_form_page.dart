import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/tournament_provider.dart';
import '../../domain/entities/tournament_entity.dart';

/// Formulario para crear o editar un torneo.
class TournamentFormPage extends StatefulWidget {
  /// null → crear nuevo; no null → editar existente.
  final TournamentEntity? torneo;
  const TournamentFormPage({super.key, this.torneo});

  @override
  State<TournamentFormPage> createState() => _TournamentFormPageState();
}

class _TournamentFormPageState extends State<TournamentFormPage> {
  final _formKey  = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String _estado     = 'activo';
  String _colorHex   = '#00D4AA';
  bool   _guardando  = false;

  static const _colores = {
    'Verde':   '#00D4AA',
    'Azul':    '#3B82F6',
    'Naranja': '#F59E0B',
    'Rojo':    '#EF4444',
    'Violeta': '#8B5CF6',
    'Cian':    '#06B6D4',
  };

  bool get _modoEdicion => widget.torneo != null;

  @override
  void initState() {
    super.initState();
    if (_modoEdicion) {
      final t = widget.torneo!;
      _nombreCtrl.text = t.nombre;
      _descCtrl.text   = t.descripcion;
      _fechaInicio = t.fechaInicio;
      _fechaFin    = t.fechaFin;
      _estado      = t.estado;
      _colorHex    = t.colorHex;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final torneo = TournamentEntity(
      id:          widget.torneo?.id,
      nombre:      _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      fechaInicio: _fechaInicio,
      fechaFin:    _fechaFin,
      estado:      _estado,
      colorHex:    _colorHex,
    );

    final provider = context.read<TournamentProvider>();
    final ok = _modoEdicion
        ? await provider.update(torneo)
        : await provider.create(torneo);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? 'Error al guardar'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _pickDate(bool esInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (esInicio ? _fechaInicio : _fechaFin) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => esInicio ? _fechaInicio = picked : _fechaFin = picked);
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Seleccionar';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(_modoEdicion ? 'Editar torneo' : 'Nuevo torneo',
            style: const TextStyle(color: AppColors.textPrimary)),
        leading: const BackButton(color: AppColors.textSecondary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_nombreCtrl, 'Nombre del torneo *',  Icons.emoji_events_rounded,
                required: true),
            const SizedBox(height: 10),
            _field(_descCtrl,   'Descripción (opcional)', Icons.notes_rounded),
            const SizedBox(height: 16),
            // Fechas
            Row(children: [
              Expanded(child: _dateTile('Inicio', _fechaInicio, () => _pickDate(true))),
              const SizedBox(width: 10),
              Expanded(child: _dateTile('Fin',    _fechaFin,    () => _pickDate(false))),
            ]),
            const SizedBox(height: 16),
            // Estado
            DropdownButtonFormField<String>(
              value: _estado,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Estado', prefixIcon: Icon(Icons.flag_rounded)),
              items: const [
                DropdownMenuItem(value: 'activo',     child: Text('Activo')),
                DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
              ],
              onChanged: (v) => setState(() => _estado = v ?? _estado),
            ),
            const SizedBox(height: 16),
            // Color
            const Text('Color',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _colores.entries.map((e) {
                Color c;
                try { c = Color(int.parse('FF${e.value.replaceAll("#", "")}', radix: 16)); }
                catch (_) { c = AppColors.primary; }
                final sel = _colorHex == e.value;
                return GestureDetector(
                  onTap: () => setState(() => _colorHex = e.value),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 3),
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _modoEdicion ? 'Guardar cambios' : 'Crear torneo',
                      style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
              Text(_fmt(date),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13)),
            ],
          )),
        ]),
      ),
    );
  }
}

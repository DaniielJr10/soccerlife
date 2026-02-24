import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/fifa_card_entity.dart';

/// Formulario editable para los campos de la Carta FIFA.
/// Devuelve la entidad actualizada via [onChanged].
class FifaStatsForm extends StatefulWidget {
  final FifaCardEntity initial;
  final ValueChanged<FifaCardEntity> onChanged;

  const FifaStatsForm({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<FifaStatsForm> createState() => _FifaStatsFormState();
}

class _FifaStatsFormState extends State<FifaStatsForm> {
  late FifaCardEntity _data;

  final _posiciones = ['POR', 'DFC', 'DC', 'LI', 'LD', 'MCD', 'MC', 'MCO',
    'MP', 'EXI', 'EXD', 'SD', 'DEL'];

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
  }

  void _emit(FifaCardEntity updated) {
    setState(() => _data = updated);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _sectionTitle('Información básica'),
        _textField(
          label: 'Nombre del jugador',
          value: _data.nombre,
          onChanged: (v) => _emit(_data.copyWith(nombre: v)),
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Club',
          value: _data.club,
          onChanged: (v) => _emit(_data.copyWith(club: v)),
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Contacto (email / Instagram)',
          value: _data.contacto,
          onChanged: (v) => _emit(_data.copyWith(contacto: v)),
        ),
        const SizedBox(height: 12),
        _posicionDropdown(),
        const SizedBox(height: 12),
        _overallSlider(),
        const SizedBox(height: 20),
        _sectionTitle('Estadísticas (0 – 99)'),
        _statSlider('Ritmo (RIT)', _data.ritmo,
            (v) => _emit(_data.copyWith(ritmo: v))),
        _statSlider('Tiro (TIR)', _data.tiro,
            (v) => _emit(_data.copyWith(tiro: v))),
        _statSlider('Pase (PAS)', _data.pase,
            (v) => _emit(_data.copyWith(pase: v))),
        _statSlider('Regate (REG)', _data.regate,
            (v) => _emit(_data.copyWith(regate: v))),
        _statSlider('Defensa (DEF)', _data.defensa,
            (v) => _emit(_data.copyWith(defensa: v))),
        _statSlider('Físico (FÍS)', _data.fisico,
            (v) => _emit(_data.copyWith(fisico: v))),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      );

  Widget _textField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) =>
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );

  Widget _posicionDropdown() => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Posición',
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _posiciones.contains(_data.posicion) ? _data.posicion : _posiciones.first,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            items: _posiciones
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => _emit(_data.copyWith(posicion: v)),
          ),
        ),
      );

  Widget _overallSlider() => _sliderRow(
        label: 'Overall',
        value: _data.overall,
        color: const Color(0xFFFFD700),
        onChanged: (v) => _emit(_data.copyWith(overall: v)),
      );

  Widget _statSlider(String label, int value, ValueChanged<int> onChanged) =>
      _sliderRow(label: label, value: value, color: AppColors.primary, onChanged: onChanged);

  Widget _sliderRow({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 99,
                divisions: 99,
                activeColor: color,
                inactiveColor: color.withValues(alpha: 0.2),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '$value',
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Sección de controles de estadísticas numéricas para el formulario de partido.
/// Cada campo tiene botones + / – para mayor comodidad en móvil.
class StatsFormSection extends StatelessWidget {
  final Map<String, int> values;
  final void Function(String key, int newVal) onChanged;

  const StatsFormSection({
    super.key,
    required this.values,
    required this.onChanged,
  });

  static const List<_StatField> _fields = [
    _StatField('goles',            'Goles',               Icons.sports_soccer,                AppColors.primary),
    _StatField('asistencias',      'Asistencias',         Icons.sports_handball_rounded,       AppColors.secondary),
    _StatField('remates',          'Remates totales',     Icons.ads_click_rounded,             AppColors.info),
    _StatField('regatesExitosos',  'Regates exitosos',    Icons.directions_run_rounded,        AppColors.primary),
    _StatField('regatesFallidos',  'Regates fallidos',    Icons.remove_circle_outline_rounded, AppColors.warning),
    _StatField('faltasCometidas',  'Faltas cometidas',    Icons.warning_amber_rounded,         AppColors.warning),
    _StatField('faltasRecibidas',  'Faltas recibidas',    Icons.medical_services_rounded,      AppColors.info),
    _StatField('tarjetasAmarillas','Tarjetas amarillas',  Icons.square_rounded,                AppColors.cardYellow),
    _StatField('tarjetasRojas',    'Tarjetas rojas',      Icons.square_rounded,                AppColors.cardRed),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_fields.length, (i) {
        final f = _fields[i];
        final val = values[f.key] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _StatCounter(
            icon: f.icon,
            label: f.label,
            color: f.color,
            value: val,
            onDecrement: val > 0 ? () => onChanged(f.key, val - 1) : null,
            onIncrement: () => onChanged(f.key, val + 1),
          ),
        );
      }),
    );
  }
}

class _StatField {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _StatField(this.key, this.label, this.icon, this.color);
}

class _StatCounter extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _StatCounter({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: TextStyle(
                color: value > 0 ? color : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

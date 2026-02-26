import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/statistics_entity.dart';

/// Radar/Spider chart de los 6 atributos clave del jugador.
class RadarChartWidget extends StatelessWidget {
  final StatisticsEntity stats;

  const RadarChartWidget({super.key, required this.stats});

  List<_RadarAttribute> get _attributes {
    final p = stats.partidosJugados;
    return [
      _RadarAttribute(
        label: 'Goles',
        value: p == 0 ? 0 : (stats.golesPorPartido / 1.5).clamp(0, 1),
        color: AppColors.primary,
      ),
      _RadarAttribute(
        label: 'Asistencias',
        value: p == 0
            ? 0
            : ((stats.asistencias / p) / 1.0).clamp(0, 1),
        color: AppColors.secondary,
      ),
      _RadarAttribute(
        label: 'Remates',
        value: stats.precisionRemates / 100,
        color: AppColors.info,
      ),
      _RadarAttribute(
        label: 'Pases',
        value: stats.precisionPases / 100,
        color: AppColors.success,
      ),
      _RadarAttribute(
        label: 'Regates',
        value: stats.precisionRegates / 100,
        color: AppColors.warning,
      ),
      _RadarAttribute(
        label: 'Victorias',
        value: stats.porcentajeVictorias / 100,
        color: AppColors.primary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final attrs = _attributes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Atributos del jugador',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _RadarPainter(attributes: attrs),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Leyenda
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: attrs.map((a) => _LegendItem(attr: a)).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final List<_RadarAttribute> attributes;
  const _RadarPainter({required this.attributes});

  static const int _levels = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 24;
    final n = attributes.length;
    final angleStep = (2 * math.pi) / n;
    const startAngle = -math.pi / 2;

    // ── Guias circulares ──
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int level = 1; level <= _levels; level++) {
      final r = maxRadius * level / _levels;
      final gridPath = Path();
      for (int i = 0; i < n; i++) {
        final angle = startAngle + i * angleStep;
        final pt = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          gridPath.moveTo(pt.dx, pt.dy);
        } else {
          gridPath.lineTo(pt.dx, pt.dy);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // ── Ejes ──
    final axisPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..strokeWidth = 0.8;
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      canvas.drawLine(
        center,
        Offset(
          center.dx + maxRadius * math.cos(angle),
          center.dy + maxRadius * math.sin(angle),
        ),
        axisPaint,
      );
    }

    // ── Área del jugador ──
    final areaPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final r = maxRadius * attributes[i].value;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, areaPaint);
    canvas.drawPath(dataPath, borderPaint);

    // ── Puntos en vértices ──
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final r = maxRadius * attributes[i].value;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      dotPaint.color = attributes[i].color;
      canvas.drawCircle(pt, 4, dotPaint);
      // Borde blanco
      canvas.drawCircle(
        pt,
        4,
        Paint()
          ..color = AppColors.background.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ── Etiquetas ──
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final labelR = maxRadius + 18;
      final pt = Offset(
        center.dx + labelR * math.cos(angle),
        center.dy + labelR * math.sin(angle),
      );
      final pct = (attributes[i].value * 100).toStringAsFixed(0);
      _drawLabel(canvas, attributes[i].label, pct, pt, attributes[i].color);
    }
  }

  void _drawLabel(
      Canvas canvas, String label, String pct, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label\n',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '$pct%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 56);

    textPainter.paint(
      canvas,
      pos.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.attributes != attributes;
}

// ── Modelos y leyenda ─────────────────────────────────────────────────────────

class _RadarAttribute {
  final String label;
  final double value; // 0.0 – 1.0
  final Color color;
  const _RadarAttribute(
      {required this.label, required this.value, required this.color});
}

class _LegendItem extends StatelessWidget {
  final _RadarAttribute attr;
  const _LegendItem({required this.attr});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: attr.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${attr.label} ${(attr.value * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

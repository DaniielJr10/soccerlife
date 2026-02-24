import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter — fondo premium estilo carta FIFA:
/// navy oscuro con destellos dorados / cristales y partículas.
class FifaGeometricPainter extends CustomPainter {
  const FifaGeometricPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawNabyGradient(canvas, size);
    _drawGoldShards(canvas, size);
    _drawGlowLines(canvas, size);
    _drawParticles(canvas, size);
  }

  void _drawNabyGradient(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.3, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF1A2E6E),
            Color(0xFF0D1B45),
            Color(0xFF060E28),
          ],
        ).createShader(rect),
    );
  }

  void _drawGoldShards(Canvas canvas, Size size) {
    final shards = [
      // [x1, y1, x2, y2, x3, y3, opacity]
      [0.55, -0.05, 0.95, 0.35, 0.75, 0.05, 0.55],
      [0.65, 0.10, 1.05, 0.50, 0.85, 0.08, 0.45],
      [0.40, -0.02, 0.90, 0.28, 0.70, 0.22, 0.38],
      [0.72, 0.32, 1.10, 0.65, 0.95, 0.28, 0.42],
      [0.50, 0.40, 0.80, 0.75, 0.62, 0.55, 0.30],
      [0.30, 0.60, 0.65, 0.92, 0.48, 0.72, 0.25],
    ];

    for (final s in shards) {
      final path = Path()
        ..moveTo(s[0] * size.width, s[1] * size.height)
        ..lineTo(s[2] * size.width, s[3] * size.height)
        ..lineTo(s[4] * size.width, s[5] * size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: s[6])
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFED8A).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }
  }

  void _drawGlowLines(Canvas canvas, Size size) {
    final lines = [
      [0.60, 0.0, 1.0, 0.55, 2.5, 0.35],
      [0.45, 0.0, 0.95, 0.42, 1.5, 0.25],
      [0.70, 0.15, 1.02, 0.70, 3.0, 0.20],
    ];
    for (final l in lines) {
      canvas.drawLine(
        Offset(l[0] * size.width, l[1] * size.height),
        Offset(l[2] * size.width, l[3] * size.height),
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: l[5])
          ..strokeWidth = l[4]
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 22; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.75;
      final r = rng.nextDouble() * 1.8 + 0.4;
      final a = rng.nextDouble() * 0.5 + 0.1;
      paint.color = (i % 3 == 0)
          ? const Color(0xFFFFD700).withValues(alpha: a)
          : const Color(0xFF7BA7FF).withValues(alpha: a * 0.6);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

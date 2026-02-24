import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter — fondo geométrico dorado facetado de la Carta FIFA.
class FifaGeometricPainter extends CustomPainter {
  const FifaGeometricPainter();

  static const _facets = [
    Color(0xFFFFD700),
    Color(0xFFFFF176),
    Color(0xFFDAA520),
    Color(0xFFB8860B),
    Color(0xFFF0C040),
    Color(0xFFFFE566),
    Color(0xFF9C6F00),
    Color(0xFFFFED8A),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.62;
    final cy = size.height * 0.42;
    final r = size.width * 0.70;
    final center = Offset(cx, cy);

    final outer = _radial(cx, cy, r, 6, -15);
    final inner = _radial(cx, cy, r * 0.36, 6, 15);

    for (var i = 0; i < 6; i++) {
      _tri(canvas, center, outer[i], inner[i],
          _facets[i % _facets.length]);
      _tri(canvas, inner[i], outer[i], outer[(i + 1) % 6],
          _facets[(i + 2) % _facets.length]);
      _tri(canvas, center, inner[i], inner[(i + 1) % 6],
          _facets[(i + 4) % _facets.length]);
    }

    // Brillo central
    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85),
            const Color(0xFFFFD700).withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.18)),
    );
  }

  void _tri(Canvas canvas, Offset a, Offset b, Offset c, Color col) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = col);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  List<Offset> _radial(double cx, double cy, double r, int n, double deg) =>
      List.generate(n, (i) {
        final a = (360 / n * i + deg) * math.pi / 180;
        return Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

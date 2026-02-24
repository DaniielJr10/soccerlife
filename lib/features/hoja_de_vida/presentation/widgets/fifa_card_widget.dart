import 'package:flutter/material.dart';
import '../../domain/entities/fifa_card_entity.dart';
import 'fifa_card_painter.dart';
import 'fifa_card_stats_panel.dart';

/// Carta FIFA premium — navy oscuro + destellos dorados + foto del jugador.
class FifaCardWidget extends StatelessWidget {
  final FifaCardEntity card;
  final double width;

  const FifaCardWidget({super.key, required this.card, this.width = 270});

  static const _borderW = 5.0;
  static const _gold1 = Color(0xFFFFD700);
  static const _gold2 = Color(0xFFB8860B);
  static const _gold3 = Color(0xFFFFF0A0);

  @override
  Widget build(BuildContext context) {
    final h = width * 1.41;
    final bw = width + _borderW * 2;
    final bh = h + _borderW * 2;
    return SizedBox(
      width: bw,
      height: bh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Borde dorado ornamental
          ClipPath(
            clipper: _ShieldClipper(),
            child: Container(
              width: bw,
              height: bh,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gold3, _gold1, _gold2, _gold1, _gold3],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Cuerpo de la carta
          ClipPath(
            clipper: _ShieldClipper(),
            child: SizedBox(
              width: width,
              height: h,
              child: Stack(
                children: [
                  _background(width, h),
                  _shards(width, h),
                  _photoArea(width, h),
                  _photoGradient(width, h),
                  _topStars(width),
                  _ratingBadge(width),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: FifaCardStatsPanel(card: card, cardWidth: width),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background(double w, double h) => Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B45), Color(0xFF060E28)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

  Widget _shards(double w, double h) => SizedBox(
        width: w,
        height: h,
        child: const CustomPaint(painter: FifaGeometricPainter()),
      );

  Widget _photoArea(double w, double h) {
    final photoH = h * 0.60;
    if (card.imageBytes == null) return _photoPlaceholder(w, photoH);

    return Positioned(
      top: h * 0.07,
      left: 0,
      right: 0,
      height: photoH,
      child: Image.memory(
        card.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(w, photoH),
      ),
    );
  }

  Widget _photoPlaceholder(double w, double h) => Positioned(
        top: w * 0.22,
        left: w * 0.25,
        child: SizedBox(
          width: w * 0.5,
          height: h * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_rounded,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  size: w * 0.25),
              const SizedBox(height: 6),
              Text(
                'Añadir foto',
                style: TextStyle(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    fontSize: w * 0.040),
              ),
            ],
          ),
        ),
      );

  Widget _photoGradient(double w, double h) => Positioned(
        bottom: h * 0.30,
        left: 0,
        right: 0,
        height: h * 0.25,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0xFF060E28)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );

  Widget _topStars(double w) => Positioned(
        top: w * 0.04,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: _gold1, size: w * 0.058),
            SizedBox(width: w * 0.025),
            Icon(Icons.star_rounded, color: _gold1, size: w * 0.058),
          ],
        ),
      );

  Widget _ratingBadge(double w) => Positioned(
        top: w * 0.05,
        left: w * 0.06,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${card.overall}',
              style: TextStyle(
                color: const Color(0xFFF5ECD7),
                fontSize: w * 0.175,
                fontWeight: FontWeight.w900,
                height: 1.0,
                shadows: const [
                  Shadow(color: Color(0xFFFFD700), blurRadius: 12),
                ],
              ),
            ),
            Text(
              card.posicion,
              style: TextStyle(
                color: const Color(0xFFF5ECD7),
                fontSize: w * 0.075,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                shadows: const [
                  Shadow(color: Color(0xFFFFD700), blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Clipper forma escudo ─────────────────────────────────────────────────────
class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.10, 0)
      ..lineTo(w * 0.90, 0)
      ..quadraticBezierTo(w, 0, w, h * 0.07)
      ..lineTo(w, h * 0.70)
      ..quadraticBezierTo(w, h * 0.94, w * 0.50, h)
      ..quadraticBezierTo(0, h * 0.94, 0, h * 0.70)
      ..lineTo(0, h * 0.07)
      ..quadraticBezierTo(0, 0, w * 0.10, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

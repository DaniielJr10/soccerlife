import 'package:flutter/material.dart';
import '../../domain/entities/fifa_card_entity.dart';
import 'fifa_card_painter.dart';

/// Carta FIFA visual — replica el estilo de la imagen de referencia.
class FifaCardWidget extends StatelessWidget {
  final FifaCardEntity card;
  final double width;

  const FifaCardWidget({
    super.key,
    required this.card,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.40;

    return SizedBox(
      width: width + 6,
      height: height + 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Borde dorado exterior
          _buildGoldBorder(width + 6, height + 6),
          // Contenido interior
          ClipPath(
            clipper: _ShieldClipper(),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  _buildMarbleBackground(width, height),
                  _buildGeometricOverlay(width, height),
                  _buildDiagonalDivider(width, height),
                  _buildRatingBadge(),
                  _buildBottomPanel(width, height),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldBorder(double w, double h) {
    return ClipPath(
      clipper: _ShieldClipper(),
      child: Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF0C100), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildMarbleBackground(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8), Color(0xFFD0D0D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildGeometricOverlay(double w, double h) {
    return Positioned(
      right: -w * 0.12,
      top: -h * 0.05,
      child: SizedBox(
        width: w * 0.85,
        height: h * 0.68,
        child: const CustomPaint(
          painter: FifaGeometricPainter(),
        ),
      ),
    );
  }

  Widget _buildDiagonalDivider(double w, double h) {
    return Positioned(
      top: 0,
      left: 0,
      child: CustomPaint(
        size: Size(w, h * 0.62),
        painter: _DiagonalPainter(),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Positioned(
      top: 18,
      left: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${card.overall}',
            style: TextStyle(
              fontSize: width * 0.16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF3D2B00),
              height: 1.0,
            ),
          ),
          Text(
            card.posicion,
            style: TextStyle(
              fontSize: width * 0.075,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3D2B00),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(double w, double h) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: h * 0.36,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF0EFED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Text(
              card.nombre,
              style: TextStyle(
                fontSize: w * 0.085,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C1A00),
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildStatsRow(w),
            const SizedBox(height: 10),
            Text(
              'FUT CARDS',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF8B6914),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(double w) {
    final stats = [
      ('RIT', card.ritmo),
      ('TIR', card.tiro),
      ('PAS', card.pase),
      ('REG', card.regate),
      ('DEF', card.defensa),
      ('FÍS', card.fisico),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats
          .map((s) => _statItem(s.$1, s.$2, w))
          .toList(),
    );
  }

  Widget _statItem(String label, int value, double w) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.038,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B6914),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: w * 0.075,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C1A00),
          ),
        ),
      ],
    );
  }
}

// ── Clipper escudo ────────────────────────────────────────────────────────────
class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.08, 0);
    path.lineTo(w * 0.92, 0);
    path.quadraticBezierTo(w, 0, w, h * 0.07);
    path.lineTo(w, h * 0.72);
    path.quadraticBezierTo(w, h * 0.93, w * 0.5, h);
    path.quadraticBezierTo(0, h * 0.93, 0, h * 0.72);
    path.lineTo(0, h * 0.07);
    path.quadraticBezierTo(0, 0, w * 0.08, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// ── División diagonal mármol / geométrico ────────────────────────────────────
class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.52, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

import 'package:flutter/material.dart';
import '../../domain/entities/fifa_card_entity.dart';

/// Panel inferior de la Carta FIFA: nombre + 6 estadísticas.
class FifaCardStatsPanel extends StatelessWidget {
  final FifaCardEntity card;
  final double cardWidth;

  const FifaCardStatsPanel({
    super.key,
    required this.card,
    required this.cardWidth,
  });

  static const _goldDark  = Color(0xFFD4AF37);
  static const _goldLight = Color(0xFFFFF0A0);
  static const _cream     = Color(0xFFF5ECD7);
  static const _navyDeep  = Color(0xFF060E28);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      padding: EdgeInsets.fromLTRB(
          cardWidth * 0.05, cardWidth * 0.04, cardWidth * 0.05, cardWidth * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A153A), _navyDeep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: _goldDark.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildName(),
          SizedBox(height: cardWidth * 0.028),
          _buildDivider(),
          SizedBox(height: cardWidth * 0.028),
          _buildStats(),
          SizedBox(height: cardWidth * 0.022),
          _buildBranding(),
        ],
      ),
    );
  }

  Widget _buildName() => Text(
        card.nombre.toUpperCase(),
        style: TextStyle(
          color: _cream,
          fontSize: cardWidth * 0.082,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          shadows: const [
            Shadow(color: Color(0xFFFFD700), blurRadius: 8, offset: Offset(0, 1)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );

  Widget _buildDivider() => Row(
        children: [
          Expanded(child: Container(height: 1, color: _goldDark.withValues(alpha: 0.3))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.025),
            child: Icon(Icons.sports_soccer_rounded, color: _goldDark, size: cardWidth * 0.045),
          ),
          Expanded(child: Container(height: 1, color: _goldDark.withValues(alpha: 0.3))),
        ],
      );

  Widget _buildStats() {
    final stats = [
      ('RIT', card.ritmo),
      ('TIR', card.tiro),
      ('PAS', card.pase),
      ('REG', card.regate),
      ('DEF', card.defensa),
      ('FÍS', card.fisico),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((s) => _statCol(s.$1, s.$2)).toList(),
    );
  }

  Widget _statCol(String label, int value) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: _goldDark,
              fontSize: cardWidth * 0.036,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: cardWidth * 0.01),
          Text(
            '$value',
            style: TextStyle(
              color: _goldLight,
              fontSize: cardWidth * 0.075,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      );

  Widget _buildBranding() => Text(
        'FUT CARDS',
        style: TextStyle(
          color: _goldDark.withValues(alpha: 0.6),
          fontSize: cardWidth * 0.032,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
        ),
      );
}

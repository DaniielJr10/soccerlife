import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';
import '../../../profile_picture/presentation/widgets/profile_avatar_widget.dart';

/// Cabecera del dashboard  diseño moderno con avatar amplio,
/// badge de rating real y decoración de fondo.
class DashboardHeader extends StatelessWidget {
  final UsuarioModel usuario;
  final bool cargando;
  final Uint8List? photoBytes;
  final double? rating;

  const DashboardHeader({
    super.key,
    required this.usuario,
    this.cargando = false,
    this.photoBytes,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _HeaderBackground()),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(usuario: usuario, photoBytes: photoBytes),
              const SizedBox(width: 16),
              Expanded(child: _Info(usuario: usuario, cargando: cargando)),
              const SizedBox(width: 12),
              if (rating != null && rating! > 0) _RatingBadge(rating: rating!),
            ],
          ),
        ),
      ],
    );
  }
}

//  Fondo decorativo 

class _HeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiamondPatternPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, Color(0xFF0D1627)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width, 0),
        radius: size.height * 1.5,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//  Avatar 

class _Avatar extends StatelessWidget {
  final UsuarioModel usuario;
  final Uint8List? photoBytes;
  const _Avatar({required this.usuario, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: ProfileAvatarWidget(
                nombre: usuario.nombre,
                imageBytes: photoBytes,
                radius: 33,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

//  Info 

class _Info extends StatelessWidget {
  final UsuarioModel usuario;
  final bool cargando;
  const _Info({required this.usuario, required this.cargando});

  String _saludo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días,';
    if (h < 18) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Skeleton(width: 80, height: 11),
          SizedBox(height: 6),
          _Skeleton(width: 130, height: 18),
          SizedBox(height: 8),
          _Skeleton(width: 90, height: 22),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _saludo(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          usuario.nombre.isEmpty ? 'Jugador' : usuario.nombre,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (usuario.posicion.isNotEmpty) ...[
              _Chip(
                text: usuario.posicion,
                color: AppColors.primary,
                icon: Icons.sports_soccer_rounded,
              ),
              const SizedBox(width: 6),
            ],
            if (usuario.club.isNotEmpty)
              Flexible(
                child: _Chip(
                  text: usuario.club,
                  color: AppColors.secondary,
                  icon: Icons.shield_rounded,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Chip({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

//  Rating Badge 

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  Color get _color {
    if (rating >= 8) return AppColors.success;
    if (rating >= 6) return AppColors.primary;
    if (rating >= 4) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.25),
            _color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: _color, size: 16),
          const SizedBox(height: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: _color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rating',
            style: TextStyle(
              color: _color.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

//  Skeleton 

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;
  const _Skeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

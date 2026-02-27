import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';
import '../../../profile_picture/presentation/widgets/profile_avatar_widget.dart';

/// Cabecera premium del dashboard con diseño moderno glassmorphism.
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 170,
          child: Stack(
          children: [
            // Fondo base oscuro
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF253656), Color(0xFF2A3F68), Color(0xFF1E2E4E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Orb 1 — verde esmeralda detrás del avatar
            Positioned(
              top: -40,
              left: -30,
              child: _GlowOrb(
                size: 200,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            // Orb 2 — azul/secundario en esquina derecha
            Positioned(
              bottom: -50,
              right: -20,
              child: _GlowOrb(
                size: 180,
                color: AppColors.secondary.withValues(alpha: 0.28),
              ),
            ),
            // Orb 3 — acento dorado sutil en el centro
            Positioned(
              top: 10,
              right: 80,
              child: _GlowOrb(
                size: 100,
                color: AppColors.warning.withValues(alpha: 0.18),
              ),
            ),
            // Líneas de cuadrícula decorativas
            Positioned.fill(child: CustomPaint(painter: _GridLinePainter())),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PremiumAvatar(usuario: usuario, photoBytes: photoBytes),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _Info(usuario: usuario, cargando: cargando),
                  ),
                  if (rating != null && rating! > 0) ...[
                    const SizedBox(width: 14),
                    _RatingBadge(rating: rating!),
                  ],
                ],
              ),
            ),
            // Línea luminosa inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.5),
                      AppColors.secondary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ── Orb de luz difusa ──────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ── Líneas de cuadrícula sutiles ───────────────────────────────────────────────

class _GridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;
    const gap = 32.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final diag = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.14)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width, size.height * 0.7),
      diag,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Avatar premium con anillo de luz ──────────────────────────────────────────

class _PremiumAvatar extends StatelessWidget {
  final UsuarioModel usuario;
  final Uint8List? photoBytes;
  const _PremiumAvatar({required this.usuario, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Anillo exterior con degradado cónico (sweep)
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.primary,
              ],
              startAngle: 0,
              endAngle: math.pi * 2,
            ),
          ),
        ),
        // Separador interno
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF253656),
          ),
        ),
        // Foto / iniciales
        ClipOval(
          child: SizedBox(
            width: 76,
            height: 76,
            child: ProfileAvatarWidget(
              nombre: usuario.nombre,
              imageBytes: photoBytes,
              radius: 38,
            ),
          ),
        ),
        // Indicador online
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF253656), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Info central ──────────────────────────────────────────────────────────────

class _Info extends StatelessWidget {
  final UsuarioModel usuario;
  final bool cargando;
  const _Info({required this.usuario, required this.cargando});

  String _saludo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Skeleton(width: 90, height: 11),
          SizedBox(height: 8),
          _Skeleton(width: 140, height: 22),
          SizedBox(height: 10),
          _Skeleton(width: 100, height: 20),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Saludo con punto luminoso
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _saludo(),
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Nombre con degradado de texto
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFB0C4DE)],
          ).createShader(bounds),
          child: Text(
            usuario.nombre.isEmpty ? 'Jugador' : usuario.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        // Chips posición / club
        Row(
          children: [
            if (usuario.posicion.isNotEmpty) ...[
              _PillChip(
                text: usuario.posicion,
                color: AppColors.primary,
                icon: Icons.sports_soccer_rounded,
              ),
              const SizedBox(width: 6),
            ],
            if (usuario.club.isNotEmpty)
              Flexible(
                child: _PillChip(
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

// ── Chip estilo píldora ───────────────────────────────────────────────────────

class _PillChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _PillChip({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 6),
        ],
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
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating Badge premium ──────────────────────────────────────────────────────

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
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.22),
            _color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: _color.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [_color, _color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(b),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: _color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: [
                Shadow(color: _color.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'RATING',
            style: TextStyle(
              color: _color.withValues(alpha: 0.65),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

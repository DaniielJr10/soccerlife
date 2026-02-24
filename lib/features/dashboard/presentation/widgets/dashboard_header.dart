import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';

/// Cabecera del dashboard: saludo, nombre y posición del jugador.
class DashboardHeader extends StatelessWidget {
  final UsuarioModel usuario;
  final bool cargando;

  const DashboardHeader({
    super.key,
    required this.usuario,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          _Avatar(usuario: usuario),
          const SizedBox(width: 14),
          Expanded(child: _Info(usuario: usuario, cargando: cargando)),
          _RatingBadge(rating: null),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final UsuarioModel usuario;
  const _Avatar({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text(
          usuario.iniciales,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final UsuarioModel usuario;
  final bool cargando;
  const _Info({required this.usuario, required this.cargando});

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Skeleton(width: 100, height: 14),
          SizedBox(height: 6),
          _Skeleton(width: 60, height: 12),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          usuario.nombre.isEmpty ? 'Jugador' : usuario.nombre,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            if (usuario.posicion.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  usuario.posicion,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (usuario.club.isNotEmpty)
              Text(
                usuario.club,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double? rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            rating!.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Rating',
            style: TextStyle(color: AppColors.textOnPrimary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

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

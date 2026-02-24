import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget de avatar reutilizable.
/// Muestra la foto de perfil si existe; de lo contrario las iniciales del nombre.
///
/// Parámetros:
/// - [imageBytes]  bytes de la imagen (null → muestra iniciales)
/// - [nombre]      nombre del usuario para generar las iniciales
/// - [radius]      radio del avatar (default 48)
/// - [onTap]       callback cuando el usuario toca el avatar
/// - [showEditBadge] muestra el badge de lápiz sobre el avatar
class ProfileAvatarWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final String nombre;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const ProfileAvatarWidget({
    super.key,
    required this.nombre,
    this.imageBytes,
    this.radius = 48,
    this.onTap,
    this.showEditBadge = false,
  });

  String get _initials {
    final parts = nombre.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
      child: imageBytes == null
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.65,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          : null,
    );

    final decorated = showEditBadge
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: radius * 0.7,
                  height: radius * 0.7,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.background, width: 2),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: radius * 0.35),
                ),
              ),
            ],
          )
        : avatar;

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: decorated);
    }
    return decorated;
  }
}

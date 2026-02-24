import 'dart:typed_data';

/// Entidad de dominio para la foto de perfil del usuario.
class ProfilePictureEntity {
  /// Bytes de la imagen (null si no tiene foto).
  final Uint8List? imageBytes;

  const ProfilePictureEntity({this.imageBytes});

  bool get tieneFoto => imageBytes != null;

  ProfilePictureEntity copyWith({Uint8List? imageBytes}) =>
      ProfilePictureEntity(imageBytes: imageBytes);

  /// Entidad vacía — sin foto cargada.
  const ProfilePictureEntity.empty() : imageBytes = null;
}

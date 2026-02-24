import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/storage_service.dart';
import '../domain/entities/profile_picture_entity.dart';

/// Resultado genérico de las operaciones de foto de perfil.
class ProfilePictureResult {
  final bool success;
  final String? message;
  final ProfilePictureEntity? entity;

  const ProfilePictureResult({
    required this.success,
    this.message,
    this.entity,
  });
}

/// Servicio CRUD para la foto de perfil — sincroniza con MongoDB.
class ProfilePictureService {
  static final _base = '${ApiConfig.baseUrl}/usuarios/foto-perfil';

  // ── Helper de cabeceras ──────────────────────────────────────────────────

  static Future<Map<String, String>?> _headers() async {
    final token = await StorageService.obtenerToken();
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Obtener foto ─────────────────────────────────────────────────────────

  /// Descarga la foto de perfil desde MongoDB.
  /// Devuelve `entity.imageBytes == null` si el usuario no tiene foto.
  static Future<ProfilePictureResult> obtenerFoto() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const ProfilePictureResult(
            success: false, message: 'No autenticado.');
      }

      final res = await http
          .get(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['fotoPerfil'] as String?;

        if (raw == null || raw.isEmpty) {
          return const ProfilePictureResult(
              success: true, entity: ProfilePictureEntity.empty());
        }

        // El servidor puede devolver base64 puro o con prefijo data:image/...
        final base64Str =
            raw.contains(',') ? raw.split(',').last : raw;
        final bytes = base64Decode(base64Str);
        return ProfilePictureResult(
          success: true,
          entity: ProfilePictureEntity(imageBytes: bytes),
        );
      }
      return ProfilePictureResult(
          success: false, message: 'Error (${res.statusCode})');
    } on Exception catch (e) {
      return ProfilePictureResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Guardar foto ─────────────────────────────────────────────────────────

  /// Sube la foto al servidor en base64.
  static Future<ProfilePictureResult> guardarFoto(Uint8List bytes) async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const ProfilePictureResult(
            success: false, message: 'No autenticado.');
      }

      final fotoBase64 = base64Encode(bytes);
      final body = jsonEncode({'fotoBase64': fotoBase64});

      final res = await http
          .put(Uri.parse(_base), headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ProfilePictureResult(
          success: true,
          message: 'Foto guardada correctamente.',
          entity: ProfilePictureEntity(imageBytes: bytes),
        );
      }
      return ProfilePictureResult(
          success: false,
          message: 'Error del servidor (${res.statusCode}).');
    } on Exception catch (e) {
      return ProfilePictureResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Eliminar foto ────────────────────────────────────────────────────────

  /// Elimina la foto de perfil del usuario en MongoDB.
  static Future<ProfilePictureResult> eliminarFoto() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const ProfilePictureResult(
            success: false, message: 'No autenticado.');
      }

      final res = await http
          .delete(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return const ProfilePictureResult(
          success: true,
          message: 'Foto eliminada correctamente.',
          entity: ProfilePictureEntity.empty(),
        );
      }
      return ProfilePictureResult(
          success: false,
          message: 'Error (${res.statusCode})');
    } on Exception catch (e) {
      return ProfilePictureResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

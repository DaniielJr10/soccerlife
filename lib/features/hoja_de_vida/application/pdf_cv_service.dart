import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/storage_service.dart';

/// Resultado de las operaciones de CV PDF.
class PdfUploadResult {
  final bool success;
  final String? message;
  /// Nombre del archivo almacenado (solo en obtenerInfoCv).
  final String? cvNombre;
  const PdfUploadResult({
    required this.success,
    this.message,
    this.cvNombre,
  });
}

/// Servicio CRUD para el CV en PDF del usuario — sincroniza con MongoDB.
class PdfCvService {
  static final _base = '${ApiConfig.baseUrl}/usuarios/cv';

  static Future<Map<String, String>?> _headers() async {
    final token = await StorageService.obtenerToken();
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Obtener info del CV ──────────────────────────────────────────────────

  /// Consulta si el usuario tiene CV guardado y devuelve su nombre.
  /// No descarga los bytes del PDF.
  static Future<PdfUploadResult> obtenerInfoCv() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const PdfUploadResult(
            success: false, message: 'No autenticado.');
      }
      final res = await http
          .get(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return PdfUploadResult(
          success: true,
          cvNombre: body['cvNombre'] as String?,
        );
      }
      return PdfUploadResult(
          success: false,
          message: 'Error (${res.statusCode})');
    } on Exception catch (e) {
      return PdfUploadResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Subir / reemplazar CV ────────────────────────────────────────────────

  /// Envía el PDF codificado en base64 al backend.
  static Future<PdfUploadResult> subirCv({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const PdfUploadResult(
            success: false, message: 'No autenticado. Inicia sesión de nuevo.');
      }

      final body = jsonEncode({
        'cvBase64': base64Encode(bytes),
        'cvNombre': filename,
      });

      final res = await http
          .post(Uri.parse(_base), headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return const PdfUploadResult(
            success: true, message: 'CV subido correctamente.');
      }
      return PdfUploadResult(
          success: false,
          message: 'Error del servidor (${res.statusCode}). Intenta de nuevo.');
    } on Exception catch (e) {
      return PdfUploadResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Eliminar CV ──────────────────────────────────────────────────────────

  /// Elimina el CV del usuario de MongoDB.
  static Future<PdfUploadResult> eliminarCv() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const PdfUploadResult(
            success: false, message: 'No autenticado.');
      }
      final res = await http
          .delete(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return const PdfUploadResult(
            success: true, message: 'CV eliminado correctamente.');
      }
      return PdfUploadResult(
          success: false,
          message: 'Error (${res.statusCode})');
    } on Exception catch (e) {
      return PdfUploadResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

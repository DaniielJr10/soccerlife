import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/storage_service.dart';

/// Resultado de la operación de subida de CV.
class PdfUploadResult {
  final bool success;
  final String? message;
  const PdfUploadResult({required this.success, this.message});
}

/// Servicio para subir el CV en PDF al backend del usuario.
class PdfCvService {
  /// Sube el PDF usando multipart/form-data.
  /// [bytes]    — bytes binarios del archivo.
  /// [filename] — nombre original del archivo.
  static Future<PdfUploadResult> subirCv({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final token = await StorageService.obtenerToken();
      if (token == null) {
        return const PdfUploadResult(
            success: false, message: 'No autenticado. Inicia sesión de nuevo.');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/usuarios/cv');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'cv',
          bytes,
          filename: filename,
        ));

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const PdfUploadResult(success: true, message: 'CV subido correctamente.');
      } else {
        return PdfUploadResult(
          success: false,
          message: 'Error del servidor (${response.statusCode}). Intenta de nuevo.',
        );
      }
    } on Exception catch (e) {
      return PdfUploadResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

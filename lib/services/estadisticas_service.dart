import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/**
 * Servicio de API para Estadísticas
 */
class EstadisticasService {
  static String get baseUrl => '${ApiConfig.baseUrl}/estadisticas';

  /// Obtener estadísticas del usuario
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final url = Uri.parse(baseUrl);
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'estadisticas': data['estadisticas'],
        };
      } else {
        String? message;
        try {
          final data = json.decode(response.body);
          message = data['message']?.toString();
        } catch (_) {
          // Ignorar parseo si el backend no envía JSON
        }
        return {
          'success': false,
          'message': message ?? 'Error al obtener estadísticas',
          'estadisticas': null,
        };
      }
    } catch (e) {
      print('❌ Error en obtenerEstadisticas: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'estadisticas': null,
      };
    }
  }
}

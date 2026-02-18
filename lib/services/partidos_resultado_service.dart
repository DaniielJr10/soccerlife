import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/**
 * Servicio para registrar resultados de partidos
 */
class PartidosResultadoService {
  static String get baseUrl => '${ApiConfig.baseUrl}/partidos';

  /// Registrar resultado de un partido
  static Future<Map<String, dynamic>> registrarResultado({
    required String partidoId,
    required int golesLocal,
    required int golesVisitante,
    int goles = 0,
    int asistencias = 0,
    int tarjetasAmarillas = 0,
    int tarjetasRojas = 0,
    int minutosJugados = 0,
    double? valoracion,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$partidoId/resultado');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = {
        'golesLocal': golesLocal,
        'golesVisitante': golesVisitante,
        'goles': goles,
        'asistencias': asistencias,
        'tarjetasAmarillas': tarjetasAmarillas,
        'tarjetasRojas': tarjetasRojas,
        'minutosJugados': minutosJugados,
        if (valoracion != null) 'valoracion': valoracion,
      };

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Resultado registrado exitosamente',
          'partido': json.decode(response.body)['partido'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al registrar resultado',
        };
      }
    } catch (e) {
      print('❌ Error en registrarResultado: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

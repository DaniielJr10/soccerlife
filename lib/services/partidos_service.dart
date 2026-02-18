import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/**
 * Servicio de API para Partidos
 * Maneja todas las operaciones relacionadas con partidos
 */
class PartidosService {
  static String get baseUrl => '${ApiConfig.baseUrl}/partidos';

  /// Crear un nuevo partido
  static Future<Map<String, dynamic>> crearPartido({
    required String equipoRival,
    required DateTime fecha,
    required String hora,
    required String lugar,
    String tipo = 'Amistoso',
    String? notas,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = {
        'equipoRival': equipoRival,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'lugar': lugar,
        'tipo': tipo,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Partido creado exitosamente',
          'partido': json.decode(response.body)['partido'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al crear partido',
        };
      }
    } catch (e) {
      print('❌ Error en crearPartido: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener partidos futuros (programados)
  static Future<Map<String, dynamic>> obtenerPartidosFuturos() async {
    try {
      final url = Uri.parse('$baseUrl/futuros');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'partidos': data['partidos'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener partidos futuros',
          'partidos': [],
        };
      }
    } catch (e) {
      print('❌ Error en obtenerPartidosFuturos: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'partidos': [],
      };
    }
  }

  /// Obtener partidos jugados (finalizados)
  static Future<Map<String, dynamic>> obtenerPartidosJugados({int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/jugados?limit=$limit');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'partidos': data['partidos'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener partidos jugados',
          'partidos': [],
        };
      }
    } catch (e) {
      print('❌ Error en obtenerPartidosJugados: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'partidos': [],
      };
    }
  }

  /// Actualizar partido
  static Future<Map<String, dynamic>> actualizarPartido({
    required String partidoId,
    String? equipoRival,
    DateTime? fecha,
    String? hora,
    String? lugar,
    String? tipo,
    String? notas,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$partidoId');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = <String, dynamic>{};
      if (equipoRival != null) body['equipoRival'] = equipoRival;
      if (fecha != null) body['fecha'] = fecha.toIso8601String();
      if (hora != null) body['hora'] = hora;
      if (lugar != null) body['lugar'] = lugar;
      if (tipo != null) body['tipo'] = tipo;
      if (notas != null) body['notas'] = notas;

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Partido actualizado exitosamente',
          'partido': json.decode(response.body)['partido'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar partido',
        };
      }
    } catch (e) {
      print('❌ Error en actualizarPartido: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Eliminar partido
  static Future<Map<String, dynamic>> eliminarPartido(String partidoId) async {
    try {
      final url = Uri.parse('$baseUrl/$partidoId');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Partido eliminado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al eliminar partido',
        };
      }
    } catch (e) {
      print('❌ Error en eliminarPartido: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

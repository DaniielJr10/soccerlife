import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/**
 * Servicio de API para Entrenamientos
 */
class EntrenamientosService {
  static String get baseUrl => '${ApiConfig.baseUrl}/entrenamientos';

  /// Crear un nuevo entrenamiento
  static Future<Map<String, dynamic>> crearEntrenamiento({
    required DateTime fecha,
    required int duracion,
    required String tipo,
    required String ubicacion,
    required String objetivos,
    List<String>? habilidadesTrabajadas,
    String? notas,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = {
        'fecha': fecha.toIso8601String(),
        'duracion': duracion,
        'tipo': tipo,
        'ubicacion': ubicacion,
        'objetivos': objetivos,
        if (habilidadesTrabajadas != null && habilidadesTrabajadas.isNotEmpty)
          'habilidadesTrabajadas': habilidadesTrabajadas,
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
          'message': 'Entrenamiento creado exitosamente',
          'entrenamiento': json.decode(response.body)['entrenamiento'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al crear entrenamiento',
        };
      }
    } catch (e) {
      print('❌ Error en crearEntrenamiento: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener entrenamientos próximos
  static Future<Map<String, dynamic>> obtenerEntrenamientosProximos() async {
    try {
      final url = Uri.parse('$baseUrl/proximos');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'entrenamientos': data['entrenamientos'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener entrenamientos próximos',
          'entrenamientos': [],
        };
      }
    } catch (e) {
      print('❌ Error en obtenerEntrenamientosProximos: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'entrenamientos': [],
      };
    }
  }

  /// Obtener entrenamientos anteriores (completados)
  static Future<Map<String, dynamic>> obtenerEntrenamientosAnteriores({int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/anteriores?limit=$limit');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'entrenamientos': data['entrenamientos'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener entrenamientos anteriores',
          'entrenamientos': [],
        };
      }
    } catch (e) {
      print('❌ Error en obtenerEntrenamientosAnteriores: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'entrenamientos': [],
      };
    }
  }

  /// Actualizar un entrenamiento existente
  static Future<Map<String, dynamic>> actualizarEntrenamiento({
    required String entrenamientoId,
    DateTime? fecha,
    int? duracion,
    String? tipo,
    String? ubicacion,
    String? objetivos,
    List<String>? habilidadesTrabajadas,
    String? notas,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$entrenamientoId');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = <String, dynamic>{};
      if (fecha != null) body['fecha'] = fecha.toIso8601String();
      if (duracion != null) body['duracion'] = duracion;
      if (tipo != null) body['tipo'] = tipo;
      if (ubicacion != null) body['ubicacion'] = ubicacion;
      if (objetivos != null) body['objetivos'] = objetivos;
      if (habilidadesTrabajadas != null) body['habilidadesTrabajadas'] = habilidadesTrabajadas;
      if (notas != null) body['notas'] = notas;

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Entrenamiento actualizado exitosamente',
          'entrenamiento': json.decode(response.body)['entrenamiento'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar entrenamiento',
        };
      }
    } catch (e) {
      print('❌ Error en actualizarEntrenamiento: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Marcar entrenamiento como completado
  static Future<Map<String, dynamic>> completarEntrenamiento({
    required String entrenamientoId,
    String intensidad = 'Media',
    double? valoracion,
    List<String>? habilidadesTrabajadas,
    String? notas,
    String? lesiones,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$entrenamientoId/completar');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final body = {
        'intensidad': intensidad,
        if (valoracion != null) 'valoracion': valoracion,
        if (habilidadesTrabajadas != null) 'habilidadesTrabajadas': habilidadesTrabajadas,
        if (notas != null) 'notas': notas,
        if (lesiones != null) 'lesiones': lesiones,
      };

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Entrenamiento completado exitosamente',
          'entrenamiento': json.decode(response.body)['entrenamiento'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al completar entrenamiento',
        };
      }
    } catch (e) {
      print('❌ Error en completarEntrenamiento: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Eliminar entrenamiento
  static Future<Map<String, dynamic>> eliminarEntrenamiento(String entrenamientoId) async {
    try {
      final url = Uri.parse('$baseUrl/$entrenamientoId');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Entrenamiento eliminado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al eliminar entrenamiento',
        };
      }
    } catch (e) {
      print('❌ Error en eliminarEntrenamiento: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

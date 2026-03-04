import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/// Servicio de API para Logros
class LogrosService {
  static String get baseUrl => '${ApiConfig.baseUrl}/logros';

  /// Obtener logros del usuario con progreso
  static Future<Map<String, dynamic>> obtenerLogrosUsuario() async {
    try {
      final url = Uri.parse('$baseUrl/mis-logros');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'logros': data['logros'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener logros',
          'logros': [],
        };
      }
    } catch (e) {
      debugPrint('❌ Error en obtenerLogrosUsuario: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'logros': [],
      };
    }
  }

  /// Verificar y desbloquear nuevos logros
  static Future<Map<String, dynamic>> verificarLogros() async {
    try {
      final url = Uri.parse('$baseUrl/verificar');
      final headers = await AuthService.obtenerHeadersAutenticados();

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'logrosDesbloqueados': data['logrosDesbloqueados'] ?? [],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al verificar logros',
          'logrosDesbloqueados': [],
        };
      }
    } catch (e) {
      debugPrint('❌ Error en verificarLogros: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'logrosDesbloqueados': [],
      };
    }
  }
}

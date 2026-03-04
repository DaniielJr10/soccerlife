import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserRecuperarService {
  // URL base de tu API - Ahora usa configuración dinámica
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Generar código de recuperación de 4 dígitos (solo uso local/testing)
  static String _generarCodigoRecuperacion() {
    Random random = Random();
    String codigo = '';
    for (int i = 0; i < 4; i++) {
      codigo += random.nextInt(10).toString();
    }
    return codigo;
  }

  // Solicitar recuperación de contraseña por email
  static Future<Map<String, dynamic>> solicitarRecuperacionPorEmail({
    required String email,
  }) async {
    try {
      debugPrint('🔗 Solicitando recuperación por email: $email');
      final url = Uri.parse('$baseUrl/usuarios/recuperar-password/email');
      
      final body = {
        'email': email,
      };

      debugPrint('📤 Enviando solicitud de recuperación: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('📥 Respuesta del servidor - Status: ${response.statusCode}');
      debugPrint('📥 Respuesta del servidor - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Código de recuperación enviado a tu email',
          'codigo': responseData['codigo'], // Para testing - en producción no se devuelve
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al enviar código de recuperación',
        };
      }
    } catch (e) {
      debugPrint('❌ Error en solicitarRecuperacionPorEmail: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet.',
      };
    }
  }



  // Verificar código de recuperación
  static Future<Map<String, dynamic>> verificarCodigoRecuperacion({
    required String email,
    required String codigo,
  }) async {
    try {
      debugPrint('🔗 Verificando código de recuperación');
      final url = Uri.parse('$baseUrl/usuarios/verificar-codigo-recuperacion');
      
      final Map<String, dynamic> body = {
        'email': email,
        'codigo': codigo,
      };

      debugPrint('📤 Enviando verificación de código: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('📥 Respuesta del servidor - Status: ${response.statusCode}');
      debugPrint('📥 Respuesta del servidor - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Código verificado correctamente',
          'token': responseData['token'], // Token para cambiar contraseña
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Código incorrecto o expirado',
        };
      }
    } catch (e) {
      debugPrint('❌ Error en verificarCodigoRecuperacion: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  // Cambiar contraseña con token de recuperación
  static Future<Map<String, dynamic>> cambiarPasswordConToken({
    required String token,
    required String nuevaPassword,
  }) async {
    try {
      debugPrint('🔗 Cambiando contraseña con token');
      final url = Uri.parse('$baseUrl/usuarios/cambiar-password-recuperacion');
      
      final body = {
        'token': token,
        'nuevaPassword': nuevaPassword,
      };

      debugPrint('📤 Enviando cambio de contraseña');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('📥 Respuesta del servidor - Status: ${response.statusCode}');
      debugPrint('📥 Respuesta del servidor - Body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Contraseña cambiada exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al cambiar contraseña',
        };
      }
    } catch (e) {
      debugPrint('❌ Error en cambiarPasswordConToken: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet.',
      };
    }
  }

  // Método local para generar código (para testing)
  static String generarCodigoLocal() {
    return _generarCodigoRecuperacion();
  }
}
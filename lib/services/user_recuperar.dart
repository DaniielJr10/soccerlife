import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class UserRecuperarService {
  // URL base de tu API
  static const String baseUrl = 'http://192.168.1.44:3000/api';
  
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
      print('🔗 Solicitando recuperación por email: $email');
      final url = Uri.parse('$baseUrl/usuarios/recuperar-password/email');
      
      final body = {
        'email': email,
      };

      print('📤 Enviando solicitud de recuperación: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Respuesta del servidor - Status: ${response.statusCode}');
      print('📥 Respuesta del servidor - Body: ${response.body}');

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
      print('❌ Error en solicitarRecuperacionPorEmail: $e');
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
      print('🔗 Verificando código de recuperación');
      final url = Uri.parse('$baseUrl/usuarios/verificar-codigo-recuperacion');
      
      final Map<String, dynamic> body = {
        'email': email,
        'codigo': codigo,
      };

      print('📤 Enviando verificación de código: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Respuesta del servidor - Status: ${response.statusCode}');
      print('📥 Respuesta del servidor - Body: ${response.body}');

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
      print('❌ Error en verificarCodigoRecuperacion: $e');
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
      print('🔗 Cambiando contraseña con token');
      final url = Uri.parse('$baseUrl/usuarios/cambiar-password-recuperacion');
      
      final body = {
        'token': token,
        'nuevaPassword': nuevaPassword,
      };

      print('📤 Enviando cambio de contraseña');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Respuesta del servidor - Status: ${response.statusCode}');
      print('📥 Respuesta del servidor - Body: ${response.body}');

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
      print('❌ Error en cambiarPasswordConToken: $e');
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
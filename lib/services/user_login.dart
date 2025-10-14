import 'dart:convert';
import 'package:http/http.dart' as http;

class UserLoginService {
  // URL base de tu API - Para navegador web
  static const String baseUrl = 'http://192.168.1.44:3000/api';
  
  // Login de usuario
  static Future<Map<String, dynamic>> loginUsuario({
    required String email,
    required String password,
  }) async {
    try {
      print('🔗 Intentando conectar a: $baseUrl/usuarios/login');
      final url = Uri.parse('$baseUrl/usuarios/login');
      
      final body = {
        'email': email,
        'password': password,
      };

      print('📤 Enviando datos de login: $body');

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
        // Login exitoso
        return {
          'success': true,
          'message': 'Inicio de sesión exitoso',
          'data': json.decode(response.body),
        };
      } else {
        // Error del servidor
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      // Error de conexión
      print('❌ Error capturado: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

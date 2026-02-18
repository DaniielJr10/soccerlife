import 'auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserRegistrationService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Registrar un nuevo usuario
  static Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    String posicion = 'Volante',
    int? numeroJugador,
    String? telefono,
    String? club,
    int? edad,
    double? estatura,
    int? peso,
  }) async {
    return await AuthService.registro(
      nombre: nombre,
      email: email,
      password: password,
      posicion: posicion,
      club: club,
      edad: edad,
      estatura: estatura,
      peso: peso,
    );
  }

  // Obtener todos los usuarios (admin)
  static Future<Map<String, dynamic>> obtenerUsuarios() async {
    try {
      final url = Uri.parse('$baseUrl/usuarios');
      final headers = await AuthService.obtenerHeadersAutenticados();
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener usuarios',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}


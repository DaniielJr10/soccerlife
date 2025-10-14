import 'dart:convert';
import 'package:http/http.dart' as http;

class UserRegistrationService {
  // URL base de tu API - Para navegador web
  static const String baseUrl = 'http://192.168.1.44:3000/api';
  
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
    try {
      print('🔗 Intentando conectar a: $baseUrl/usuarios');
      final url = Uri.parse('$baseUrl/usuarios');
      
      final body = {
        'nombre': nombre,
        'email': email,
        'password': password,
        'posicion': posicion,
        if (numeroJugador != null) 'numeroJugador': numeroJugador,
        if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        if (club != null && club.isNotEmpty) 'club': club,
        if (edad != null && edad > 0) 'edad': edad,
        if (estatura != null && estatura > 0) 'estatura': estatura,
        if (peso != null && peso > 0) 'peso': peso,
      };

      print('📤 Enviando datos: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Respuesta del servidor - Status: ${response.statusCode}');
      print('📥 Respuesta del servidor - Body: ${response.body}');

      if (response.statusCode == 201) {
        // Usuario creado exitosamente
        return {
          'success': true,
          'message': 'Usuario registrado exitosamente',
          'data': json.decode(response.body),
        };
      } else {
        // Error del servidor
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al registrar usuario',
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

  // Obtener todos los usuarios
  static Future<Map<String, dynamic>> obtenerUsuarios() async {
    try {
      final url = Uri.parse('$baseUrl/usuarios');
      
      final response = await http.get(url);

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

  // Login de usuario
  static Future<Map<String, dynamic>> loginUsuario({
    required String email,
    required String password,
  }) async {
    try {
      print('🔗 Intentando login en: $baseUrl/usuarios/login');
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
          'message': 'Login exitoso',
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

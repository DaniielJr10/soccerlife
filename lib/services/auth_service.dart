import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

/**
 * Servicio de Autenticación
 * Maneja login, registro, logout y estado de sesión
 */
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Login de usuario
  static Future<Map<String, dynamic>> login({
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

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Guardar token y datos del usuario
        if (data['token'] != null) {
          await StorageService.guardarToken(data['token']);
        }

        if (data['usuario'] != null) {
          final usuario = data['usuario'];
          await StorageService.guardarDatosUsuario(
            userId: usuario['_id'] ?? '',
            email: usuario['email'] ?? '',
            nombre: usuario['nombre'] ?? '',
          );
          await StorageService.guardarPerfilCompleto(
            posicion: usuario['posicion']?.toString() ?? '',
            club: usuario['club']?.toString() ?? '',
            edad: usuario['edad'] is int
                ? usuario['edad'] as int
                : int.tryParse(usuario['edad']?.toString() ?? '') ?? 0,
          );
        }

        return {
          'success': true,
          'message': 'Login exitoso',
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Registrar usuario
  static Future<Map<String, dynamic>> registro({
    required String nombre,
    required String email,
    required String password,
    String? posicion,
    String? club,
    int? edad,
    double? estatura,
    int? peso,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios');

      final body = {
        'nombre': nombre,
        'email': email,
        'password': password,
        if (posicion != null) 'posicion': posicion,
        if (club != null && club.isNotEmpty) 'club': club,
        if (edad != null && edad > 0) 'edad': edad,
        if (estatura != null && estatura > 0) 'estatura': (estatura * 100).round(),
        if (peso != null && peso > 0) 'peso': peso,
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Tiempo de espera agotado. Verifica tu conexión.'),
          );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Usuario registrado exitosamente',
          'data': json.decode(response.body),
        };
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body) as Map<String, dynamic>;
        } catch (_) {}
        // Mostrar el error detallado de Mongoose si está disponible
        final detalle = errorData['error']?.toString();
        final mensajeBase = errorData['message']?.toString() ?? 'Error al registrar usuario';
        final mensaje = (detalle != null && detalle.isNotEmpty)
            ? '$mensajeBase: $detalle'
            : mensajeBase;
        final esEmailDuplicado = mensajeBase.toLowerCase().contains('ya está registrado') ||
            mensajeBase.toLowerCase().contains('email') ||
            response.statusCode == 400 && errorData['code'] == 11000;
        return {
          'success': false,
          'message': mensaje,
          'emailDuplicado': esEmailDuplicado,
        };
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'emailDuplicado': false,
      };
    }
  }

  /// Cerrar sesión
  static Future<bool> logout() async {
    try {
      await StorageService.limpiarDatos();
      return true;
    } catch (e) {
      print('❌ Error en logout: $e');
      return false;
    }
  }

  /// Verificar si hay sesión activa
  static Future<bool> estaCertificadoAutenticado() async {
    return await StorageService.haySesionActiva();
  }

  /// Obtener token actual
  static Future<String?> obtenerToken() async {
    return await StorageService.obtenerToken();
  }

  /// Obtener headers con autenticación
  static Future<Map<String, String>> obtenerHeadersAutenticados() async {
    final token = await obtenerToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

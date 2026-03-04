import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

/// Servicio de Autenticación
/// Maneja login, registro, logout y estado de sesión
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Login de usuario
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔗 Intentando login en: $baseUrl/usuarios/login');
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

      debugPrint('📥 Status: ${response.statusCode}');

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
            estatura: usuario['estatura'] is double
                ? usuario['estatura'] as double
                : double.tryParse(usuario['estatura']?.toString() ?? '') ?? 0.0,
            peso: usuario['peso'] is int
                ? usuario['peso'] as int
                : int.tryParse(usuario['peso']?.toString() ?? '') ?? 0,
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
      debugPrint('❌ Error en login: $e');
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
      debugPrint('❌ Error en registro: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'emailDuplicado': false,
      };
    }
  }

  /// Actualizar perfil del usuario en la base de datos
  static Future<Map<String, dynamic>> actualizarPerfil({
    required String userId,
    required Map<String, dynamic> datos,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/$userId');
      final headers = await obtenerHeadersAutenticados();

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar perfil',
        };
      }
    } catch (e) {
      debugPrint('❌ Error actualizando perfil: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Cerrar sesión
  static Future<bool> logout() async {
    try {
      await StorageService.limpiarDatos();
      return true;
    } catch (e) {
      debugPrint('❌ Error en logout: $e');
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

  // ── Contraseña y cuenta ───────────────────────────────────────────────────

  /// Cambia la contraseña del usuario autenticado
  static Future<Map<String, dynamic>> cambiarPassword({
    required String actual,
    required String nueva,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/cambiar-password');
      final headers = await obtenerHeadersAutenticados();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({'passwordActual': actual, 'passwordNueva': nueva}),
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Error al cambiar contraseña'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Elimina la cuenta del usuario (soft delete) y limpia sesión local
  static Future<Map<String, dynamic>> eliminarCuenta() async {
    try {
      final userId = await StorageService.obtenerUserId();
      if (userId == null) return {'success': false, 'message': 'No se encontró el usuario'};
      final url = Uri.parse('$baseUrl/usuarios/$userId');
      final headers = await obtenerHeadersAutenticados();
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        await StorageService.limpiarDatos();
        return {'success': true};
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      return {'success': false, 'message': data['message'] ?? 'Error al eliminar cuenta'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ── Foto de perfil ────────────────────────────────────────────────────────

  /// Subir o reemplazar la foto de perfil en el servidor (base64 con prefijo data:image)
  static Future<Map<String, dynamic>> subirFotoPerfil(String fotoBase64) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/foto-perfil');
      final headers = await obtenerHeadersAutenticados();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'fotoBase64': fotoBase64}),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final err = json.decode(response.body);
      return {'success': false, 'message': err['message'] ?? 'Error al subir foto'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Obtener la foto de perfil desde el servidor (string base64 con prefijo o null)
  static Future<String?> obtenerFotoPerfilServidor() async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/foto-perfil');
      final headers = await obtenerHeadersAutenticados();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['existe'] == true) {
          return data['fotoPerfil'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Eliminar la foto de perfil del servidor
  static Future<bool> eliminarFotoPerfilServidor() async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/foto-perfil');
      final headers = await obtenerHeadersAutenticados();
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

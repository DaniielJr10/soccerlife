import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import 'storage_service.dart';

/// Servicio de perfil de usuario.
/// Fuente de verdad: MongoDB (colección `usuarios`).
/// SharedPreferences actúa solo como caché local para lectura rápida.
class ProfileService {
  static String get _base => '${ApiConfig.baseUrl}/usuarios';

  // ────────────────────────────────────────────────
  // GET /api/usuarios/mi-perfil
  // ────────────────────────────────────────────────
  /// Obtiene el perfil actualizado desde MongoDB y refresca la caché local.
  static Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      final headers = await AuthService.obtenerHeadersAutenticados();
      final res = await http.get(
        Uri.parse('$_base/mi-perfil'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final u = data['usuario'] as Map<String, dynamic>;
        await _actualizarCache(u);
        return {'success': true, 'usuario': u};
      }
      return {'success': false, 'message': 'Error al obtener perfil'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ────────────────────────────────────────────────
  // PUT /api/usuarios/mi-perfil
  // ────────────────────────────────────────────────
  /// Persiste los cambios en MongoDB y actualiza la caché local.
  static Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    required String posicion,
    required String club,
    required int edad,
    double estatura = 0.0,
    int peso = 0,
    String telefono = '',
    int numeroJugador = 0,
  }) async {
    try {
      final headers = await AuthService.obtenerHeadersAutenticados();
      final body = <String, dynamic>{
        'nombre': nombre,
        'posicion': posicion,
        'club': club,
        'edad': edad,
      };
      if (estatura > 0) body['estatura'] = estatura;
      if (peso > 0) body['peso'] = peso;
      if (telefono.isNotEmpty) body['telefono'] = telefono;
      if (numeroJugador > 0) body['numeroJugador'] = numeroJugador;

      final res = await http.put(
        Uri.parse('$_base/mi-perfil'),
        headers: headers,
        body: json.encode(body),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final u = data['usuario'] as Map<String, dynamic>;
        await _actualizarCache(u);
        return {'success': true, 'usuario': u};
      }
      final err = json.decode(res.body) as Map<String, dynamic>;
      return {
        'success': false,
        'message': err['message'] ?? 'Error al actualizar perfil',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────
  /// Sincroniza la caché SharedPreferences con datos frescos de MongoDB.
  static Future<void> _actualizarCache(Map<String, dynamic> u) async {
    final userId = await StorageService.obtenerUserId() ?? '';
    final email = u['email']?.toString() ?? await StorageService.obtenerUserEmail() ?? '';
    final nombre = u['nombre']?.toString() ?? '';

    await StorageService.guardarDatosUsuario(
      userId: userId,
      email: email,
      nombre: nombre,
    );
    await StorageService.guardarPerfilCompleto(
      posicion: u['posicion']?.toString() ?? '',
      club: u['club']?.toString() ?? '',
      edad: u['edad'] is int
          ? u['edad'] as int
          : int.tryParse(u['edad']?.toString() ?? '') ?? 0,
      estatura: u['estatura'] is double
          ? u['estatura'] as double
          : double.tryParse(u['estatura']?.toString() ?? '') ?? 0.0,
      peso: u['peso'] is int
          ? u['peso'] as int
          : int.tryParse(u['peso']?.toString() ?? '') ?? 0,
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/**
 * Servicio de almacenamiento local
 * Gestiona el guardado y recuperación de datos en el dispositivo
 */
class StorageService {
  // Keys para almacenamiento
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserNombre = 'user_nombre';
  static const String _keyUserData = 'user_data';

  /// Guardar token de autenticación
  static Future<bool> guardarToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyToken, token);
    } catch (e) {
      print('Error guardando token: $e');
      return false;
    }
  }

  /// Obtener token de autenticación
  static Future<String?> obtenerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  /// Guardar datos del usuario
  static Future<bool> guardarDatosUsuario({
    required String userId,
    required String email,
    required String nombre,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserNombre, nombre);
      return true;
    } catch (e) {
      print('Error guardando datos de usuario: $e');
      return false;
    }
  }

  /// Obtener ID del usuario
  static Future<String?> obtenerUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      print('Error obteniendo userId: $e');
      return null;
    }
  }

  /// Obtener email del usuario
  static Future<String?> obtenerUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      print('Error obteniendo email: $e');
      return null;
    }
  }

  /// Obtener nombre del usuario
  static Future<String?> obtenerUserNombre() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserNombre);
    } catch (e) {
      print('Error obteniendo nombre: $e');
      return null;
    }
  }

  /// Verificar si hay sesión activa
  static Future<bool> haySesionActiva() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  /// Limpiar todos los datos (cerrar sesión)
  static Future<bool> limpiarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserNombre);
      await prefs.remove(_keyUserData);
      return true;
    } catch (e) {
      print('Error limpiando datos: $e');
      return false;
    }
  }

  /// Guardar dato genérico
  static Future<bool> guardar(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      print('Error guardando $key: $e');
      return false;
    }
  }

  /// Obtener dato genérico
  static Future<String?> obtener(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('Error obteniendo $key: $e');
      return null;
    }
  }
}

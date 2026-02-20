import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';

/// Servicio de almacenamiento local.
/// Gestiona el guardado y recuperación de datos en el dispositivo.
class StorageService {
  // Keys para almacenamiento
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserNombre = 'user_nombre';
  static const String _keyUserData = 'user_data';
  static const String _keyUserPosicion = 'user_posicion';
  static const String _keyUserClub = 'user_club';
  static const String _keyUserEdad = 'user_edad';
  static const String _keyUserEstatura = 'user_estatura';
  static const String _keyUserPeso = 'user_peso';

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

  /// Guardar datos básicos del usuario
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

  /// Guardar perfil completo del usuario (incluyendo posición, club, edad, estatura y peso)
  static Future<bool> guardarPerfilCompleto({
    required String posicion,
    required String club,
    required int edad,
    double estatura = 0.0,
    int peso = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserPosicion, posicion);
      await prefs.setString(_keyUserClub, club);
      await prefs.setInt(_keyUserEdad, edad);
      await prefs.setDouble(_keyUserEstatura, estatura);
      await prefs.setInt(_keyUserPeso, peso);
      return true;
    } catch (e) {
      print('Error guardando perfil: $e');
      return false;
    }
  }

  /// Obtener posición del usuario
  static Future<String> obtenerUserPosicion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPosicion) ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Obtener club del usuario
  static Future<String> obtenerUserClub() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserClub) ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Obtener edad del usuario
  static Future<int> obtenerUserEdad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserEdad) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Obtener estatura del usuario (en metros)
  static Future<double> obtenerUserEstatura() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyUserEstatura) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Obtener peso del usuario (en kg)
  static Future<int> obtenerUserPeso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserPeso) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Obtener todos los datos del usuario como modelo
  static Future<UsuarioModel> obtenerUsuarioModel() async {
    final nombre = await obtenerUserNombre() ?? '';
    final email = await obtenerUserEmail() ?? '';
    final posicion = await obtenerUserPosicion();
    final club = await obtenerUserClub();
    final edad = await obtenerUserEdad();
    final estatura = await obtenerUserEstatura();
    final peso = await obtenerUserPeso();
    return UsuarioModel(
      nombre: nombre,
      email: email,
      posicion: posicion,
      club: club,
      edad: edad,
      estatura: estatura,
      peso: peso,
    );
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
      await prefs.remove(_keyUserPosicion);
      await prefs.remove(_keyUserClub);
      await prefs.remove(_keyUserEdad);
      await prefs.remove(_keyUserEstatura);
      await prefs.remove(_keyUserPeso);
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

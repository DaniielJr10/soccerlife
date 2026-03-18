import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuración para diferentes entornos
  static const String _casaIP = '192.168.1.45:3000';
  static const String _localhost = '127.0.0.1:3000';
  static const String _androidEmulator = '10.0.2.2:3000';
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
  
  // URLs para diferentes entornos
  static const String _baseUrlCasa = 'http://$_casaIP/api';
  static const String _baseUrlLocal = 'http://$_localhost/api';
  static const String _baseUrlAndroidEmulator = 'http://$_androidEmulator/api';

  static String _sanitizeUrl(String value) {
    // Evita fallos por espacios/saltos de línea en la configuración.
    return value.trim().replaceAll(RegExp(r'\s+'), '');
  }

  static String _normalizePath(String path) {
    final clean = path.trim();
    return clean.replaceFirst(RegExp(r'^/+'), '');
  }

  static Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final cleanBase = _sanitizeUrl(baseUrl);
    final baseUri = Uri.parse(cleanBase);
    final basePath = baseUri.path.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = _normalizePath(path);
    final query = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return baseUri.replace(
      path: '$basePath/$normalizedPath',
      queryParameters: query,
    );
  }
  
  // URL actual — detecta automáticamente la plataforma:
  // · Web / Windows / Linux / macOS (misma máquina) → localhost
  // · Android emulador → 10.0.2.2
  // · Android / iOS (dispositivo físico en la misma red) → IP local
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _sanitizeUrl(_overrideBaseUrl);
    }

    if (kIsWeb || (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS))) {
      return _sanitizeUrl(_baseUrlLocal); // localhost para web y desktop
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _sanitizeUrl(_baseUrlAndroidEmulator);
    }

    return _sanitizeUrl(_baseUrlCasa); // iOS/dispositivo físico
  }
  
  // Método para cambiar la configuración dinámicamente
  static String getUrlForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'casa':
        return _sanitizeUrl(_baseUrlCasa);
      case 'android-emulator':
        return _sanitizeUrl(_baseUrlAndroidEmulator);
      case 'local':
        return _sanitizeUrl(_baseUrlLocal);
      default:
        return _sanitizeUrl(_baseUrlLocal);
    }
  }
  
  // Para debugging
  static void printCurrentConfig() {
    debugPrint('🔧 URL actual de la API: $baseUrl');
  }
}
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuración para diferentes entornos
  static const String _casaIP = '192.168.1.45:3000';
  static const String _localhost = '127.0.0.1:3000';
  
  // URLs para diferentes entornos
  static const String _baseUrlCasa = 'http://$_casaIP/api';
  static const String _baseUrlLocal = 'http://$_localhost/api';
  
  // URL actual — detecta automáticamente la plataforma:
  // · Web / Windows / Linux / macOS (misma máquina) → localhost
  // · Android / iOS (dispositivo físico en la misma red) → IP local
  static String get baseUrl {
    if (kIsWeb || (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS))) {
      return _baseUrlLocal; // localhost para web y desktop
    }
    return _baseUrlCasa; // IP de red para dispositivos móviles
  }
  
  // Método para cambiar la configuración dinámicamente
  static String getUrlForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'casa':
        return _baseUrlCasa;
      case 'local':
        return _baseUrlLocal;
      default:
        return _baseUrlLocal;
    }
  }
  
  // Para debugging
  static void printCurrentConfig() {
    debugPrint('🔧 URL actual de la API: $baseUrl');
  }
}
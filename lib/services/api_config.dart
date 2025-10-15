class ApiConfig {
  // Configuración para diferentes entornos
  static const String _casaIP = '192.168.1.44:3000';
  static const String _localhost = 'localhost:3000';
  
  // URLs para diferentes entornos
  static const String _baseUrlCasa = 'http://$_casaIP/api';
  static const String _baseUrlLocal = 'http://$_localhost/api';
  
  // URL actual (cambiar según donde estés)
  static String get baseUrl {
    // Puedes cambiar esto manualmente o implementar detección automática
    return _baseUrlLocal; // Para usar en el mismo computador
    // return _baseUrlCasa; // Para usar desde otro dispositivo en tu casa
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
    print('🔧 URL actual de la API: $baseUrl');
  }
}
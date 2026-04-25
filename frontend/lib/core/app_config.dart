/// Configuración de la aplicación NRS Frontend
/// 
/// Este archivo contiene las configuraciones globales que pueden
/// ser ajustadas según el ambiente (desarrollo, prueba, producción)

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  late String _baseUrl;
  late bool _verbose;
  late int _requestTimeout;

  AppConfig._internal() {
    // Configuración por defecto
    _baseUrl = 'http://localhost:8080';
    _verbose = true;
    _requestTimeout = 30;
  }

  factory AppConfig() {
    return _instance;
  }

  /// Obtiene la URL base del backend
  String get baseUrl => _baseUrl;

  /// Establece la URL base del backend
  void setBaseUrl(String url) {
    _baseUrl = url;
    if (_verbose) {
      print('[AppConfig] Base URL configurada a: $_baseUrl');
    }
  }

  /// Obtiene si el modo verbose está habilitado
  bool get verbose => _verbose;

  /// Habilita o deshabilita el modo verbose
  void setVerbose(bool enabled) {
    _verbose = enabled;
  }

  /// Obtiene el timeout para requests
  int get requestTimeout => _requestTimeout;

  /// Establece el timeout para requests (en segundos)
  void setRequestTimeout(int seconds) {
    _requestTimeout = seconds;
  }

  /// Logea un mensaje si el modo verbose está habilitado
  void log(String message) {
    if (_verbose) {
      print('[NRS] $message');
    }
  }

  /// Logea un error
  void logError(String message) {
    print('[ERROR] $message');
  }

  /// Configura todos los parámetros para un ambiente específico
  void configureForEnvironment(Environment environment) {
    switch (environment) {
      case Environment.development:
        _baseUrl = 'http://localhost:8080';
        _verbose = true;
        _requestTimeout = 60;
        log('Ambiente: DESARROLLO');

      case Environment.staging:
        _baseUrl = 'http://staging.nrs.local:8080';
        _verbose = true;
        _requestTimeout = 30;
        log('Ambiente: STAGING');

      case Environment.production:
        _baseUrl = 'https://api.nrs.com';
        _verbose = false;
        _requestTimeout = 20;
        log('Ambiente: PRODUCCIÓN');
    }
  }
}

/// Ambientes disponibles
enum Environment {
  development,
  staging,
  production,
}

/// Instancia global de configuración
final appConfig = AppConfig();

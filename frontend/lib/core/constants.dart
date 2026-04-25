/// Constantes de la aplicación
class AppConstants {
  /// URL base del backend
  static const String baseUrl = 'http://localhost:8080';

  /// Endpoints del backend
  static const String loginEndpoint = '/auth/login';
  static const String studentLoginEndpoint = '/students/login';
  static const String studentRegisterEndpoint = '/students/register';
  static const String notebooksEndpoint = '/notebooks';
  static const String reservationsEndpoint = '/reservations';
  static const String checkoutsEndpoint = '/checkouts';
  static const String returnsEndpoint = '/returns';
  static const String watchlistEndpoint = '/watchlist';

  /// Claves de almacenamiento
  static const String tokenStorageKey = 'jwt_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';

  /// Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Timeout de requests (segundos)
  static const int requestTimeout = 30;
}

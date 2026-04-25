import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/auth_storage.dart';
import 'package:nrs_frontend/core/constants.dart';

/// Servicio de autenticación que maneja login de usuarios
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiClient _apiClient = ApiClient();
  final AuthStorage _authStorage = AuthStorage();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Login con email, password y role (admin/teacher/student)
  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        body: {
          'email': email,
          'password': password,
          'role': role,
        },
      );

      // Si la respuesta contiene un token, almacenarlo
      if (response is Map<String, dynamic>) {
        if (response.containsKey('token')) {
          await _authStorage.saveToken(response['token'] as String);
          await _authStorage.saveUserRole(role);
          if (response.containsKey('id')) {
            await _authStorage.saveUserId(response['id'] as String);
          }
        }
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en login: $e',
        originalError: e,
      );
    }
  }

  /// Login de estudiante con email y DNI
  /// POST /students/login
  Future<Map<String, dynamic>> studentLogin({
    required String email,
    required String dni,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.studentLoginEndpoint,
        body: {
          'email': email,
          'dni': dni,
        },
      );

      if (response is Map<String, dynamic>) {
        // Almacenar datos si es necesario (el endpoint puede retornar los datos del estudiante)
        if (response.containsKey('id')) {
          await _authStorage.saveUserId(response['id'] as String);
        }
        await _authStorage.saveUserRole('student');
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en login de estudiante: $e',
        originalError: e,
      );
    }
  }

  /// Registro de nuevo estudiante
  /// POST /students/register
  Future<Map<String, dynamic>> studentRegister({
    required String email,
    required String dni,
    required String name,
    required int year,
    required int division,
    String? specialty,
  }) async {
    try {
      final body = {
        'email': email,
        'dni': dni,
        'name': name,
        'year': year,
        'division': division,
      };

      // Agregar especialidad si se proporciona (solo para ciclo superior)
      if (specialty != null && specialty.isNotEmpty) {
        body['specialty'] = specialty;
      }

      final response = await _apiClient.post(
        AppConstants.studentRegisterEndpoint,
        body: body,
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('id')) {
          await _authStorage.saveUserId(response['id'] as String);
        }
        await _authStorage.saveUserRole('student');
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en registro de estudiante: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene el token actual almacenado
  Future<String?> getToken() async {
    return await _authStorage.getToken();
  }

  /// Obtiene el rol del usuario actual
  Future<String?> getUserRole() async {
    return await _authStorage.getUserRole();
  }

  /// Obtiene el ID del usuario actual
  Future<String?> getUserId() async {
    return await _authStorage.getUserId();
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    return await _authStorage.hasToken();
  }

  /// Cierra sesión y limpia los datos almacenados
  Future<void> logout() async {
    await _authStorage.clear();
  }
}

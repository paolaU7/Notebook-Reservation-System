import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'auth_storage.dart';

/// Excepción lanzada por el cliente API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Cliente HTTP para manejar todas las peticiones al backend
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final String _baseUrl = AppConstants.baseUrl;
  final AuthStorage _authStorage = AuthStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  /// Construye los headers para una petición, incluyendo el token si está disponible
  Future<Map<String, String>> _buildHeaders() async {
    final headers = Map<String, String>.from(AppConstants.defaultHeaders);
    final token = await _authStorage.getToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Realiza una petición GET
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _buildHeaders();

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: AppConstants.requestTimeout),
        onTimeout: () {
          throw ApiException(
            message: 'Request timeout',
            statusCode: null,
          );
        },
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en petición GET a $endpoint',
        originalError: e,
      );
    }
  }

  /// Realiza una petición POST
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _buildHeaders();

      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            const Duration(seconds: AppConstants.requestTimeout),
            onTimeout: () {
              throw ApiException(
                message: 'Request timeout',
                statusCode: null,
              );
            },
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en petición POST a $endpoint',
        originalError: e,
      );
    }
  }

  /// Realiza una petición PATCH
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _buildHeaders();

      final response = await http
          .patch(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            const Duration(seconds: AppConstants.requestTimeout),
            onTimeout: () {
              throw ApiException(
                message: 'Request timeout',
                statusCode: null,
              );
            },
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en petición PATCH a $endpoint',
        originalError: e,
      );
    }
  }

  /// Procesa la respuesta HTTP y lanza excepciones si es necesario
  dynamic _handleResponse(http.Response response) {
    try {
      // Intenta decodificar el JSON
      final decoded = jsonDecode(response.body);

      // Si el status code indica error, lanza excepción
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage =
            decoded['error'] ?? 'Error en la respuesta del servidor';
        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }

      return decoded;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error decodificando respuesta: ${response.statusCode}',
        statusCode: response.statusCode,
        originalError: e,
      );
    }
  }
}

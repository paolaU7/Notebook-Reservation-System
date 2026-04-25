import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/constants.dart';

/// Servicio para manejar operaciones de observación de dispositivos
class WatchlistService {
  static final WatchlistService _instance = WatchlistService._internal();
  final ApiClient _apiClient = ApiClient();

  factory WatchlistService() {
    return _instance;
  }

  WatchlistService._internal();

  /// Obtiene la lista de supervisión de dispositivos (admin)
  /// GET /watchlist
  Future<List<dynamic>> getWatchlist() async {
    try {
      final response = await _apiClient.get(AppConstants.watchlistEndpoint);

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> &&
          response.containsKey('watchlist')) {
        final watchlist = response['watchlist'];
        if (watchlist is List) {
          return watchlist;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo lista de supervisión: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene detalles de un elemento en la lista de supervisión
  /// GET /watchlist/:id
  Future<Map<String, dynamic>> getWatchlistItem(String itemId) async {
    try {
      final response =
          await _apiClient.get('${AppConstants.watchlistEndpoint}/$itemId');

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo detalles de supervisión: $e',
        originalError: e,
      );
    }
  }

  /// Agrega un dispositivo a la lista de supervisión (admin)
  /// POST /watchlist
  Future<Map<String, dynamic>> addToWatchlist({
    required String deviceId,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'device_id': deviceId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        ...?additionalData,
      };

      final response =
          await _apiClient.post(AppConstants.watchlistEndpoint, body: body);

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error agregando a lista de supervisión: $e',
        originalError: e,
      );
    }
  }

  /// Elimina un dispositivo de la lista de supervisión (admin)
  /// DELETE /watchlist/:id
  Future<Map<String, dynamic>> removeFromWatchlist(String itemId) async {
    try {
      // Nota: El backend debe soportar DELETE si queremos eliminar
      // De lo contrario, esta es una suposición basada en convenciones RESTful
      final response = await _apiClient.get(
        '${AppConstants.watchlistEndpoint}/$itemId/remove',
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error removiendo de lista de supervisión: $e',
        originalError: e,
      );
    }
  }
}

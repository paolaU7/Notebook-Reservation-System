import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/constants.dart';

/// Servicio para manejar operaciones de reservas
class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  final ApiClient _apiClient = ApiClient();

  factory ReservationService() {
    return _instance;
  }

  ReservationService._internal();

  /// Crea una nueva reserva
  /// POST /reservations
  Future<Map<String, dynamic>> createReservation({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'device_id': deviceId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        ...?additionalData,
      };

      final response = await _apiClient.post(
        AppConstants.reservationsEndpoint,
        body: body,
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error creando reserva: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene las reservas del usuario actual
  /// GET /reservations
  Future<List<dynamic>> getMyReservations() async {
    try {
      final response = await _apiClient.get(AppConstants.reservationsEndpoint);

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('reservations')) {
        final reservations = response['reservations'];
        if (reservations is List) {
          return reservations;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo reservas: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene todas las reservas (solo admin)
  /// GET /reservations/all
  Future<List<dynamic>> getAllReservations() async {
    try {
      final response = await _apiClient.get('${AppConstants.reservationsEndpoint}/all');

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('reservations')) {
        final reservations = response['reservations'];
        if (reservations is List) {
          return reservations;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo todas las reservas: $e',
        originalError: e,
      );
    }
  }

  /// Cancela una reserva existente
  /// PATCH /reservations/:id/cancel
  Future<Map<String, dynamic>> cancelReservation(String reservationId) async {
    try {
      final response = await _apiClient.patch(
        '${AppConstants.reservationsEndpoint}/$reservationId/cancel',
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error cancelando reserva: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene los tokens (códigos de autorización) de una reserva
  /// GET /reservations/:id/tokens
  Future<List<dynamic>> getReservationTokens(String reservationId) async {
    try {
      final response =
          await _apiClient.get('${AppConstants.reservationsEndpoint}/$reservationId/tokens');

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('tokens')) {
        final tokens = response['tokens'];
        if (tokens is List) {
          return tokens;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo tokens de reserva: $e',
        originalError: e,
      );
    }
  }
}

import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/constants.dart';

/// Servicio para manejar operaciones de entrega de dispositivos
class CheckoutService {
  static final CheckoutService _instance = CheckoutService._internal();
  final ApiClient _apiClient = ApiClient();

  factory CheckoutService() {
    return _instance;
  }

  CheckoutService._internal();

  /// Confirma la entrega de un dispositivo a un usuario
  /// POST /checkouts
  Future<Map<String, dynamic>> checkoutDevice({
    required String reservationId,
    String? deviceNotes,
    bool confirm = false,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'reservation_id': reservationId,
        if (deviceNotes != null && deviceNotes.isNotEmpty)
          'device_notes': deviceNotes,
        'confirm': confirm,
        ...?additionalData,
      };

      final response =
          await _apiClient.post(AppConstants.checkoutsEndpoint, body: body);

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error en checkout de dispositivo: $e',
        originalError: e,
      );
    }
  }

  /// Redime un checkout (marca como confirmado)
  /// POST /checkouts/redeem
  Future<Map<String, dynamic>> redeemCheckout({
    required String checkoutId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'checkout_id': checkoutId,
        ...?additionalData,
      };

      final response = await _apiClient.post(
        '${AppConstants.checkoutsEndpoint}/redeem',
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
        message: 'Error redimiendo checkout: $e',
        originalError: e,
      );
    }
  }

  /// Registra la devolución de un dispositivo
  /// POST /returns
  Future<Map<String, dynamic>> returnDevice({
    required String checkoutId,
    String? condition,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'checkout_id': checkoutId,
        if (condition != null && condition.isNotEmpty) 'condition': condition,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        ...?additionalData,
      };

      final response =
          await _apiClient.post(AppConstants.returnsEndpoint, body: body);

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error devolviendo dispositivo: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene información de una devolución
  /// GET /returns/:id
  Future<Map<String, dynamic>> getReturnDetails(String returnId) async {
    try {
      final response =
          await _apiClient.get('${AppConstants.returnsEndpoint}/$returnId');

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo detalles de devolución: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene la lista de devoluciones (admin)
  /// GET /returns
  Future<List<dynamic>> getReturns() async {
    try {
      final response = await _apiClient.get(AppConstants.returnsEndpoint);

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('returns')) {
        final returns = response['returns'];
        if (returns is List) {
          return returns;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo devoluciones: $e',
        originalError: e,
      );
    }
  }
}

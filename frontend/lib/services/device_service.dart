import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/constants.dart';

/// Servicio para manejar operaciones de dispositivos
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  final ApiClient _apiClient = ApiClient();

  factory DeviceService() {
    return _instance;
  }

  DeviceService._internal();

  /// Obtiene la lista de notebooks (dispositivos) disponibles
  /// GET /notebooks
  Future<List<dynamic>> getNotebooks() async {
    try {
      final response = await _apiClient.get(AppConstants.notebooksEndpoint);

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('notebooks')) {
        final notebooks = response['notebooks'];
        if (notebooks is List) {
          return notebooks;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo notebooks: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene los dispositivos (admin)
  /// GET /devices?type=:type&status=:status&limit=:limit
  Future<List<dynamic>> getDevices({
    String? type,
    String? status,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit.toString();

      String endpoint = '/devices';
      if (queryParams.isNotEmpty) {
        final queryString =
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _apiClient.get(endpoint);

      if (response is List) {
        return response;
      } else if (response is Map<String, dynamic> && response.containsKey('devices')) {
        final devices = response['devices'];
        if (devices is List) {
          return devices;
        }
      }

      throw ApiException(
        message: 'Formato de respuesta inválido',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo dispositivos: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene los detalles de un dispositivo específico
  /// GET /devices/:id
  Future<Map<String, dynamic>> getDeviceDetails(String deviceId) async {
    try {
      final response = await _apiClient.get('/devices/$deviceId');

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo detalles del dispositivo: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene el estado de un dispositivo
  /// GET /devices/:id/status
  Future<Map<String, dynamic>> getDeviceStatus(String deviceId) async {
    try {
      final response = await _apiClient.get('/devices/$deviceId/status');

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error obteniendo estado del dispositivo: $e',
        originalError: e,
      );
    }
  }

  /// Crea un nuevo dispositivo (solo admin)
  /// POST /devices
  Future<Map<String, dynamic>> createDevice({
    required String name,
    required String type,
    String? serial,
    String? model,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = {
        'name': name,
        'type': type,
        if (serial != null) 'serial': serial,
        if (model != null) 'model': model,
        ...?additionalData,
      };

      final response = await _apiClient.post('/devices', body: body);

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw ApiException(message: 'Respuesta inválida del servidor');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error creando dispositivo: $e',
        originalError: e,
      );
    }
  }
}

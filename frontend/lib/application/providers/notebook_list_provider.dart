import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/device.dart';
import '../../infrastructure/api_client.dart';

class NotebookListNotifier extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() async {
    return _fetchDevices();
  }

  Future<List<Device>> _fetchDevices() async {
    try {
      // The backend /devices endpoint currently requires the admin token.
      final response = await ApiClient.instance.get(
        '/devices',
        options: Options(
          headers: {
            'Authorization': 'Bearer admin-secret-token',
          },
        ),
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) {
        return Device(
          id: json['id'],
          model: _mapModelString(json['type']),
          type: json['type'] == 'television' ? 'Televisor' : 'Notebook',
          specialty: 'General', // Backend doesn't provide specialty yet
          status: _mapStatusString(json['status']),
          statusNotes: json['status_notes'],
        );
      }).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? e.message);
      }
      throw Exception('Error al cargar dispositivos: $e');
    }
  }

  DeviceModel _mapModelString(String type) {
    if (type == 'television') return DeviceModel.tv;
    return DeviceModel.conectarIgualdad; // Default mapping
  }

  DeviceStatus _mapStatusString(String status) {
    switch (status) {
      case 'in_use':
        return DeviceStatus.inUse;
      case 'out_of_service':
        return DeviceStatus.outOfService;
      case 'maintenance':
        return DeviceStatus.maintenance;
      default:
        return DeviceStatus.available;
    }
  }

  Future<void> updateDeviceStatus(String id, DeviceStatus status, {String? userEmail}) async {
    // This function might need to be removed or adapted since backend reservations handle status
    // For now, let's refresh the list to sync with backend
    ref.invalidateSelf();
  }

  Future<void> cancelReservation(String reservationId) async {
    state = const AsyncValue.loading();
    try {
      await ApiClient.instance.post('/reservations/$reservationId/cancel');
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncValue.error('Error al cancelar reserva: $e', StackTrace.current);
    }
  }

  Future<void> reserveDeviceForStudent(String deviceId, DateTime date, String startTime, String endTime) async {
    state = const AsyncValue.loading();
    try {
      await ApiClient.instance.post(
        '/reservations',
        data: {
          'device_id': deviceId,
          'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'start_time': startTime,
          'end_time': endTime,
        },
      );
      ref.invalidateSelf();
    } catch (e) {
      if (e is DioException) {
        state = AsyncValue.error(e.response?.data['error'] ?? e.message ?? 'Error', StackTrace.current);
      } else {
        state = AsyncValue.error(e.toString(), StackTrace.current);
      }
    }
  }

  Future<void> returnDevice(String id) async {
    ref.invalidateSelf();
  }
}

final notebookListProvider = AsyncNotifierProvider<NotebookListNotifier, List<Device>>(() {
  return NotebookListNotifier();
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation.dart';
import '../../infrastructure/api_client.dart';

class MyReservationsNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  Future<List<Reservation>> build() => fetchReservations();

  Future<List<Reservation>> fetchReservations() async {
    try {
      final res = await ApiClient.instance.get('/reservations');
      final list = res.data as List<dynamic>;
      return list.map((j) => Reservation.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map?)?['error'] as String?) ??
            'Error al cargar reservas',
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<String?> getTeacherToken(String reservationId) async {
    try {
      final res = await ApiClient.instance.post('/reservations/$reservationId/tokens');
      return res.data['token'] as String?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        ((e.response?.data as Map?)?['error'] as String?) ??
            'Error al cargar token',
      );
    }
  }
}

final myReservationsProvider =
    AsyncNotifierProvider<MyReservationsNotifier, List<Reservation>>(
      () => MyReservationsNotifier(),
    );

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/my_reservations_provider.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/user.dart';
import '../theme/theme_provider.dart';

class MyReservationsScreen extends ConsumerWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(myReservationsProvider);
    final user = ref.read(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(myReservationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('$err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(myReservationsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('No tenés reservas registradas.'));
          }

          final actives = reservations.where((r) => r.isActive).toList();
          final history = reservations.where((r) => !r.isActive).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Activas'),
                    Tab(text: 'Historial'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ReservationsList(reservations: actives, isHistory: false, isTeacher: user?.role == UserRole.teacher),
                      _ReservationsList(reservations: history, isHistory: true, isTeacher: user?.role == UserRole.teacher),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationsList extends ConsumerWidget {
  final List<Reservation> reservations;
  final bool isHistory;
  final bool isTeacher;

  const _ReservationsList({
    required this.reservations,
    required this.isHistory,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(isHistory ? 'Tu historial está vacío.' : 'No tenés reservas activas.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final r = reservations[index];
        final statusColor = _getStatusColor(r.status);
        final statusLabel = _getStatusLabel(r.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fecha: \${r.date}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Horario: \${r.startTime} a \${r.endTime}'),
                if (isTeacher && r.isActive) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.key),
                      label: const Text('Ver Token'),
                      onPressed: () => _showTokenDialog(context, ref, r.id),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTokenDialog(BuildContext context, WidgetRef ref, String reservationId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await ref.read(myReservationsProvider.notifier).getTeacherToken(reservationId);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Token de Reserva'),
          content: Text(
            token != null
                ? 'El token para que alguien retire el dispositivo por vos es:\n\n$token'
                : 'Aún no se ha generado un token o esta reserva no lo admite.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return AppTheme.statusAvailable;
      case ReservationStatus.cancelled: return AppTheme.statusMaint;
      case ReservationStatus.expired: return AppTheme.statusOff;
      case ReservationStatus.completed: return AppTheme.primaryBlue;
      case ReservationStatus.pending: return AppTheme.warningColor;
    }
  }

  String _getStatusLabel(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return 'Confirmada';
      case ReservationStatus.cancelled: return 'Cancelada';
      case ReservationStatus.expired: return 'Expirada';
      case ReservationStatus.completed: return 'Completada';
      case ReservationStatus.pending: return 'Pendiente';
    }
  }
}

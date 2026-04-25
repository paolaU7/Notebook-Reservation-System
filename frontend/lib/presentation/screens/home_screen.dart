import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/notebook_list_provider.dart';
import '../../application/providers/auth_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/device.dart';
import '../widgets/device_card.dart';

final deviceFilterTypeProvider = StateProvider<String>((ref) => 'Todos');
final deviceFilterAvailableProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    final notebooksAsync = ref.watch(notebookListProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100, errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 100)),
                  const SizedBox(height: 32),
                  const Text('NRS - Iniciar Sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).login('12345678', '12345678', UserRole.student);
                    },
                    child: const Text('Simular Login Alumno'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).login('87654321', '87654321', UserRole.teacher);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Simular Login Docente'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).login('admin@nrs.com', 'adminpass', UserRole.admin);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Simular Login Admin'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.school)),
                const SizedBox(width: 8),
                Text('NRS (${user.role.name})'),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, size: 28),
                onSelected: (value) {
                  if (value == 'logout') {
                    ref.read(authProvider.notifier).logout();
                  } else if (value == 'theme') {
                    // Toggle theme to be implemented via ThemeProvider
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('Usuario: ${user.email}'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'theme',
                    child: Text('Cambiar Tema'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          body: notebooksAsync.when(
            data: (devices) {
              if (user.role == UserRole.admin) {
                return _buildAdminView(context, ref, devices);
              } else {
                return _buildUserGrid(context, ref, devices, user);
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar dispositivos:\n$err', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(notebookListProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error de autenticación: $err'))),
    );
  }

  Widget _buildUserGrid(BuildContext context, WidgetRef ref, List<Device> devices, User user) {
    final filterType = ref.watch(deviceFilterTypeProvider);
    final onlyAvailable = ref.watch(deviceFilterAvailableProvider);

    final visibleDevices = devices.where((device) {
      if (user.role == UserRole.student && device.model == DeviceModel.tv) {
        return false;
      }
      if (onlyAvailable && device.status != DeviceStatus.available) {
        return false;
      }
      if (filterType != 'Todos') {
        if (filterType == 'Computadoras' && device.model == DeviceModel.tv) return false;
        if (filterType == 'Televisores' && device.model != DeviceModel.tv) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        if (!user.isActive)
          Container(
            color: Colors.orange.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cuenta en Aire. Tu cuenta se activará tras tu primer retiro físico.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.role == UserRole.teacher)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Todos', label: Text('Todos')),
                    ButtonSegment(value: 'Computadoras', label: Text('PC')),
                    ButtonSegment(value: 'Televisores', label: Text('TV')),
                  ],
                  selected: {filterType},
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(deviceFilterTypeProvider.notifier).state = newSelection.first;
                  },
                ),
              if (user.role == UserRole.teacher) const SizedBox(width: 16),
              FilterChip(
                label: const Text('Solo Disponibles'),
                selected: onlyAvailable,
                onSelected: (bool value) {
                  ref.read(deviceFilterAvailableProvider.notifier).state = value;
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: visibleDevices.length,
            itemBuilder: (context, index) {
              return DeviceCard(
                device: visibleDevices[index],
                onReserve: (date, start, end) {
                  ref.read(notebookListProvider.notifier).reserveDeviceForStudent(
                    visibleDevices[index].id,
                    date,
                    start.format(context),
                    end.format(context),
                  );
                },
                onCancel: visibleDevices[index].status == DeviceStatus.inUse
                  ? () => ref.read(notebookListProvider.notifier).cancelReservation(visibleDevices[index].id)
                  : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminView(BuildContext context, WidgetRef ref, List<Device> devices) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Panel de Administración', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Usuario')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: devices.map((device) {
                        return DataRow(cells: [
                          DataCell(Text(device.id)),
                          DataCell(Text(device.type)),
                          DataCell(Text(device.status.name)),
                          DataCell(Text(device.currentUserEmail ?? '-')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.build),
                                onPressed: () {
                                  // Cambiar a mantenimiento
                                  ref.read(notebookListProvider.notifier).updateDeviceStatus(
                                    device.id, 
                                    device.status == DeviceStatus.maintenance 
                                      ? DeviceStatus.available 
                                      : DeviceStatus.maintenance,
                                  );
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

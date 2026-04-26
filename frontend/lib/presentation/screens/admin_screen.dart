// lib/presentation/screens/admin_screen.dart
// Tabs: Dispositivos | Reservas | Usuarios
// El tab Usuarios es la réplica exacta de nrs_usuarios_panel.html

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/notebook_list_provider.dart';
import '../../domain/entities/device.dart';
import '../../infrastructure/api_client.dart';
import '../theme/theme_provider.dart';

final _allReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.read(notebookListProvider.notifier).getAllReservations();
});

enum _ReservationFlowState { pending, active, finalized, cancelled }

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this); // ← 3 tabs
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NRS — Panel Admin'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dispositivos', icon: Icon(Icons.laptop_chromebook, size: 16)),
            Tab(text: 'Reservas',     icon: Icon(Icons.calendar_today,     size: 16)),
            Tab(text: 'Usuarios',     icon: Icon(Icons.people_rounded,     size: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notebookListProvider.notifier).refresh();
              ref.invalidate(_allReservationsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _DevicesTab(),
          _ReservationsTab(),
          _UsuariosTab(),   // ← nuevo
        ],
      ),
    );
  }
}

_ReservationFlowState _resolveReservationFlow(Map<String, dynamic> reservation) {
  final status    = reservation['status']?.toString().toLowerCase() ?? '';
  final checkoutId = reservation['checkout_id']?.toString();
  final returnedAt = reservation['returned_at']?.toString();

  if (status == 'cancelled') return _ReservationFlowState.cancelled;

  final hasCheckout = checkoutId != null && checkoutId.isNotEmpty;
  final hasReturn   = returnedAt != null && returnedAt.isNotEmpty;

  if (hasCheckout && !hasReturn) return _ReservationFlowState.active;
  if (status == 'pending' || status == 'confirmed') {
    return _ReservationFlowState.pending;
  }
  return _ReservationFlowState.finalized;
}

// ─── Tab Dispositivos ─────────────────────────────────────────────────────────

class _DevicesTab extends ConsumerWidget {
  const _DevicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notebookListProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$err',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notebookListProvider.notifier).refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (devices) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1260),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.computer_outlined,
                              color: AppTheme.secondaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dispositivos',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${devices.length} dispositivos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showAddEditDeviceDialog(context, ref),
                          child: Ink(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryBlue,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondaryBlue.withValues(alpha: 0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.black.withValues(alpha: 0.08),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width * 0.85,
                            ),
                            child: DataTable(
                              horizontalMargin: 28,
                              columnSpacing: 16,
                              headingRowHeight: 56,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 60,
                              headingRowColor: WidgetStateProperty.all(Colors.white),
                              dataRowColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return AppTheme.cardColor.withValues(alpha: 0.35);
                                }
                                return Colors.white;
                              }),
                              headingTextStyle: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.4,
                              ),
                              columns: const [
                                DataColumn(label: Text('NÚMERO')),
                                DataColumn(label: Text('TIPO')),
                                DataColumn(label: Text('ESTADO')),
                                DataColumn(label: Text('NOTAS')),
                                DataColumn(label: Text('ACCIONES')),
                              ],
                              rows: devices.map((d) => _deviceRow(context, ref, d)).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 28,
                      runSpacing: 16,
                      children: const [
                        _LegendItem(
                          icon: Icons.build,
                          color: Color(0xFFB8BDC7),
                          title: 'Mantenimiento (deshabilitado)',
                          subtitle: 'No disponible cuando el dispositivo está en uso.',
                        ),
                        _LegendItem(
                          icon: Icons.build,
                          color: AppTheme.statusMaint,
                          title: 'Mantenimiento',
                          subtitle: 'Poner el dispositivo en mantenimiento.',
                        ),
                        _LegendItem(
                          icon: Icons.edit,
                          color: AppTheme.primaryBlue,
                          title: 'Editar',
                          subtitle: 'Modificar número o notas.',
                        ),
                        _LegendItem(
                          icon: Icons.delete,
                          color: Colors.red,
                          title: 'Eliminar',
                          subtitle: 'Eliminar dispositivo.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _deviceRow(BuildContext context, WidgetRef ref, Device device) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            device.number,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textColor,
            ),
          ),
        ),
        DataCell(
          Text(
            device.model == DeviceModel.tv ? 'TV' : 'PC',
            style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(_StatusBadge(status: device.status)),
        DataCell(
          Text(
            device.statusNotes ?? '—',
            style: TextStyle(
              color: AppTheme.textColor.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ),
        DataCell(_ActionButtons(device: device, context: context, ref: ref)),
      ],
    );
  }

  void _showAddEditDeviceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditDeviceDialog(
        device: null,
        onSave: (number, type, notes) async {
          try {
            await ref.read(notebookListProvider.notifier).createDevice(
              number: number,
              type: type,
              statusNotes: notes,
            );
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Dispositivo agregado.'),
                  backgroundColor: AppTheme.statusAvailable,
                ),
              );
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// ─── Botones de acción (Dispositivos) ────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  final Device device;
  final BuildContext context;
  final WidgetRef ref;

  const _ActionButtons({
    required this.device,
    required this.context,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInUse = device.status == DeviceStatus.inUse;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: isInUse
              ? 'No disponible: dispositivo en uso'
              : 'Poner en mantenimiento',
          child: _ActionIconButton(
            icon: Icons.build,
            color: isInUse ? const Color(0xFFB8BDC7) : AppTheme.statusMaint,
            onPressed: isInUse
                ? null
                : () async {
                    final newStatus = device.status == DeviceStatus.maintenance
                        ? DeviceStatus.available
                        : DeviceStatus.maintenance;
                    try {
                      await ref
                          .read(notebookListProvider.notifier)
                          .updateDeviceStatus(device.id, newStatus);
                    } catch (e) {
                      if (this.context.mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
          ),
        ),
        Tooltip(
          message: 'Editar dispositivo',
          child: _ActionIconButton(
            icon: Icons.edit,
            color: AppTheme.primaryBlue,
            onPressed: () => _showEditDeviceDialog(context, ref),
          ),
        ),
        Tooltip(
          message: 'Eliminar dispositivo',
          child: _ActionIconButton(
            icon: Icons.delete,
            color: Colors.red,
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ),
      ],
    );
  }

  void _showEditDeviceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditDeviceDialog(
        device: device,
        onSave: (number, _, notes) async {
          try {
            await ref.read(notebookListProvider.notifier).updateDevice(
              id: device.id,
              number: number,
              statusNotes: notes,
            );
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Dispositivo actualizado.'),
                  backgroundColor: AppTheme.statusAvailable,
                ),
              );
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar dispositivo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el dispositivo ${device.number}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(notebookListProvider.notifier).deleteDevice(device.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Dispositivo eliminado.'),
                      backgroundColor: AppTheme.statusAvailable,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Formulario Agregar/Editar Dispositivo ─────────────────────────────────

class _AddEditDeviceDialog extends StatefulWidget {
  final Device? device;
  final Function(String number, String type, String? notes) onSave;

  const _AddEditDeviceDialog({required this.device, required this.onSave});

  @override
  State<_AddEditDeviceDialog> createState() => _AddEditDeviceDialogState();
}

class _AddEditDeviceDialogState extends State<_AddEditDeviceDialog> {
  late TextEditingController _numberCtrl;
  late TextEditingController _notesCtrl;
  String _deviceType = 'notebook';

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(text: widget.device?.number ?? '');
    _notesCtrl  = TextEditingController(text: widget.device?.statusNotes ?? '');
    if (widget.device != null) {
      _deviceType = widget.device!.model == DeviceModel.tv ? 'television' : 'notebook';
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.device != null;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Editar dispositivo' : 'Agregar dispositivo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogFieldLabel('Nombre (Número de PC/TV) *'),
              const SizedBox(height: 8),
              TextField(
                controller: _numberCtrl,
                decoration: const InputDecoration(hintText: 'Ej. CI-NB-0015'),
              ),
              const SizedBox(height: 20),
              _DialogFieldLabel('Tipo *'),
              const SizedBox(height: 8),
              if (!isEditing)
                DropdownButtonFormField<String>(
                  initialValue: _deviceType,
                  decoration: const InputDecoration(hintText: 'Seleccionar tipo'),
                  items: const [
                    DropdownMenuItem(value: 'notebook',    child: Text('PC')),
                    DropdownMenuItem(value: 'television',  child: Text('TV')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _deviceType = v);
                  },
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    _deviceType == 'television' ? 'TV' : 'PC',
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const _DialogFieldLabel('Notas (opcional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ej. Ubicación, características, etc.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onPressed: () {
                      final number = _numberCtrl.text.trim();
                      if (number.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El nombre es requerido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      widget.onSave(
                        number,
                        _deviceType,
                        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                      );
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab Reservas ─────────────────────────────────────────────────────────────

class _ReservationsTab extends ConsumerWidget {
  const _ReservationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(_allReservationsProvider);

    return reservationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$err',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(_allReservationsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (reservations) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1260),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppTheme.secondaryBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reservas',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reservations.length} reservas',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                      child: reservations.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
                              child: Center(
                                child: Text(
                                  'No hay reservas registradas.',
                                  style: TextStyle(
                                    color: AppTheme.textColor.withValues(alpha: 0.75),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.black.withValues(alpha: 0.08),
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width * 0.85,
                                  ),
                                  child: DataTable(
                                    horizontalMargin: 28,
                                    columnSpacing: 16,
                                    headingRowHeight: 56,
                                    dataRowMinHeight: 64,
                                    dataRowMaxHeight: 70,
                                    headingRowColor: WidgetStateProperty.all(Colors.white),
                                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.hovered)) {
                                        return AppTheme.cardColor.withValues(alpha: 0.35);
                                      }
                                      return Colors.white;
                                    }),
                                    headingTextStyle: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      letterSpacing: 0.4,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('RESERVANTE')),
                                      DataColumn(label: Text('TIPO')),
                                      DataColumn(label: Text('DISPOSITIVO')),
                                      DataColumn(label: Text('FECHA')),
                                      DataColumn(label: Text('INICIO')),
                                      DataColumn(label: Text('FIN')),
                                      DataColumn(label: Text('ESTADO')),
                                      DataColumn(
                                        label: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text('ACCIONES'),
                                        ),
                                      ),
                                    ],
                                    rows: reservations
                                        .map((r) => _reservationRow(context, r))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlue.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Las acciones disponibles dependen del estado actual de la reserva.',
                            style: TextStyle(
                              color: AppTheme.textColor.withValues(alpha: 0.84),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _reservationRow(BuildContext context, Map<String, dynamic> reservation) {
    final isTeacher  = reservation['booker_type'] == 'teacher';
    final typeLabel  = isTeacher ? 'Profesor' : 'Estudiante';
    final nameRaw    = isTeacher ? reservation['teacher_name'] : reservation['student_name'];
    final reservantName = (nameRaw?.toString().trim().isNotEmpty ?? false)
        ? nameRaw.toString().trim()
        : 'Sin nombre';
    final flowState = _resolveReservationFlow(reservation);

    return DataRow(
      cells: [
        DataCell(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservantName,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                typeLabel,
                style: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.58),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        DataCell(_BookerTypeBadge(typeLabel: typeLabel, isTeacher: isTeacher)),
        DataCell(
          Text(
            _formatDeviceLabel(reservation),
            style: const TextStyle(
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        DataCell(
          Text(
            reservation['date']?.toString() ?? '—',
            style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
          ),
        ),
        DataCell(
          Text(
            reservation['start_time']?.toString() ?? '—',
            style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
          ),
        ),
        DataCell(
          Text(
            reservation['end_time']?.toString() ?? '—',
            style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
          ),
        ),
        DataCell(_ReservationFlowBadge(flowState: flowState)),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: _ReservationActionButtons(
              reservation: reservation,
              flowState: flowState,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDeviceLabel(Map<String, dynamic> reservation) {
    final number    = reservation['device_number']?.toString().trim() ?? '';
    final rawType   = reservation['device_type']?.toString();
    final fallbackId = reservation['device_id']?.toString() ?? '—';

    final typeLabel = switch (rawType) {
      'television' => 'TV',
      'notebook'   => 'PC',
      _ => '',
    };

    if (number.isEmpty) {
      if (typeLabel.isEmpty) return fallbackId;
      return '$fallbackId ($typeLabel)';
    }
    if (typeLabel.isEmpty) return number;
    return '$number ($typeLabel)';
  }
}

// ─── Tab Usuarios (réplica de nrs_usuarios_panel.html) ────────────────────────

// Colores del HTML
const _kPrimary      = Color(0xFF1565C0);
const _kBgCard       = Colors.white;
const _kBorder       = Color(0xFFE8E8E8);
const _kBorderTable  = Color(0xFFE8ECF4);
const _kText1        = Color(0xFF1A1A2E);
const _kText2        = Color(0xFF333333);
const _kText3        = Color(0xFF555555);
const _kText4        = Color(0xFF888888);
const _kText5        = Color(0xFF666666);
const _kTextAaa      = Color(0xFFAAAAAA);
const _kIconGray     = Color(0xFFBBBBBB);

// ─── Providers para el tab Usuarios (conectados a la BDD) ────────────────────

final _teachersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiClient.instance.get('/admin/teachers');
  return (res.data as List).cast<Map<String, dynamic>>();
});

final _studentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiClient.instance.get('/admin/students');
  return (res.data as List).cast<Map<String, dynamic>>();
});

// Helpers
String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

final _kAvatarPalette = const [
  (Color(0xFFE3F2FD), Color(0xFF1565C0)),
  (Color(0xFFFCE4EC), Color(0xFFC62828)),
  (Color(0xFFE8F5E9), Color(0xFF2E7D32)),
  (Color(0xFFFFF3E0), Color(0xFFE65100)),
  (Color(0xFFF3E5F5), Color(0xFF6A1B9A)),
  (Color(0xFFE0F7FA), Color(0xFF006064)),
];

(Color, Color) _avatarColors(String id) {
  final idx = id.codeUnits.fold(0, (a, b) => a + b) % _kAvatarPalette.length;
  return _kAvatarPalette[idx];
}

class _UsuariosTab extends ConsumerStatefulWidget {
  const _UsuariosTab();

  @override
  ConsumerState<_UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends ConsumerState<_UsuariosTab>
    with SingleTickerProviderStateMixin {
  late final TabController _inner;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }

  // ── Toggle estado profesor ────────────────────────────────────────────────
  Future<void> _toggleTeacher(Map<String, dynamic> t) async {
    final id     = t['id'] as String;
    final activo = t['is_active'] as bool;
    final action = activo ? 'deactivate' : 'activate';
    try {
      await ApiClient.instance.patch(
        '/admin/teachers/$id',
        data: {'action': action},
      );
      ref.invalidate(_teachersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Toggle estado alumno ──────────────────────────────────────────────────
  Future<void> _toggleStudent(Map<String, dynamic> s) async {
    final id     = s['id'] as String;
    final activo = s['is_active'] as bool;
    final action = activo ? 'deactivate' : 'activate';
    try {
      await ApiClient.instance.patch(
        '/admin/students/$id',
        data: {'action': action},
      );
      ref.invalidate(_studentsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(_teachersProvider);
    final studentsAsync = ref.watch(_studentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1260),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people_rounded, color: _kPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuarios',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _kText1)),
                          SizedBox(height: 1),
                          Text('Gestioná los usuarios del sistema.',
                              style: TextStyle(fontSize: 12, color: _kText4)),
                        ],
                      ),
                    ),
                    // Botón refrescar
                    GestureDetector(
                      onTap: () {
                        ref.invalidate(_teachersProvider);
                        ref.invalidate(_studentsProvider);
                      },
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Tabs internos: Profesores / Alumnos ───────────────────
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _kBorder, width: 1.5)),
                  ),
                  child: TabBar(
                    controller: _inner,
                    labelColor: _kPrimary,
                    unselectedLabelColor: _kText4,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    indicatorColor: _kPrimary,
                    indicatorWeight: 2.5,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_rounded, size: 15),
                            SizedBox(width: 6),
                            Text('Profesores'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_rounded, size: 15),
                            SizedBox(width: 6),
                            Text('Alumnos'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Contenido de tabs ─────────────────────────────────────
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _inner,
                    children: [
                      // ── Tab Profesores ──────────────────────────────────
                      teachersAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 36),
                              const SizedBox(height: 8),
                              Text('Error al cargar profesores: $e',
                                  style: const TextStyle(color: _kText3)),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => ref.invalidate(_teachersProvider),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                        data: (teachers) {
                          final filtered = teachers
                              .where((t) =>
                                  (t['full_name'] as String)
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()) ||
                                  (t['email'] as String)
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Toolbar
                              Row(
                                children: [
                                  const Icon(Icons.school_rounded, size: 15, color: _kText4),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filtered.length} profesores',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _kText3),
                                  ),
                                  const Spacer(),
                                  _SearchBox(
                                    hint: 'Buscar profesor...',
                                    onChanged: (v) => setState(() => _search = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Tabla
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2.2),
                                      1: FlexColumnWidth(2.5),
                                      2: FlexColumnWidth(1.2),
                                      3: FlexColumnWidth(1.0),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: _kBorderTable, width: 1.5)),
                                        ),
                                        children: const [
                                          _ThCell('Nombre y Apellido'),
                                          _ThCell('Email'),
                                          _ThCell('Estado'),
                                          _ThCell('Acciones'),
                                        ],
                                      ),
                                      ...filtered.asMap().entries.map((e) {
                                        final t      = e.value;
                                        final isLast = e.key == filtered.length - 1;
                                        final name   = t['full_name'] as String;
                                        final email  = t['email'] as String;
                                        final activo = t['is_active'] as bool;
                                        final id     = t['id'] as String;
                                        final (bg, fg) = _avatarColors(id);

                                        return TableRow(
                                          decoration: isLast
                                              ? null
                                              : const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: _kBorderTable))),
                                          children: [
                                            _TdPadding(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 30, height: 30,
                                                    decoration: BoxDecoration(
                                                        color: bg,
                                                        shape: BoxShape.circle),
                                                    child: Center(
                                                      child: Text(_initials(name),
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w700,
                                                              color: fg)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 9),
                                                  Expanded(
                                                    child: Text(name,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                            color: _kText1)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _TdPadding(
                                              child: Text(email,
                                                  style: const TextStyle(
                                                      fontSize: 12, color: _kText3)),
                                            ),
                                            _TdPadding(
                                              child: _ProfesorStatusBadge(activo: activo),
                                            ),
                                            _TdPadding(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Tooltip(
                                                    message: activo
                                                        ? 'Desactivar profesor'
                                                        : 'Activar profesor',
                                                    child: _UserActionBtn(
                                                      icon: activo
                                                          ? Icons.block_rounded
                                                          : Icons.check_circle_outline_rounded,
                                                      borderColor: activo
                                                          ? const Color(0xFFFFCDD2)
                                                          : const Color(0xFFC8E6C9),
                                                      iconColor: activo
                                                          ? Colors.red
                                                          : Colors.green,
                                                      onTap: () => _toggleTeacher(t),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // ── Tab Alumnos ─────────────────────────────────────
                      studentsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 36),
                              const SizedBox(height: 8),
                              Text('Error al cargar alumnos: $e',
                                  style: const TextStyle(color: _kText3)),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => ref.invalidate(_studentsProvider),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                        data: (students) {
                          final filtered = students
                              .where((s) =>
                                  (s['full_name'] as String)
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()) ||
                                  (s['email'] as String)
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Toolbar
                              Row(
                                children: [
                                  const Icon(Icons.people_rounded, size: 15, color: _kText4),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filtered.length} alumnos',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _kText3),
                                  ),
                                  const Spacer(),
                                  _SearchBox(
                                    hint: 'Buscar alumno...',
                                    onChanged: (v) => setState(() => _search = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Tabla
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2.2),
                                      1: FlexColumnWidth(2.5),
                                      2: FlexColumnWidth(0.8),
                                      3: FlexColumnWidth(1.0),
                                      4: FlexColumnWidth(1.2),
                                      5: FlexColumnWidth(1.0),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: _kBorderTable, width: 1.5)),
                                        ),
                                        children: const [
                                          _ThCell('Nombre y Apellido'),
                                          _ThCell('Email'),
                                          _ThCell('Año/Div'),
                                          _ThCell('Especialidad'),
                                          _ThCell('Estado'),
                                          _ThCell('Acciones'),
                                        ],
                                      ),
                                      ...filtered.asMap().entries.map((e) {
                                        final s      = e.value;
                                        final isLast = e.key == filtered.length - 1;
                                        final name   = s['full_name'] as String;
                                        final email  = s['email'] as String;
                                        final activo = s['is_active'] as bool;
                                        final id     = s['id'] as String;
                                        final year   = s['year'] as int;
                                        final div    = s['division'] as int;
                                        final spec   = s['specialty'] as String? ?? '—';
                                        final dmg    = s['damage_count'] as int;
                                        final (bg, fg) = _avatarColors(id);

                                        return TableRow(
                                          decoration: isLast
                                              ? null
                                              : const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: _kBorderTable))),
                                          children: [
                                            _TdPadding(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 30, height: 30,
                                                    decoration: BoxDecoration(
                                                        color: bg,
                                                        shape: BoxShape.circle),
                                                    child: Center(
                                                      child: Text(_initials(name),
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w700,
                                                              color: fg)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 9),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(name,
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: _kText1)),
                                                        ),
                                                        if (dmg > 0)
                                                          Tooltip(
                                                            message: '$dmg daño${dmg > 1 ? 's' : ''} registrado${dmg > 1 ? 's' : ''}',
                                                            child: Container(
                                                              margin: const EdgeInsets.only(left: 4),
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 5, vertical: 1),
                                                              decoration: BoxDecoration(
                                                                color: Colors.red.shade50,
                                                                borderRadius:
                                                                    BorderRadius.circular(10),
                                                                border: Border.all(
                                                                    color: Colors.red.shade200),
                                                              ),
                                                              child: Text('⚠ $dmg',
                                                                  style: TextStyle(
                                                                      fontSize: 10,
                                                                      color: Colors.red.shade700,
                                                                      fontWeight: FontWeight.w600)),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _TdPadding(
                                              child: Text(email,
                                                  style: const TextStyle(
                                                      fontSize: 12, color: _kText3)),
                                            ),
                                            _TdPadding(
                                              child: Text('$year°/$div°',
                                                  style: const TextStyle(
                                                      fontSize: 12, color: _kText3)),
                                            ),
                                            _TdPadding(
                                              child: Text(
                                                spec == 'ciclo_basico' ? '—' : spec,
                                                style: const TextStyle(
                                                    fontSize: 12, color: _kText3),
                                              ),
                                            ),
                                            _TdPadding(
                                              child: _ProfesorStatusBadge(activo: activo),
                                            ),
                                            _TdPadding(
                                              child: _UserActionBtn(
                                                icon: activo
                                                    ? Icons.block_rounded
                                                    : Icons.check_circle_outline_rounded,
                                                borderColor: activo
                                                    ? const Color(0xFFFFCDD2)
                                                    : const Color(0xFFC8E6C9),
                                                iconColor: activo
                                                    ? Colors.red
                                                    : Colors.green,
                                                onTap: () => _toggleStudent(s),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

// Widget auxiliar: caja de búsqueda
class _SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBox({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190, height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFDDDDEE)),
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 14, color: _kIconGray),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12, color: _kText3),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12, color: _kIconGray),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Widgets auxiliares compartidos ──────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final DeviceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DeviceStatus.available   => AppTheme.statusAvailable,
      DeviceStatus.inUse       => AppTheme.statusInUse,
      DeviceStatus.maintenance => AppTheme.statusMaint,
      DeviceStatus.outOfService => AppTheme.statusOff,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        Device.statusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        splashRadius: 20,
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textColor.withValues(alpha: 0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFieldLabel extends StatelessWidget {
  final String text;
  const _DialogFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textColor,
      ),
    );
  }
}

class _BookerTypeBadge extends StatelessWidget {
  final String typeLabel;
  final bool isTeacher;
  const _BookerTypeBadge({required this.typeLabel, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final color = isTeacher ? AppTheme.statusAvailable : AppTheme.secondaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        typeLabel,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

class _ReservationFlowBadge extends StatelessWidget {
  final _ReservationFlowState flowState;
  const _ReservationFlowBadge({required this.flowState});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (flowState) {
      _ReservationFlowState.pending   => ('Pendiente',  AppTheme.warningColor),
      _ReservationFlowState.active    => ('Activa',     AppTheme.secondaryBlue),
      _ReservationFlowState.finalized => ('Finalizada', AppTheme.statusAvailable),
      _ReservationFlowState.cancelled => ('Cancelada',  Colors.redAccent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

// ─── Widgets auxiliares de Usuarios ──────────────────────────────────────────

class _ThCell extends StatelessWidget {
  final String text;
  const _ThCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _kPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TdPadding extends StatelessWidget {
  final Widget child;
  const _TdPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: child,
    );
  }
}

class _ProfesorStatusBadge extends StatelessWidget {
  final bool activo;
  const _ProfesorStatusBadge({required this.activo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: activo ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        activo ? '● Activo' : '● Inactivo',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: activo ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
        ),
      ),
    );
  }
}

class _UserActionBtn extends StatelessWidget {
  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _UserActionBtn({
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}

// ─── Botones de acción (Reservas) ────────────────────────────────────────────

class _ReservationActionButtons extends ConsumerWidget {
  final Map<String, dynamic> reservation;
  final _ReservationFlowState flowState;

  const _ReservationActionButtons({
    required this.reservation,
    required this.flowState,
  });

  static const Color _disabledColor = Color(0xFFB8BDC7);

  String get _reservationId => reservation['id']?.toString() ?? '';

  String? get _checkoutId {
    final checkoutId = reservation['checkout_id']?.toString();
    if (checkoutId == null || checkoutId.isEmpty) return null;
    return checkoutId;
  }

  bool get _canCheckout => flowState == _ReservationFlowState.pending;
  bool get _canReturn   => flowState == _ReservationFlowState.active;
  bool get _canCancel   => flowState == _ReservationFlowState.pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: _canCheckout
              ? 'Registrar retirada'
              : 'Solo disponible cuando está pendiente',
          child: _ActionIconButton(
            icon: Icons.login_rounded,
            color: _canCheckout ? AppTheme.secondaryBlue : _disabledColor,
            onPressed: _canCheckout ? () => _handleCheckout(context, ref) : null,
          ),
        ),
        Tooltip(
          message: _canReturn
              ? 'Registrar devuelta'
              : 'Solo disponible cuando está activa',
          child: _ActionIconButton(
            icon: Icons.assignment_returned_rounded,
            color: _canReturn ? AppTheme.statusAvailable : _disabledColor,
            onPressed: _canReturn ? () => _handleReturn(context, ref) : null,
          ),
        ),
        Tooltip(
          message: _canCancel
              ? 'Cancelar reserva'
              : 'Solo disponible cuando está pendiente',
          child: _ActionIconButton(
            icon: Icons.delete_outline_rounded,
            color: _canCancel ? Colors.red : _disabledColor,
            onPressed: _canCancel ? () => _handleCancel(context, ref) : null,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    if (_reservationId.isEmpty) return;
    try {
      final notifier = ref.read(notebookListProvider.notifier);
      final result   = await notifier.approveCheckout(reservationId: _reservationId);
      if (!context.mounted) return;

      if (result['requires_confirmation'] == true) {
        final message = result['message']?.toString() ??
            'El alumno no está activado. ¿Deseás confirmar la retirada?';
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar retirada'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
        final confirmedResult = await notifier.approveCheckout(
          reservationId: _reservationId,
          confirm: true,
        );
        if (!context.mounted) return;
        _showCheckoutSuccess(context, confirmedResult);
      } else {
        _showCheckoutSuccess(context, result);
      }
      ref.invalidate(_allReservationsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _handleReturn(BuildContext context, WidgetRef ref) async {
    final checkoutId = _checkoutId;
    if (checkoutId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el checkout para esta reserva.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    try {
      await ref.read(notebookListProvider.notifier).processReturn(checkoutId: checkoutId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Devolución registrada.'),
          backgroundColor: AppTheme.statusAvailable,
        ),
      );
      ref.invalidate(_allReservationsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    if (_reservationId.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('¿Querés cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(notebookListProvider.notifier).cancelReservation(_reservationId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Reserva cancelada.'),
          backgroundColor: AppTheme.statusAvailable,
        ),
      );
      ref.invalidate(_allReservationsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  void _showCheckoutSuccess(BuildContext context, Map<String, dynamic> result) {
    final studentActivated = result['student_activated'] == true;
    final message = studentActivated
        ? '✓ Retirada registrada y alumno activado.'
        : '✓ Retirada registrada.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusAvailable,
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
/// Guía de integración de servicios en widgets Flutter
/// 
/// Este archivo contiene ejemplos de cómo integrar los servicios
/// de la API en los widgets de Flutter

import 'package:flutter/material.dart';
import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/services/auth_service.dart';
import 'package:nrs_frontend/services/device_service.dart';
import 'package:nrs_frontend/services/reservation_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 1: Widget de contraseña para Login
// ═══════════════════════════════════════════════════════════════════════════

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
        role: 'student', // O 'admin', 'teacher'
      );

      // Navegar a la pantalla principal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido, ${result['name'] ?? 'Usuario'}')),
        );
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 2: Widget para listar notebooks
// ═══════════════════════════════════════════════════════════════════════════

class NotebooksListPage extends StatefulWidget {
  const NotebooksListPage({Key? key}) : super(key: key);

  @override
  State<NotebooksListPage> createState() => _NotebooksListPageState();
}

class _NotebooksListPageState extends State<NotebooksListPage> {
  final _deviceService = DeviceService();
  late Future<List<dynamic>> _notebooksFuture;

  @override
  void initState() {
    super.initState();
    _notebooksFuture = _deviceService.getNotebooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notebooks Disponibles')),
      body: FutureBuilder<List<dynamic>>(
        future: _notebooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _notebooksFuture = _deviceService.getNotebooks();
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final notebooks = snapshot.data ?? [];

          if (notebooks.isEmpty) {
            return const Center(child: Text('No hay notebooks disponibles'));
          }

          return ListView.builder(
            itemCount: notebooks.length,
            itemBuilder: (context, index) {
              final notebook = notebooks[index] as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(notebook['name'] ?? 'Sin nombre'),
                  subtitle: Text(
                    'Estado: ${notebook['status'] ?? 'desconocido'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegar a detalles o crear reserva
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Seleccionaste: ${notebook['name']}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 3: Widget para crear una reserva
// ═══════════════════════════════════════════════════════════════════════════

class CreateReservationPage extends StatefulWidget {
  final String deviceId;

  const CreateReservationPage({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<CreateReservationPage> createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends State<CreateReservationPage> {
  final _reservationService = ReservationService();
  late DateTime _startDate;
  late DateTime _endDate;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
  }

  Future<void> _createReservation() async {
    setState(() => _isLoading = true);

    try {
      final result = await _reservationService.createReservation(
        deviceId: widget.deviceId,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva creada: ${result['id']}')),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fecha de inicio:'),
            ListTile(
              title: Text(_startDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Fecha de fin:'),
            ListTile(
              title: Text(_endDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: _startDate.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _endDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createReservation,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 4: Widget para listar mis reservas (Stateful con StreamBuilder)
// ═══════════════════════════════════════════════════════════════════════════

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final _reservationService = ReservationService();
  late Future<List<dynamic>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _reservationService.getMyReservations();
  }

  Future<void> _refresh() async {
    setState(() {
      _reservationsFuture = _reservationService.getMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _reservationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final reservations = snapshot.data ?? [];

            if (reservations.isEmpty) {
              return const Center(child: Text('No tienes reservas'));
            }

            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(res['device_id'] ?? 'Dispositivo desconocido'),
                    subtitle: Text('Estado: ${res['status']}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Desde: ${res['start_date']}'),
                            Text('Hasta: ${res['end_date']}'),
                            if (res['notes'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Notas: ${res['notes']}'),
                              ),
                            if (res['status'] == 'active')
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await _reservationService
                                            .cancelReservation(res['id']);
                                        _refresh();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Reserva cancelada',
                                              ),
                                            ),
                                          );
                                        }
                                      } on ApiException catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: ${e.message}',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Cancelar Reserva'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Notas de Implementación
// ═══════════════════════════════════════════════════════════════════════════

/*
RECOMENDACIONES DE ARQUITECTURA:

1. **State Management**: 
   - Para aplicaciones simples, usa setState()
   - Para aplicaciones medianas, considera bloc o provider
   - Los servicios son singletons y thread-safe

2. **Manejo de Errores**:
   - Siempre usa try-catch para las llamadas a servicios
   - Muestra mensajes de error amigables al usuario
   - Logea los errores para debugging

3. **Carga de Datos**:
   - Usa FutureBuilder para operaciones asincrónicas
   - Usa RefreshIndicator para actualizar datos
   - Considera paginación para listas grandes

4. **Autenticación**:
   - Verifica si el usuario está autenticado antes de permitir acceso
   - Maneja los tokens expirados gracefully
   - Implementa logout en todas las pantallas relevantes

5. **Testing**:
   - Escribe tests unitarios para lógica de negocio
   - Escribe tests de widget para la UI
   - Escribe tests de integración para flujos completos

6. **Seguridad**:
   - Nunca guardes contraseñas en SharedPreferences
   - Usa flutter_secure_storage para tokens (ya implementado)
   - Valida inputs en el cliente antes de enviar al servidor
   - Implementa certificado pinning para HTTPS en producción
*/

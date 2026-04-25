/// Ejemplo de uso de los servicios de NRS Frontend
/// 
/// Este archivo contiene ejemplos prácticos de cómo usar los servicios
/// para las operaciones más comunes en la aplicación.

// ignore_for_file: unused_local_variable

import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/services/auth_service.dart';
import 'package:nrs_frontend/services/device_service.dart';
import 'package:nrs_frontend/services/reservation_service.dart';
import 'package:nrs_frontend/services/checkout_service.dart';

/// Ejemplo 1: Autenticación de administrador
Future<void> exampleAdminLogin() async {
  final authService = AuthService();

  try {
    final response = await authService.login(
      email: 'admin@nrs.com',
      password: 'admin123',
      role: 'admin',
    );

    print('✓ Admin autenticado: ${response['id']}');
    print('  Email: ${response['email']}');
    print('  Rol: ${response['role']}');

    // El token se guarda automáticamente en almacenamiento seguro
    final isAuth = await authService.isAuthenticated();
    print('  ¿Autenticado?: $isAuth');
  } on ApiException catch (e) {
    print('✗ Error en login: ${e.message}');
  }
}

/// Ejemplo 2: Registro de estudiante
Future<void> exampleStudentRegister() async {
  final authService = AuthService();

  try {
    final response = await authService.studentRegister(
      email: 'juan.perez@school.com',
      dni: '12345678',
      name: 'Juan Pérez',
      year: 2,
      division: 3,
      // specialty es opcional y solo para ciclo superior (años 4-7)
    );

    print('✓ Estudiante registrado: ${response['id']}');
    print('  Nombre: ${response['name']}');
    print('  Email: ${response['email']}');
  } on ApiException catch (e) {
    print('✗ Error en registro: ${e.message}');
  }
}

/// Ejemplo 3: Login de estudiante
Future<void> exampleStudentLogin() async {
  final authService = AuthService();

  try {
    final response = await authService.studentLogin(
      email: 'juan.perez@school.com',
      dni: '12345678',
    );

    print('✓ Estudiante autenticado: ${response['id']}');
    print('  Email: ${response['email']}');

    // Verificar el rol
    final role = await authService.getUserRole();
    print('  Rol: $role');
  } on ApiException catch (e) {
    print('✗ Error en login: ${e.message}');
  }
}

/// Ejemplo 4: Ver notebooks disponibles
Future<void> exampleGetNotebooks() async {
  final deviceService = DeviceService();

  try {
    final notebooks = await deviceService.getNotebooks();

    print('✓ Notebooks disponibles: ${notebooks.length}');
    for (var i = 0; i < notebooks.length && i < 3; i++) {
      final notebook = notebooks[i] as Map<String, dynamic>;
      print('  - ${notebook['name']} (${notebook['id']})');
      print('    Estado: ${notebook['status']}');
    }
  } on ApiException catch (e) {
    print('✗ Error obteniendo notebooks: ${e.message}');
  }
}

/// Ejemplo 5: Crear una reserva
Future<void> exampleCreateReservation() async {
  final reservationService = ReservationService();

  try {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextWeek = DateTime.now().add(const Duration(days: 7));

    final response = await reservationService.createReservation(
      deviceId: 'notebook-001',
      startDate: tomorrow,
      endDate: nextWeek,
      notes: 'Necesito para proyecto de programación',
    );

    print('✓ Reserva creada: ${response['id']}');
    print('  Dispositivo: ${response['device_id']}');
    print('  Desde: ${response['start_date']}');
    print('  Hasta: ${response['end_date']}');
    print('  Estado: ${response['status']}');
  } on ApiException catch (e) {
    print('✗ Error creando reserva: ${e.message}');
  }
}

/// Ejemplo 6: Ver mis reservas
Future<void> exampleGetMyReservations() async {
  final reservationService = ReservationService();

  try {
    final reservations = await reservationService.getMyReservations();

    print('✓ Mis reservas: ${reservations.length}');
    for (var i = 0; i < reservations.length && i < 5; i++) {
      final res = reservations[i] as Map<String, dynamic>;
      print('  - ${res['id']}');
      print('    Dispositivo: ${res['device_id']}');
      print('    Estado: ${res['status']}');
    }
  } on ApiException catch (e) {
    print('✗ Error obteniendo reservas: ${e.message}');
  }
}

/// Ejemplo 7: Cancelar una reserva
Future<void> exampleCancelReservation() async {
  final reservationService = ReservationService();

  try {
    final response =
        await reservationService.cancelReservation('reservation-123');

    print('✓ Reserva cancelada: ${response['id']}');
    print('  Nuevo estado: ${response['status']}');
  } on ApiException catch (e) {
    print('✗ Error cancelando reserva: ${e.message}');
  }
}

/// Ejemplo 8: Entregar un dispositivo (Checkout)
Future<void> exampleCheckout() async {
  final checkoutService = CheckoutService();

  try {
    // Primero, registrar el checkout sin confirmar
    final checkoutResponse = await checkoutService.checkoutDevice(
      reservationId: 'reservation-123',
      deviceNotes: 'Dispositivo en buen estado, batería al 100%',
      confirm: false,
    );

    print('✓ Checkout creado: ${checkoutResponse['id']}');
    print('  Estado: ${checkoutResponse['status']}');

    // Luego, redimir (confirmar) el checkout
    final redeemResponse = await checkoutService.redeemCheckout(
      checkoutId: checkoutResponse['id'] as String,
    );

    print('✓ Checkout redimido: ${redeemResponse['id']}');
    print('  Estado: ${redeemResponse['status']}');
  } on ApiException catch (e) {
    print('✗ Error en checkout: ${e.message}');
  }
}

/// Ejemplo 9: Devolver un dispositivo
Future<void> exampleReturn() async {
  final checkoutService = CheckoutService();

  try {
    final returnResponse = await checkoutService.returnDevice(
      checkoutId: 'checkout-456',
      condition: 'good',
      notes: 'Dispositivo devuelto en perfecto estado',
    );

    print('✓ Devolución registrada: ${returnResponse['id']}');
    print('  Checkout: ${returnResponse['checkout_id']}');
    print('  Condición: ${returnResponse['condition']}');
  } on ApiException catch (e) {
    print('✗ Error registrando devolución: ${e.message}');
  }
}

/// Ejemplo 10: Ver dispositivos por tipo (Admin)
Future<void> exampleGetDevicesByType() async {
  final deviceService = DeviceService();

  try {
    final devices = await deviceService.getDevices(
      type: 'notebook',
      status: 'available',
      limit: 10,
    );

    print('✓ Dispositivos encontrados: ${devices.length}');
    for (var device in devices) {
      final d = device as Map<String, dynamic>;
      print('  - ${d['name']} (Serial: ${d['serial']})');
      print('    Estado: ${d['status']}');
    }
  } on ApiException catch (e) {
    print('✗ Error obteniendo dispositivos: ${e.message}');
  }
}

/// Ejemplo 11: Ver todas las devoluciones (Admin)
Future<void> exampleGetAllReturns() async {
  final checkoutService = CheckoutService();

  try {
    final returns = await checkoutService.getReturns();

    print('✓ Devoluciones registradas: ${returns.length}');
    for (var i = 0; i < returns.length && i < 5; i++) {
      final r = returns[i] as Map<String, dynamic>;
      print('  - ${r['id']}');
      print('    Usuario: ${r['user_id']}');
      print('    Condición: ${r['condition']}');
    }
  } on ApiException catch (e) {
    print('✗ Error obteniendo devoluciones: ${e.message}');
  }
}

/// Ejemplo 12: Logout
Future<void> exampleLogout() async {
  final authService = AuthService();

  try {
    await authService.logout();
    print('✓ Sesión cerrada');

    // Verificar que no hay token
    final isAuth = await authService.isAuthenticated();
    print('  ¿Autenticado?: $isAuth');
  } catch (e) {
    print('✗ Error en logout: $e');
  }
}

/// Ejemplo completo: Flujo de usuario estudiante
Future<void> exampleCompleteStudentFlow() async {
  print('\n═══ EJEMPLO: Flujo Completo de Estudiante ═══\n');

  final authService = AuthService();
  final deviceService = DeviceService();
  final reservationService = ReservationService();
  final checkoutService = CheckoutService();

  try {
    // 1. Login
    print('1. Autenticando...');
    await authService.studentLogin(
      email: 'juan.perez@school.com',
      dni: '12345678',
    );
    print('   ✓ Autenticado\n');

    // 2. Ver notebooks disponibles
    print('2. Buscando notebooks disponibles...');
    final notebooks = await deviceService.getNotebooks();
    print('   ✓ ${notebooks.length} notebooks encontrados\n');

    if (notebooks.isEmpty) {
      print('   ✗ No hay notebooks disponibles\n');
      return;
    }

    // 3. Crear reserva
    print('3. Creando reserva...');
    final firstNotebook = notebooks[0] as Map<String, dynamic>;
    final reservation = await reservationService.createReservation(
      deviceId: firstNotebook['id'] as String,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 8)),
      notes: 'Proyecto académico',
    );
    print('   ✓ Reserva creada: ${reservation['id']}\n');

    // 4. Ver mis reservas
    print('4. Consultando mis reservas...');
    final myReservations = await reservationService.getMyReservations();
    print('   ✓ Tengo ${myReservations.length} reservas\n');

    // 5. Logout
    print('5. Cerrando sesión...');
    await authService.logout();
    print('   ✓ Sesión cerrada\n');

    print('═══ Flujo completado exitosamente ═══\n');
  } on ApiException catch (e) {
    print('\n   ✗ Error: ${e.message}\n');
  }
}

void main() {
  print('Ejemplos disponibles:\n');
  print('1. exampleAdminLogin() - Login de admin');
  print('2. exampleStudentRegister() - Registro de estudiante');
  print('3. exampleStudentLogin() - Login de estudiante');
  print('4. exampleGetNotebooks() - Ver notebooks disponibles');
  print('5. exampleCreateReservation() - Crear una reserva');
  print('6. exampleGetMyReservations() - Ver mis reservas');
  print('7. exampleCancelReservation() - Cancelar una reserva');
  print('8. exampleCheckout() - Entregar un dispositivo');
  print('9. exampleReturn() - Devolver un dispositivo');
  print('10. exampleGetDevicesByType() - Ver dispositivos (filtrado)');
  print('11. exampleGetAllReturns() - Ver todas las devoluciones');
  print('12. exampleLogout() - Cerrar sesión');
  print('13. exampleCompleteStudentFlow() - Flujo completo de estudiante');
}

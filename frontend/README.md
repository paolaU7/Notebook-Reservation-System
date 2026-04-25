# NRS Frontend - Notebook Reservation System

Frontend Flutter para el sistema de reservas de notebooks NRS, con integración completa con el backend Dart Frog.

## Estructura del Proyecto

```
lib/
├── core/
│   ├── api_client.dart          # Cliente HTTP con gestión de headers y tokens
│   ├── constants.dart           # Constantes de la app (URLs, endpoints, keys)
│   └── auth_storage.dart        # Almacenamiento seguro de tokens JWT
├── services/
│   ├── auth_service.dart        # Servicio de autenticación y login
│   ├── reservation_service.dart # Servicio de operaciones de reservas
│   ├── device_service.dart      # Servicio de gestión de dispositivos
│   ├── checkout_service.dart    # Servicio de entregas y devoluciones
│   └── watchlist_service.dart   # Servicio de supervisión de dispositivos
└── main.dart                    # Punto de entrada de la aplicación
```

## Configuración

### Dependencias

El `pubspec.yaml` incluye:
- `http: ^1.2.0` - Cliente HTTP para peticiones REST
- `flutter_secure_storage: ^9.0.0` - Almacenamiento seguro de tokens

### URL del Backend

Por defecto, el cliente apunta a:
```dart
static const String baseUrl = 'http://localhost:8080';
```

Para cambiar la URL, edita `lib/core/constants.dart`:
```dart
static const String baseUrl = 'http://tu-servidor:puerto';
```

## Uso

### 1. Autenticación

```dart
import 'package:nrs_frontend/services/auth_service.dart';

final authService = AuthService();

// Login como admin/teacher/student
try {
  final result = await authService.login(
    email: 'user@example.com',
    password: 'password',
    role: 'student',
  );
  print('Login exitoso: $result');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 2. Obtener Notebooks

```dart
import 'package:nrs_frontend/services/device_service.dart';

final deviceService = DeviceService();

try {
  final notebooks = await deviceService.getNotebooks();
  print('Notebooks disponibles: $notebooks');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 3. Crear una Reserva

```dart
import 'package:nrs_frontend/services/reservation_service.dart';

final reservationService = ReservationService();

try {
  final reservation = await reservationService.createReservation(
    deviceId: 'device-123',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    notes: 'Mis notas',
  );
  print('Reserva creada: $reservation');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 4. Entregar un Dispositivo (Checkout)

```dart
import 'package:nrs_frontend/services/checkout_service.dart';

final checkoutService = CheckoutService();

try {
  final checkout = await checkoutService.checkoutDevice(
    reservationId: 'reservation-123',
    deviceNotes: 'Dispositivo en buen estado',
    confirm: true,
  );
  print('Checkout completado: $checkout');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 5. Devolver un Dispositivo (Return)

```dart
try {
  final returnResult = await checkoutService.returnDevice(
    checkoutId: 'checkout-123',
    condition: 'good',
    notes: 'Sin daños',
  );
  print('Devolución registrada: $returnResult');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

## Endpoints Cubiertos

### Autenticación
- `POST /auth/login` - Login con email, contraseña y rol
- `POST /students/login` - Login de estudiante con email y DNI
- `POST /students/register` - Registro de nuevo estudiante

### Dispositivos
- `GET /notebooks` - Obtener lista de notebooks disponibles
- `GET /devices` - Obtener dispositivos (con filtros opcionales)
- `GET /devices/:id` - Obtener detalles de un dispositivo
- `GET /devices/:id/status` - Obtener estado del dispositivo
- `POST /devices` - Crear nuevo dispositivo (solo admin)

### Reservas
- `POST /reservations` - Crear nueva reserva
- `GET /reservations` - Obtener mis reservas
- `GET /reservations/all` - Obtener todas las reservas (admin)
- `GET /reservations/:id/tokens` - Obtener tokens de una reserva
- `PATCH /reservations/:id/cancel` - Cancelar una reserva

### Entregas
- `POST /checkouts` - Registrar entrega de dispositivo
- `POST /checkouts/redeem` - Redimir/confirmar checkout
- `POST /returns` - Registrar devolución
- `GET /returns/:id` - Obtener detalles de devolución
- `GET /returns` - Obtener lista de devoluciones (admin)

### Supervisión
- `GET /watchlist` - Obtener lista de supervisión (admin)
- `GET /watchlist/:id` - Obtener detalles de item en watchlist
- `POST /watchlist` - Agregar a lista de supervisión (admin)

## Manejo de Errores

Todos los servicios lanzan `ApiException` en caso de error:

```dart
try {
  // ... código del servicio
} on ApiException catch (e) {
  print('Error: ${e.message}');
  print('Status: ${e.statusCode}');
  print('Error original: ${e.originalError}');
}
```

## Almacenamiento de Tokens

Los tokens JWT se almacenan de forma segura usando `flutter_secure_storage`:

```dart
import 'package:nrs_frontend/core/auth_storage.dart';

final storage = AuthStorage();

// Guardar token
await storage.saveToken('mi-token-jwt');

// Obtener token
final token = await storage.getToken();

// Eliminar token (logout)
await storage.deleteToken();

// Limpiar todo
await storage.clear();
```

## Instalación y Ejecución

1. Instalar dependencias:
```bash
flutter pub get
```

2. Configurar el backend en `lib/core/constants.dart` si es necesario

3. Ejecutar la app:
```bash
flutter run
```

## Notas Importantes

- Los servicios son singletons para asegurar una única instancia durante la ejecución
- La autenticación se maneja automáticamente con los headers de autorización
- Los errores del backend se mapean automáticamente a excepciones `ApiException`
- El manejo de CORS debe estar configurado en el backend si está en otro dominio

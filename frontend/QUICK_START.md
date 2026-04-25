# ⚡ INICIO RÁPIDO - NRS Frontend REST Integration

**5 minutos para tener la integración funcionando.**

---

## 1️⃣ Clonar/Copiar el código

```bash
cd frontend
flutter pub get
```

---

## 2️⃣ Configurar URL del Backend

Abre `lib/core/constants.dart` y cambia:

```dart
static const String baseUrl = 'http://localhost:8080';
```

Por tu URL real si es diferente.

---

## 3️⃣ Ejecutar la App

```bash
flutter run
```

---

## 4️⃣ Usar en tu código

```dart
import 'package:nrs_frontend/services/auth_service.dart';

// Login
final authService = AuthService();
await authService.login(
  email: 'user@example.com',
  password: 'password',
  role: 'student',
);

// El token se guarda automáticamente ✓
```

---

## 5️⃣ Otros servicios disponibles

```dart
import 'package:nrs_frontend/services/device_service.dart';
import 'package:nrs_frontend/services/reservation_service.dart';
import 'package:nrs_frontend/services/checkout_service.dart';

// Dispositivos
final devices = await DeviceService().getNotebooks();

// Reservas
final reservations = await ReservationService().getMyReservations();

// Entregas
await CheckoutService().checkoutDevice(reservationId: 'id', confirm: true);
```

---

## 📖 Si necesitas ayuda

| Necesito | Archivo |
|----------|---------|
| Setup completo | `SETUP_INSTRUCTIONS.md` |
| Todos los ejemplos | `lib/examples.dart` |
| Ejemplos UI | `lib/widgets_examples.dart` |
| Documentación | `README.md` |
| Lista de archivos | `FILES_INDEX.md` |
| Overview | `INTEGRATION_SUMMARY.md` |

---

## ✅ Listo

El backend está disponible en: **http://localhost:8080**

La integración está **funcional y lista** para usar. 🎉

---

Próximo paso: Leer `SETUP_INSTRUCTIONS.md` si algo no funciona.

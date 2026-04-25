% SETUP Y CONFIGURACIÓN INICIAL - NRS Frontend Integración REST

# Instrucciones de Setup Inicial

Sigue estos pasos para tener la integración REST completamente operacional.

## 1️⃣ Prerequisitos

- Flutter SDK >= 3.0.0
- Backend Dart Frog ejecutándose en http://localhost:8080
- Editor: VS Code, Android Studio o Xcode

## 2️⃣ Instalación de Dependencias

```bash
# Navega a la carpeta frontend
cd frontend

# Instala las dependencias
flutter pub get

# (Opcional) Actualiza las dependencias
flutter pub upgrade
```

## 3️⃣ Configuración de la URL del Backend

### Opción A: URL estática (recomendado para desarrollo)

Edita `lib/core/constants.dart`:

```dart
class AppConstants {
  static const String baseUrl = 'http://localhost:8080';
  // ... resto del código
}
```

### Opción B: URL dinámica en tiempo de ejecución

En `lib/main.dart` o en `main_complete.dart`, usa:

```dart
import 'package:nrs_frontend/core/app_config.dart';

void main() {
  // Configura la URL antes de runApp()
  appConfig.setBaseUrl('http://192.168.1.100:8080');
  // O especifica el ambiente
  appConfig.configureForEnvironment(Environment.development);
  
  runApp(const MyApp());
}
```

### Opción C: Diferentes URLs por ambiente

```dart
void main() {
  final isProduction = bool.fromEnvironment('dart.vm.product');
  
  if (isProduction) {
    appConfig.setBaseUrl('https://api.nrs.com');
  } else {
    appConfig.setBaseUrl('http://localhost:8080');
  }
  
  runApp(const MyApp());
}
```

## 4️⃣ Verificar Conectividad

Ejecuta esta prueba rápida:

```dart
import 'package:nrs_frontend/services/auth_service.dart';

void testConnection() async {
  final authService = AuthService();
  
  try {
    // Intenta un login con credenciales de prueba
    // (Este debería fallar si las credenciales son inválidas,
    // pero nos dirá si la conexión al backend funciona)
    await authService.login(
      email: 'test@test.com',
      password: 'test',
      role: 'student',
    );
  } catch (e) {
    print('Error: $e');
    // Si ves "Error de conexión" o "Connection refused",
    // el backend no está disponible
  }
}
```

## 5️⃣ Usar la Integración en tu App

### opción 1: Usar main_complete.dart

Si quieres una estructura lista con Login/Home:

```bash
# Reemplaza main.dart con main_complete.dart
mv lib/main.dart lib/main_basic.dart
mv lib/main_complete.dart lib/main.dart

# Ejecuta la app
flutter run
```

### Opción 2: Integrar manualmente en tu main.dart existente

```dart
import 'package:nrs_frontend/services/auth_service.dart';
import 'package:nrs_frontend/services/device_service.dart';

// En tu widget:
final authService = AuthService();

Future<void> loginExample() async {
  try {
    await authService.login(
      email: 'user@example.com',
      password: 'password',
      role: 'student',
    );
    // Login exitoso, el token se guardó automáticamente
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

## 6️⃣ Ejecutar la Aplicación

```bash
# Ejecuta en dispositivo o emulador
flutter run

# O especifica un device
flutter run -d <device-id>

# Mode release (más rápido)
flutter run --release
```

## 7️⃣ Verificar que Todo Funciona

Una vez que la app esté corriendo:

1. **Login**: Intenta autenticarte con credenciales válidas del backend
2. **Conectividad**: Deberías ver que los datos se cargan sin errores
3. **Tokens**: El token se guardará automáticamente en almacenamiento seguro
4. **Requests**: Usa las herramientas de desarrollo para ver las peticiones

## 8️⃣ Configuración Avanzada

### Modo Verbose (Debug)

```dart
appConfig.setVerbose(true); // Ver logs en consola
```

### Timeout Personalizado

```dart
appConfig.setRequestTimeout(45); // 45 segundos
```

### Cambiar Ambiente

```dart
appConfig.configureForEnvironment(Environment.production);
```

## ⚠️ Problemas Comunes

### 1. "Connection refused" o "Unable to connect"

**Problema**: El frontend no puede conectar con el backend.

**Soluciones**:
- Verifica que el backend está ejecutándose en `http://localhost:8080`
- Si es en otro servidor: `appConfig.setBaseUrl('http://tu-servidor:puerto')`
- Revisa el firewall: asegúrate que el puerto 8080 está abierto
- En emulador Android: usa `http://10.0.2.2:8080` en lugar de `localhost`

### 2. "Bad State: Future already completed"

**Problema**: Se llama un servicio después de logout.

**Solución**:
- Verifica si `await authService.isAuthenticated()` devuelve true
- Re-autentica antes de hacer nuevas peticiones

### 3. Token expirado o inválido

**Problema**: Requests fallan después de cierto tiempo.

**Solución**:
- Implementa refresh de tokens
- O re-autentica al usuario
- Ver `services/auth_service.dart` para más detalles

### 4. CORS errors (si el backend está en otro dominio)

**Problema**: Browser devuelve CORS error.

**Solución**:
- Configura CORS en el backend Dart Frog
- Agrega headers apropiados en ApiClient

### 5. Pantalla en blanco después de login

**Problema**: La app se queda cargando indefinidamente.

**Solución**:
- Revisa los logs con `flutter logs`
- Verifica que los endpoints existen en el backend
- Comprueba que la respuesta JSON es válida

## ✅ Checklist de Verificación

- [ ] Flutter SDK instalado y actualizado
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Backend ejecutándose y accesible
- [ ] URL del backend configurada correctamente
- [ ] Credenciales de prueba disponibles
- [ ] No hay errores de red en la consola
- [ ] El login funciona
- [ ] Los datos se cargan correctamente
- [ ] Logout limpia los datos
- [ ] Tests pasan (`flutter test`)

## 📝 Próximos Pasos Después del Setup

1. **Adaptar la UI**: Personaliza las pantallas según tu diseño
2. **Agregar State Management**: Provider, Bloc o GetX
3. **Implementar Validaciones**: Campos, errores, etc.
4. **Agregar Caché**: Para mejor rendimiento
5. **Testing**: Escribe tests unitarios e integración

## 🆘 Si Algo No Funciona

1. Revisa los logs:
   ```bash
   flutter logs
   ```

2. Ejecuta con verbose:
   ```bash
   flutter run -v
   ```

3. Limpia el proyecto:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. Reconstruye:
   ```bash
   flutter pub get
   flutter pub upgrade
   flutter run --release
   ```

## 📚 Recursos

- **README.md** - Documentación completa
- **examples.dart** - 13 ejemplos de uso
- **widgets_examples.dart** - Ejemplos de UI
- **INTEGRATION_SUMMARY.md** - Resumen de la integración
- **services_test.dart** - Guía de testing

## 🎉 ¡Listo!

Una vez completado el setup, la integración REST está completamente operacional y lista para:

- Llamar cualquier endpoint del backend
- Manejar autenticación
- Almacenar datos en forma segura
- Capturar y mostrar errores

¡Comienza a construir tu app! 🚀

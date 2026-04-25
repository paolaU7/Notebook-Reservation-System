#!/usr/bin/env dart

/// Script de verificación de la integración REST
/// 
/// Ejecutar con:
/// dart lib/verify_integration.dart
/// 
/// Este script verifica que todos los archivos necesarios existan
/// y que la configuración esté correcta.

import 'dart:io';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  Verificación de Integración REST - NRS Frontend           ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  var allGood = true;

  // Verificar estructura de carpetas
  print('📁 Verificando estructura de carpetas...\n');
  allGood &= verifyFolder('lib');
  allGood &= verifyFolder('lib/core');
  allGood &= verifyFolder('lib/services');
  allGood &= verifyFolder('lib/models');
  allGood &= verifyFolder('test');

  print('\n');

  // Verificar archivos core
  print('🔧 Verificando archivos Core...\n');
  allGood &= verifyFile('lib/core/api_client.dart');
  allGood &= verifyFile('lib/core/constants.dart');
  allGood &= verifyFile('lib/core/auth_storage.dart');
  allGood &= verifyFile('lib/core/service_locator.dart');
  allGood &= verifyFile('lib/core/app_config.dart');

  print('\n');

  // Verificar archivos services
  print('⚙️  Verificando archivos Services...\n');
  allGood &= verifyFile('lib/services/auth_service.dart');
  allGood &= verifyFile('lib/services/device_service.dart');
  allGood &= verifyFile('lib/services/reservation_service.dart');
  allGood &= verifyFile('lib/services/checkout_service.dart');

  print('\n');

  // Verificar archivos models
  print('📦 Verificando archivos Models...\n');
  allGood &= verifyFile('lib/models/data_models.dart');

  print('\n');

  // Verificar ejemplos y documentación
  print('📚 Verificando documentación y ejemplos...\n');
  allGood &= verifyFile('lib/examples.dart');
  allGood &= verifyFile('lib/widgets_examples.dart');
  allGood &= verifyFile('lib/main.dart');
  allGood &= verifyFile('lib/main_complete.dart');
  allGood &= verifyFile('README.md');
  allGood &= verifyFile('SETUP_INSTRUCTIONS.md');
  allGood &= verifyFile('INTEGRATION_SUMMARY.md');
  allGood &= verifyFile('QUICK_START.md');
  allGood &= verifyFile('FILES_INDEX.md');

  print('\n');

  // Verificar pubspec.yaml
  print('📦 Verificando pubspec.yaml...\n');
  allGood &= verifyPubspec();

  print('\n');

  // Resumen
  print('\n╔════════════════════════════════════════════════════════════╗');
  if (allGood) {
    print('║  ✅ VERIFICACIÓN COMPLETADA - TODO CORRECTO                  ║');
    print('║                                                            ║');
    print('║  La integración REST está lista para usar.                 ║');
    print('║                                                            ║');
    print('║  Próximo paso: flutter pub get && flutter run             ║');
    print('╚════════════════════════════════════════════════════════════╝');
    exit(0);
  } else {
    print('║  ⚠️  VERIFICACIÓN FALLIDA - REVISAR ERRORES                 ║');
    print('║                                                            ║');
    print('║  Algunos archivos no fueron encontrados.                  ║');
    print('║  Verifica la estructura del proyecto.                     ║');
    print('╚════════════════════════════════════════════════════════════╝');
    exit(1);
  }
}

bool verifyFolder(String path) {
  final folder = Directory(path);
  if (folder.existsSync()) {
    print('  ✓ Carpeta encontrada: $path');
    return true;
  } else {
    print('  ✗ Carpeta NO encontrada: $path');
    return false;
  }
}

bool verifyFile(String path) {
  final file = File(path);
  if (file.existsSync()) {
    print('  ✓ Archivo encontrado: $path');
    return true;
  } else {
    print('  ✗ Archivo NO encontrado: $path');
    return false;
  }
}

bool verifyPubspec() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('  ✗ pubspec.yaml no encontrado');
    return false;
  }

  print('  ✓ pubspec.yaml encontrado');

  try {
    final content = file.readAsStringSync();

    // Verificar dependencias necesarias
    final hasHttp = content.contains('http:');
    final hasSecureStorage = content.contains('flutter_secure_storage:');

    if (hasHttp) {
      print('  ✓ Dependencia http configurada');
    } else {
      print('  ✗ Falta dependencia http');
    }

    if (hasSecureStorage) {
      print('  ✓ Dependencia flutter_secure_storage configurada');
    } else {
      print('  ✗ Falta dependencia flutter_secure_storage');
    }

    return hasHttp && hasSecureStorage;
  } catch (e) {
    print('  ✗ Error leyendo pubspec.yaml: $e');
    return false;
  }
}

// ALTERNATIVA: Resumen manual en print (sin dependencies externas)
/*
void main() {
  print('''
╔════════════════════════════════════════════════════════════╗
║        Verificación Manual de Integración REST             ║
╚════════════════════════════════════════════════════════════╝

ARCHIVOS QUE DEBEN EXISTIR:

Core Layer:
  □ lib/core/api_client.dart
  □ lib/core/constants.dart
  □ lib/core/auth_storage.dart
  □ lib/core/service_locator.dart
  □ lib/core/app_config.dart

Services Layer:
  □ lib/services/auth_service.dart
  □ lib/services/device_service.dart
  □ lib/services/reservation_service.dart
  □ lib/services/checkout_service.dart
  □ lib/services/watchlist_service.dart

Models Layer:
  □ lib/models/data_models.dart

Main App:
  □ lib/main.dart
  □ lib/main_complete.dart

Ejemplos:
  □ lib/examples.dart
  □ lib/widgets_examples.dart

Testing:
  □ test/services_test.dart

Documentación:
  □ README.md
  □ SETUP_INSTRUCTIONS.md
  □ INTEGRATION_SUMMARY.md
  □ QUICK_START.md
  □ FILES_INDEX.md

Configuración:
  □ pubspec.yaml (con http y flutter_secure_storage)

Si todos los archivos existen, ¡la integración está lista! 🎉
  ''');
}
*/

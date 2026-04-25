/// Service Locator para inyección de dependencias
/// 
/// Este archivo proporciona acceso fácil a todos los servicios
/// desde cualquier parte de la aplicación

import 'package:nrs_frontend/core/api_client.dart';
import 'package:nrs_frontend/core/auth_storage.dart';
import 'package:nrs_frontend/services/auth_service.dart';
import 'package:nrs_frontend/services/checkout_service.dart';
import 'package:nrs_frontend/services/device_service.dart';
import 'package:nrs_frontend/services/reservation_service.dart';

/// Service Locator - Proporciona acceso centralizado a todos los servicios
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  /// Obtiene la instancia del cliente API
  ApiClient getApiClient() {
    return ApiClient();
  }

  /// Obtiene la instancia de almacenamiento de autenticación
  AuthStorage getAuthStorage() {
    return AuthStorage();
  }

  /// Obtiene la instancia del servicio de autenticación
  AuthService getAuthService() {
    return AuthService();
  }

  /// Obtiene la instancia del servicio de dispositivos
  DeviceService getDeviceService() {
    return DeviceService();
  }

  /// Obtiene la instancia del servicio de reservas
  ReservationService getReservationService() {
    return ReservationService();
  }

  /// Obtiene la instancia del servicio de entregas
  CheckoutService getCheckoutService() {
    return CheckoutService();
  }
}

/// Acceso global a los servicios
final serviceLocator = ServiceLocator();

// Atajos para acceso rápido a servicios comunes
ApiClient get apiClient => serviceLocator.getApiClient();
AuthStorage get authStorage => serviceLocator.getAuthStorage();
AuthService get authService => serviceLocator.getAuthService();
DeviceService get deviceService => serviceLocator.getDeviceService();
ReservationService get reservationService =>
    serviceLocator.getReservationService();
CheckoutService get checkoutService => serviceLocator.getCheckoutService();

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// Servicio para almacenar y recuperar datos de autenticación de forma segura
class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  late final FlutterSecureStorage _storage;

  factory AuthStorage() {
    return _instance;
  }

  AuthStorage._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        keyCipherAlgorithm:
            KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
  }

  /// Guarda el token JWT
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: AppConstants.tokenStorageKey,
      value: token,
    );
  }

  /// Recupera el token JWT
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenStorageKey);
  }

  /// Elimina el token JWT
  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenStorageKey);
  }

  /// Guarda el rol del usuario
  Future<void> saveUserRole(String role) async {
    await _storage.write(
      key: AppConstants.userRoleKey,
      value: role,
    );
  }

  /// Recupera el rol del usuario
  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  /// Guarda el ID del usuario
  Future<void> saveUserId(String id) async {
    await _storage.write(
      key: AppConstants.userIdKey,
      value: id,
    );
  }

  /// Recupera el ID del usuario
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  /// Limpia todos los datos de autenticación
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: AppConstants.tokenStorageKey),
      _storage.delete(key: AppConstants.userRoleKey),
      _storage.delete(key: AppConstants.userIdKey),
    ]);
  }

  /// Verifica si existe un token almacenado
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

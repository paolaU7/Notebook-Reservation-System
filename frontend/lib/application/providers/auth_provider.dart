import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/api_client.dart';
import 'package:dio/dio.dart';

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null); // Null means no user logged in
  }

  Future<void> login(String email, String password, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient.instance.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': role.name,
        },
      );

      final token = response.data['token'];
      ApiClient.setAuthToken(token);

      // Alumnos inician como "Cuenta en Aire" (is_active: false)
      // TODO: Ideally the backend returns isActive, but for now we maintain business logic
      bool isActive = role == UserRole.student ? false : true;

      state = AsyncValue.data(
        User(
          email: email,
          dni: password, // Assuming DNI is used as password
          role: role,
          isActive: isActive,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        state = AsyncValue.error(e.response?.data['error'] ?? e.message ?? 'Error', StackTrace.current);
      } else {
        state = AsyncValue.error(e.toString(), StackTrace.current);
      }
    }
  }

  void logout() {
    ApiClient.clearAuthToken();
    state = const AsyncValue.data(null);
  }

  void activateAccount() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isActive: true));
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});

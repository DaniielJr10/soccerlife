import 'auth_service.dart';

class UserLoginService {
  // Ahora usamos AuthService que maneja todo
  static Future<Map<String, dynamic>> loginUsuario({
    required String email,
    required String password,
  }) async {
    return await AuthService.login(email: email, password: password);
  }
}

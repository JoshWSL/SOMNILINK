import 'package:dio/dio.dart';

class AuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });
}

class AuthService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://127.0.0.1:8000/api"),
  );

  // LOGIN
  static Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        "/accounts/login/",
        data: {"username": username, "password": password},
      );

      return AuthResult(
        success: true,
        accessToken: response.data["access"],
        refreshToken: response.data["refresh"],
      );
    } catch (e) {
      return AuthResult(success: false, errorMessage: "Login fehlgeschlagen");
    }
  }

  // REGISTRIEREN
  static Future<AuthResult> register(String username, String password) async {
    try {
      await _dio.post(
        "/accounts/register/",
        data: {"username": username, "password": password},
      );

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: "Registrierung fehlgeschlagen",
      );
    }
  }
}

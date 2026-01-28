// Registration and page is not fully connected to backend yet

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
    BaseOptions(baseUrl: "http://127.0.0.1:8000/api"), // url must fit to the ip of the django backend 
  );

  // LOGIN method
  static Future<AuthResult> login(String username, String password) async {
    try {
      // post the entered user and password to the django backend
      final response = await _dio.post(
        "/accounts/login/",
        data: {"username": username, "password": password},
      );
      // tokens for user account verification
      return AuthResult(
        success: true,
        accessToken: response.data["access"],
        refreshToken: response.data["refresh"],
      );
      // catch if wrong login is used 
    } catch (e) {
      return AuthResult(success: false, errorMessage: "Login fehlgeschlagen");
    }
  }

  // Register Method
  static Future<AuthResult> register(String username, String password) async {
    try {
      // post the registered user and password in the django backend
      await _dio.post(
        "/accounts/register/",
        data: {"username": username, "password": password},
      );

      // Cath if registration failed
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: "Registrierung fehlgeschlagen",
      );
    }
  }
}

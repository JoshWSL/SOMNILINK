// API zur verbindung mit Django REST

import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000//api/",  // URL für Backend (!!!! lokaler PC muss für VM geändert werden !!!!!!) eigener PC -> baseUrl: "http://127.0.0.1:8000//api/"
      connectTimeout: const Duration(seconds: 10),  // Timeout wird ab 10s mit Fehler abgefangen 
      receiveTimeout: const Duration(seconds: 10),  
      contentType: "application/json",  // Daten werden als JSON gesendet / empfangen
    ),
  );

  // Logging Interceptor -> zeigt welche Daten gesendet/empfangen werden (nur für entwicklung)
  static void init() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,          // zeigt url und header an
        requestBody: true,      // zeigt gesendete Daten an
        responseBody: true,     // zeigt antwort des Servers an
        error: true,            // zeigt Fehlermeldungen eines Requests an
      ),
    );
  }

  static Dio get instance => _dio;





  // Unterhalb alle Requests die die API an den Server schicken soll

  // ---------------- SEND SYMPTOM ----------------
  static Future<bool> sendSymptom(String symptom) async {
    try {
      final response = await _dio.post(
        "symptom",
        data: {"symptom": symptom},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------- LOAD HISTORY ----------------
  static Future<List<String>> loadHistory() async {
    try {
      final response = await _dio.get("history");

      if (response.statusCode != 200) return [];

      final List<dynamic> decoded = response.data;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- SEND CONSENT ----------------
  static Future<bool> sendConsent(bool value) async {
    try {
      final response = await _dio.post(
        "consent",
        data: {"consent": value},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

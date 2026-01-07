
// GET und POST Requests für die FHIR-Ressourcen von Django Backend
// Zugriff jeweils nur auf die Daten der jeweiligen ID
// Mit Fehler Behandlung für den Fall eines Netzwerkfehlers 
// Daten werden als JSON versendet und empfangen

import 'package:dio/dio.dart';
import 'api_service_dio.dart';

class FhirService {
  final Dio dio = ApiClient.instance;


  // GET: Patient 
  Future<Map<String, dynamic>> getPatient(String id) async {
    try {
      final response = await dio.get("/patient/$id/");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }



  // GET: Mental Health Questionnaire
  Future<Map<String, dynamic>> getMentalHealthQuestionnaire() async {
    try {
      final response = await dio.get("questionnaires/mental_health/");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Fehler: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Server Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerk Fehler: ${e.message}");
      }
    }
  }



// GET: Sleep Score Questionnaire
  Future<Map<String, dynamic>> getSleepScoreQuestionnaire() async {
    try {
      final response = await dio.get("questionnaires/rls_schlafscore/");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Fehler: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Server Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerk Fehler: ${e.message}");
      }
    }
  }
}


// GET Requests for FHIR-Ressources from Django Backend
// ID is defined in questionnaire pages, not in this page
// Exception handling for unforeseen errors
// Questionnaires are recived as .json
// Based on dio api service

import 'package:dio/dio.dart';
import 'api_service_dio.dart';

class FhirService {
  final Dio dio = ApiClient.instance;


  // GET: Patient // is not used at the moment (to be implemented in the future)
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



// GET: IRLS Questionnaire
  Future<Map<String, dynamic>> getIrlsQuestionnaire() async {
    try {
      final response = await dio.get("questionnaires/IRLS/"); // slug from django
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

  // GET: MHI-5 Questionnaire
  Future<Map<String, dynamic>> getMhi5Questionnaire() async {
    try {
      final response = await dio.get("questionnaires/MHI-5/");// slug from django
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

    // GET: Tagebuch Questionnaire
  Future<Map<String, dynamic>> getTagebuchQuestionnaire() async {
    try {
      final response = await dio.get("questionnaires/Tagebuch/");// slug from django
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

      // GET: RLS-6 Questionnaire
  Future<Map<String, dynamic>> getRls6Questionnaire() async {
    try {
      final response = await dio.get("questionnaires/RLS-6/");// slug from django
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

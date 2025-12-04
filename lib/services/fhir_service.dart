
// GET und POST Requests für die FHIR-Ressourcen
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

  // POST: Patient erstellen oder aktualisieren (nur für diese ID)
  Future<Map<String, dynamic>> postPatient(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.post("/patient/$id/", data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}"); // Server antwortet mit Fehler (404/400/500)
      } else {
        throw Exception("Netzwerkfehler: ${e.message}"); // Keine Antwort von Server enthalten
      }
    }
  }

  // GET: User
  Future<Map<String, dynamic>> getUser(String id) async {
    try {
      final response = await dio.get("/user/$id/");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: User
  Future<Map<String, dynamic>> postUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.post("/user/$id/", data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // GET: Questionnaires für Patienten
  Future<List<dynamic>> getQuestionnaires(String patientId) async {
    try {
      final response = await dio.get(
        "/questionnaire/",
        queryParameters: {"patient": patientId},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: Questionnaire für Patienten
  Future<Map<String, dynamic>> postQuestionnaire(String patientId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        "/questionnaire/",
        queryParameters: {"patient": patientId},
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // GET: QuestionnaireResponses für Patienten
  Future<List<dynamic>> getQuestionnaireResponses(String patientId) async {
    try {
      final response = await dio.get(
        "/questionnaireResponse/",
        queryParameters: {"patient": patientId},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: QuestionnaireResponse für Patienten
  Future<Map<String, dynamic>> postQuestionnaireResponse(String patientId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        "/questionnaireResponse/",
        queryParameters: {"patient": patientId},
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // GET: Consents für Patienten
  Future<List<dynamic>> getConsents(String patientId) async {
    try {
      final response = await dio.get(
        "/consent/",
        queryParameters: {"patient": patientId},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: Consent für Patienten
  Future<Map<String, dynamic>> postConsent(String patientId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        "/consent/",
        queryParameters: {"patient": patientId},
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // GET: MedicationStatements für Patienten
  Future<List<dynamic>> getMedicationStatements(String patientId) async {
    try {
      final response = await dio.get(
        "/medicationStatement/",
        queryParameters: {"patient": patientId},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: MedicationStatement für Patienten
  Future<Map<String, dynamic>> postMedicationStatement(String patientId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        "/medicationStatement/",
        queryParameters: {"patient": patientId},
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // GET: Consent by ID (bleibt unverändert)
  Future<Map<String, dynamic>> getConsent(String id) async {
    try {
      final response = await dio.get("/consent/$id/");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }

  // POST: Observation erstellen (bleibt unverändert)
  Future<Map<String, dynamic>> createObservation(Map<String, dynamic> fhirJson) async {
    try {
      final response = await dio.post("/observation/", data: fhirJson);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
      } else {
        throw Exception("Netzwerkfehler: ${e.message}");
      }
    }
  }
}

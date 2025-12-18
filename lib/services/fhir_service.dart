
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


  // POST: Mental Health Questionnaire
Future<Map<String, dynamic>> postMentalHealthAnswers(
    String patientId,
    Map<String, dynamic> data, // z.B. {"1":5,"2":3,"3":4,"4":2,"5":4}
) async {
  try {
    final response = await dio.post(
      "/questionnaireResponse/mental_health/", 
      queryParameters: {"patient": patientId},
      data: data,
    );
    return response.data;
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
          "Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
    } else {
      throw Exception("Netzwerkfehler: ${e.message}");
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


  // POST: Sleep Score Questionnaire
Future<Map<String, dynamic>> postSleepScoreAnswers(
    String patientId,
    Map<String, dynamic> data, // z.B. {"1":5,"2":3,"3":4,"4":2,"5":4}
) async {
  try {
    final response = await dio.post(
      "/questionnaireResponse/rls_schlafscore/", 
      queryParameters: {"patient": patientId},
      data: data,
    );
    return response.data;
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
          "Fehler: ${e.response!.statusCode} -> ${e.response!.data}");
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

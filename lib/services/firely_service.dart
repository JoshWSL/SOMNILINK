import 'dart:convert';
import 'package:http/http.dart' as http;

class FirelyService {
  final String baseUrl = "http://localhost:4080";

  Future<void> postQuestionnaireResponse(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/QuestionnaireResponse'),
      headers: {
        'Content-Type': 'application/fhir+json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw Exception("Fehler beim Senden: ${res.body}");
    }
  }
}

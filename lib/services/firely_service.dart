
// Connection to the firely-server
// baseURL must be updated as soon as the app is used on a other system with the IP of the firely server

import 'dart:convert';
import 'package:http/http.dart' as http;

class FirelyService {
  final String baseUrl = "http://localhost:4080"; // connects to local host // port 4080 is port for firely-server

  Future<void> postQuestionnaireResponse(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/QuestionnaireResponse'), // access to the QuestionaireResponce ressource on the firely
      headers: {
        'Content-Type': 'application/fhir+json',
      },
      body: jsonEncode(body),
    );
    
    // catches every false status code as error message
    if (res.statusCode != 201) {
      throw Exception("Fehler beim Senden: ${res.body}");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; 
  // WICHTIG: Für Android Emulator. Für Chrome ggf ändern auf localhost.

  // ---------------- SEND SYMPTOM ----------------
  static Future<bool> sendSymptom(String symptom) async {
    try {
      final url = Uri.parse("$baseUrl/symptom");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symptom": symptom}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------- LOAD HISTORY ----------------
  static Future<List<String>> loadHistory() async {
    try {
      final url = Uri.parse("$baseUrl/history");
      final response = await http.get(url);

      if (response.statusCode != 200) return [];

      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => e.toString()).toList();

    } catch (_) {
      return [];
    }
  }

  // ---------------- SEND CONSENT ----------------
  static Future<bool> sendConsent(bool value) async {
    try {
      final url = Uri.parse("$baseUrl/consent");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"consent": value}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

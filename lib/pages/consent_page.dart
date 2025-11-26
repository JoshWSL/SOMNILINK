import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rls_patient_app/services/api_service.dart';

class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _consent = false;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _consent = prefs.getBool("consent_active") ?? false;
      _lastUpdated = prefs.getString("consent_updated");
    });
  }

  Future<void> _saveConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("consent_active", value);

    final timestamp = DateTime.now().toString();
    await prefs.setString("consent_updated", timestamp);

    setState(() {
      _lastUpdated = timestamp;
    });
  }

  Future<void> _sendConsentToBackend() async {
    final success = await ApiService.sendConsent(_consent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "✔ Freigabe aktualisiert" : "❌ Fehler beim Aktualisieren"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datenfreigabe für Arzt"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Freigabestatus",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text(
                "Daten für ärztliches Dashboard freigeben",
                style: TextStyle(fontSize: 18),
              ),
              value: _consent,
              onChanged: (value) {
                setState(() => _consent = value);
                _saveConsent(value);
                _sendConsentToBackend();
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            const SizedBox(height: 20),
            const Text(
              "Letzte Aktualisierung:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            Text(
              _lastUpdated ?? "Keine Daten",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () async {
                _saveConsent(_consent);
                _sendConsentToBackend();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Freigabe aktualisieren"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

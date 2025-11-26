import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Patientendaten
  String name = "Unbekannt";
  String email = "-";
  String patientId = "PID-0000";
  String diagnosis = "RLS";
  String medication = "Keine Angaben";
  String severity = "Unbekannt";

  // Systemdaten
  String lastConsent = "Keine Daten";
  int symptomCount = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "Unbekannt";
      email = prefs.getString("email") ?? "-";
      patientId = prefs.getString("patientId") ?? "PID-0000";
      diagnosis = prefs.getString("diagnosis") ?? "RLS";
      medication = prefs.getString("medication") ?? "Keine Angaben";
      severity = prefs.getString("severity") ?? "Unbekannt";

      lastConsent = prefs.getString("consent_updated") ?? "Keine Daten";
      symptomCount = prefs.getInt("symptom_count") ?? 0;

      _loading = false;
    });
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("patientId", patientId);
    await prefs.setString("diagnosis", diagnosis);
    await prefs.setString("medication", medication);
    await prefs.setString("severity", severity);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil gespeichert")),
    );

    setState(() {});
  }

  void editField({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
          ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                saveProfile();
                Navigator.pop(context);
              },
              child: const Text("Speichern")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --------------------------------------------------------
            // PROFILKOPF
            // --------------------------------------------------------

            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue[200],
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text("Patienten-ID: $patientId"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --------------------------------------------------------
            // PERSÖNLICHE DATEN
            // --------------------------------------------------------

            const Text(
              "Persönliche Daten",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ListTile(
              title: const Text("Name"),
              subtitle: Text(name),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "Name ändern",
                currentValue: name,
                onSave: (v) => setState(() => name = v),
              ),
            ),

            ListTile(
              title: const Text("E-Mail"),
              subtitle: Text(email),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "E-Mail ändern",
                currentValue: email,
                onSave: (v) => setState(() => email = v),
              ),
            ),

            ListTile(
              title: const Text("Patienten-ID"),
              subtitle: Text(patientId),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "Patienten-ID ändern",
                currentValue: patientId,
                onSave: (v) => setState(() => patientId = v),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // --------------------------------------------------------
            // MEDIZINISCHE DATEN
            // --------------------------------------------------------

            const SizedBox(height: 20),
            const Text(
              "Medizinische Daten",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ListTile(
              title: const Text("Diagnose"),
              subtitle: Text(diagnosis),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "Diagnose ändern",
                currentValue: diagnosis,
                onSave: (v) => setState(() => diagnosis = v),
              ),
            ),

            ListTile(
              title: const Text("Medikation"),
              subtitle: Text(medication),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "Medikamente bearbeiten",
                currentValue: medication,
                onSave: (v) => setState(() => medication = v),
              ),
            ),

            ListTile(
              title: const Text("RLS-Schweregrad"),
              subtitle: Text(severity),
              trailing: const Icon(Icons.edit),
              onTap: () => editField(
                title: "RLS-Schweregrad",
                currentValue: severity,
                onSave: (v) => setState(() => severity = v),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // --------------------------------------------------------
            // SYSTEMINFORMATIONEN
            // --------------------------------------------------------

            const SizedBox(height: 20),
            const Text(
              "Systeminformationen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Symptome dokumentiert"),
              subtitle: Text("$symptomCount Einträge"),
            ),

            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text("Letzte Datenfreigabe"),
              subtitle: Text(lastConsent),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rls_patient_app/models/patient.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Patient data (dummy)
  String name = "Unbekannt";
  String email = "-";
  String patientId = "PID-0000";
  String diagnosis = "RLS";
  String medication = "Keine Angaben";
  String severity = "Unbekannt";

  // System data (dummy)
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

  // get Patient ID 
  patientId = prefs.getString("patientId") ?? "PID-0000";

  try {
    // Backend-Call
    final fhirService = FhirService();
    final json = await fhirService.getPatient(patientId);
    final patient = Patient.fromJson(json);

    setState(() {
      name = patient.name;
      severity = patient.gender; // example mapping
      _loading = false;
    });

    // Optional: lokal cachen
    await prefs.setString("name", name);

  } catch (e) {
    // Fallback auf lokale Daten
    setState(() {
      name = prefs.getString("name") ?? "Max Mustermann";
      email = prefs.getString("email") ?? "-";
      diagnosis = prefs.getString("diagnosis") ?? "RLS";
      medication = prefs.getString("medication") ?? "Keine Angaben";
      severity = prefs.getString("severity") ?? "Unbekannt";

      lastConsent = prefs.getString("consent_updated") ?? "Keine Daten";
      symptomCount = prefs.getInt("symptom_count") ?? 0;

      _loading = false;
    });
  }
}


  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("patientId", patientId);
    await prefs.setString("diagnosis", diagnosis);
    await prefs.setString("medication", medication);
    await prefs.setString("severity", severity);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profil gespeichert")));

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
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              saveProfile();
              Navigator.pop(context);
            },
            child: Text("Speichern"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SomniLink",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PROFILKOPF
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.blue[200],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Patienten-ID: $patientId"),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // PERSÖNLICHE DATEN
                  Text(
                    "Persönliche Daten",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  ListTile(
                    title: Text("Name"),
                    subtitle: Text(name),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "Name ändern",
                      currentValue: name,
                      onSave: (v) => setState(() => name = v),
                    ),
                  ),

                  ListTile(
                    title: Text("E-Mail"),
                    subtitle: Text(email),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "E-Mail ändern",
                      currentValue: email,
                      onSave: (v) => setState(() => email = v),
                    ),
                  ),

                  ListTile(
                    title: Text("Patienten-ID"),
                    subtitle: Text(patientId),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "Patienten-ID ändern",
                      currentValue: patientId,
                      onSave: (v) => setState(() => patientId = v),
                    ),
                  ),

                  SizedBox(height: 20),
                  Divider(),

                  // MEDIZINISCHE DATEN
                  SizedBox(height: 20),
                  Text(
                    "Medizinische Daten",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  ListTile(
                    title: Text("Diagnose"),
                    subtitle: Text(diagnosis),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "Diagnose ändern",
                      currentValue: diagnosis,
                      onSave: (v) => setState(() => diagnosis = v),
                    ),
                  ),

                  ListTile(
                    title: Text("Medikation"),
                    subtitle: Text(medication),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "Medikamente bearbeiten",
                      currentValue: medication,
                      onSave: (v) => setState(() => medication = v),
                    ),
                  ),

                  ListTile(
                    title: Text("RLS-Schweregrad"),
                    subtitle: Text(severity),
                    trailing: Icon(Icons.edit),
                    onTap: () => editField(
                      title: "RLS-Schweregrad",
                      currentValue: severity,
                      onSave: (v) => setState(() => severity = v),
                    ),
                  ),

                  SizedBox(height: 20),
                  Divider(),

                  // SYSTEMINFORMATIONEN
                  SizedBox(height: 20),
                  Text(
                    "Systeminformationen",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Symptome dokumentiert"),
                    subtitle: Text("$symptomCount Einträge"),
                  ),

                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text("Letzte Datenfreigabe"),
                    subtitle: Text(lastConsent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

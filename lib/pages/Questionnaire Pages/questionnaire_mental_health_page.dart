import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';

class MentalHealthPage extends StatefulWidget {
  const MentalHealthPage({super.key});

  @override
  State<MentalHealthPage> createState() => _MentalHealthPageState();
}

class _MentalHealthPageState extends State<MentalHealthPage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  // Map, um die Sliderwerte pro Frage zu speichern
  Map<int, double> sliderValues = {};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getMentalHealthQuestionnaire();

      // Null-sichere Items-Liste
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;

        // Initialisiere Sliderwerte auf 4 für jeden Eintrag
        sliderValues = {for (int i = 0; i < items.length; i++) i: 4};
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> submitAnswers() async {
    if (questionnaire == null) return;

    final patientId = "123"; // Hier dynamisch setzen

    // Map für Backend: linkId -> integer Wert
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    Map<String, int> answers = {};
    for (int i = 0; i < items.length; i++) {
      final linkId = items[i]['linkId'] ?? i.toString();
      answers[linkId] = sliderValues[i]?.round() ?? 0;
    }

    try {
      final result =
          await questionnaireService.postMentalHealthAnswers(patientId, answers);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Antworten erfolgreich gesendet!")),
      );

      print("POST Ergebnis: $result");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Senden: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text("Fehler: $error"));

    // Null-sicher die Items-Liste
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    final title = questionnaire?['title'] ?? "Fragebogen";
    final description = questionnaire?['description'] ?? "Fragebogen";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SomniLink",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // Titel über den Slidern in der Mitte
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // Beschreibung des Fragebogens
            Text(
              description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Flexible ListView für die Fragen
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final q = items[index] as Map<String, dynamic>? ?? {};
                  final text = q['text'] ?? "Keine Frage verfügbar";
                  final sliderValue = sliderValues[index] ?? 4;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.left,
                        ),
                        Slider(
                          value: sliderValue,
                          min: 0,
                          max: 8,
                          divisions: 8,
                          label: sliderValue.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              sliderValues[index] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // BUTTON zum Senden der Antworten
            ElevatedButton(
              onPressed: submitAnswers,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "Antworten senden",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

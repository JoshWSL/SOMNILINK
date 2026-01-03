import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';

class SleepScorePage extends StatefulWidget {
  const SleepScorePage({super.key});

  @override
  State<SleepScorePage> createState() => _SleepScorePage();
}

class _SleepScorePage extends State<SleepScorePage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  // Map to save the slider values
  Map<int, double> sliderValues = {};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getSleepScoreQuestionnaire();

      // items list
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;

        // slider values are initially on 4
        sliderValues = {for (int i = 0; i < items.length; i++) i: 2};
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

    final patientId = "123"; // patient id -> has to be dynamic

    // Map for Backend: linkId -> integer value
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    Map<String, int> answers = {};
    for (int i = 0; i < items.length; i++) {
      final linkId = items[i]['linkId'] ?? i.toString();
      answers[linkId] = sliderValues[i]?.round() ?? 0;
    }

    try {
      final result =
          await questionnaireService.postSleepScoreAnswers(patientId, answers);

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
            // Title above the questions
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // description of the questionnaire
            Text(
              description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // felxible ListView for the questions
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
                          max: 5,
                          divisions: 5,
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

            // Button to save the questions in backend
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

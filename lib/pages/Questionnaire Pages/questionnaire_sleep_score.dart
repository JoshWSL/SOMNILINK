import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class SleepScorePage extends StatefulWidget {
  final DateTime selectedDate; // Kalenderdatum übergeben

  const SleepScorePage({super.key, required this.selectedDate});

  @override
  State<SleepScorePage> createState() => _SleepScorePageState();
}

class _SleepScorePageState extends State<SleepScorePage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  // Map für die Slider-Werte
  Map<int, double> sliderValues = {};

  //----------------------------------------------------------------------------------------------------
  // create json for firely
  Map<String, dynamic> buildQuestionnaireResponse(
      String patientId,
      Map<int, double> sliderValues,
      DateTime authoredDate) {

    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];

    final responseItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map<String, dynamic>;
      final linkId = item['linkId'] ?? index.toString();
      final value = sliderValues[index]?.round() ?? 0;

      return {
        "linkId": linkId,
        "answer": [
          {"valueInteger": value}
        ]
      };
    }).toList();

    return {
      "resourceType": "QuestionnaireResponse",
      "status": "completed",
      "questionnaire": "Questionnaire/rls_schlafscore",
      "subject": {"reference": "Patient/111"}, // Patient-ID ggf. dynamisch setzen
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems
    };
  }

  //----------------------------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getSleepScoreQuestionnaire();

      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;

        // Slider initial auf 2
        sliderValues = {for (int i = 0; i < items.length; i++) i: 2};
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }


  // Send answers to Firely Server
  Future<void> submitAnswers() async {
    if (questionnaire == null) return;

    final patientId = "111"; // will be dynamic later on
    final firelyService = FirelyService();

    final response = buildQuestionnaireResponse(
        patientId, sliderValues, widget.selectedDate);

    try {
      await firelyService.postQuestionnaireResponse(response);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Antworten erfolgreich gesendet!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Senden: $e")),
      );
    }
  }

  // UI section
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text("Fehler: $error"));

    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    final title = questionnaire?['title'] ?? "Fragebogen";
    final description = questionnaire?['description'] ?? "Fragebogen";

    return Scaffold(
      // basic App bar (same on every page)
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
      //column with questions ans sliders
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final q = items[index] as Map<String, dynamic>? ?? {};
                  final text = q['text'] ?? "Keine Frage verfügbar";
                  final sliderValue = sliderValues[index] ?? 2;

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

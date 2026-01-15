import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class IrlsPage extends StatefulWidget {
  final DateTime selectedDate; // date from calender page

  const IrlsPage({super.key, required this.selectedDate});

  @override
  State<IrlsPage> createState() => _IrlsPageState();
}

class _IrlsPageState extends State<IrlsPage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  // map for slider values
  Map<int, double> sliderValues = {};


  // generates jason that will be sent to firely server
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
      "questionnaire": "Questionnaire/IRLS", 
      "subject": {"reference": "Patient/111"}, // will be dynamic later on
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems
    };
  }

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  // questionaires aus django backend laden
  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getIrlsQuestionnaire();
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;
        // Slider initial auf 4
        sliderValues = {for (int i = 0; i < items.length; i++) i: 4};
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }


  // Send answer to firely server
  Future<void> submitAnswers() async {
    if (questionnaire == null) return;

    final patientId = "111";
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

  //UI section
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

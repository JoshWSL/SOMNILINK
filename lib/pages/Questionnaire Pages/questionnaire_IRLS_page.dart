import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class IrlsPage extends StatefulWidget {
  final DateTime selectedDate;

  const IrlsPage({super.key, required this.selectedDate});

  @override
  State<IrlsPage> createState() => _IrlsPageState();
}

class _IrlsPageState extends State<IrlsPage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  Map<int, double> sliderValues = {};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }


  // Method to load IRLS from django backend  / catching exeptions for several errors that might occur
  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getIrlsQuestionnaire();
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;
        sliderValues = {for (int i = 0; i < items.length; i++) i: 2.0};
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // create a FHIR-ressource that can be send to the Firely-Server
  Map<String, dynamic> buildQuestionnaireResponse(
      String patientId, Map<int, double> sliderValues, DateTime authoredDate) {
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
      "subject": {"reference": "Patient/111"},
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems
    };
  }

  // Procedure for submitting the answers to the firely server as soon as the button is tapped
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

  // Display the Questionnaire with appropriate UI elements
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text("Fehler: $error")));

   
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    final title = questionnaire?['title'] ?? "IRLS Fragebogen";
    final description = questionnaire?['description'] ?? "";

    // description of the slider
    final sliderLabels = ["Nicht vorhanden", "Leicht", "Mäßig", "Ziemlich", "Sehr"];

    return Scaffold(
      // gneric app bar
      appBar: AppBar(
        title: const Text(
          "SomniLink",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final q = items[index] as Map<String, dynamic>;
                final text = q['text'] ?? "";
                final currentVal = sliderValues[index] ?? 2.0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Slider(
                          value: currentVal,
                          min: 0,
                          max: 4,
                          divisions: 4,
                          label: sliderLabels[currentVal.round()],
                          onChanged: (value) {
                            setState(() => sliderValues[index] = value);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(sliderLabels.length, (i) {
                              final isSelected = i == currentVal.round();
                              return Expanded(
                                child: Text(
                                  sliderLabels[i],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.blue : Colors.black54,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Button to submit answers
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: submitAnswers,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "Antworten senden",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

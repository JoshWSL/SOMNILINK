import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class Mhi5Page extends StatefulWidget {
  final DateTime selectedDate;

  const Mhi5Page({super.key, required this.selectedDate});

  @override
  State<Mhi5Page> createState() => _Mhi5PageState();
}

class _Mhi5PageState extends State<Mhi5Page> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  // Map für Slider-Werte: LinkId als Key, double als Wert für den Slider
  Map<String, double> sliderValues = {};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  /// Extrahiert die Fragen aus der FHIR-Struktur (beachtet die 'group')
  List<dynamic> _getQuestions() {
    if (questionnaire == null) return [];
    final items = questionnaire!['item'] as List<dynamic>? ?? [];
    
    // Da MHI-5 oft in einer Gruppe "mhi5" gekapselt ist:
    if (items.isNotEmpty && items[0]['type'] == 'group') {
      return items[0]['item'] as List<dynamic>? ?? [];
    }
    return items;
  }

  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getMhi5Questionnaire();
      setState(() {
        questionnaire = data;
        final questions = _getQuestions();
        
        // Initialwert auf 4 (Manchmal) für jede Frage setzen
        sliderValues = {
          for (var q in questions) q['linkId'].toString(): 4.0
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> buildQuestionnaireResponse(
      String patientId,
      Map<String, double> sliderValues,
      DateTime authoredDate) {
    
    final questions = _getQuestions();

    final responseItems = questions.map((item) {
      final linkId = item['linkId'];
      final value = sliderValues[linkId]?.round() ?? 4;

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
      "questionnaire": "Questionnaire/MHI-5",
      "subject": {"reference": "Patient/111"},
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems
    };
  }

  Future<void> submitAnswers() async {
    if (questionnaire == null) return;

    final patientId = "111";
    final firelyService = FirelyService();
    final response = buildQuestionnaireResponse(patientId, sliderValues, widget.selectedDate);

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text("Fehler: $error")));

    final questions = _getQuestions();
    final title = questionnaire?['title'] ?? "MHI-5 Fragebogen";
    final description = questionnaire?['description'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SomniLink",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final linkId = q['linkId'];
                final text = q['text'] ?? "";
                final currentVal = sliderValues[linkId] ?? 4.0;
                final options = q['answerOption'] as List<dynamic>? ?? [];

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
                          min: 1,
                          max: 6,
                          divisions: 5,
                          onChanged: (value) {
                            setState(() => sliderValues[linkId] = value);
                          },
                        ),
                        // Dynamische Beschriftung unter dem Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: options.map((opt) {
                              final code = opt['valueCoding']['code'].toString();
                              final display = opt['valueCoding']['display'].toString();
                              final isSelected = code == currentVal.round().toString();

                              return Expanded(
                                child: Text(
                                  display,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.blue : Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
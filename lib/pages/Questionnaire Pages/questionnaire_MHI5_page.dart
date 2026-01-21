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

  // Map to save the slider values (pure, not inverted)
  Map<String, double> sliderValues = {};

  // for MHI-5 there is a need to invert some answer values 
  final Set<String> invertedQuestions = {'c', 'e'};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  /// Extrahiert Fragen (beachtet optionale group-Kapselung)
  List<dynamic> _getQuestions() {
    if (questionnaire == null) return [];
    final items = questionnaire!['item'] as List<dynamic>? ?? [];

    if (items.isNotEmpty && items[0]['type'] == 'group') {
      return items[0]['item'] as List<dynamic>? ?? [];
    }
    return items;
  }

  // Method to load MHI-5 from django backend  / catching exeptions for several errors that might occur
  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getMhi5Questionnaire();
      setState(() {
        questionnaire = data;
        final questions = _getQuestions();
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

  // encode/inverse slider values of question c and e
  int _encodeMhi5Value(String linkId, int rawValue) {
    if (invertedQuestions.contains(linkId)) {
      return 7 - rawValue;
    }
    return rawValue;
  }

  // create a FHIR-ressource that can be send to the Firely-Server
  Map<String, dynamic> buildQuestionnaireResponse(
    String patientId,
    Map<String, double> sliderValues,
    DateTime authoredDate,
  ) {
    final questions = _getQuestions();

    final responseItems = questions.map((item) {
      final String linkId = item['linkId'].toString();
      final int rawValue = sliderValues[linkId]?.round() ?? 4;

      // save encoded value
      final int encodedValue = _encodeMhi5Value(linkId, rawValue);

      return {
        "linkId": linkId,
        "answer": [
          {"valueInteger": encodedValue}
        ]
      };
    }).toList();

    return {
      "resourceType": "QuestionnaireResponse",
      "status": "completed",
      "questionnaire": "Questionnaire/MHI-5",
      "subject": {"reference": "Patient/$patientId"},
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems
    };
  }

  // Procedure for submitting the answers to the firely server as soon as the button is tapped
  Future<void> submitAnswers() async {
    if (questionnaire == null) return;

    final patientId = "111";
    final firelyService = FirelyService();
    final response =
        buildQuestionnaireResponse(patientId, sliderValues, widget.selectedDate);

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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text("Fehler: $error")),
      );
    }

    final questions = _getQuestions();
    final title = questionnaire?['title'] ?? "MHI-5 Fragebogen";
    final description = questionnaire?['description'] ?? "";

    return Scaffold(
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final linkId = q['linkId'].toString();
                final text = q['text'] ?? "";
                final currentVal = sliderValues[linkId] ?? 4.0;
                final options = q['answerOption'] as List<dynamic>? ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: options.map((opt) {
                              final code =
                                  opt['valueCoding']['code'].toString();
                              final display =
                                  opt['valueCoding']['display'].toString();
                              final isSelected =
                                  code == currentVal.round().toString();

                              return Expanded(
                                child: Text(
                                  display,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.black54,
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
          // Button to submit answers
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: submitAnswers,
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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

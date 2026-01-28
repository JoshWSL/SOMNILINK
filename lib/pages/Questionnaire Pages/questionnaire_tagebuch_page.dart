import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class TagebuchPage extends StatefulWidget {
  final DateTime selectedDate;

  const TagebuchPage({super.key, required this.selectedDate});

  @override
  State<TagebuchPage> createState() => _TagebuchPageState();
}

class _TagebuchPageState extends State<TagebuchPage> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  Map<String, String> answers = {}; // for integer and time in format HH:mm:ss

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  // load tagebuch from django backend (tagebuch is trated in backend same like a questionnire)
  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getTagebuchQuestionnaire();
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;

        for (var item in items) {
          if (item['type'] == 'group') {
            for (var sub in (item['item'] as List<dynamic>)) {
              answers[sub['linkId']] = '';
            }
          } else {
            answers[item['linkId']] = '';
          }
        }
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
      String patientId, Map<String, String> answers, DateTime authoredDate) {
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];

    List<Map<String, dynamic>> responseItems = [];

    for (var item in items) {
      if (item['type'] == 'group') {
        List<Map<String, dynamic>> subItems = [];
        for (var sub in item['item']) {
          if (sub['type'] == 'integer') {
            final value = int.tryParse(answers[sub['linkId']] ?? '0') ?? 0;
            subItems.add({
              "linkId": sub['linkId'],
              "answer": [
                {"valueInteger": value}
              ]
            });
          } else if (sub['type'] == 'time') {
            final value = answers[sub['linkId']] ?? '';
            if (value.isNotEmpty) {
              subItems.add({
                "linkId": sub['linkId'],
                "answer": [
                  {"valueTime": value}
                ]
              });
            }
          }
        }
        responseItems.add({
          "linkId": item['linkId'],
          "item": subItems
        });
      } else if (item['type'] == 'integer') {
        final value = int.tryParse(answers[item['linkId']] ?? '0') ?? 0;
        responseItems.add({
          "linkId": item['linkId'],
          "answer": [
            {"valueInteger": value}
          ]
        });
      } else if (item['type'] == 'time') {
        final value = answers[item['linkId']] ?? '';
        if (value.isNotEmpty) {
          responseItems.add({
            "linkId": item['linkId'],
            "answer": [
              {"valueTime": value}
            ]
          });
        }
      }
    }

    return {
      "resourceType": "QuestionnaireResponse",
      "status": "completed",
      "questionnaire": "Questionnaire/Tagebuch",
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

    final response = buildQuestionnaireResponse(patientId, answers, widget.selectedDate);

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

  Widget buildItemRow(Map<String, dynamic> item) {
    if (item['type'] == 'group') {
      final subItems = (item['item'] as List<dynamic>).cast<Map<String, dynamic>>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(item['text'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (item['linkId'] == '5')
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
            ),
          ...subItems.map((sub) => buildItemRow(sub)),
        ],
      );
    }

    // data handling for the integer values
    if (item['type'] == 'integer') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(item['text'])),
            Expanded(
              flex: 1,
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    answers[item['linkId']] = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    // data handling for the time values
    if (item['type'] == 'time') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(item['text'])),
            Expanded(
              flex: 1,
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d:]'))
                ],
                decoration: const InputDecoration(
                  // format is relevant to be savable in firely server
                  hintText: 'HH:mm:ss',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    answers[item['linkId']] = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Build UI elements that are not already biuld in the upper section
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text("Fehler: $error"));

    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    final title = questionnaire?['title'] ?? "Fragebogen";
    final description = questionnaire?['description'] ?? "Fragebogen";

    return Scaffold(
      // generic app bar
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: items.map((item) => buildItemRow(item as Map<String, dynamic>)).toList(),
              ),
            ),
            // Button to submit answers to firely-server
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

import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:rls_patient_app/services/firely_service.dart';

class Rls6Page extends StatefulWidget {
  final DateTime selectedDate;

  const Rls6Page({super.key, required this.selectedDate});

  @override
  State<Rls6Page> createState() => _Rls6PageState();
}

class _Rls6PageState extends State<Rls6Page> {
  final questionnaireService = FhirService();
  Map<String, dynamic>? questionnaire;
  bool isLoading = true;
  String? error;

  Map<String, double> sliderValues = {};

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  Future<void> loadQuestionnaire() async {
    try {
      final data = await questionnaireService.getRls6Questionnaire();
      final items = (data['item'] as List<dynamic>?) ?? [];

      setState(() {
        questionnaire = data;
        isLoading = false;

        sliderValues = {};
        for (var item in items) {
          if (item['type'] == 'group') {
            for (var sub in item['item']) {
              sliderValues[sub['linkId']] = 5.0;
            }
          } else {
            sliderValues[item['linkId']] = 5.0;
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

  Map<String, dynamic> buildQuestionnaireResponse(
      String patientId, Map<String, double> sliderValues, DateTime authoredDate) {
    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];

    List<Map<String, dynamic>> responseItems = [];

    for (var item in items) {
      if (item['type'] == 'group') {
        List<Map<String, dynamic>> subItems = [];
        for (var sub in item['item']) {
          subItems.add({
            "linkId": sub['linkId'],
            "answer": [
              {"valueInteger": sliderValues[sub['linkId']]?.round() ?? 0}
            ]
          });
        }
        responseItems.add({
          "linkId": item['linkId'],
          "item": subItems,
        });
      } else if (item['type'] == 'integer') {
        responseItems.add({
          "linkId": item['linkId'],
          "answer": [
            {"valueInteger": sliderValues[item['linkId']]?.round() ?? 0}
          ]
        });
      }
    }

    return {
      "resourceType": "QuestionnaireResponse",
      "status": "completed",
      "questionnaire": "Questionnaire/RLS-6",
      "subject": {"reference": "Patient/111"},
      "authored": authoredDate.toUtc().toIso8601String(),
      "item": responseItems,
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

  // Hilfsfunktion: Beschriftungen links/rechts des Sliders
  Map<String, String> getSliderBounds(String linkId) {
    switch (linkId) {
      case '1':
        return {"start": "völlig zufrieden", "end": "völlig unzufrieden"};
      case '2.1':
      case '2.2':
      case '2.3':
      case '2.4':
        return {"start": "nicht vorhanden", "end": "sehr schwer"};
      case '3':
        return {"start": "überhaupt nicht", "end": "sehr müde"};
      default:
        return {"start": "", "end": ""};
    }
  }

  Widget buildItemRow(Map<String, dynamic> item, {double indent = 0}) {
    if (item['type'] == 'group') {
      final subItems = (item['item'] as List<dynamic>).cast<Map<String, dynamic>>();
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['text'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...subItems.map((sub) => buildItemRow(sub, indent: indent + 16)).toList(),
          ],
        ),
      );
    }

    final currentVal = sliderValues[item['linkId']] ?? 5.0;
    final bounds = getSliderBounds(item['linkId']);

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['text'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bounds["start"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(bounds["end"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Slider(
            value: currentVal,
            min: 0,
            max: 10,
            divisions: 10,
            label: currentVal.round().toString(),
            onChanged: (value) {
              setState(() {
                sliderValues[item['linkId']] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text("Fehler: $error"));

    final items = (questionnaire?['item'] as List<dynamic>?) ?? [];
    final title = questionnaire?['title'] ?? "RLS-6";
    final description = questionnaire?['description'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SomniLink",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: items.map((item) => buildItemRow(item as Map<String, dynamic>)).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: submitAnswers,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text("Antworten senden", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

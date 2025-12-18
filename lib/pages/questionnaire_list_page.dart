import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_mental_health_page.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_sleep_score.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionnaireListPage extends StatefulWidget {
  final DateTime selectedDate; // Datum vom Kalender

  const QuestionnaireListPage({super.key, required this.selectedDate});

  @override
  State<QuestionnaireListPage> createState() => _QuestionnaireListPageState();
}

class _QuestionnaireListPageState extends State<QuestionnaireListPage> {
  List<Map<String, dynamic>> questionnaires = [];

  @override
  void initState() {
    super.initState();
    _loadQuestionnaires();
  }

  Future<void> _loadQuestionnaires() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("completed_questionnaires") ?? [];

    final questionnaireService = FhirService();
    final metalHealthData = await questionnaireService.getMentalHealthQuestionnaire();
    final metalHealthTitle = metalHealthData['title'] ?? "Fragebogen";

    final sleepScoreData = await questionnaireService.getSleepScoreQuestionnaire();
    final sleepScoreTitle = sleepScoreData['title'] ?? "Fragebogen";



    final fakeData = [
      {
        "id": "q1",
        "title": metalHealthTitle,
      },
      {
        "id": "q2",
        "title": sleepScoreTitle,
      },

    ];

    setState(() {
      questionnaires = fakeData
          .map((q) => {
                ...q,
                "completed": saved.contains(q["id"]),
                // Hier wird das Datum aus dem Kalender gesetzt
                "date": widget.selectedDate,
              })
          .toList();
    });
  }

  Future<void> _markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("completed_questionnaires") ?? [];

    if (!saved.contains(id)) {
      saved.add(id);
      await prefs.setStringList("completed_questionnaires", saved);
      _loadQuestionnaires();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: questionnaires.length,
        itemBuilder: (context, i) {
          final item = questionnaires[i];
          final bool completed = item["completed"];
          final DateTime date = item["date"];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(item["title"], style: const TextStyle(fontSize: 18)),
              subtitle: Text(
                "Datum: ${date.day}.${date.month}.${date.year}",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              trailing: Icon(
                completed ? Icons.check_circle : Icons.help,
                color: completed ? Colors.green : Colors.amber,
                size: 32,
              ),
              onTap: () async {
                if (!completed) {
                  await _markCompleted(item["id"]);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      completed
                          ? "Bereits erledigt."
                          : "Als erledigt markiert!",
                    ),
                  ),
                );

                // Navigation zu den entsprechenden Fragebogen-Seiten
                if (item["id"] == "q1") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MentalHealthPage()),
                  );
                }
                if (item["id"] == "q2") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SleepScorePage()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

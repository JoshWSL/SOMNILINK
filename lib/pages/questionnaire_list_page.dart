import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionnaireListPage extends StatefulWidget {
  const QuestionnaireListPage({super.key});

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

    // Fake-Daten bis Backend existiert
    final fakeData = [
      {
        "id": "q1",
        "title": "RLS Nachtfragebogen",
        "date": DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        "id": "q2",
        "title": "Täglicher Check-In",
        "date": DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        "id": "q3",
        "title": "Medikamenten Wirkung",
        "date": DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        "id": "q4",
        "title": "Schlafqualität Fragebogen",
        "date": DateTime.now().subtract(const Duration(days: 7)),
      },
    ];

    setState(() {
      questionnaires = fakeData
          .map((q) => {
                ...q,
                "completed": saved.contains(q["id"]),
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
          "Fragebögen",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: questionnaires.length,
        itemBuilder: (context, i) {
          final item = questionnaires[i];
          final bool completed = item["completed"];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item["title"],
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                "Datum: ${item["date"].day}.${item["date"].month}.${item["date"].year}",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              trailing: Icon(
                completed ? Icons.check_circle : Icons.help,
                color: completed ? Colors.green : Colors.amber,
                size: 32,
              ),
              onTap: () async {
                // später öffnet das den Fragebogen
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
              },
            ),
          );
        },
      ),
    );
  }
}

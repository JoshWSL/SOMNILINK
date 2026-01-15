import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_IRLS_page.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_MHI5_page.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_RLS6_page.dart';
import 'package:rls_patient_app/pages/Questionnaire%20Pages/questionnaire_tagebuch_page.dart';
import 'package:rls_patient_app/services/fhir_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionnaireListPage extends StatefulWidget {
  final DateTime selectedDate;

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

  // load questionnares from api
  Future<void> _loadQuestionnaires() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("completed_questionnaires") ?? [];

    final questionnaireService = FhirService();
    
    final tagebuchData = await questionnaireService.getTagebuchQuestionnaire();
    final tagebuchTitle = tagebuchData['title'] ?? "Fragebogen";
        
    final irlsData = await questionnaireService.getIrlsQuestionnaire();
    final irlsTitle = irlsData['title'] ?? "Fragebogen";

    final mhi5Data = await questionnaireService.getMhi5Questionnaire();
    final mhi5Title = mhi5Data['title'] ?? "Fragebogen";

    final rls6Data = await questionnaireService.getRls6Questionnaire();
    final rls6Title = rls6Data['title'] ?? "Fragebogen";
    
    

    // collection of the available questionnares
    final questData = [
      {
        "id": "q1",
        "title": tagebuchTitle,
      },
      {
        "id": "q2",
        "title": irlsTitle,
      },
      {
        "id": "q3",
        "title": mhi5Title,
      },
      {
        "id": "q4",
        "title": rls6Title,
      }
    ];

    // save if questionnaire is filled an on which date
    setState(() {
      questionnaires = questData
          .map((q) => {
                ...q,
                "completed": saved.contains(q["id"]),
                "date": widget.selectedDate,
              })
          .toList();
    });
  }

  // save if a questionnaire is completet or not
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
      // App bar (consistent for all pages)
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

          // List of all questionnaires that are able to fill out
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
              // coloured icon depending on completion status of the questionnare
              trailing: Icon(
                completed ? Icons.check_circle : Icons.help,
                color: completed ? Colors.green : Colors.amber,
                size: 32,
              ),
              onTap: () async {
                if (!completed) {
                  await _markCompleted(item["id"]);
                }

                // Navigation to the questionnares by taping the buttons
                if (item["id"] == "q1") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TagebuchPage(selectedDate: item["date"])),
                  );
                }
                if (item["id"] == "q2") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  IrlsPage(selectedDate: item["date"])),
                  );
                }
                if (item["id"] == "q3") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  Mhi5Page(selectedDate: item["date"])),
                  );
                }
                if (item["id"] == "q4") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  Rls6Page(selectedDate: item["date"])),
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

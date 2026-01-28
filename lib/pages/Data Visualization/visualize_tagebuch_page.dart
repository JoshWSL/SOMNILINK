import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class VisualizeTagebuchPage extends StatefulWidget {
  final DateTime selectedDate;

  const VisualizeTagebuchPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<VisualizeTagebuchPage> createState() => _VisualizeTagebuchPageState();
}

class _VisualizeTagebuchPageState extends State<VisualizeTagebuchPage> {
  final String baseUrl = "http://localhost:4080"; // url with firely server port (4080)
  bool isLoading = true;
  String? error;
  // List to save the results
  List<dynamic> items = [];


  // Mapping Table linkID to description text
  final Map<String, String> questionTexts = {
    "1": "Typische Schlafdauer",
    "2": "Typische Dauer im Bett",
    "3": "Zubettgehzeit",
    "4": "Zeitpunkt des Einschlafens",
    "5": "Schlafstörungen in der Nacht",
    "5a": "Wie oft nachts aufgewacht?",
    "5b": "Wie viele Stunden wach gewesen?",
    "6": "Zeitpunkt des Aufwachens",
    "7": "Zeitpunkt des Aufstehens",
    "8": "Schlafqualität insgesamt (1-9)",
  };

  @override
  void initState() {
    super.initState();
    loadEntry(patientId: '111');
  }

  // Method to load tagebuch from firely server / catching exeptions for several errors that might occur
  Future<void> loadEntry({required String patientId}) async {
    try {
      final res = await http.get(
        Uri.parse(
          '$baseUrl/QuestionnaireResponse'
          '?subject=http://localhost:4080/Patient/$patientId'
          '&_sort=-authored'
          '&_count=20',
        ),
        headers: {'Accept': 'application/fhir+json'},
      );

      if (res.statusCode != 200) throw Exception("Fehler: ${res.statusCode}");

      final decoded = jsonDecode(res.body);
      final List bundleEntries = decoded['entry'] ?? [];

      final sameDayEntry = bundleEntries
          .map((e) => e['resource'])
          .where((r) => r['questionnaire'] == 'Questionnaire/Tagebuch')
          .firstWhere(
        (r) {
          final authored = DateTime.parse(r['authored']).toLocal();
          return _isSameDay(authored, widget.selectedDate);
        },
        orElse: () => null,
      );

      setState(() {
        items = sameDayEntry != null ? (sameDayEntry['item'] ?? []) : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // check day of selected tagbuch
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // display items from tagebuch-json
  Widget buildItem(Map<String, dynamic> item) {
    final String linkId = item['linkId']?.toString() ?? "";
    final String labelText = questionTexts[linkId] ?? item['text'] ?? "Frage $linkId";


    if (item['item'] != null) {
      final subItems = (item['item'] as List<dynamic>).cast<Map<String, dynamic>>();
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
            ),
            const Divider(),
            ...subItems.map(buildItem),
          ],
        ),
      );
    }

    // Extract the answers that were made in the tagebuch entry
    final answers = item['answer'] as List<dynamic>? ?? [];
    String value = '-';

    if (answers.isNotEmpty) {
      final answer = answers.first;
      if (answer.containsKey('valueInteger')) {
        value = answer['valueInteger'].toString();
      } else if (answer.containsKey('valueTime')) {
        value = (answer['valueTime'] as String).substring(0, 5);
      }
    }

    // define Layout of list entry
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(labelText)),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Define all UI Elements for the tagebuch entries
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar like on every other page
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : items.isEmpty
                  ? const Center(child: Text("Kein Eintrag gefunden"))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          DateFormat('dd.MM.yyyy').format(widget.selectedDate),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...items.map((i) => buildItem(i)).toList(),
                      ],
                    ),
    );
  }
}
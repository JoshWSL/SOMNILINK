import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// for RLS-6, no total score is available -> selection of single questions, displayed in a line chart

class VisualizeRls6Page extends StatefulWidget {
  const VisualizeRls6Page({super.key});

  @override
  State<VisualizeRls6Page> createState() => _VisualizeRls6PageState();
}

class _VisualizeRls6PageState extends State<VisualizeRls6Page> {
  final String baseUrl = "http://localhost:4080"; // base url with firely port (4080)

  bool isLoading = true;
  String? error;

  String selectedItem = '1';

  // selections of the question of interest -> will be selected in a drop down
  final Map<String, String> itemOptions = {
    '1': 'Zufriedenheit mit meinem Schlaf',
    '2.4': 'Zufriedenheit mit meinem Alltag',
    '3': 'Müdigkeit in letzter Zeit',
  };

  // generating a lsit to hold the responses
  List<_Rls6Entry> entries = [];

  @override
  void initState() {
    super.initState();
    loadData(patientId: '111'); // will be dynamic later on
  }

  Future<void> loadData({required String patientId}) async {
    try {
      final res = await http.get(
        Uri.parse(
          '$baseUrl/QuestionnaireResponse'
          '?subject=http://localhost:4080/Patient/$patientId'
          '&_sort=-authored'
          '&_count=50',
        ),
        headers: {'Accept': 'application/fhir+json'},
      );

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      final decoded = jsonDecode(res.body);
      final List bundleEntries = decoded['entry'] ?? [];

      final filteredEntries = bundleEntries
          .map((e) => e['resource'])
          .where((resource) =>
              resource['questionnaire'] == 'Questionnaire/RLS-6') // firely slug = RLS-6
          .map<_Rls6Entry>((resource) {
        final authored = DateTime.parse(resource['authored']).toLocal();
        final items = resource['item'] as List<dynamic>? ?? [];

        final int? value = _findAnswerValue(items, selectedItem);

        return _Rls6Entry(
          date: authored,
          value: value?.toDouble() ?? 0,
        );
      }).toList();

      filteredEntries.sort((a, b) => a.date.compareTo(b.date));

      final last7Entries = filteredEntries.length > 7 // show only the last 7 entries
          ? filteredEntries.sublist(filteredEntries.length - 7)
          : filteredEntries;

      setState(() {
        entries = last7Entries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // get answers that is of interest -> dropdown selection
  int? _findAnswerValue(List<dynamic> items, String linkId) {
    for (final item in items) {
      if (item['linkId'] == linkId) {
        final answers = item['answer'] as List<dynamic>? ?? [];
        if (answers.isNotEmpty) {
          return answers.first['valueInteger'] as int?;
        }
      }

      if (item['item'] != null) {
        final found = _findAnswerValue(item['item'], linkId);
        if (found != null) return found;
      }
    }
    return null;
  }
 // build general UI items
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

    if (entries.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Keine Daten vorhanden")),
      );
    }

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
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Auswahl der gewünschten Information:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                // Selection of the question of interest
                DropdownButton<String>(
                  value: selectedItem,
                  items: itemOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedItem = value;
                      isLoading = true;
                    });
                    loadData(patientId: '111');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: buildChart()),
          ],
        ),
      ),
    );
  }
   // Build line graph (x = dates , y = score)
  Widget buildChart() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: 0,
        maxY: 10,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }

                final date = entries[index].date;

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('dd.MM').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(entries.length, (i) {
              return FlSpot(i.toDouble(), entries[i].value);
            }),
            isCurved: false,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

// Class to save intermediate results temp.
class _Rls6Entry {
  final DateTime date;
  final double value;

  _Rls6Entry({
    required this.date,
    required this.value,
  });
}

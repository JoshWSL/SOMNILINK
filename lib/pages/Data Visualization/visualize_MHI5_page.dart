import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// MHI-5 Score calculation:
// Score = 100 * ((sum of items - 5) / 25)

class VisualizeMhi5Page extends StatefulWidget {
  const VisualizeMhi5Page({super.key});

  @override
  State<VisualizeMhi5Page> createState() => _VisualizeMhi5PageState();
}

class _VisualizeMhi5PageState extends State<VisualizeMhi5Page> {
  final String baseUrl = "http://localhost:4080";

  bool isLoading = true;
  String? error;

  List<_Mhi5Entry> entries = [];

  @override
  void initState() {
    super.initState();
    loadData(patientId: '111'); // später dynamisch
  }

  // Method to load tagebuch from firely server / catching exeptions for several errors that might occur
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
              resource['questionnaire'] == 'Questionnaire/MHI-5')
          .map<_Mhi5Entry>((resource) {
        final authored = DateTime.parse(resource['authored']).toLocal();
        final items = resource['item'] as List<dynamic>? ?? [];

        int sum = 0;
        for (final item in items) {
          final answers = item['answer'] as List<dynamic>? ?? [];
          for (final answer in answers) {
            sum += (answer['valueInteger'] ?? 0) as int;
          }
        }

        // calculation of MHI-5 total score
        final double score = 100 * ((sum - 5) / 25);

        return _Mhi5Entry(
          date: authored,
          score: score.clamp(0, 100),
        );
      }).toList();

      filteredEntries.sort((a, b) => a.date.compareTo(b.date));

      final last7Entries = filteredEntries.length > 7
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // catch errors for no data available with error messages
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
            const Text(
              "Verlauf des MHI-5-Score (0–100, letzte 7 Einträge)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(child: buildChart()),
          ],
        ),
      ),
    );
  }

  // method to build the line chart with the total score
  Widget buildChart() {
    final DateTime startDate = entries.first.date;
    final double maxX = entries.last.date
        .difference(startDate)
        .inDays
        .toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX == 0 ? 1 : maxX,
        minY: 0,
        maxY: 100, 
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date =
                    startDate.add(Duration(days: value.toInt()));
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
            spots: entries.map((entry) {
              final x = entry.date
                  .difference(startDate)
                  .inDays
                  .toDouble();
              return FlSpot(x, entry.score);
            }).toList(),
            isCurved: false,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

// class to save date and score temporary
class _Mhi5Entry {
  final DateTime date;
  final double score;

  _Mhi5Entry({
    required this.date,
    required this.score,
  });
}

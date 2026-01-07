import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class VisualizeSleepScorePage extends StatefulWidget {
  const VisualizeSleepScorePage({super.key});

  @override
  State<VisualizeSleepScorePage> createState() =>
      _VisualizeSleepScorePageState();
}


class _VisualizeSleepScorePageState
    extends State<VisualizeSleepScorePage> {
  final String baseUrl = "http://localhost:4080"; // firely-server url

  bool isLoading = true;
  String? error;

  List<_SleepScoreEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadData(patientId: '111'); // will be dynamic later on
  }

  //method to load data from firely-server
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

      // filter for desired questionnaire (rls_schlafscore) (cant be done on server somehow)
      final filteredEntries = bundleEntries
          .map((e) => e['resource'])
          .where((resource) =>
              resource['questionnaire'] == 'Questionnaire/rls_schlafscore')
          .map<_SleepScoreEntry>((resource) {
        final authored = DateTime.parse(resource['authored']).toLocal();
        final items = resource['item'] as List<dynamic>? ?? [];

        int sum = 0;
        for (final item in items) {
          final answers = item['answer'] as List<dynamic>? ?? [];
          for (final answer in answers) {
            sum += (answer['valueInteger'] ?? 0) as int;
          }
        }

        return _SleepScoreEntry(date: authored, sum: sum);
      }).toList();

      // sort chronologically
      filteredEntries.sort((a, b) => a.date.compareTo(b.date));

      // only last 7 entries will be shown (can be adapdet)
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

  // generate UI
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
      // generic app bar like on all other pages
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
      // Title of graph
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Verlauf des Sleep-Score (letzte 7 Einträge)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(child: buildChart()),
          ],
        ),
      ),
    );
  }

  // Line chart
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
        maxY: 30,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
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
              return FlSpot(x, entry.sum.toDouble());
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

// class for saving intermediate results
class _SleepScoreEntry {
  final DateTime date;
  final int sum;

  _SleepScoreEntry({
    required this.date,
    required this.sum,
  });
}

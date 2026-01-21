import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class VisualizeIrlsPage extends StatefulWidget {
  const VisualizeIrlsPage({super.key});

  @override
  State<VisualizeIrlsPage> createState() =>
      _VisualizeIrlsPageState();
}

class _VisualizeIrlsPageState
    extends State<VisualizeIrlsPage> {
  final String baseUrl = "http://localhost:4080"; // url from firely

  bool isLoading = true;
  String? error;

  List<_IrlsEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadData(patientId: '111'); // will be dynamic later on
  }

  //load the questionnaires from the firely server
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

      // filter for the desired questionnaires (IRLS)
      final filteredEntries = bundleEntries
          .map((e) => e['resource'])
          .where((resource) =>
              resource['questionnaire'] == 'Questionnaire/IRLS')
          .map<_IrlsEntry>((resource) {
        final authored = DateTime.parse(resource['authored']).toLocal();
        final items = resource['item'] as List<dynamic>? ?? [];

        int sum = 0;
        for (final item in items) {
          final answers = item['answer'] as List<dynamic>? ?? [];
          for (final answer in answers) {
            sum += (answer['valueInteger'] ?? 0) as int;
          }
        }

        return _IrlsEntry(date: authored, sum: sum);
      }).toList();

      // sort descending chronologically
      filteredEntries.sort((a, b) => a.date.compareTo(b.date));

      // filter for last 7 entries
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

  //UI section
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // catch error
    if (error != null) {
      return Scaffold(
        body: Center(child: Text("Fehler: $error")),
      );
    }
    // catch error if no Data is accessable
    if (entries.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Keine Daten vorhanden")),
      );
    }

    return Scaffold(
      // app bar (same on every page)
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
      // title of the chart
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Verlauf des IRLS-Score (letzte 7 Einträge)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(child: buildChart()),
          ],
        ),
      ),
    );
  }

  // biulding the line chart with total IRLS score
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
        maxY: 40,
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

// class for saving temporary results
class _IrlsEntry {
  final DateTime date;
  final int sum;

  _IrlsEntry({
    required this.date,
    required this.sum,
  });
}

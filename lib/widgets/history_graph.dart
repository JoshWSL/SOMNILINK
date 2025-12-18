import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryGraph extends StatelessWidget {
  final List<DateTime> entries;

  const HistoryGraph({
    super.key,
    required this.entries,
  });

  List<FlSpot> _buildSpots(List<DateTime> data) {
    if (data.isEmpty) return [];

    // sortieren für saubere Darstellung
    data.sort();

    final first = data.first.millisecondsSinceEpoch.toDouble();

    return data.asMap().entries.map((e) {
      final index = e.key.toDouble();
      return FlSpot(index, 1); // jede Meldung zählt "1"
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots(entries);

    if (spots.isEmpty) {
      return const Center(
        child: Text("Keine Daten für Diagramm."),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 2,
          gridData: FlGridData(show: true),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              dotData: const FlDotData(show: true),
            )
          ],
        ),
      ),
    );
  }
}

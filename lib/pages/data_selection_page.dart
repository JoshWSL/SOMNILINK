import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/visualize_mental_health_page.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/visualize_sleep_score_page.dart';

class DataSelectionPage extends StatelessWidget {
  const DataSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar (same on every page)
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
      // Grid with 4*2 Buttons containing the charts
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2,
          children: [

            // Button for navigate to Mental Healt Line chart
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualizeMentalHealthPage(),
                  ),
                );
              },
              child: const Text("Mentale Gesundheit"),
            ),

            // Button for navigate to Sleep score chart
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualizeSleepScorePage(),
                  ),
                );
              },
              child: const Text("Schlafqualität"),
            ),

            // ---------------------- Button 3 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),

            // ---------------------- Button 4 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),

            // ---------------------- Button 5 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),

            // ---------------------- Button 6 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),

            // ---------------------- Button 7 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),

            // ---------------------- Button 8 ----------------------
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("tbd"),
            ),
          ],
        ),
      ),
    );
  }
}

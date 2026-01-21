import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/visualize_IRLS_page.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/visualize_MHI5_page.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/visualize_RLS6_page.dart';
import 'package:rls_patient_app/pages/Data%20Visualization/calendar_tagebuch_page.dart';

// The IRLS Score is calculated by summing the value from each question up
// The questions range from 0 (good) to 4 (bad) -> a higher score equals a worse state of the patient

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
      // Grid with 2*2 Buttons containing the charts
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2,
          children: [

            // Button for navigate to tagebuch date selection
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarTagebuchPage(),
                  ),
                );
              },
              child: const Text("Tagebuch"),
            ),

            // Button for navigate to IRLS Score visualization
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualizeIrlsPage(),
                  ),
                );
              },
              child: const Text("Symptomverlauf Allgemein\n(IRLS)", textAlign: TextAlign.center),
            ),

            // Button for navigate to MHI5 Score visualization
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualizeMhi5Page(),
                  ),
                );
              },
              child: const Text("Persönliches Wohbefinden \n(MHI-5)", textAlign: TextAlign.center),
            ),

            // Button for navigate to RLS-6 Score visualization
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualizeRls6Page(),
                  ),
                );
              },
              child: const Text("Zufriedenheit/Müdigkeit \n(RLS-6)", textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

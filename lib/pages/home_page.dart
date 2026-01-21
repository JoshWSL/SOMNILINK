import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/calendar_page.dart';
import 'package:rls_patient_app/pages/data_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// adding tab controller to choos the desired page
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
    
  @override
  void initState() {
    super.initState();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // App bar (same for all pages)
    appBar: AppBar(
        title: Text(
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
    // adding UI element for the data entry/visualisation buttons
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // zentriert vertikal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button for data entry and data visualisation
            const SizedBox(height: 100), // verschiebt die Buttons nach unten/in mitte
            SizedBox(
              height: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalendarPage(),
                    ),
                  );
                },
                child: const Text("Daten Eingeben"),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>   DataSelectionPage(),
                    ),
                  );
                },
                child: const Text("Daten anzeigen"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
    }
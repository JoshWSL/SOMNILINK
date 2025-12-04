import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/calendar_page.dart';
import 'package:rls_patient_app/pages/data_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
    
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
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
    // ❌ KEINE bottomNavigationBar -> kommt aus root_navigation.dart
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // zentriert vertikal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Buttons ----------
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
            const SizedBox(height: 15), // für Abstand zwischen Buttons
            SizedBox(
              height: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>   DataSelectionPage(), // andere Seite
                    ),
                  );
                },
                child: const Text("Daten anzeigen"),
              ),
            ),
            const SizedBox(height: 30),
            // Hier kannst du weitere Widgets einfügen
          ],
        ),
      ),
    ),
  );
}
    }
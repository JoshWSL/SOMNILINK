
import 'package:flutter/material.dart';



class DataSelectionPage extends StatelessWidget {
  const DataSelectionPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2, // 2 Buttons pro Reihe
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2, // Verhältnis Breite/Höhe der Buttons
          children: List.generate(8, (index) {
            return ElevatedButton(
              onPressed: () {
                // Beispiel: Navigation oder Funktion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Button ${index + 1} gedrückt")), // -> Hier Funktion zuordnen
                );
              },
              child: Text("Auswertung ${index + 1}"), // -> Hier benennen, was der jew. Button anzeigen soll
            );
          }),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class DataSelectionPage extends StatelessWidget {
  const DataSelectionPage({super.key});

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
      // grid with 2 * 4 buttons for selection of the data that should be visualized
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2, // 2 buttons in each row
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2, 
          children: List.generate(8, (index) {  // generate 8 buttons in total
            return ElevatedButton(
              // platzhalter für Funktion der buttons
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Button ${index + 1} gedrückt")), 
                );
              },
              //Platzhalter für benennung der Buttons
              child: Text("Auswertung ${index + 1}"),
            );
          }),
        ),
      ),
    );
  }
}

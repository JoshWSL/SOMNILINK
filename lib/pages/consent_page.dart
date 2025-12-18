import 'package:flutter/material.dart';

class InfoPageRLS extends StatelessWidget {
  const InfoPageRLS({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Was ist RLS?",
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "Restless-Legs-Syndrom (RLS)",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text(
              "Das Restless-Legs-Syndrom – auch „Unruhige Beine“ genannt – ist eine "
              "chronische neurologische Erkrankung. Sie führt dazu, dass Betroffene "
              "besonders abends oder nachts einen starken Drang verspüren, die Beine zu bewegen.",
              style: TextStyle(fontSize: 18, height: 1.4),
            ),

            const SizedBox(height: 30),

            const Text(
              "Typische Symptome:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _infoBullet("Kribbeln oder Ziehen in den Beinen"),
            _infoBullet("Innere Unruhe in den Beinen"),
            _infoBullet("Zwang, die Beine bewegen zu müssen"),
            _infoBullet("Beschwerden treten meist abends auf"),
            _infoBullet("Schlafstörungen durch nächtliche Bewegungen"),

            const SizedBox(height: 30),

            const Text(
              "Was sind mögliche Ursachen?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _infoBullet("Störungen im Dopaminstoffwechsel"),
            _infoBullet("Eisenmangel"),
            _infoBullet("Vererbung / familiäre Vorbelastung"),
            _infoBullet("Bestimmte Medikamente"),
            _infoBullet("Schwangerschaft (vorübergehend)"),

            const SizedBox(height: 30),

            const Text(
              "Wie wird RLS behandelt?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _infoBullet("Behandlung eines möglichen Eisenmangels"),
            _infoBullet("Medikamente, die den Dopaminhaushalt beeinflussen"),
            _infoBullet("Schlafhygiene und Entspannungsrituale"),
            _infoBullet("Reduktion von Koffein, Alkohol und Nikotin"),

            const SizedBox(height: 30),

            const Text(
              "Tipps für den Alltag:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _infoBullet("Leichte Bewegung am Abend"),
            _infoBullet("Warmes Bad oder Massage der Beine"),
            _infoBullet("Regelmäßiger Schlafrhythmus"),
            _infoBullet("Bewegung statt langes Sitzen"),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ------- Hilfsfunktion für Listenpunkte -------
  Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 20, height: 1.3)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPageRLS extends StatelessWidget {
  const InfoPageRLS({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar (same for all pages)
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

      // body with information about RLS
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              "Imformationen über RLS",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
            const Text(
              "Weitere Informationen auf der RLS e.V.-Website",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _openRLSevWebsite,
              child: const Text(
                'Website des RLS e.V.',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 40),


            const Text(
              "Information über Fragebögen",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "IRLS – International RLS Severity Scale ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Der IRLS-Score bietet Patienten eine beschreibung des Schweregrades der RLS-Erkrankung. Der Verlauf des IRLS-Scores stellt zusammengefasst den allgemeinen"
              " Symptomverlauf der Krankheit dar.",
              style: TextStyle(fontSize: 18),
            ),


            const SizedBox(height: 10),

            const Text(
              "MHI-5 – Mental Health Inentory ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Der MHI-5-Score bildet Stimmungs- und Angststörungen in aus den letzten 4 Wochen ab. Der Verlauf des MHI-5-Scores bietet einen Überblick über den Zustand der "
              " mentalen Gesundheit aus den vergangenen Wochen.",
              style: TextStyle(fontSize: 18),
            ),


            const SizedBox(height: 10),

            const Text(
              "RLS-6-Skalen",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Der RLS-6-Fragebogen beschreibt in 6 Fragen die Auswirkung der RLS-Erkrankung auf den Alltag von Patienten. Dabei lässt sich kein Gesamtscore berechnen. "
              " Die Antworten des Fragebogens werden individuell betrachtet.",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tagebuch",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Der in dieser App als Tagebuch bezeichnete Fragebogen dient der Erfassung der Schlafgesundheit der Patienten"
              " Er bietet die möglichkeit der täglichen Dokumentation von Schlafenszeiten und Qualität des Schlafes",
              style: TextStyle(fontSize: 18),
            ),


          ],
        ),
      ),
    );
  }

  // function for generating bullet points
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

// method that opens website link to the RLS e.v.
Future<void> _openRLSevWebsite() async {
  final uri = Uri.parse('https://www.restless-legs.org');

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Konnte die URL nicht öffnen';
  }
}

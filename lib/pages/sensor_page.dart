import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../services/sensor_event_service.dart';
import '../services/episode_service.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String _status = "Keine Bewegung erkannt";

  @override
  void initState() {
    super.initState();

    SensorService().onMovementDetected = (double intensity) async {
      // Episoden-Tracking
      EpisodeService().registerMovement(intensity);

      setState(() {
        _status = "Bewegung (Intensität ${intensity.toStringAsFixed(2)})";
      });

      // Event an Backend senden
      await SensorEventService.sendMovementEvent(
        patientId: "patient123",
        intensity: intensity,
      );
    };

    SensorService().start();
  }

  @override
  void dispose() {
    SensorService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sensor- und Episodentest")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _status,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final episodes = EpisodeService().episodes;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Episoden heute"),
                    content: Text(episodes.isEmpty
                        ? "Keine Episoden erkannt."
                        : episodes
                            .map((e) =>
                                "Start: ${e.start}\nDauer: ${e.duration.inSeconds}s\nIntensität: ${e.totalIntensity.toStringAsFixed(2)}\n")
                            .join("\n")),
                  ),
                );
              },
              child: const Text("Episoden anzeigen"),
            ),
          ],
        ),
      ),
    );
  }
}


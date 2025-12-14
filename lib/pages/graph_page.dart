import 'package:flutter/material.dart';
import 'package:rls_patient_app/services/api_service_dio.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verlauf")),
      body: FutureBuilder(
        future: ApiClient.loadHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data as List<String>;

          if (history.isEmpty) {
            return const Center(child: Text("Keine Einträge gefunden."));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(history[index]),
            ),
          );
        },
      ),
    );
  }
}

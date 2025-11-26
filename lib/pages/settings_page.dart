import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool("dark_mode") ?? false;
      _notifications = prefs.getBool("notifications") ?? true;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark_mode", value);
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const SizedBox(height: 10),
          const Text(
            "App Einstellungen",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: const Text("Dunkles Design"),
            subtitle: const Text("Schalte auf dunkles Farbschema um"),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              _saveDarkMode(value);
            },
          ),

          SwitchListTile(
            title: const Text("Benachrichtigungen"),
            subtitle: const Text("Push-Hinweise für Symptome und Freigaben"),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
              _saveNotifications(value);
            },
          ),

          const SizedBox(height: 20),
          const Divider(),

          const SizedBox(height: 20),
          const Text(
            "Informationen",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Über die App"),
            subtitle: const Text("Version 1.0 • RLS Projekt THU"),
          ),

          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text("Datenschutz"),
            subtitle: const Text("Details zur Datenverarbeitung"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Datenschutz"),
                  content: const Text(
                    "Deine Daten werden ausschließlich für die medizinische Auswertung "
                    "und Arztfreigabe genutzt (DSGVO-konform).",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("App zurücksetzen"),
            subtitle: const Text("Alle gespeicherten Daten löschen"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("App wirklich zurücksetzen?"),
                  content: const Text("Alle lokalen Daten werden gelöscht."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Abbrechen"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("App zurückgesetzt.")),
                        );
                      },
                      child: const Text("Ja, zurücksetzen"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

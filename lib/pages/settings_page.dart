import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;

  // settings are reloaded each time the app is opened
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // load settings of notification preferences,
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool("notifications") ?? true;
    });
  }

  // save settings of notification preferences 
  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications", value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Scaffold containing all UI elements of this page
    return Scaffold(
      // App bar (consistent for all pages)
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

      // further UI elements are strucutred in a list view
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // header for next section
          const SizedBox(height: 10),
          const Text(
            "App Einstellungen",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // Option to choose dark mode
          SwitchListTile(
            title: const Text("Dunkles Design"),
            subtitle: const Text("Schalte auf dunkles Farbschema um"),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),

          
          // option to activate / deactivate notifications
          SwitchListTile(
            title: const Text("Benachrichtigungen"),
            subtitle: const Text("Push-Hinweise für Symptome und Fragebögen"),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
              _saveNotifications(value);
            },
          ),

          // items for page layout
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // header for next section
          const Text(
            "Informationen",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // Information about version of the App
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Über die App"),
            subtitle: const Text("Version 1.0 • RLS Projekt THU"),
          ),

          // Infobox about data privacy, opens pop up with further information
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

          //Option to reset all data in app -> opens pop up to confirm
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

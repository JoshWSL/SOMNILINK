import 'package:flutter/material.dart';
import 'features/record/record_page.dart';
import 'features/timeline/timeline_page.dart';
import 'features/settings/settings_page.dart';

class RlsApp extends StatelessWidget {
  const RlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RLS Patient App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RlsHome(),
    );
  }
}

class RlsHome extends StatefulWidget {
  const RlsHome({super.key});

  @override
  State<RlsHome> createState() => _RlsHomeState();
}

class _RlsHomeState extends State<RlsHome> {
  int _index = 0;
  final _pages = const [
    RecordPage(),
    TimelinePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fiber_manual_record), label: 'Record'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Timeline'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

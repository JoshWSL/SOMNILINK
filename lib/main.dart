import 'package:flutter/material.dart';
import 'root_navigation.dart';

void main() {
  runApp(const RlsApp());
}

class RlsApp extends StatelessWidget {
  const RlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RLS Patienten-App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const RootNavigation(),
      routes: {
        '/home': (context) => const RootNavigation(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/home_page.dart';

class RlsApp extends StatelessWidget {
  const RlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RLS Patienten-App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'root_navigation.dart';
import 'services/api_service_dio.dart'; //Verbindung zu API Datei

void main() {
  ApiClient.init(); // Interceptor aktivieren
  runApp( RlsApp());
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
      home:  RootNavigation(),
      routes: {
        '/home': (context) =>  RootNavigation(),
      },
    );
  }
}

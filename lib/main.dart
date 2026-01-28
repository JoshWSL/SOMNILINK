import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rls_patient_app/pages/auth/login_page.dart';
import 'theme/theme_provider.dart';

// main()-method to start the app

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),   // App uses Theme privider from theme_provider.dart
      child: const SomniApp(),
    ),
  );
}

class SomniApp extends StatelessWidget {
  const SomniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // create app with either dark or light mode
    return MaterialApp(
      title: "SomniLink",
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      home: const LoginPage(),  // defines the login page as default page that is opened when started
    );
  }
}

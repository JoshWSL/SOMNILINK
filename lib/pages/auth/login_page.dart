import 'package:flutter/material.dart';
import '../../root_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    // --- HIER später API Login einbauen ---
    await Future.delayed(const Duration(seconds: 1));

    // Bei Erfolg → Navigiere zur RootNavigation (mit BottomNav)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootNavigation()),
    );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SomniLink Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Benutzername",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Passwort",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Einloggen"),
                      ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {},
                  child: const Text("Noch keinen Account? Registrieren"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

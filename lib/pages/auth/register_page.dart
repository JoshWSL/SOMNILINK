import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _errorMessage;
  bool _loading = false;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      _username.text.trim(),
      _password.text.trim(),
    );

    setState(() => _loading = false);

    if (result.success) {
      Navigator.pop(context); // zurück zum Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrierung erfolgreich!")),
      );
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrieren")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(
                labelText: "Benutzername",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Passwort",
                border: OutlineInputBorder(),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrieren"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

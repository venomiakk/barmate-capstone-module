import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_gate.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:flutter/material.dart';

class SetLoginScreen extends StatefulWidget {
  const SetLoginScreen({super.key});

  @override
  State<SetLoginScreen> createState() => _SetLoginScreenState();
}

class _SetLoginScreenState extends State<SetLoginScreen> {
  final loginController = TextEditingController();
  AuthService authService = AuthService();
  UserPreferences?
  _prefs; // Dodaj zmienną dla przechowywania instancji preferencji
  bool _isLoading = true; // Flaga ładowania

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  // Inicjalizacja preferencji
  Future<void> _initPreferences() async {
    try {
      _prefs = await UserPreferences.getInstance();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metoda do obsługi przycisku submit
  Future<void> _handleSubmit() async {
    if (_prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot access user preferences"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = _prefs!.getUserId(); // Teraz bezpiecznie pobierz userId
    final login = loginController.text;

    if (login.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final value = await authService.setLoginById(userId, login);
      if (value == '1') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login already exist"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        await _prefs!.setUserName(login); // Używamy zapisanej instancji
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login set"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Get Yourself a Login',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: loginController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    hintText: 'Write your login here',
                    hintStyle: const TextStyle(
                      color: Colors.black45,
                      fontSize: 18,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _handleSubmit,
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

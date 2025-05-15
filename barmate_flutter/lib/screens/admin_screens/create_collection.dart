import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:flutter/material.dart';

class CreateCollection extends StatefulWidget {
  const CreateCollection({super.key});

  @override
  State<CreateCollection> createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<CreateCollection> {
  final authService = AuthService();
  void logout() async {
    resetNotifiersToDefaults();
    try {
      // Pobierz instancję preferencji z await
      final prefs = await UserPreferences.getInstance();

      // Wyczyść preferencje z await
      await prefs.clear();

      // Wyloguj użytkownika
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              SizedBox(
                height: size.height * 0.08, // Adjust the height as needed
                child: Stack(
                  children: [
                    // Centered "Account" text
                    const Align(
                      alignment: Alignment.center,
                      child: const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Logout icon on the right
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.logout, size: 30),
                        onPressed: logout, // Link the logout function here
                      ),
                    ),
                  ],
                ),
              ), // Adjust the height as needed
            ],
          ),
        ),
      ),
    );
  }
}

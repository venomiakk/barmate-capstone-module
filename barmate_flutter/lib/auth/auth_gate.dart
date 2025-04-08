import 'package:barmate/screens/home_screen.dart';
import 'package:barmate/screens/spash_screen.dart';
import 'package:barmate/screens/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Correct import

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          print("session");
          final jwt = JwtDecoder.decode(session.accessToken);
          print(jwt);
          return const WidgetTree();
        } else {
          return const SpashScreen();
        }
      },
    );
  }
}
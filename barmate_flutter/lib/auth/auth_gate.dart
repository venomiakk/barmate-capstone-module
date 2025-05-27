import 'package:barmate/data/notifiers.dart';
import 'package:barmate/screens/admin_screens/admin_widget_tree.dart';
import 'package:barmate/screens/moderator_screens/moderator_widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/screens/user_screens/set_login_screen.dart';
import 'package:barmate/screens/user_screens/spash_screen.dart';
import 'package:barmate/screens/user_screens/widget_tree.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _handleAuthState(AuthState authState) async {
    final session = authState.session;
    if (session != null) {
      final jwt = JwtDecoder.decode(session.accessToken);
      final userId = jwt['user_metadata']['sub']?.toString() ?? '0';
      final userRole = jwt['user_role'];

      // Pobierz instancję preferencji tylko raz
      final prefs = await UserPreferences.getInstance();
      await prefs.setUserId(userId);

      final authService = AuthService();
      final userName = await authService.fetchUserLoginById(userId);
      await prefs.setUserName(userName.toString());

      if (userRole == 'admin') {
        await prefs.setUserName('admin');
        return const AdminWidgetTree();
      }
      if (userRole == 'moderator') {
        return const ModeratorWidgetTree();
      }
      if (userName == null || userName.isEmpty) {
        return const SetLoginScreen();
      } else {
        return const WidgetTree();
      }
    } else {
      return const SpashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<Widget>(
            future: _handleAuthState(snapshot.data!),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (futureSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Wystąpił błąd: ${futureSnapshot.error}'),
                  ),
                );
              } else {
                return futureSnapshot.data!;
              }
            },
          );
        } else {
          return const SpashScreen();
        }
      },
    );
  }
}

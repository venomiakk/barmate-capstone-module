
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/screens/set_login_screen.dart';
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
        AuthService authService = AuthService();
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          final jwt = JwtDecoder.decode(session.accessToken);
          UserPreferences.setId(jwt['user_metadata']['sub']?.toString() ?? '0'); // Convert to int
          try{
            authService.fetchUserLoginById(UserPreferences().getUserId()).then((value)=>{
              UserPreferences.setUserName(value!),
            });
            if (UserPreferences().getUserName() == 'guest') {
              return const SetLoginScreen();
            }
          }catch(e){
            return const SetLoginScreen();
          }
          return const WidgetTree();
        } else {
          return const SpashScreen();
        }
      },
    );
  }
}
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:barmate/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/data/notifiers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZ3BydGppbHpudnRlenZpaHd3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjkxMTAwOCwiZXhwIjoyMDU4NDg3MDA4fQ.uJAtHRsLeDJCV2sRrSriH7MqJSoNPYz5dU3ZRq3O9dY',
    url: 'https://dqgprtjilznvtezvihww.supabase.co',
  );
  await UserPreferences.getInstance().init(); // Initialize user preferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                currentTheme ? ColorScheme.light() : ColorScheme.dark(),
          ), // Use the current theme mode
          home: AuthGate(),
        );
      },
    );
  }
}

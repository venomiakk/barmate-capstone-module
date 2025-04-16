import 'package:flutter/material.dart';
import 'package:barmate/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZ3BydGppbHpudnRlenZpaHd3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjkxMTAwOCwiZXhwIjoyMDU4NDg3MDA4fQ.uJAtHRsLeDJCV2sRrSriH7MqJSoNPYz5dU3ZRq3O9dY',
    url: 'https://dqgprtjilznvtezvihww.supabase.co',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:Scaffold(
        body: AuthGate()
        ),
    );
  }
}

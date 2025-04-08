import 'package:flutter/material.dart';
import 'package:barmate/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZ3BydGppbHpudnRlenZpaHd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5MTEwMDgsImV4cCI6MjA1ODQ4NzAwOH0.fFq8-aLLYCBuE4jYIlY23RZfUkIp43S49Xnqh5dnvOM',
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

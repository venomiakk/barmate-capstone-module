import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:barmate/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // nie dziala !!!!
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final SupabaseClient supabase = Supabase.instance.client;
  testWidgets('database integration test - user authentication', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Attempt to sign in with a test user
    final response = await supabase.auth.signInWithPassword(
      email: 'testuser@example.com',
      password: 'password123',
    );

    // Check if the user is authenticated
    expect(response.user, isNotNull, reason: 'User should be authenticated');
    expect(response.session, isNotNull, reason: 'Session should not be null');
    expect(response.user?.email, equals('testuser@example.com'), reason: 'Email should match the test user');
  });

  testWidgets('database integration test - fetch data', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Fetch data from a test table
    final response = await supabase.from('test_table').select();

    // Check if data was fetched successfully
    expect(response, isNotNull, reason: 'Response should not be null');
    expect(response, isNotEmpty, reason: 'Data should not be empty');
  });

  testWidgets('database integration test - insert data', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Insert data into a test table
    final response = await supabase.from('test_table').insert({
      'column1': 'value1',
      'column2': 'value2',
    }).select();

    // Check if data was inserted successfully
    expect(response, isNotNull, reason: 'Inserted data should not be null');
    expect(response[0]['column1'], equals('value1'), reason: 'Inserted column1 value should match');
    expect(response[0]['column2'], equals('value2'), reason: 'Inserted column2 value should match');
  });
}

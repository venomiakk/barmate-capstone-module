import 'package:flutter/material.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedTitle;

  final userPreferences = UserPreferences();

  @override
  void initState() {
    super.initState();
    _loadUserTitle();
  }

  void _loadUserTitle() async {
    final title = await userPreferences.getUserTitle();
    setState(() {
      selectedTitle = title ?? 'Mixologist';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select User Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTitle,
              hint: const Text('Choose a title'),
              items: const [
                DropdownMenuItem(value: 'Mixologist', child: Text('Mixologist')),
                DropdownMenuItem(value: 'Bartender', child: Text('Bartender')),
                DropdownMenuItem(value: 'Cocktail Lover', child: Text('Cocktail Lover')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTitle = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedTitle != null) {
                  userPreferences.setUserTitle(selectedTitle!);
                  Navigator.pop(context, selectedTitle);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

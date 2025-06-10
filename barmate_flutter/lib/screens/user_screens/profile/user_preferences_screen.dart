import 'package:barmate/model/tag_model.dart';
import 'package:barmate/repositories/tag_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  var logger = Logger(printer: PrettyPrinter());
  final TagRepository tagRepository = TagRepository();
  // Preferencje użytkownika
  Set<TagModel> selectedDrinkTypes = <TagModel>{};

  // Opcje do wyboru
  final List<TagModel> drinkTypes = [];

  @override
  void initState() {
    super.initState();
    _loadTags(); // To już będzie wywoływać _loadPreferences() wewnętrznie
  }

  Future<void> _loadTags() async {
    try {
      final tags = await tagRepository.getEveryTag();
      // logger.i("Loaded ${tags.length} tags from repository");

      if (tags.isNotEmpty) {
        // logger.i("First tag: ${tags[0].id} - ${tags[0].name}");
        setState(() {
          drinkTypes.addAll(tags);
        });

        // Załaduj preferencje AFTER załadowania tagów
        await _loadPreferences();
      }
    } catch (e) {
      logger.e("Error loading tags: $e");
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Załaduj ID wybranych tagów jako stringi
      final savedTagIds = prefs.getStringList('drink_tag_ids') ?? [];
      logger.i("Loaded saved tag IDs: $savedTagIds");

      setState(() {
        // Znajdź TagModel obiekty na podstawie zapisanych ID
        selectedDrinkTypes =
            drinkTypes
                .where((tag) => savedTagIds.contains(tag.id.toString()))
                .toSet();
      });

      // logger.i("Loaded ${selectedDrinkTypes.length} selected tags");
    } catch (e) {
      logger.e("Error loading preferences: $e");
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Zapisz tylko ID wybranych tagów jako stringi
      final tagIds =
          selectedDrinkTypes.map((tag) => tag.id.toString()).toList();

      await prefs.setStringList('drink_tag_ids', tagIds);

      logger.i("Preferences saved successfully. Saved tags: $tagIds");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e("Error saving preferences: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preferences'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPreferenceSection({
    required String title,
    required IconData icon,
    required List<TagModel> options,
    required Set<TagModel> selectedOptions,
    required Function(TagModel, bool) onSelectionChanged,
    bool multiSelect = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  options.map((option) {
                    final isSelected = selectedOptions.contains(option);

                    return ChoiceChip(
                      label: Text(option.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        onSelectionChanged(option, selected);
                      },
                      selectedColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      // labelStyle: TextStyle(
                      //   color:
                      //       isSelected
                      //           ? Theme.of(
                      //             context,
                      //           ).colorScheme.onPrimaryContainer
                      //           : Theme.of(context).colorScheme.onSurface,
                      //   fontWeight:
                      //       isSelected ? FontWeight.w600 : FontWeight.normal,
                      // ),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      elevation: isSelected ? 2 : 0,
                      pressElevation: 4,
                    );
                  }).toList(),
            ),

            if (selectedOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Selected: ${selectedOptions.length} ${selectedOptions.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Preferences'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _savePreferences,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.tune,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize Your Experience',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your preferences to get personalized drink recommendations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Drink Types
          _buildPreferenceSection(
            title: 'Favorite Drink Types',
            icon: Icons.local_bar,
            options: drinkTypes,
            selectedOptions: selectedDrinkTypes,
            onSelectionChanged: (option, selected) {
              setState(() {
                if (selected) {
                  selectedDrinkTypes.add(option);
                } else {
                  selectedDrinkTypes.remove(option);
                }
              });
            },
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savePreferences,
              icon: const Icon(Icons.save),
              label: const Text('Save Preferences'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

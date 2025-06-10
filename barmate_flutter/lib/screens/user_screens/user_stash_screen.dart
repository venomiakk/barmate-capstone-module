import 'package:barmate/Utils/groq_service.dart';
import 'package:barmate/model/generated_recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:barmate/constants.dart' as constants;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barmate/screens/user_screens/generated_recipe_screen.dart';
import 'package:barmate/model/recipe_model.dart';

import 'package:provider/provider.dart';
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/model/notifications_model.dart';



class UserStashScreen extends StatefulWidget {
  const UserStashScreen({super.key});

  @override
  State<UserStashScreen> createState() => _UserStashScreenState();
}

class _UserStashScreenState extends State<UserStashScreen> {
  final UserStashRepository repository = UserStashRepository();
  final List<UserStash> stash = [];
  final Set<int> selectedIngredientIds = {};
  final Map<int, int> selectedAmounts = {};
  Map<String, List<UserStash>> groupedStash = {};
  bool isDeleteMode = false;
  bool isLoading = true;
  String? selectedCategory;
  String searchQuery = '';
  bool sortAscending = true;
  List<String> availableCategories = [];
  bool isSearchPanelVisible = false;
  final groqService = GroqService(

  apiKey: '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',
  endpoint: 'https://api.groq.com/openai/v1/chat/completions',
);


  @override
  void initState() {
    super.initState();
    _loadStash();
  }

  Future<void> _loadStash() async {
  setState(() => isLoading = true);

  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final fetchedStash = await repository.fetchUserStash(userId);

  setState(() {
    stash.clear();
    stash.addAll(fetchedStash);
    selectedIngredientIds.clear();
    selectedAmounts.clear();

    for (var item in fetchedStash) {
      selectedAmounts[item.ingredientId] = item.amount;
    }

    groupedStash = {};
    for (var item in fetchedStash) {
      groupedStash.putIfAbsent(item.categoryName, () => []).add(item);
    }

    availableCategories = groupedStash.keys.toList()..sort();
    isDeleteMode = false;
    isLoading = false;
  });


    final lowQuantityItems = fetchedStash.where((item) {
    final amount = item.amount;
    final unit = item.unit.toLowerCase();

    if (unit.contains('ml') || unit.contains('g')) {
      return amount < 400;
    } else {
      return amount < 2;
    }
  }).toList();


  if (lowQuantityItems.isNotEmpty && context.mounted) {
    final notifier = Provider.of<NotificationService>(context, listen: false);

    for (final item in lowQuantityItems) {
    final amount = item.amount;
    final unit = item.unit;
    final name = item.ingredientName;

    final alreadyNotified = notifier.notifications.any(
      (n) => n.title == "Low on $name",
    );

    if (!alreadyNotified) {
      notifier.addNotification(
        AppNotification(
          title: "Low on $name",
          message: "Only $amount $unit left in your stash.",
          timestamp: DateTime.now(),
        ),
      );
    }
  }


  }
}


  void _toggleSelection(int ingredientId) {
    setState(() {
      if (selectedIngredientIds.contains(ingredientId)) {
        selectedIngredientIds.remove(ingredientId);
      } else {
        selectedIngredientIds.add(ingredientId);
      }
    });
  }

  void _showSearchFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                SearchBar(
                  hintText: 'Search ingredient',
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  elevation: const WidgetStatePropertyAll(2),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category dropdown
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelText: 'Filter category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    value: selectedCategory,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All")),
                      ...availableCategories.map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          selectedCategory = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Clear"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Show Results"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteSelectedIngredients() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    for (final id in selectedIngredientIds) {
      await repository.removeFromStash(userId, id);
    }
    _loadStash();
  }

  void _shareStash() {
    if (stash.isEmpty) return;
    final text = stash
        .map((e) => '${e.ingredientName} x${e.amount} (${e.categoryName})')
        .join('\n');
    Share.share('Mój stash w BarMate:\n\n$text');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stash'),
        actions: [
          IconButton(
            icon: Icon(isSearchPanelVisible ? Icons.close : Icons.search),
            tooltip: isSearchPanelVisible ? 'Close Filter' : 'Search / Filter',
            onPressed: () {
              setState(() {
                if (isSearchPanelVisible) {
                  // Resetujemy filtrowanie przy zamknięciu
                  searchQuery = '';
                  selectedCategory = null;
                }
                isSearchPanelVisible = !isSearchPanelVisible;
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share your stash',
            onPressed: _shareStash,
          ),
          IconButton(
            icon: Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: 'Sort by amount',
            onPressed: () {
              setState(() {
                sortAscending = !sortAscending;
              });
            },
          ),
          IconButton(
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete),
            onPressed: () {
              setState(() {
                isDeleteMode = !isDeleteMode;
                selectedIngredientIds.clear();
              });
            },
          ),
          if (isDeleteMode && selectedIngredientIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _deleteSelectedIngredients,
              tooltip: 'Remove selected ingredients',
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadStash,
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    if (isSearchPanelVisible) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            SearchBar(
                              hintText: 'Search ingredient',
                              leading: const Icon(Icons.search),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                              elevation: const WidgetStatePropertyAll(2),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(24),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.surface,
                                  labelText: 'Filter category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                value: selectedCategory,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text("All"),
                                  ),
                                  ...availableCategories.map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                    Expanded(child: _buildGroupedListView()),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.auto_awesome),
        label: const Text("AI Recipe"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () async {
          bool dialogShown = false;
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    content: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text("Generating recipe using your stash..."),
                        ),
                      ],
                    ),
                  ),
            );
            dialogShown = true;
            final ingredients = stash.map((e) => e.ingredientName).toList();
            final recipeJson = await groqService.generateRecipeFromIngredients(
              ingredients,
            );
            if (context.mounted && dialogShown) Navigator.pop(context);
            if (recipeJson != null) {
              final generatedRecipe = GeneratedRecipeModel.fromJson(recipeJson);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GeneratedRecipeScreen(
                          recipe: generatedRecipe,
                        ), // <-- przekaż GeneratedRecipeModel
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to generate recipe. Try again."),
                ),
              );
            }
          } catch (e) {
            if (context.mounted && dialogShown) Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
    );
  }

  Widget _buildGroupedListView() {
    final filteredGrouped = <String, List<UserStash>>{};

    groupedStash.forEach((category, items) {
      if (selectedCategory == null || selectedCategory == category) {
        final filtered =
            items
                .where(
                  (item) =>
                      item.ingredientName.toLowerCase().contains(searchQuery),
                )
                .toList();

        filtered.sort(
          (a, b) =>
              sortAscending
                  ? a.amount.compareTo(b.amount)
                  : b.amount.compareTo(a.amount),
        );

        if (filtered.isNotEmpty) {
          filteredGrouped[category] = filtered;
        }
      }
    });

    if (filteredGrouped.isEmpty) {
      return const Center(child: Text("No ingredients found"));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children:
          filteredGrouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(_iconForCategory(category)),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    final isSelected = selectedIngredientIds.contains(
                      entry.ingredientId,
                    );
                    return _buildIngredientCard(entry, isSelected);
                  },
                ),
              ],
            );
          }).toList(),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'alcohol':
        return Icons.local_bar;
      case 'fruit':
        return Icons.emoji_nature;
      case 'juice':
        return Icons.local_drink;
      case 'sweetener':
        return Icons.cookie;
      case 'herb':
        return Icons.spa;
      case 'vegetable':
        return Icons.grass;
      case 'coffee':
        return Icons.coffee;
      case 'cream':
        return Icons.icecream;
      case 'syrup':
        return Icons.water_drop;
      case 'spice':
        return Icons.whatshot;
      case 'mixer':
        return Icons.bubble_chart;
      default:
        return Icons.category;
    }
  }

  Widget _buildIngredientCard(UserStash entry, bool isSelected) {
    final index = stash.indexWhere((e) => e.ingredientId == entry.ingredientId);

    return GestureDetector(
      onTap: () {
        if (isDeleteMode) {
          _toggleSelection(entry.ingredientId);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => IngredientScreen(
                    ingredientId: entry.ingredientId,
                    isFromStash: true,
                  ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    entry.photoUrl.isNotEmpty
                        ? Image.network(
                          '${constants.picsBucketUrl}/${entry.photoUrl}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (ctx, error, _) => Image.asset(
                                'images/przyklad.png',
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset('images/przyklad.png', fit: BoxFit.cover),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.ingredientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final userId =
                                Supabase.instance.client.auth.currentUser?.id;
                            if (userId == null) return;

                            final current =
                                selectedAmounts[entry.ingredientId] ?? 0;
                            final updated = current - 1;

                            if (updated <= 0) {
                              await repository.removeFromStash(
                                userId,
                                entry.ingredientId,
                              );
                              setState(() {
                                  stash.removeAt(index);
                                  selectedAmounts.remove(entry.ingredientId);
                                });
                            } else {
                              await repository.changeIngredientAmount(
                                userId,
                                entry.ingredientId,
                                updated,
                                context: context,
                                ingredientName: entry.ingredientName,
                                unit: entry.unit,
                              );

                              setState(() {
                                selectedAmounts[entry.ingredientId] = updated;
                              });
                            }
                          },
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${selectedAmounts[entry.ingredientId] ?? 0} ${entry.unit}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                        GestureDetector(
                          onTap: () async {
                            final userId =
                                Supabase.instance.client.auth.currentUser?.id;
                            final current =
                                selectedAmounts[entry.ingredientId] ?? 0;
                            final updated = current + 1;
                            setState(() {
                              selectedAmounts[entry.ingredientId] = updated;
                            });
                            await repository.changeIngredientAmount(
                              userId!,
                              entry.ingredientId,
                              updated,
                            );
                          },
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isDeleteMode)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

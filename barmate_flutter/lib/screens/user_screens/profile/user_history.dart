import 'package:barmate/controllers/user_history_controller.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/user_history_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:barmate/constants.dart' as constants;

enum TimePeriod {
  week('Last Week'),
  month('Last Month'),
  threeMonths('Last 3 Months'),
  sixMonths('Last 6 Months'),
  allTime('All Time');

  const TimePeriod(this.label);
  final String label;
}

class DrinkHistoryItem {
  final int consumedCount;
  final DateTime lastConsumed;
  final Recipe recipeModel;

  DrinkHistoryItem({
    required this.consumedCount,
    required this.lastConsumed,
    required this.recipeModel,
  });
}

class UserHistoryScreen extends StatefulWidget {
  final String userUuid;
  const UserHistoryScreen({super.key, required this.userUuid});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  var logger = Logger(printer: PrettyPrinter());
  final UserHistoryController _historyController =
      UserHistoryController.create();
  final RecipeRepository _recipeRepository = RecipeRepository();

  TimePeriod selectedPeriod = TimePeriod.month;
  List<DrinkHistoryItem> historyItems = [];
  bool isLoading = true;
  int totalDrinksConsumed = 0;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  DateTime _getStartDateForPeriod(TimePeriod period) {
    final now = DateTime.now();

    switch (period) {
      case TimePeriod.week:
        return DateTime(now.year, now.month, now.day - 7);
      case TimePeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case TimePeriod.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case TimePeriod.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case TimePeriod.allTime:
        return DateTime(
          1970,
          1,
          1,
        ); // Bardzo wczesna data dla "wszystkich czasów"
    }
  }

  // Dodaj cache jako pole klasy
  final Map<int, Recipe> _recipeCache = {};

  Future<List<DrinkHistoryItem>> _processHistoryData(
    List<UserHistoryModel> historyData,
  ) async {
    // Mapa: recipe_id -> lista timestampów
    final Map<int, List<DateTime>> recipeTimestamps = {};
    final List<DateTime> deletedRecipeTimestamps =
        []; // Lista timestampów dla usuniętych przepisów

    // Grupuj timestampy według recipe_id
    for (final historyItem in historyData) {
      final recipeId = historyItem.id;
      final timestamp = historyItem.consumedAt;

      if (recipeId == null) {
        // Jeśli recipe_id jest null, dodaj do listy usuniętych
        deletedRecipeTimestamps.add(timestamp);
      } else {
        recipeTimestamps.putIfAbsent(recipeId, () => []).add(timestamp);
      }
    }

    // Lista wynikowych DrinkHistoryItem
    final List<DrinkHistoryItem> result = [];

    // Pobierz unikalne recipe_id, które nie są w cache
    final uniqueRecipeIds = recipeTimestamps.keys.toSet();
    final missingRecipeIds =
        uniqueRecipeIds.where((id) => !_recipeCache.containsKey(id)).toList();

    // Batch pobieranie przepisów
    if (missingRecipeIds.isNotEmpty) {
      try {
        for (final recipeId in missingRecipeIds) {
          try {
            final recipe = await _recipeRepository.getRecipeById(recipeId);
            _recipeCache[recipeId] = recipe;
          } catch (e) {
            logger.e("Error loading recipe $recipeId: $e");
          }
        }
      } catch (e) {
        logger.e("Error batch loading recipes: $e");
      }
    }

    // Przetwórz każde recipe_id
    for (final entry in recipeTimestamps.entries) {
      final recipeId = entry.key;
      final timestamps = entry.value;

      // Sprawdź czy mamy przepis w cache
      final recipe = _recipeCache[recipeId];
      if (recipe == null) {
        logger.w("Recipe $recipeId not found, skipping...");
        continue;
      }

      // Znajdź najnowszy timestamp
      timestamps.sort((a, b) => b.compareTo(a)); // Sortuj malejąco
      final lastConsumed = timestamps.first;

      // Zlicz wystąpienia
      final consumedCount = timestamps.length;

      // Stwórz DrinkHistoryItem
      final drinkHistoryItem = DrinkHistoryItem(
        consumedCount: consumedCount,
        lastConsumed: lastConsumed,
        recipeModel: recipe,
      );

      result.add(drinkHistoryItem);
    }

    // Dodaj kartę dla usuniętych przepisów, jeśli istnieją
    DrinkHistoryItem? deletedDrinkHistoryItem;
    if (deletedRecipeTimestamps.isNotEmpty) {
      deletedRecipeTimestamps.sort((a, b) => b.compareTo(a)); // Sortuj malejąco
      final lastDeletedConsumed = deletedRecipeTimestamps.first;
      final deletedCount = deletedRecipeTimestamps.length;

      // Stwórz placeholder Recipe dla usuniętych drinków
      final deletedRecipe = Recipe(
        id: -1, // Specjalne ID dla usuniętych
        name: "Deleted Recipe",
        description: "This recipe has been removed from the database",
        photoUrl: null,
        ingredients: [],
      );

      deletedDrinkHistoryItem = DrinkHistoryItem(
        consumedCount: deletedCount,
        lastConsumed: lastDeletedConsumed,
        recipeModel: deletedRecipe,
      );
    }

    // Sortuj tylko normalne wyniki według najnowszego spożycia (malejąco)
    result.sort((a, b) => b.lastConsumed.compareTo(a.lastConsumed));

    // Dodaj usuniętą kartę na końcu, jeśli istnieje
    if (deletedDrinkHistoryItem != null) {
      result.add(deletedDrinkHistoryItem);
    }

    return result;
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final startDate = _getStartDateForPeriod(selectedPeriod);
      final data = await _historyController.getUserHistory(
        widget.userUuid,
        startDate,
      );
      logger.d(
        "Loaded ${data.length} history items for user ${widget.userUuid}",
      );
      final processedHistoryItems = await _processHistoryData(data);

      if (mounted) {
        setState(() {
          historyItems = processedHistoryItems;
          totalDrinksConsumed = data.length;
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e("Error loading history data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load history data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadHistoryData();
  }

  void _onPeriodChanged(TimePeriod? newPeriod) {
    if (newPeriod != null && newPeriod != selectedPeriod) {
      setState(() {
        selectedPeriod = newPeriod;
      });
      _loadHistoryData();
    }
  }

  String _formatLastConsumed(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drink History'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Period selector and stats section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Period dropdown
                  Row(
                    children: [
                      const Text(
                        'Time period: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<TimePeriod>(
                          value: selectedPeriod,
                          onChanged: _onPeriodChanged,
                          items:
                              TimePeriod.values.map((period) {
                                return DropdownMenuItem(
                                  value: period,
                                  child: Text(period.label),
                                );
                              }).toList(),
                          isExpanded: true,
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Drinks',
                          totalDrinksConsumed.toString(),
                          Icons.local_bar,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Different Recipes',
                          historyItems.length.toString(),
                          Icons.restaurant_menu,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // History list
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : historyItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: historyItems.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(historyItems[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DrinkHistoryItem item) {
    final isDeletedRecipe = item.recipeModel.id == -1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: isDeletedRecipe ? Colors.red[100] : Colors.grey[200],
            child:
                isDeletedRecipe
                    ? Icon(
                      Icons.delete_forever,
                      color: Colors.red[400],
                      size: 30,
                    )
                    : item.recipeModel.photoUrl?.isNotEmpty == true
                    ? Image.network(
                      '${constants.picsBucketUrl}/${item.recipeModel.photoUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/unavailable-image.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Image.asset(
                      'images/unavailable-image.jpg',
                      fit: BoxFit.cover,
                    ),
          ),
        ),
        title: Text(
          item.recipeModel.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDeletedRecipe ? Colors.red[600] : null,
            fontStyle: isDeletedRecipe ? FontStyle.italic : null,
          ),
        ),
        subtitle: Text(
          'Last consumed: ${_formatLastConsumed(item.lastConsumed)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDeletedRecipe ? Colors.red[50] : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.consumedCount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDeletedRecipe
                          ? Colors.red[600]
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                item.consumedCount == 1 ? 'drink' : 'drinks',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isDeletedRecipe
                          ? Colors.red[600]
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          if (isDeletedRecipe) {
            // Pokaż dialog dla usuniętego przepisu
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Recipe Not Available'),
                    content: const Text(
                      'This recipe has been removed from the database and is no longer available.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          } else {
            // Normalna nawigacja do przepisu
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeScreen(recipe: item.recipeModel),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No drinks consumed yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your drinks to see your history here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

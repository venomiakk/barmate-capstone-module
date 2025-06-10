import 'dart:math';

import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/edit_profile_screen.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/favourite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/drink_card_widget.dart'; // Add this import
import 'package:barmate/screens/user_screens/profile/settings_screen.dart';
import 'package:barmate/screens/user_screens/profile/user_history.dart';
import 'package:barmate/screens/user_screens/profile/widgets/users_recipes_list.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var logger = Logger(printer: PrettyPrinter());
  final LoggedinUserProfileController _controller =
      LoggedinUserProfileController.create();
  final PublicUserProfileController _publicController =
      PublicUserProfileController.create();
  final RecipeRepository _recipeRepository = RecipeRepository();
  String? userTitle;
  String? userBio;
  String? userAvatarUrl;

  // Dodaj nowe zmienne stanu
  String userName = '';
  String userId = '';
  String? userTitleFromPrefs;
  List<FavouriteDrink> favouriteDrinks = [];
  bool _isLoading = true; // Dodaj tę zmienną

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPrefsData();
  }

  Future<void> _getRandomRecommendedRecipe() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Finding perfect recipe for you...'),
                    ],
                  ),
                ),
              ),
            ),
      );
      final userPreferredTagIds = await _loadUserPreferences();

      // Pobierz wszystkie przepisy
      final allRecipes = await _recipeRepository.getAllRecipes();

      if (allRecipes.isEmpty) {
        Navigator.of(context).pop(); // Zamknij loading dialog
        _showNoRecipesMessage();
        return;
      }

      Recipe selectedRecipe;

      if (userPreferredTagIds.isNotEmpty) {
        // Filtruj przepisy na podstawie preferencji
        final recommendedRecipes =
            allRecipes.where((recipe) {
              if (recipe.tags == null || recipe.tags!.isEmpty) return false;

              // Sprawdź czy przepis ma tagi pasujące do preferencji
              final recipeTagIds = recipe.tags!.map((tag) => tag.id).toSet();
              final hasMatchingTags = userPreferredTagIds.any(
                (prefId) => recipeTagIds.contains(prefId),
              );

              return hasMatchingTags;
            }).toList();

        if (recommendedRecipes.isNotEmpty) {
          // Wybierz losowy przepis z rekomendowanych
          final random = Random();
          selectedRecipe =
              recommendedRecipes[random.nextInt(recommendedRecipes.length)];
          logger.i("Selected recommended recipe: ${selectedRecipe.name}");
        } else {
          // Jeśli brak pasujących przepisów, wybierz losowy z wszystkich
          final random = Random();
          selectedRecipe = allRecipes[random.nextInt(allRecipes.length)];
          logger.i(
            "No matching recipes found, selected random: ${selectedRecipe.name}",
          );
        }
      } else {
        // Jeśli brak preferencji, wybierz całkowicie losowy przepis
        final random = Random();
        selectedRecipe = allRecipes[random.nextInt(allRecipes.length)];
        logger.i(
          "No preferences set, selected random recipe: ${selectedRecipe.name}",
        );
      }

      // Zamknij loading dialog
      Navigator.of(context).pop();

      // Nawiguj do przepisu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeScreen(recipe: selectedRecipe),
        ),
      );
    } catch (e) {
      // Zamknij loading dialog w przypadku błędu
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      logger.e("Error getting random recipe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load recipe. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Set<int>> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTagIds = prefs.getStringList('drink_tag_ids') ?? [];

      // Konwertuj string IDs na int IDs
      final intIds =
          savedTagIds
              .map((id) => int.tryParse(id))
              .where((id) => id != null)
              .cast<int>()
              .toSet();

      logger.i("Loaded user preferences: $intIds");
      return intIds;
    } catch (e) {
      logger.e("Error loading user preferences: $e");
      return <int>{};
    }
  }

  void _showNoRecipesMessage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('No Recipes Available'),
            content: const Text(
              'There are no recipes available at the moment. Please try again later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Dodaj tę metodę do ładowania danych z preferencji
  Future<void> _loadPrefsData() async {
    try {
      final prefs = await UserPreferences.getInstance();
      if (mounted) {
        // Sprawdź, czy widget jest zamontowany przed aktualizacją stanu
        setState(() {
          userName = prefs.getUserName();
          userId = prefs.getUserId();
          userTitleFromPrefs = prefs.getUserTitle();
        });
      }
      // logger.i("""
      //   Username: $userName,
      //   ID: $userId,
      //   Title: $userTitleFromPrefs
      // """);
    } catch (e) {
      logger.e("Error loading preferences: $e");
    }
  }

  Future<void> _loadData() async {
    // logger.d("_loadData");
    userTitle = await _controller.loadUserTitle();
    userBio = await _controller.getUserBio();
    userAvatarUrl = await _controller.loadUserAvatarUrl();
    favouriteDrinks = await _controller.loadUserFavouriteDrinks();
    if (mounted) {
      setState(() {
        _isLoading = false; // Zakończ ładowanie
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(
              userTitle: userTitle,
              userBio: userBio,
              userImageUrl: userAvatarUrl,
            ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (mounted) {
        setState(() {
          userTitle = result['title'];
          userBio = result['bio'];
        });
        // Sprawdź, czy widget jest zamontowany przed aktualizacją stanu
      }

      // Odśwież wszystkie dane po powrocie z ekranu ustawień
      await _loadData();
      await _loadPrefsData(); // Dodaj to, aby odświeżyć również dane z preferencji
    }
  }

  // Dodaj tę metodę do klasy _UserPageState
  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true; // Rozpocznij ładowanie przy odświeżaniu
      });
      await Future.wait([_loadData(), _loadPrefsData()]);
    } catch (e) {
      logger.e("Error refreshing profile data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Zakończ ładowanie nawet przy błędzie
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Sprawdź czy userId nie jest pusty przed nawigacją
              if (userId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserHistoryScreen(userUuid: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User data not loaded yet'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              logger.d("Share button pressed");
              // Share profile functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _controller.logoutConfiramtionTooltip(context);
              // Logout functionality
              // Needs to ask for confirmation
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warunkowo wyświetl loader lub UserProfileWidget
              _isLoading
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : UserProfileWidget(
                    username: userName,
                    userTitle: userTitle,
                    userBio: userBio,
                    userAvatarUrl: userAvatarUrl,
                    onSettingsTap: _navigateToEditProfile,
                  ),
              const SizedBox(height: 24),

              // Add a title for the section
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Favorite Drinks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Set a fixed height for the widget
              SizedBox(
                height: 170,
                child: FavouriteDrinksListWidget(
                  initialDrinks: favouriteDrinks,
                ),
              ),

              const SizedBox(height: 24),
              if (!_isLoading) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Your Recipes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: UsersRecipesList(userId: userId, isCurrentUser: true),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getRandomRecommendedRecipe,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.casino_rounded),
        label: const Text('Surprise Me!'),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

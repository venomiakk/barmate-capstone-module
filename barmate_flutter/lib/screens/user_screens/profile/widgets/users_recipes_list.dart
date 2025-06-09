import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/screens/user_screens/add_recipe.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:barmate/screens/user_screens/profile/widgets/users_recipe_card.dart';
import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';

class UsersRecipesList extends StatefulWidget {
  final String userId;
  final bool isCurrentUser; // Czy to profil aktualnie zalogowanego użytkownika

  const UsersRecipesList({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  UsersRecipesListState createState() => UsersRecipesListState();
}

class UsersRecipesListState extends State<UsersRecipesList> {
  var logger = Logger(printer: PrettyPrinter());
  final PublicUserProfileController _publicController =
      PublicUserProfileController.create();
  final LoggedinUserProfileController _loggedInController =
      LoggedinUserProfileController.create();

  final RecipeRepository _recipeRepository = RecipeRepository();

  List<UserRecipe> userRecipes = [];
  bool isLoading = true;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadUserRecipes();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = await UserPreferences.getInstance();
      currentUserId = prefs.getUserId();
    } catch (e) {
      logger.e("Error loading current user ID: $e");
    }
  }

  Future<void> _loadUserRecipes() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Załaduj przepisy użytkownika
      final recipes = await _publicController.getUsersRecipes(widget.userId);

      // Konwertuj na UserRecipe objects
      final convertedRecipes =
          recipes
              .map(
                (recipe) => UserRecipe(
                  id: recipe.id,
                  recipeId: recipe.id,
                  name: recipe.name,
                  imageUrl: recipe.photoUrl ?? '',
                  description: recipe.description,
                ),
              )
              .toList();

      if (mounted) {
        setState(() {
          userRecipes = convertedRecipes;
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e("Error loading user recipes: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> removeRecipe(int recipeId, String imageUrl) async {
    // Pokaż dialog potwierdzenia
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Recipe'),
            content: const Text(
              'Are you sure you want to delete this recipe? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _recipeRepository.deleteRecipe(recipeId, imageUrl);
        setState(() {
          userRecipes.removeWhere((recipe) => recipe.recipeId == recipeId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logger.e("Error removing recipe: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete recipe'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> viewRecipeDetails(UserRecipe recipe) async {
    try {
      // Załaduj pełne szczegóły przepisu
      final fullRecipe = await _loggedInController.getRecipeById(
        recipe.recipeId,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(recipe: fullRecipe),
          ),
        );
      }
    } catch (e) {
      logger.e("Error loading recipe details: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load recipe details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_bar, size: 36, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              widget.isCurrentUser
                  ? 'No recipes created yet'
                  : 'No recipes shared yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (widget.isCurrentUser) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to create recipe screen
                  logger.d("Navigate to create recipe screen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRecipeScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Recipe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      scrollDirection: Axis.horizontal,
      itemCount: userRecipes.length,
      itemBuilder: (context, index) {
        final recipe = userRecipes[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 120,
            height: 150,
            child: UserRecipeCard(
              recipe: recipe,
              showRemoveButton:
                  widget.isCurrentUser, // Pokaż X tylko dla własnych przepisów
              onRemove:
                  widget.isCurrentUser
                      ? () => removeRecipe(recipe.recipeId, recipe.imageUrl)
                      : null,
              onTap: () => viewRecipeDetails(recipe),
            ),
          ),
        );
      },
    );
  }
}

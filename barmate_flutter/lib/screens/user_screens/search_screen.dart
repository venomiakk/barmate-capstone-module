import 'package:barmate/model/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:string_similarity/string_similarity.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final IngredientRepository ingredientRepository = IngredientRepository();
  final UserStashRepository userStashRepository = UserStashRepository();
  final RecipeRepository recipeRepository = RecipeRepository();

  final List<Ingredient> ingredients = [];
  final List<Recipe> recipes = [];
  final List<Ingredient> filteredIngredients = [];
  final List<Recipe> filteredRecipes = [];
  final List<dynamic > filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _loadRecipes();
  }

  Future<void> _loadIngredients() async {
    final List<Ingredient> fetchedIngredients =
        await ingredientRepository.fetchAllIngredients();
    setState(() {
      ingredients.addAll(fetchedIngredients);
    });
  }

  Future<void> _loadRecipes() async {
    final List<Recipe> fetchedRecipes = await recipeRepository.getAllRecipes();
    setState(() {
      recipes.addAll(fetchedRecipes);
    });
  }

  Future<void> _addToStash(int ingredientId, int quantity) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await userStashRepository.addToStash(userId, ingredientId, quantity);
    }
  }

void _filterIngredients(String query) {
  setState(() {
    filteredItems.clear();
    filteredIngredients.clear();
    filteredRecipes.clear();

    if (query.isEmpty) {
      return;
    }

    final lowerQuery = query.toLowerCase();

    final ingredientMatches = ingredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(lowerQuery))
        .map((ingredient) {
          final similarity = StringSimilarity.compareTwoStrings(
            ingredient.name.toLowerCase(),
            lowerQuery,
          );
          return {'item': ingredient, 'similarity': similarity};
        })
        .toList();

    final recipeMatches = recipes
        .where((recipe) => recipe.name.toLowerCase().contains(lowerQuery))
        .map((recipe) {
          final similarity = StringSimilarity.compareTwoStrings(
            recipe.name.toLowerCase(),
            lowerQuery,
          );
          return {'item': recipe, 'similarity': similarity};
        })
        .toList();

    ingredientMatches.sort((a, b) =>
        (b['similarity'] as double).compareTo(a['similarity'] as double));
    recipeMatches.sort((a, b) =>
        (b['similarity'] as double).compareTo(a['similarity'] as double));

    filteredIngredients.addAll(
      ingredientMatches.map((e) => e['item'] as Ingredient),
    );
    filteredRecipes.addAll(
      recipeMatches.map((e) => e['item'] as Recipe),
    );

    filteredItems.addAll([
      ...filteredIngredients,
      ...filteredRecipes,
    ]);
  });
}


  Future<void> _showAddToDialog(
    Ingredient ingredient,
    String destination,
  ) async {
    int counter = 1;
    const int minValue = 1;
    const int maxValue = 99999;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 140,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildCounterRow(
                            counter,
                            minValue,
                            maxValue,
                            setState,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (destination == 'shopping list') {
                                // Add to shopping list logic
                              } else {
                                _addToStash(ingredient.id, counter);
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Add to ' + destination,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Row _buildCounterRow(
    int counter,
    int minValue,
    int maxValue,
    StateSetter setState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          iconSize: 32.0,
          onPressed: () {
            setState(() {
              if (counter > minValue) counter--;
            });
          },
        ),
        Text(
          '$counter',
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 32.0,
          onPressed: () {
            setState(() {
              if (counter < maxValue) counter++;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildSearchBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SearchBar(
        hintText: 'Search',
        onChanged: _filterIngredients,
        leading: const Icon(Icons.search),
        trailing: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: 400,
              width: 300,
              child: Center(
                child: Text(
                  'Ustawienia / informacje',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  GridView _buildGrid() {
    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.6,
      children: List.generate(filteredItems.length, (index) {
        return filteredItems[index] is Ingredient ? _buildIngredientCard(filteredItems[index]) : _buildRecipeCard(filteredItems[index]);
      }),
    );
  }

  Card _buildIngredientCard(Ingredient ingredient) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildCardImage(),
          const SizedBox(width: 16),
          _buildCardInfo(ingredient),
          const SizedBox(width: 8),
          _buildIngredientActions(ingredient),
        ],
      ),
    );
  }

  Stack _buildCardImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'images/przyklad.png',
            width: 104,
            height: 104,
            fit: BoxFit.cover,
          ),
        ),
        _buildImageGradientOverlay(),
      ],
    );
  }

  Positioned _buildImageGradientOverlay() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 40,
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.25),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Expanded _buildCardInfo(dynamic data) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.name.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            data.description,
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Column _buildIngredientActions(Ingredient ingredient) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.add, size: 30),
          onPressed: () => _showAddToDialog(ingredient, 'stash'),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: 26),
          onPressed: () => _showAddToDialog(ingredient, 'shopping list'),
        ),
      ],
    );
  }

  Card _buildRecipeCard(Recipe recipe) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildCardImage(),
          const SizedBox(width: 16),
          _buildCardInfo(recipe),
          const SizedBox(width: 8),
          _buildRecipeActions(recipe),
        ],
      ),
    );
  }

  Column _buildRecipeActions(Recipe recipe) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.local_bar, size: 30),
          onPressed: () => (),
        ),
      ],
    );
  }
}

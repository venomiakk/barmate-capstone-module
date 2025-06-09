import 'package:barmate/constants.dart' as constatns;
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/screens/collection_screen.dart';
import 'package:barmate/screens/user_screens/add_recipe.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Collection>> _collectionsList;
  late Future<List<Recipe>> _popularRecipesFuture;
  final RecipeRepository recipeRepository = RecipeRepository();
  final CollectionRepository collectionRepository = CollectionRepository();

  String? selectedTag; // State to track the selected tag

  @override
  void initState() {
    super.initState();
    _collectionsList = collectionRepository.getCollections();
    _popularRecipesFuture = recipeRepository.getPopularRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30),
              collectionListWidget<Collection>(
                title: 'Featured Collections',
                future: _collectionsList,
                getName: (collection) => collection.name,
                getPhotoUrl: (collection) => collection.photoUrl ?? '',
              ),
              const SizedBox(height: 30),
              popularRecipes(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the floating action button
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget recipeCard(Recipe recipe, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty)
                      ? Image.network(
                        '${constatns.picsBucketUrl}/${recipe.photoUrl!}',
                        height: 230,
                        width: 140,
                        fit: BoxFit.cover,
                      )
                      : Image.asset(
                        'images/default_recipe_image.jpg',
                        height: 230,
                        width: 140,
                        fit: BoxFit.cover,
                      ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget collectionListWidget<T>({
    required String title,
    required Future<List<T>> future,
    required String Function(T) getName,
    String? Function(T)? getPhotoUrl,
    Recipe? Function(T)? getRecipe,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No $title available.');
        } else {
          final items = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final photoUrl =
                        getPhotoUrl != null ? getPhotoUrl(item) : null;
                    final name = getName(item);
                    return GestureDetector(
                      onTap: () {
                        if (item is Collection) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      CollectionScreen(collection: item),
                            ),
                          );
                        }
                        // Możesz dodać inne typy jeśli chcesz obsłużyć inne przypadki
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child:
                                  (photoUrl != null && photoUrl.isNotEmpty)
                                      ? Image.network(
                                        '${constatns.picsBucketUrl}/$photoUrl',
                                        height: 200,
                                        width: 140,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        'images/default_recipe_image.jpg',
                                        height: 200,
                                        width: 140,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget popularRecipes() {
    return FutureBuilder<List<Recipe>>(
      future: _popularRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No popular recipes available.');
        } else {
          final recipes = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Popular Recipes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return recipeCard(recipe, context);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
